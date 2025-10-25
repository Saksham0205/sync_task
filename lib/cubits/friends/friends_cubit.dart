import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../models/friend.dart';

part 'friends_state.dart';

class FriendsCubit extends Cubit<FriendsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  StreamSubscription? _friendsSubscription;

  FriendsCubit() : super(const FriendsState()) {
    _initializeFriendsListener();
  }

  void _initializeFriendsListener() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _listenToFriends(user.uid);
      } else {
        _friendsSubscription?.cancel();
        emit(const FriendsState());
      }
    });
  }

  void _listenToFriends(String userId) {
    _friendsSubscription?.cancel();
    _friendsSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .snapshots()
        .listen((snapshot) async {
      // Get friend details from users collection
      final friendIds = snapshot.docs.map((doc) => doc.id).toList();
      
      if (friendIds.isEmpty) {
        emit(const FriendsState());
        return;
      }

      // Fetch friend details
      final friendDocs = await Future.wait(
        friendIds.map((id) => _firestore.collection('users').doc(id).get()),
      );

      final friends = friendDocs
          .where((doc) => doc.exists)
          .map((doc) => Friend.fromJson({...doc.data()!, 'id': doc.id}))
          .toList();

      emit(state.copyWith(friends: friends));
    });
  }

  Future<void> addFriendByEmail(String email) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Find user by email
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        print('User not found with email: $email');
        return;
      }

      final friendDoc = userQuery.docs.first;
      final friendId = friendDoc.id;

      // Don't add yourself as a friend
      if (friendId == user.uid) {
        print('Cannot add yourself as a friend');
        return;
      }

      // Add friend to current user's friends
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('friends')
          .doc(friendId)
          .set({'addedAt': FieldValue.serverTimestamp()});

      // Add current user to friend's friends (mutual friendship)
      await _firestore
          .collection('users')
          .doc(friendId)
          .collection('friends')
          .doc(user.uid)
          .set({'addedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      print('Error adding friend: $e');
    }
  }

  Future<void> addFriend(Friend friend) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('friends')
          .doc(friend.id)
          .set({'addedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      print('Error adding friend: $e');
    }
  }

  Future<void> removeFriend(String friendId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Remove from current user's friends
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('friends')
          .doc(friendId)
          .delete();

      // Remove current user from friend's friends
      await _firestore
          .collection('users')
          .doc(friendId)
          .collection('friends')
          .doc(user.uid)
          .delete();
    } catch (e) {
      print('Error removing friend: $e');
    }
  }

  @override
  Future<void> close() {
    _friendsSubscription?.cancel();
    return super.close();
  }
}
