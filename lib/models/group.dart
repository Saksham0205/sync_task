import 'package:equatable/equatable.dart';

class TaskGroup extends Equatable {
  final String id;
  final String name;
  final int memberCount;
  final int completedTasks;
  final int totalTasks;
  final List<GroupTask> tasks;

  const TaskGroup({
    required this.id,
    required this.name,
    required this.memberCount,
    required this.completedTasks,
    required this.totalTasks,
    this.tasks = const [],
  });

  TaskGroup copyWith({
    String? id,
    String? name,
    int? memberCount,
    int? completedTasks,
    int? totalTasks,
    List<GroupTask>? tasks,
  }) {
    return TaskGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      memberCount: memberCount ?? this.memberCount,
      completedTasks: completedTasks ?? this.completedTasks,
      totalTasks: totalTasks ?? this.totalTasks,
      tasks: tasks ?? this.tasks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'memberCount': memberCount,
      'completedTasks': completedTasks,
      'totalTasks': totalTasks,
      'tasks': tasks.map((task) => task.toJson()).toList(),
    };
  }

  factory TaskGroup.fromJson(Map<String, dynamic> json) {
    return TaskGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      memberCount: json['memberCount'] as int,
      completedTasks: json['completedTasks'] as int,
      totalTasks: json['totalTasks'] as int,
      tasks:
          (json['tasks'] as List<dynamic>?)
              ?.map((task) => GroupTask.fromJson(task as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    memberCount,
    completedTasks,
    totalTasks,
    tasks,
  ];
}

class GroupTask extends Equatable {
  final String id;
  final String text;
  final String createdBy;
  final Map<String, bool> completedBy;
  final String priority;
  final DateTime createdAt;

  const GroupTask({
    required this.id,
    required this.text,
    required this.createdBy,
    required this.completedBy,
    required this.priority,
    required this.createdAt,
  });

  GroupTask copyWith({
    String? id,
    String? text,
    String? createdBy,
    Map<String, bool>? completedBy,
    String? priority,
    DateTime? createdAt,
  }) {
    return GroupTask(
      id: id ?? this.id,
      text: text ?? this.text,
      createdBy: createdBy ?? this.createdBy,
      completedBy: completedBy ?? this.completedBy,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'createdBy': createdBy,
      'completedBy': completedBy,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory GroupTask.fromJson(Map<String, dynamic> json) {
    return GroupTask(
      id: json['id'] as String,
      text: json['text'] as String,
      createdBy: json['createdBy'] as String,
      completedBy: Map<String, bool>.from(json['completedBy'] as Map),
      priority: json['priority'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
    id,
    text,
    createdBy,
    completedBy,
    priority,
    createdAt,
  ];
}
