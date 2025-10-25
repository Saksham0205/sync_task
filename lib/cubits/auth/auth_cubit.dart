import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthCubit() : super(AuthInitial()) {
    // Listen to auth state changes
    _firebaseAuth.authStateChanges().listen((firebaseUser) {
      if (firebaseUser != null) {
        _loadUserData(firebaseUser.uid);
      } else {
        emit(AuthInitial());
      }
    });
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final user = User.fromJson({...doc.data()!, 'id': uid});
        emit(AuthAuthenticated(user));
      }
    } catch (e) {
      emit(AuthError('Failed to load user data: $e'));
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      emit(AuthLoading());
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Auth state listener will handle the rest
    } catch (e) {
      emit(AuthError('Sign in failed: ${e.toString()}'));
    }
  }

  Future<void> signUp(String username, String email, String password) async {
    try {
      emit(AuthLoading());
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final user = User(
          id: credential.user!.uid,
          username: username,
          email: email,
          avatarLetter: username.isNotEmpty ? username[0].toUpperCase() : 'U',
          memberSince: DateTime.now(),
        );

        // Save user data to Firestore
        await _firestore.collection('users').doc(credential.user!.uid).set(user.toJson());
        
        emit(AuthAuthenticated(user));
      }
    } catch (e) {
      emit(AuthError('Sign up failed: ${e.toString()}'));
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError('Sign out failed: ${e.toString()}'));
    }
  }

}
