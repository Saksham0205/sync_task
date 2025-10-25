import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/task.dart';

part 'tasks_state.dart';

class TasksCubit extends HydratedCubit<TasksState> {
  TasksCubit() : super(const TasksState());

  void addTask(String text) {
    final task = Task(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      createdAt: DateTime.now(),
    );
    emit(state.copyWith(tasks: [...state.tasks, task]));
  }

  void toggleTask(String taskId) {
    final updatedTasks = state.tasks.map((task) {
      if (task.id == taskId) {
        return task.copyWith(completed: !task.completed);
      }
      return task;
    }).toList();
    emit(state.copyWith(tasks: updatedTasks));
  }

  void deleteTask(String taskId) {
    final updatedTasks = state.tasks
        .where((task) => task.id != taskId)
        .toList();
    emit(state.copyWith(tasks: updatedTasks));
  }

  void loadSampleData() {
    if (state.tasks.isEmpty) {
      final sampleTasks = [
        Task(
          id: 'task_1',
          text: 'Complete project proposal',
          createdAt: DateTime.now(),
        ),
        Task(
          id: 'task_2',
          text: 'Buy groceries',
          completed: true,
          createdAt: DateTime.now(),
        ),
        Task(id: 'task_3', text: 'Call mom', createdAt: DateTime.now()),
        Task(
          id: 'task_4',
          text: 'Schedule dentist appointment',
          createdAt: DateTime.now(),
        ),
      ];
      emit(state.copyWith(tasks: sampleTasks));
    }
  }

  @override
  TasksState? fromJson(Map<String, dynamic> json) {
    try {
      final tasks = (json['tasks'] as List<dynamic>)
          .map((task) => Task.fromJson(task as Map<String, dynamic>))
          .toList();
      return TasksState(tasks: tasks);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(TasksState state) {
    return {'tasks': state.tasks.map((task) => task.toJson()).toList()};
  }
}
