import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_text_styles.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/custom_checkbox.dart';
import '../widgets/common/page_header.dart';
import '../cubits/tasks/tasks_cubit.dart';
import '../models/task.dart';

class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen({super.key});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> {
  final _taskController = TextEditingController();
  TaskPriority _selectedPriority = TaskPriority.medium;

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      context.read<TasksCubit>().addTask(
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

  void _showPriorityMenu(BuildContext context, Task task) {
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
                    context.read<TasksCubit>().updateTaskPriority(
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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLG),
          child: BlocBuilder<TasksCubit, TasksState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageHeader(
                    title: 'My Tasks',
                    subtitle:
                        '${state.completedCount} of ${state.tasks.length} completed',
                  ),
                  const SizedBox(height: AppSizes.paddingLG),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add New Task',
                          style: AppTextStyles.bodyLarge,
                        ),
                        const SizedBox(height: AppSizes.paddingSM),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _taskController,
                                decoration: const InputDecoration(
                                  hintText: 'What do you need to do?',
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
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingLG),
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.tasks.length,
                      itemBuilder: (context, index) {
                        final task = state.tasks[index];
                        return AppCard(
                          margin: const EdgeInsets.only(
                            bottom: AppSizes.paddingSM,
                          ),
                          child: Row(
                            children: [
                              CustomCheckbox(
                                isChecked: task.completed,
                                onTap: () => context
                                    .read<TasksCubit>()
                                    .toggleTask(task.id),
                              ),
                              const SizedBox(width: AppSizes.paddingSM),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.text,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: task.completed
                                            ? AppColors.textTertiary
                                            : AppColors.textPrimary,
                                        decoration: task.completed
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          _getPriorityIcon(task.priority),
                                          size: 14,
                                          color: _getPriorityColor(
                                            task.priority,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          task.priority.displayName,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _getPriorityColor(
                                              task.priority,
                                            ),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
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
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.error,
                                ),
                                onPressed: () => context
                                    .read<TasksCubit>()
                                    .deleteTask(task.id),
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
