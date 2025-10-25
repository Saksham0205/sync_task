import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';

/// A reusable circular avatar widget with letter display
class UserAvatar extends StatelessWidget {
  final String letter;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;

  const UserAvatar({
    super.key,
    required this.letter,
    this.radius = AppSizes.avatarMD,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? AppColors.primary,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: fontSize ?? radius * 0.8,
          fontWeight: FontWeight.bold,
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
    );
  }
}
