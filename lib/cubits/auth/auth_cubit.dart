import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/user.dart';

part 'auth_state.dart';

class AuthCubit extends HydratedCubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  void signIn(String email, String password) {
    // For now, create a mock user
    final user = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      username: '@john_doe',
      email: email,
      avatarLetter: 'J',
      memberSince: DateTime.now(),
    );
    emit(AuthAuthenticated(user));
  }

  void signUp(String username, String email, String password) {
    final user = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      username: username,
      email: email,
      avatarLetter: username.isNotEmpty ? username[0].toUpperCase() : 'U',
      memberSince: DateTime.now(),
    );
    emit(AuthAuthenticated(user));
  }

  void signOut() {
    emit(AuthInitial());
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    try {
      if (json['type'] == 'authenticated') {
        return AuthAuthenticated(
          User.fromJson(json['user'] as Map<String, dynamic>),
        );
      }
      return AuthInitial();
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    if (state is AuthAuthenticated) {
      return {'type': 'authenticated', 'user': state.user.toJson()};
    }
    return null;
  }
}
