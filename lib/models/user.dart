import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username;
  final String email;
  final String avatarLetter;
  final DateTime memberSince;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.avatarLetter,
    required this.memberSince,
  });

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarLetter,
    DateTime? memberSince,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarLetter: avatarLetter ?? this.avatarLetter,
      memberSince: memberSince ?? this.memberSince,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatarLetter': avatarLetter,
      'memberSince': memberSince.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      avatarLetter: json['avatarLetter'] as String,
      memberSince: DateTime.parse(json['memberSince'] as String),
    );
  }

  @override
  List<Object?> get props => [id, username, email, avatarLetter, memberSince];
}
