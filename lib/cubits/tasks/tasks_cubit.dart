import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../models/task.dart';

part 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  StreamSubscription? _tasksSubscription;

  TasksCubit() : super(const TasksState()) {
    _initializeTasksListener();
  }

  void _initializeTasksListener() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _listenToTasks(user.uid);
      } else {
        _tasksSubscription?.cancel();
        emit(const TasksState());
      }
    });
  }

  void _listenToTasks(String userId) {
    _tasksSubscription?.cancel();
    _tasksSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          final tasks = snapshot.docs.map((doc) {
            return Task.fromJson({...doc.data(), 'id': doc.id});
          }).toList();
          emit(state.copyWith(tasks: tasks));
        });
  }

  Future<void> addTask(
    String text, {
    TaskPriority priority = TaskPriority.medium,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final task = Task(
        id: '',
        text: text,
        createdAt: DateTime.now(),
        priority: priority,
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .add(task.toJson());
    } catch (e) {
      // Handle error - could emit error state if needed
      print('Error adding task: $e');
    }
  }

  Future<void> toggleTask(String taskId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final task = state.tasks.firstWhere((t) => t.id == taskId);
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .doc(taskId)
          .update({'completed': !task.completed});
    } catch (e) {
      print('Error toggling task: $e');
    }
  }

  Future<void> updateTaskPriority(String taskId, TaskPriority priority) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .doc(taskId)
          .update({'priority': priority.name});
    } catch (e) {
      print('Error updating task priority: $e');
    }
  }

  Future<void> deleteTask(String taskId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .doc(taskId)
          .delete();
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}
