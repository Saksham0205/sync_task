part of 'friends_cubit.dart';

class FriendsState extends Equatable {
  final List<Friend> friends;
  final List<Friend> searchResults;
  final List<FriendRequest> sentRequests;
  final List<FriendRequest> receivedRequests;
  final bool isSearching;
  final String? errorMessage;
  final String? successMessage;

  const FriendsState({
    this.friends = const [],
    this.searchResults = const [],
    this.sentRequests = const [],
    this.receivedRequests = const [],
    this.isSearching = false,
    this.errorMessage,
    this.successMessage,
  });

  FriendsState copyWith({
    List<Friend>? friends,
    List<Friend>? searchResults,
    List<FriendRequest>? sentRequests,
    List<FriendRequest>? receivedRequests,
    bool? isSearching,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return FriendsState(
      friends: friends ?? this.friends,
      searchResults: searchResults ?? this.searchResults,
      sentRequests: sentRequests ?? this.sentRequests,
      receivedRequests: receivedRequests ?? this.receivedRequests,
      isSearching: isSearching ?? this.isSearching,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        friends,
        searchResults,
        sentRequests,
        receivedRequests,
        isSearching,
        errorMessage,
        successMessage,
      ];
}
