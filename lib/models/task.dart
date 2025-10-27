import 'package:equatable/equatable.dart';

enum TaskPriority {
  low,
  medium,
  high,
  critical;

  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.critical:
        return 'Critical';
    }
  }
}

class Task extends Equatable {
  final String id;
  final String text;
  final bool completed;
  final DateTime createdAt;
  final TaskPriority priority;
  final DateTime? deadline;

  const Task({
    required this.id,
    required this.text,
    this.completed = false,
    required this.createdAt,
    this.priority = TaskPriority.medium,
    this.deadline,
  });

  Task copyWith({
    String? id,
    String? text,
    bool? completed,
    DateTime? createdAt,
    TaskPriority? priority,
    DateTime? deadline,
  }) {
    return Task(
      id: id ?? this.id,
      text: text ?? this.text,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      priority: priority ?? this.priority,
      deadline: deadline ?? this.deadline,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'completed': completed,
      'createdAt': createdAt.toIso8601String(),
      'priority': priority.name,
      'deadline': deadline?.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      text: json['text'] as String,
      completed: json['completed'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      priority: TaskPriority.values.firstWhere(
        (p) => p.name == (json['priority'] as String?),
        orElse: () => TaskPriority.medium,
      ),
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    text,
    completed,
    createdAt,
    priority,
    deadline,
  ];
}
