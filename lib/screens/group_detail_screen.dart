import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_text_styles.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/custom_checkbox.dart';
import '../cubits/groups/groups_cubit.dart';
import '../models/task.dart';
import '../models/group.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final _taskController = TextEditingController();
  String? _currentUsername;
  TaskPriority _selectedPriority = TaskPriority.medium;

  @override
  void initState() {
    super.initState();
    _loadCurrentUsername();
    _cleanupTaskData();
  }

  Future<void> _loadCurrentUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        setState(() {
          _currentUsername = userDoc.data()?['username'] ?? 'You';
        });
      } catch (e) {
        setState(() {
          _currentUsername = 'You';
        });
      }
    }
  }

  Future<void> _cleanupTaskData() async {
    // Clean up any tasks that have both "You" and the actual username
    await context.read<GroupsCubit>().cleanupTaskMemberships(widget.groupId);
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      context.read<GroupsCubit>().addTaskToGroup(
        widget.groupId,
        _taskController.text,
        priority: _selectedPriority,
      );
      _taskController.clear();
      setState(() {
        _selectedPriority = TaskPriority.medium;
      });
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.blue;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.deepOrange;
      case TaskPriority.critical:
        return Colors.red;
    }
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Icons.arrow_downward;
      case TaskPriority.medium:
        return Icons.drag_handle;
      case TaskPriority.high:
        return Icons.arrow_upward;
      case TaskPriority.critical:
        return Icons.priority_high;
    }
  }

  void _showPriorityMenu(BuildContext context, GroupTask task) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLG),
        ),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMD),
                child: const Text('Set Priority', style: AppTextStyles.h3),
              ),
              ...TaskPriority.values.map((priority) {
                return ListTile(
                  leading: Icon(
                    _getPriorityIcon(priority),
                    color: _getPriorityColor(priority),
                  ),
                  title: Text(
                    priority.displayName,
                    style: AppTextStyles.bodyLarge,
                  ),
                  selected: task.priority == priority,
                  selectedTileColor: AppColors.surfaceDark.withOpacity(0.5),
                  onTap: () {
                    context.read<GroupsCubit>().updateTaskPriority(
                      widget.groupId,
                      task.id,
                      priority,
                    );
                    Navigator.pop(context);
                  },
                );
              }).toList(),
              const SizedBox(height: AppSizes.paddingSM),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupsCubit, GroupsState>(
      builder: (context, state) {
        final group = context.read<GroupsCubit>().getGroupById(widget.groupId);

        if (group == null) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: const Center(
              child: Text(
                'Group not found',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(group.name, style: AppTextStyles.h3),
                Row(
                  children: [
                    const Icon(
                      Icons.people,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSizes.paddingXXS),
                    Text(
                      '${group.memberCount} members',
                      style: AppTextStyles.captionSmall,
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_add, size: AppSizes.iconMD),
                label: const Text('Invite'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingSM,
                    vertical: AppSizes.paddingXS,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.paddingMD),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add Group Task',
                          style: AppTextStyles.bodyLarge,
                        ),
                        const SizedBox(height: AppSizes.paddingSM),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _taskController,
                                decoration: const InputDecoration(
                                  hintText: 'What does the group need to do?',
                                ),
                                onSubmitted: (_) => _addTask(),
                              ),
                            ),
                            const SizedBox(width: AppSizes.paddingSM),
                            Container(
                              width: AppSizes.avatarLG,
                              height: AppSizes.avatarLG,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusMD,
                                ),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: AppColors.textPrimary,
                                ),
                                onPressed: _addTask,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.paddingSM),
                        Text(
                          'Priority',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingXS),
                        Wrap(
                          spacing: AppSizes.paddingSM,
                          children: TaskPriority.values.map((priority) {
                            final isSelected = _selectedPriority == priority;
                            return FilterChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getPriorityIcon(priority),
                                    size: 16,
                                    color: isSelected
                                        ? Colors.white
                                        : _getPriorityColor(priority),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(priority.displayName),
                                ],
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedPriority = priority;
                                });
                              },
                              backgroundColor: AppColors.surfaceDark,
                              selectedColor: _getPriorityColor(priority),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppSizes.paddingMD),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.auto_awesome,
                              size: AppSizes.iconMD,
                            ),
                            label: const Text('Get AI Suggestions'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.secondary,
                              side: const BorderSide(
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingLG),
                  Expanded(
                    child: ListView.builder(
                      itemCount: group.tasks.length,
                      itemBuilder: (context, index) {
                        final task = group.tasks[index];
                        final completedCount = task.completedBy.values
                            .where((v) => v)
                            .length;
                        final totalMembers = task.completedBy.length;
                        final currentUser = _currentUsername ?? 'You';
                        final isCompleted =
                            task.completedBy[currentUser] ?? false;

                        return AppCard(
                          margin: const EdgeInsets.only(
                            bottom: AppSizes.paddingMD,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CustomCheckbox(
                                    isChecked: isCompleted,
                                    onTap: () {
                                      if (_currentUsername != null) {
                                        context
                                            .read<GroupsCubit>()
                                            .toggleTaskCompletion(
                                              widget.groupId,
                                              task.id,
                                              _currentUsername!,
                                            );
                                      }
                                    },
                                  ),
                                  const SizedBox(width: AppSizes.paddingSM),
                                  Expanded(
                                    child: Text(
                                      task.text,
                                      style: AppTextStyles.bodyLarge,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.flag_outlined,
                                      color: _getPriorityColor(task.priority),
                                    ),
                                    onPressed: () =>
                                        _showPriorityMenu(context, task),
                                    tooltip: 'Change priority',
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSizes.paddingXS),
                              Row(
                                children: [
                                  Icon(
                                    _getPriorityIcon(task.priority),
                                    size: 14,
                                    color: _getPriorityColor(task.priority),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    task.priority.displayName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _getPriorityColor(task.priority),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSizes.paddingSM),
                              Text(
                                'Created by ${task.createdBy}',
                                style: AppTextStyles.captionSmall,
                              ),
                              const SizedBox(height: AppSizes.paddingSM),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Completed by $completedCount of $totalMembers',
                                    style: AppTextStyles.captionSmall,
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSizes.paddingXS),
                              Wrap(
                                spacing: AppSizes.paddingXS,
                                children: task.completedBy.entries.map((entry) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: entry.value
                                          ? AppColors.primary.withOpacity(0.2)
                                          : AppColors.surfaceDark,
                                      borderRadius: BorderRadius.circular(
                                        AppSizes.radiusSM,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          entry.value
                                              ? Icons.check
                                              : Icons.circle,
                                          size: AppSizes.iconXS,
                                          color: entry.value
                                              ? AppColors.primary
                                              : AppColors.textTertiary,
                                        ),
                                        const SizedBox(
                                          width: AppSizes.paddingXXS,
                                        ),
                                        Text(
                                          entry.key,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: entry.value
                                                ? AppColors.primary
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
