import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_text_styles.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/page_header.dart';
import '../cubits/groups/groups_cubit.dart';
import 'group_detail_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  void _showCreateGroupDialog() {
    final groupNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Create Group', style: AppTextStyles.h3),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textPrimary),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingLG),
              const Text('Group Name', style: AppTextStyles.label),
              const SizedBox(height: AppSizes.paddingXS),
              TextField(
                controller: groupNameController,
                decoration: const InputDecoration(hintText: 'Enter group name'),
              ),
              const SizedBox(height: AppSizes.paddingLG),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (groupNameController.text.isNotEmpty) {
                      context.read<GroupsCubit>().addGroup(
                        groupNameController.text,
                      );
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: const Text('Create Group'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmationDialog(String groupName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.error,
                    size: AppSizes.iconLG,
                  ),
                  SizedBox(width: AppSizes.paddingSM),
                  Text('Delete Group', style: AppTextStyles.h3),
                ],
              ),
              const SizedBox(height: AppSizes.paddingMD),
              Text(
                'Are you sure you want to delete "$groupName"? This will also delete all tasks in this group.',
                style: AppTextStyles.bodyLarge,
              ),
              const SizedBox(height: AppSizes.paddingLG),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: AppSizes.paddingSM),
                  ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLG),
          child: BlocBuilder<GroupsCubit, GroupsState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageHeader(
                    title: 'Groups',
                    subtitle: '${state.groups.length} groups',
                    action: ElevatedButton.icon(
                      onPressed: _showCreateGroupDialog,
                      icon: const Icon(Icons.add, size: AppSizes.iconLG),
                      label: const Text('Create'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingMD,
                          vertical: AppSizes.paddingSM,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingLG),
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.groups.length,
                      itemBuilder: (context, index) {
                        final group = state.groups[index];
                        return Dismissible(
                          key: Key(group.id),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) async {
                            return await _showDeleteConfirmationDialog(
                              group.name,
                            );
                          },
                          onDismissed: (direction) {
                            context.read<GroupsCubit>().deleteGroup(group.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${group.name} deleted'),
                                backgroundColor: AppColors.surfaceDark,
                              ),
                            );
                          },
                          background: Container(
                            margin: const EdgeInsets.only(
                              bottom: AppSizes.paddingMD,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusMD,
                              ),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(
                              right: AppSizes.paddingLG,
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: AppSizes.iconLG,
                            ),
                          ),
                          child: AppCard(
                            margin: const EdgeInsets.only(
                              bottom: AppSizes.paddingMD,
                            ),
                            padding: const EdgeInsets.all(AppSizes.paddingLG),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      GroupDetailScreen(groupId: group.id),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        group.name,
                                        style: AppTextStyles.h4,
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // IconButton(
                                        //   icon: const Icon(
                                        //     Icons.delete_outline,
                                        //     color: AppColors.error,
                                        //   ),
                                        //   onPressed: () async {
                                        //     final confirmed =
                                        //         await _showDeleteConfirmationDialog(
                                        //           group.name,
                                        //         );
                                        //     if (confirmed && context.mounted) {
                                        //       context
                                        //           .read<GroupsCubit>()
                                        //           .deleteGroup(group.id);
                                        //       ScaffoldMessenger.of(
                                        //         context,
                                        //       ).showSnackBar(
                                        //         SnackBar(
                                        //           content: Text(
                                        //             '${group.name} deleted',
                                        //           ),
                                        //           backgroundColor:
                                        //               AppColors.surfaceDark,
                                        //         ),
                                        //       );
                                        //     }
                                        //   },
                                        // ),
                                        const Icon(
                                          Icons.chevron_right,
                                          color: AppColors.textTertiary,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSizes.paddingXS),
                                Text(
                                  '${group.memberCount} members',
                                  style: AppTextStyles.caption,
                                ),
                                const SizedBox(height: AppSizes.paddingMD),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Progress',
                                      style: AppTextStyles.caption,
                                    ),
                                    Text(
                                      '${group.completedTasks}/${group.totalTasks}',
                                      style: AppTextStyles.bodyLarge,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSizes.paddingXS),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusXS,
                                  ),
                                  child: LinearProgressIndicator(
                                    value: group.totalTasks > 0
                                        ? group.completedTasks /
                                              group.totalTasks
                                        : 0,
                                    backgroundColor: AppColors.surfaceDark,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          AppColors.primary,
                                        ),
                                    minHeight: AppSizes.progressHeight,
                                  ),
                                ),
                              ],
                            ),
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
