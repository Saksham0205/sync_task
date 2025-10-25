import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';

/// A custom checkbox widget with consistent styling
class CustomCheckbox extends StatelessWidget {
  final bool isChecked;
  final VoidCallback onTap;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const CustomCheckbox({
    super.key,
    required this.isChecked,
    required this.onTap,
    this.size = 24.0,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isChecked
              ? (activeColor ?? AppColors.primary)
              : AppColors.transparent,
          border: Border.all(
            color: isChecked
                ? (activeColor ?? AppColors.primary)
                : (inactiveColor ?? AppColors.textTertiary),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
        ),
        child: isChecked
            ? Icon(Icons.check, color: AppColors.textPrimary, size: size * 0.67)
            : null,
      ),
    );
  }
}
