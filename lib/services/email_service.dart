import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for sending emails via Firebase Cloud Functions
/// Emails are sent from ajnabeecorp@gmail.com
class EmailService {
  static final EmailService _instance = EmailService._internal();
  factory EmailService() => _instance;
  EmailService._internal();

  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Send group invitation email to a user
  Future<bool> sendGroupInvitationEmail({
    required String inviteeUserId,
    required String inviterUsername,
    required String groupName,
  }) async {
    try {
      // Get invitee's email
      final inviteeDoc = await _firestore
          .collection('users')
          .doc(inviteeUserId)
          .get();
      if (!inviteeDoc.exists) {
        print('Invitee user not found');
        return false;
      }

      final inviteeData = inviteeDoc.data()!;
      final inviteeEmail = inviteeData['email'] as String?;
      final inviteeUsername = inviteeData['username'] as String?;

      if (inviteeEmail == null || inviteeUsername == null) {
        print('Invitee email or username not found');
        return false;
      }

      final callable = _functions.httpsCallable('sendGroupInvitationEmail');
      final result = await callable.call({
        'inviteeEmail': inviteeEmail,
        'inviteeUsername': inviteeUsername,
        'inviterUsername': inviterUsername,
        'groupName': groupName,
      });

      print('Group invitation email sent: ${result.data}');
      return result.data['success'] == true;
    } catch (e) {
      print('Error sending group invitation email: $e');
      return false;
    }
  }

  /// Send task deadline reminder email
  Future<bool> sendTaskDeadlineReminderEmail({
    required String userEmail,
    required String username,
    required String taskText,
    required DateTime deadline,
    String? groupName,
  }) async {
    try {
      final callable = _functions.httpsCallable(
        'sendTaskDeadlineReminderEmail',
      );
      final result = await callable.call({
        'userEmail': userEmail,
        'username': username,
        'taskText': taskText,
        'deadline': deadline.toIso8601String(),
        'groupName': groupName,
      });

      print('Task deadline reminder email sent: ${result.data}');
      return result.data['success'] == true;
    } catch (e) {
      print('Error sending task deadline reminder email: $e');
      return false;
    }
  }

  /// Get current user's email
  Future<String?> getCurrentUserEmail() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists) return null;

    return userDoc.data()?['email'] as String?;
  }

  /// Get current user's username
  Future<String?> getCurrentUsername() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists) return null;

    return userDoc.data()?['username'] as String?;
  }
}
