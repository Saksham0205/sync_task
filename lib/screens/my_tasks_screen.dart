import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_text_styles.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/custom_checkbox.dart';
import '../widgets/common/page_header.dart';
import '../cubits/tasks/tasks_cubit.dart';

class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen({super.key});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> {
  final _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      context.read<TasksCubit>().addTask(_taskController.text);
      _taskController.clear();
    }
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
                                child: Text(
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
