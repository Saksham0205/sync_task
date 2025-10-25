import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/group.dart';

part 'groups_state.dart';

class GroupsCubit extends HydratedCubit<GroupsState> {
  GroupsCubit() : super(const GroupsState());

  void addGroup(String name) {
    final group = TaskGroup(
      id: 'group_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      memberCount: 1,
      completedTasks: 0,
      totalTasks: 0,
    );
    emit(state.copyWith(groups: [...state.groups, group]));
  }

  void addTaskToGroup(String groupId, String taskText) {
    final updatedGroups = state.groups.map((group) {
      if (group.id == groupId) {
        final newTask = GroupTask(
          id: 'gtask_${DateTime.now().millisecondsSinceEpoch}',
          text: taskText,
          createdBy: 'You',
          completedBy: {'You': false, 'Mom': false, 'Dad': false},
          priority: 'Medium',
          createdAt: DateTime.now(),
        );
        return group.copyWith(
          tasks: [...group.tasks, newTask],
          totalTasks: group.totalTasks + 1,
        );
      }
      return group;
    }).toList();
    emit(state.copyWith(groups: updatedGroups));
  }

  void toggleTaskCompletion(String groupId, String taskId, String member) {
    final updatedGroups = state.groups.map((group) {
      if (group.id == groupId) {
        final updatedTasks = group.tasks.map((task) {
          if (task.id == taskId) {
            final newCompletedBy = Map<String, bool>.from(task.completedBy);
            newCompletedBy[member] = !(newCompletedBy[member] ?? false);
            return task.copyWith(completedBy: newCompletedBy);
          }
          return task;
        }).toList();

        // Recalculate completed tasks
        final completedCount = updatedTasks
            .where((task) => task.completedBy.values.every((v) => v))
            .length;

        return group.copyWith(
          tasks: updatedTasks,
          completedTasks: completedCount,
        );
      }
      return group;
    }).toList();
    emit(state.copyWith(groups: updatedGroups));
  }

  void loadSampleData() {
    if (state.groups.isEmpty) {
      final sampleGroups = [
        TaskGroup(
          id: 'group_1',
          name: 'Family Tasks',
          memberCount: 3,
          completedTasks: 2,
          totalTasks: 5,
          tasks: [
            GroupTask(
              id: 'gtask_1',
              text: 'Clean the house',
              createdBy: 'You',
              completedBy: {'You': true, 'Mom': true, 'Dad': false},
              priority: 'High',
              createdAt: DateTime.now(),
            ),
            GroupTask(
              id: 'gtask_2',
              text: 'Buy groceries for dinner',
              createdBy: 'Mom',
              completedBy: {'You': false, 'Mom': true, 'Dad': false},
              priority: 'Medium',
              createdAt: DateTime.now(),
            ),
            GroupTask(
              id: 'gtask_3',
              text: 'Plan weekend trip',
              createdBy: 'Dad',
              completedBy: {'You': false, 'Mom': false, 'Dad': false},
              priority: 'Low',
              createdAt: DateTime.now(),
            ),
          ],
        ),
        TaskGroup(
          id: 'group_2',
          name: 'Work Project',
          memberCount: 4,
          completedTasks: 6,
          totalTasks: 8,
        ),
        TaskGroup(
          id: 'group_3',
          name: 'Study Group',
          memberCount: 2,
          completedTasks: 1,
          totalTasks: 3,
        ),
      ];
      emit(state.copyWith(groups: sampleGroups));
    }
  }

  TaskGroup? getGroupById(String groupId) {
    try {
      return state.groups.firstWhere((group) => group.id == groupId);
    } catch (_) {
      return null;
    }
  }

  @override
  GroupsState? fromJson(Map<String, dynamic> json) {
    try {
      final groups = (json['groups'] as List<dynamic>)
          .map((group) => TaskGroup.fromJson(group as Map<String, dynamic>))
          .toList();
      return GroupsState(groups: groups);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(GroupsState state) {
    return {'groups': state.groups.map((group) => group.toJson()).toList()};
  }
}
