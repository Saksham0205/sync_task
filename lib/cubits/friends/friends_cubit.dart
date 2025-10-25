import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../models/friend.dart';
import '../../models/friend_request.dart';

part 'friends_state.dart';

class FriendsCubit extends Cubit<FriendsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  StreamSubscription? _friendsSubscription;
  StreamSubscription? _sentRequestsSubscription;
  StreamSubscription? _receivedRequestsSubscription;

  FriendsCubit() : super(const FriendsState()) {
    _initializeListeners();
  }

  void _initializeListeners() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _listenToFriends(user.uid);
        _listenToSentRequests(user.uid);
        _listenToReceivedRequests(user.uid);
      } else {
        _friendsSubscription?.cancel();
        _sentRequestsSubscription?.cancel();
        _receivedRequestsSubscription?.cancel();
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

  void _listenToSentRequests(String userId) {
    _sentRequestsSubscription?.cancel();
    _sentRequestsSubscription = _firestore
        .collection('friendRequests')
        .where('senderId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
          final requests = snapshot.docs
              .map(
                (doc) => FriendRequest.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList();
          emit(state.copyWith(sentRequests: requests));
        });
  }

  void _listenToReceivedRequests(String userId) {
    _receivedRequestsSubscription?.cancel();
    _receivedRequestsSubscription = _firestore
        .collection('friendRequests')
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
          final requests = snapshot.docs
              .map(
                (doc) => FriendRequest.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList();
          emit(state.copyWith(receivedRequests: requests));
        });
  }

  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      emit(state.copyWith(searchResults: [], clearError: true));
      return;
    }

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      emit(state.copyWith(isSearching: true, clearError: true));

      // Search by email (exact match)
      final emailQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: query.toLowerCase().trim())
          .limit(5)
          .get();

      // Search by username (contains - case-insensitive)
      final usernameQuery = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThan: query + '\uf8ff')
          .limit(5)
          .get();

      // Combine and deduplicate results
      final allDocs = {...emailQuery.docs, ...usernameQuery.docs};

      // Get current friend IDs to filter them out
      final friendsSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('friends')
          .get();
      final friendIds = friendsSnapshot.docs.map((doc) => doc.id).toSet();

      // Get pending request IDs to filter them out
      final sentRequestsSnapshot = await _firestore
          .collection('friendRequests')
          .where('senderId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'pending')
          .get();
      final pendingRequestIds = sentRequestsSnapshot.docs
          .map((doc) => doc.data()['receiverId'] as String)
          .toSet();

      final results = allDocs
          .where((doc) => doc.id != user.uid) // Exclude self
          .where(
            (doc) => !friendIds.contains(doc.id),
          ) // Exclude existing friends
          .where(
            (doc) => !pendingRequestIds.contains(doc.id),
          ) // Exclude pending requests
          .map((doc) => Friend.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      emit(
        state.copyWith(
          searchResults: results,
          isSearching: false,
          errorMessage: results.isEmpty ? 'No users found' : null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSearching: false,
          errorMessage: 'Error searching users: $e',
        ),
      );
    }
  }

  Future<void> sendFriendRequest(String receiverId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Get current user data
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data()!;

      // Check if request already exists
      final existingRequest = await _firestore
          .collection('friendRequests')
          .where('senderId', isEqualTo: user.uid)
          .where('receiverId', isEqualTo: receiverId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existingRequest.docs.isNotEmpty) {
        emit(state.copyWith(errorMessage: 'Friend request already sent'));
        return;
      }

      // Create friend request
      await _firestore.collection('friendRequests').add({
        'senderId': user.uid,
        'senderUsername': userData['username'],
        'senderEmail': userData['email'],
        'senderAvatarLetter': userData['avatarLetter'],
        'receiverId': receiverId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Remove from search results
      final updatedResults = state.searchResults
          .where((friend) => friend.id != receiverId)
          .toList();

      emit(
        state.copyWith(
          searchResults: updatedResults,
          successMessage: 'Friend request sent!',
        ),
      );

      // Clear success message after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (!isClosed) {
          emit(state.copyWith(clearSuccess: true));
        }
      });
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error sending friend request: $e'));
    }
  }

  Future<void> acceptFriendRequest(FriendRequest request) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Update request status
      await _firestore.collection('friendRequests').doc(request.id).update({
        'status': 'accepted',
      });

      // Add to each other's friends
      final batch = _firestore.batch();

      // Add sender to receiver's friends
      batch.set(
        _firestore
            .collection('users')
            .doc(user.uid)
            .collection('friends')
            .doc(request.senderId),
        {'addedAt': FieldValue.serverTimestamp()},
      );

      // Add receiver to sender's friends
      batch.set(
        _firestore
            .collection('users')
            .doc(request.senderId)
            .collection('friends')
            .doc(user.uid),
        {'addedAt': FieldValue.serverTimestamp()},
      );

      await batch.commit();

      emit(state.copyWith(successMessage: 'Friend request accepted!'));

      // Clear success message after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (!isClosed) {
          emit(state.copyWith(clearSuccess: true));
        }
      });
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error accepting friend request: $e'));
    }
  }

  Future<void> rejectFriendRequest(String requestId) async {
    try {
      await _firestore.collection('friendRequests').doc(requestId).update({
        'status': 'rejected',
      });

      emit(state.copyWith(successMessage: 'Friend request rejected'));

      // Clear success message after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (!isClosed) {
          emit(state.copyWith(clearSuccess: true));
        }
      });
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error rejecting friend request: $e'));
    }
  }

  Future<void> cancelFriendRequest(String requestId) async {
    try {
      await _firestore.collection('friendRequests').doc(requestId).delete();

      emit(state.copyWith(successMessage: 'Friend request cancelled'));

      // Clear success message after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (!isClosed) {
          emit(state.copyWith(clearSuccess: true));
        }
      });
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error cancelling friend request: $e'));
    }
  }

  void clearMessages() {
    emit(state.copyWith(clearError: true, clearSuccess: true));
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
    _sentRequestsSubscription?.cancel();
    _receivedRequestsSubscription?.cancel();
    return super.close();
  }
}
