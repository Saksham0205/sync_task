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

class _FriendsScreenState extends State<FriendsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLG),
          child: BlocBuilder<FriendsCubit, FriendsState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageHeader(
                    title: 'Friends',
                    subtitle: '${state.friends.length} friends',
                  ),
                  const SizedBox(height: AppSizes.paddingLG),
                  const Text('Search Users', style: AppTextStyles.bodyLarge),
                  const SizedBox(height: AppSizes.paddingSM),
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search by username',
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingLG),
                  const Text('My Friends', style: AppTextStyles.bodyLarge),
                  const SizedBox(height: AppSizes.paddingMD),
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.friends.length,
                      itemBuilder: (context, index) {
                        final friend = state.friends[index];
                        return AppCard(
                          margin: const EdgeInsets.only(
                            bottom: AppSizes.paddingSM,
                          ),
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
                                    Text(
                                      friend.username,
                                      style: AppTextStyles.bodyLarge,
                                    ),
                                    const SizedBox(height: AppSizes.paddingXXS),
                                    Text(
                                      friend.email,
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.check,
                                    color: AppColors.primary,
                                    size: AppSizes.iconMD,
                                  ),
                                  const SizedBox(width: AppSizes.paddingXXS),
                                  const Text(
                                    'Friends',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
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
}
