part of 'friends_cubit.dart';

class FriendsState extends Equatable {
  final List<Friend> friends;

  const FriendsState({this.friends = const []});

  FriendsState copyWith({List<Friend>? friends}) {
    return FriendsState(friends: friends ?? this.friends);
  }

  @override
  List<Object?> get props => [friends];
}
