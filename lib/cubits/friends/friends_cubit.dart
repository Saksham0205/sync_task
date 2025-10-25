import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/friend.dart';

part 'friends_state.dart';

class FriendsCubit extends HydratedCubit<FriendsState> {
  FriendsCubit() : super(const FriendsState());

  void addFriend(Friend friend) {
    emit(state.copyWith(friends: [...state.friends, friend]));
  }

  void removeFriend(String friendId) {
    final updatedFriends = state.friends
        .where((friend) => friend.id != friendId)
        .toList();
    emit(state.copyWith(friends: updatedFriends));
  }

  void loadSampleData() {
    if (state.friends.isEmpty) {
      final sampleFriends = [
        const Friend(
          id: 'friend_1',
          username: '@alice_smith',
          email: 'alice@example.com',
          avatarLetter: 'A',
        ),
        const Friend(
          id: 'friend_2',
          username: '@bob_jones',
          email: 'bob@example.com',
          avatarLetter: 'B',
        ),
        const Friend(
          id: 'friend_3',
          username: '@charlie_brown',
          email: 'charlie@example.com',
          avatarLetter: 'C',
        ),
      ];
      emit(state.copyWith(friends: sampleFriends));
    }
  }

  @override
  FriendsState? fromJson(Map<String, dynamic> json) {
    try {
      final friends = (json['friends'] as List<dynamic>)
          .map((friend) => Friend.fromJson(friend as Map<String, dynamic>))
          .toList();
      return FriendsState(friends: friends);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(FriendsState state) {
    return {'friends': state.friends.map((friend) => friend.toJson()).toList()};
  }
}
