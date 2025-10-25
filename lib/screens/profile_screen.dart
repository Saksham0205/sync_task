import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_text_styles.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/page_header.dart';
import '../widgets/common/user_avatar.dart';
import '../cubits/auth/auth_cubit.dart';
import 'sign_in_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          // Navigate to sign in screen after logout
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const SignInScreen(),
            ),
            (route) => false, // Remove all previous routes
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingLG),
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, authState) {
                  final user = authState is AuthAuthenticated
                      ? authState.user
                      : null;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PageHeader(title: 'Profile'),
                    const SizedBox(height: AppSizes.paddingXL),
                    AppCard(
                      padding: const EdgeInsets.all(AppSizes.paddingLG),
                      child: Column(
                        children: [
                          UserAvatar(letter: user?.avatarLetter ?? 'J'),
                          const SizedBox(height: AppSizes.paddingMD),
                          Text(
                            user?.username ?? '@john_doe',
                            style: AppTextStyles.h3,
                          ),
                          const SizedBox(height: AppSizes.paddingXXS),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.email_outlined,
                                size: AppSizes.iconSM,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: AppSizes.paddingXXS),
                              Text(
                                user?.email ?? 'john@example.com',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.paddingXS),
                          Text(
                            user != null
                                ? 'Member since ${_formatDate(user.memberSince)}'
                                : 'Member since March 2024',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingLG),
                    _buildMenuItem(
                      icon: Icons.settings_outlined,
                      title: 'Account Settings',
                      subtitle: 'Manage your account preferences',
                      onTap: () {},
                    ),
                    const SizedBox(height: AppSizes.paddingSM),
                    _buildMenuItem(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      subtitle: 'Configure your notification preferences',
                      onTap: () {},
                    ),
                    const SizedBox(height: AppSizes.paddingSM),
                    _buildMenuItem(
                      icon: Icons.security_outlined,
                      title: 'Privacy & Security',
                      subtitle: 'Manage your privacy and security settings',
                      onTap: () {},
                    ),
                    const SizedBox(height: AppSizes.paddingSM),
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      subtitle: 'Get help and contact support',
                      onTap: () {},
                    ),
                    const SizedBox(height: AppSizes.paddingXL),
                    AppCard(
                      color: const Color(0xFF5C1919),
                      onTap: () {
                        context.read<AuthCubit>().signOut();
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: AppColors.error),
                          SizedBox(width: AppSizes.paddingXS),
                          Text(
                            'Sign Out',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingLG),
                    const Center(
                      child: Column(
                        children: [
                          Text('SyncTask', style: AppTextStyles.bodyLarge),
                          SizedBox(height: AppSizes.paddingXXS),
                          Text(
                            'Version 1.0.0',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: AppSizes.avatarLG,
            height: AppSizes.avatarLG,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            ),
            child: Icon(icon, color: AppColors.textPrimary),
          ),
          const SizedBox(width: AppSizes.paddingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyLarge),
                const SizedBox(height: AppSizes.paddingXXS),
                Text(subtitle, style: AppTextStyles.captionSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
