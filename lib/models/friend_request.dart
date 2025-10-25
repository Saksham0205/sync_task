import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum FriendRequestStatus {
  pending,
  accepted,
  rejected,
}

class FriendRequest extends Equatable {
  final String id;
  final String senderId;
  final String senderUsername;
  final String senderEmail;
  final String senderAvatarLetter;
  final String receiverId;
  final FriendRequestStatus status;
  final DateTime createdAt;

  const FriendRequest({
    required this.id,
    required this.senderId,
    required this.senderUsername,
    required this.senderEmail,
    required this.senderAvatarLetter,
    required this.receiverId,
    required this.status,
    required this.createdAt,
  });

  FriendRequest copyWith({
    String? id,
    String? senderId,
    String? senderUsername,
    String? senderEmail,
    String? senderAvatarLetter,
    String? receiverId,
    FriendRequestStatus? status,
    DateTime? createdAt,
  }) {
    return FriendRequest(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderUsername: senderUsername ?? this.senderUsername,
      senderEmail: senderEmail ?? this.senderEmail,
      senderAvatarLetter: senderAvatarLetter ?? this.senderAvatarLetter,
      receiverId: receiverId ?? this.receiverId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderUsername': senderUsername,
      'senderEmail': senderEmail,
      'senderAvatarLetter': senderAvatarLetter,
      'receiverId': receiverId,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      senderUsername: json['senderUsername'] as String,
      senderEmail: json['senderEmail'] as String,
      senderAvatarLetter: json['senderAvatarLetter'] as String,
      receiverId: json['receiverId'] as String,
      status: FriendRequestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FriendRequestStatus.pending,
      ),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        senderId,
        senderUsername,
        senderEmail,
        senderAvatarLetter,
        receiverId,
        status,
        createdAt,
      ];
}

