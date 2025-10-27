import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../models/group.dart';
import '../../models/task.dart';
import '../../services/notification_service.dart';

part 'groups_state.dart';

class GroupsCubit extends Cubit<GroupsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();
  StreamSubscription? _groupsSubscription;
  final Map<String, StreamSubscription> _tasksSubscriptions = {};

  GroupsCubit() : super(const GroupsState()) {
    _initializeGroupsListener();
  }

  void _initializeGroupsListener() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _listenToGroups(user.uid);
      } else {
        _groupsSubscription?.cancel();
        for (var sub in _tasksSubscriptions.values) {
          sub.cancel();
        }
        _tasksSubscriptions.clear();
        emit(const GroupsState());
      }
    });
  }

  void _listenToGroups(String userId) {
    _groupsSubscription?.cancel();
    _groupsSubscription = _firestore
        .collection('groups')
        .where('members', arrayContains: userId)
        .snapshots()
        .listen((snapshot) {
          final groups = snapshot.docs.map((doc) {
            return TaskGroup.fromJson({...doc.data(), 'id': doc.id});
          }).toList();

          // Listen to tasks for each group
          for (var group in groups) {
            _listenToGroupTasks(group.id);
          }

          emit(state.copyWith(groups: groups));
        });
  }

  void _listenToGroupTasks(String groupId) {
    _tasksSubscriptions[groupId]?.cancel();
    _tasksSubscriptions[groupId] = _firestore
        .collection('groups')
        .doc(groupId)
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          final tasks = snapshot.docs.map((doc) {
            return GroupTask.fromJson({...doc.data(), 'id': doc.id});
          }).toList();

          // Update the specific group's tasks
          final updatedGroups = state.groups.map((group) {
            if (group.id == groupId) {
              final completedCount = tasks
                  .where((task) => task.completedBy.values.every((v) => v))
                  .length;
              return group.copyWith(
                tasks: tasks,
                totalTasks: tasks.length,
                completedTasks: completedCount,
              );
            }
            return group;
          }).toList();

          emit(state.copyWith(groups: updatedGroups));
        });
  }

  Future<void> addGroup(String name) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final groupData = {
        'name': name,
        'memberCount': 1,
        'completedTasks': 0,
        'totalTasks': 0,
        'members': [user.uid],
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('groups').add(groupData);
    } catch (e) {
      print('Error adding group: $e');
    }
  }

  Future<void> addTaskToGroup(
    String groupId,
    String taskText, {
    TaskPriority priority = TaskPriority.medium,
    DateTime? deadline,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Get current user's username
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final username = userDoc.data()?['username'] ?? 'You';

      final taskData = {
        'text': taskText,
        'createdBy': username,
        'completedBy': {username: false},
        'priority': priority.name,
        'createdAt': DateTime.now().toIso8601String(),
        'deadline': deadline?.toIso8601String(),
      };

      final docRef = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('tasks')
          .add(taskData);

      // Schedule notification if deadline is set
      if (deadline != null) {
        await _notificationService.scheduleTaskDeadlineNotification(
          taskId: docRef.id,
          taskText: taskText,
          deadline: deadline,
          priority: priority,
          isGroupTask: true,
          groupId: groupId,
        );
      }
    } catch (e) {
      print('Error adding task to group: $e');
    }
  }

  Future<void> updateTaskPriority(
    String groupId,
    String taskId,
    TaskPriority priority,
  ) async {
    try {
      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('tasks')
          .doc(taskId)
          .update({'priority': priority.name});
    } catch (e) {
      print('Error updating task priority: $e');
    }
  }

  Future<void> toggleTaskCompletion(
    String groupId,
    String taskId,
    String member,
  ) async {
    try {
      final taskRef = _firestore
          .collection('groups')
          .doc(groupId)
          .collection('tasks')
          .doc(taskId);

      final taskDoc = await taskRef.get();
      if (taskDoc.exists) {
        final completedBy = Map<String, bool>.from(
          taskDoc.data()?['completedBy'] ?? {},
        );

        // Clean up: If both "You" and actual username exist, merge them
        if (completedBy.containsKey('You') &&
            member != 'You' &&
            completedBy.containsKey(member)) {
          // Merge the completion status (use OR logic - if either is true, keep as true)
          completedBy[member] = completedBy[member]! || completedBy['You']!;
          completedBy.remove('You');
        }

        completedBy[member] = !(completedBy[member] ?? false);

        await taskRef.update({'completedBy': completedBy});
      }
    } catch (e) {
      print('Error toggling task completion: $e');
    }
  }

  Future<void> updateGroupTaskDeadline(
    String groupId,
    String taskId,
    DateTime? deadline,
  ) async {
    try {
      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('tasks')
          .doc(taskId)
          .update({'deadline': deadline?.toIso8601String()});

      // Cancel existing notification
      await _notificationService.cancelNotification(taskId, isGroupTask: true);

      // Schedule new notification if deadline is set
      if (deadline != null) {
        final group = getGroupById(groupId);
        if (group != null) {
          final task = group.tasks.firstWhere((t) => t.id == taskId);
          await _notificationService.scheduleTaskDeadlineNotification(
            taskId: taskId,
            taskText: task.text,
            deadline: deadline,
            priority: task.priority,
            isGroupTask: true,
            groupId: groupId,
          );
        }
      }
    } catch (e) {
      print('Error updating group task deadline: $e');
    }
  }

  Future<void> deleteGroupTask(String groupId, String taskId) async {
    try {
      // Cancel any scheduled notification
      await _notificationService.cancelNotification(taskId, isGroupTask: true);

      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('tasks')
          .doc(taskId)
          .delete();
    } catch (e) {
      print('Error deleting group task: $e');
    }
  }

  TaskGroup? getGroupById(String groupId) {
    try {
      return state.groups.firstWhere((group) => group.id == groupId);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      // Get all tasks in the group and cancel their notifications
      final group = getGroupById(groupId);
      if (group != null) {
        for (var task in group.tasks) {
          await _notificationService.cancelNotification(
            task.id,
            isGroupTask: true,
          );
        }
      }

      // Delete the group and all its tasks
      await _firestore.collection('groups').doc(groupId).delete();

      // Cancel the tasks subscription for this group
      _tasksSubscriptions[groupId]?.cancel();
      _tasksSubscriptions.remove(groupId);
    } catch (e) {
      print('Error deleting group: $e');
    }
  }

  /// Cleans up tasks that have both "You" and the actual username
  /// This is a one-time migration to fix the data inconsistency
  Future<void> cleanupTaskMemberships(String groupId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Get current user's username
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final username = userDoc.data()?['username'] ?? 'You';

      // Get all tasks for this group
      final tasksSnapshot = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('tasks')
          .get();

      // Update each task that has the issue
      final batch = _firestore.batch();
      for (var doc in tasksSnapshot.docs) {
        final completedBy = Map<String, bool>.from(
          doc.data()['completedBy'] ?? {},
        );

        // If both "You" and actual username exist, merge them
        if (completedBy.containsKey('You') && username != 'You') {
          final youStatus = completedBy['You']!;
          completedBy.remove('You');

          // If username doesn't exist, add it with the "You" status
          // If it exists, keep the existing status (preserving user's choice)
          if (!completedBy.containsKey(username)) {
            completedBy[username] = youStatus;
          }

          batch.update(doc.reference, {'completedBy': completedBy});
        }
      }

      await batch.commit();
    } catch (e) {
      print('Error cleaning up task memberships: $e');
    }
  }

  @override
  Future<void> close() {
    _groupsSubscription?.cancel();
    for (var sub in _tasksSubscriptions.values) {
      sub.cancel();
    }
    _tasksSubscriptions.clear();
    return super.close();
  }
}
