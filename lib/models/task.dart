import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final String id;
  final String text;
  final bool completed;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.text,
    this.completed = false,
    required this.createdAt,
  });

  Task copyWith({
    String? id,
    String? text,
    bool? completed,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      text: text ?? this.text,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'completed': completed,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      text: json['text'] as String,
      completed: json['completed'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [id, text, completed, createdAt];
}
