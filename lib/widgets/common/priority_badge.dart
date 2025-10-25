import 'package:flutter/material.dart';
import '../../constants/app_sizes.dart';
import '../../models/task.dart';

/// Priority badge widget for tasks
class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;

  const PriorityBadge({super.key, required this.priority});

  Color _getPriorityColor() {
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

  IconData _getPriorityIcon() {
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

  @override
  Widget build(BuildContext context) {
    final color = _getPriorityColor();
    final icon = _getPriorityIcon();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingXS,
        vertical: AppSizes.paddingXXS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.iconXS, color: color),
          const SizedBox(width: AppSizes.paddingXXS),
          Text(
            priority.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
