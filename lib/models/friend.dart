import 'package:equatable/equatable.dart';

class Friend extends Equatable {
  final String id;
  final String username;
  final String email;
  final String avatarLetter;

  const Friend({
    required this.id,
    required this.username,
    required this.email,
    required this.avatarLetter,
  });

  Friend copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarLetter,
  }) {
    return Friend(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarLetter: avatarLetter ?? this.avatarLetter,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatarLetter': avatarLetter,
    };
  }

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      avatarLetter: json['avatarLetter'] as String,
    );
  }

  @override
  List<Object?> get props => [id, username, email, avatarLetter];
}
