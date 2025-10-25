import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_text_styles.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/page_header.dart';
import '../widgets/common/user_avatar.dart';
import '../cubits/friends/friends_cubit.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLG),
          child: BlocConsumer<FriendsCubit, FriendsState>(
            listener: (context, state) {
              if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Colors.red,
                  ),
                );
                context.read<FriendsCubit>().clearMessages();
              }
              if (state.successMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.successMessage!),
                    backgroundColor: AppColors.primary,
                  ),
                );
                context.read<FriendsCubit>().clearMessages();
              }
            },
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageHeader(
                    title: 'Friends',
                    subtitle: '${state.friends.length} friends',
                  ),
                  const SizedBox(height: AppSizes.paddingLG),

                  // Search Section
                  const Text('Search Users', style: AppTextStyles.bodyLarge),
                  const SizedBox(height: AppSizes.paddingSM),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      context.read<FriendsCubit>().searchUsers(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by email or username',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textTertiary,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                context.read<FriendsCubit>().searchUsers('');
                              },
                            )
                          : null,
                    ),
                  ),

                  // Search Results
                  if (state.searchResults.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.paddingMD),
                    const Text(
                      'Search Results',
                      style: AppTextStyles.bodyLarge,
                    ),
                    const SizedBox(height: AppSizes.paddingSM),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        itemCount: state.searchResults.length,
                        itemBuilder: (context, index) {
                          final user = state.searchResults[index];
                          return AppCard(
                            margin: const EdgeInsets.only(
                              bottom: AppSizes.paddingSM,
                            ),
                            child: Row(
                              children: [
                                UserAvatar(
                                  letter: user.avatarLetter,
                                  radius: AppSizes.avatarSM,
                                ),
                                const SizedBox(width: AppSizes.paddingSM),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.username,
                                        style: AppTextStyles.bodyLarge,
                                      ),
                                      const SizedBox(
                                        height: AppSizes.paddingXXS,
                                      ),
                                      Text(
                                        user.email,
                                        style: AppTextStyles.caption,
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    context
                                        .read<FriendsCubit>()
                                        .sendFriendRequest(user.id);
                                  },
                                  icon: const Icon(Icons.person_add, size: 16),
                                  label: const Text('Add'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSizes.paddingSM,
                                      vertical: AppSizes.paddingXS,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSizes.paddingLG),

                  // Tabs
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicatorColor: AppColors.primary,
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Friends'),
                              if (state.friends.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(
                                    left: AppSizes.paddingXXS,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${state.friends.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Requests'),
                              if (state.receivedRequests.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(
                                    left: AppSizes.paddingXXS,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${state.receivedRequests.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Sent'),
                              if (state.sentRequests.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(
                                    left: AppSizes.paddingXXS,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.textSecondary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${state.sentRequests.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tab Views
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildFriendsList(state),
                        _buildReceivedRequestsList(state),
                        _buildSentRequestsList(state),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFriendsList(FriendsState state) {
    if (state.friends.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: AppColors.textTertiary),
            SizedBox(height: AppSizes.paddingMD),
            Text('No friends yet', style: AppTextStyles.bodyLarge),
            SizedBox(height: AppSizes.paddingSM),
            Text(
              'Search for users to add friends',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: AppSizes.paddingMD),
      itemCount: state.friends.length,
      itemBuilder: (context, index) {
        final friend = state.friends[index];
        return AppCard(
          margin: const EdgeInsets.only(bottom: AppSizes.paddingSM),
          child: Row(
            children: [
              UserAvatar(
                letter: friend.avatarLetter,
                radius: AppSizes.avatarSM,
              ),
              const SizedBox(width: AppSizes.paddingSM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(friend.username, style: AppTextStyles.bodyLarge),
                    const SizedBox(height: AppSizes.paddingXXS),
                    Text(friend.email, style: AppTextStyles.caption),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.person_remove, color: Colors.red),
                onPressed: () {
                  _showRemoveFriendDialog(context, friend.id, friend.username);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReceivedRequestsList(FriendsState state) {
    if (state.receivedRequests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppColors.textTertiary),
            SizedBox(height: AppSizes.paddingMD),
            Text('No friend requests', style: AppTextStyles.bodyLarge),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: AppSizes.paddingMD),
      itemCount: state.receivedRequests.length,
      itemBuilder: (context, index) {
        final request = state.receivedRequests[index];
        return AppCard(
          margin: const EdgeInsets.only(bottom: AppSizes.paddingSM),
          child: Column(
            children: [
              Row(
                children: [
                  UserAvatar(
                    letter: request.senderAvatarLetter,
                    radius: AppSizes.avatarSM,
                  ),
                  const SizedBox(width: AppSizes.paddingSM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.senderUsername,
                          style: AppTextStyles.bodyLarge,
                        ),
                        const SizedBox(height: AppSizes.paddingXXS),
                        Text(request.senderEmail, style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingSM),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<FriendsCubit>().acceptFriendRequest(
                          request,
                        );
                      },
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingSM),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.read<FriendsCubit>().rejectFriendRequest(
                          request.id,
                        );
                      },
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSentRequestsList(FriendsState state) {
    if (state.sentRequests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send_outlined, size: 64, color: AppColors.textTertiary),
            SizedBox(height: AppSizes.paddingMD),
            Text('No pending requests', style: AppTextStyles.bodyLarge),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: AppSizes.paddingMD),
      itemCount: state.sentRequests.length,
      itemBuilder: (context, index) {
        final request = state.sentRequests[index];
        // We need to get the receiver info from the request
        // Since we stored sender info, we need to fetch receiver info
        return AppCard(
          margin: const EdgeInsets.only(bottom: AppSizes.paddingSM),
          child: Row(
            children: [
              const Icon(
                Icons.pending_outlined,
                color: AppColors.textSecondary,
                size: AppSizes.iconMD,
              ),
              const SizedBox(width: AppSizes.paddingSM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Request sent', style: AppTextStyles.bodyLarge),
                    const SizedBox(height: AppSizes.paddingXXS),
                    Text(
                      'Waiting for response...',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<FriendsCubit>().cancelFriendRequest(request.id);
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRemoveFriendDialog(
    BuildContext context,
    String friendId,
    String friendName,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Remove Friend'),
        content: Text('Are you sure you want to remove $friendName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<FriendsCubit>().removeFriend(friendId);
              Navigator.pop(dialogContext);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
