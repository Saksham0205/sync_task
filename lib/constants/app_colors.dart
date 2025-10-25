import 'package:flutter/material.dart';

/// Centralized color constants for the app
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary Colors
  static const Color primary = Color(0xFF00D95F);
  static const Color secondary = Color(0xFF8B7BF7);

  // Background Colors
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceDark = Color(0xFF2A2A2A);

  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF999999);
  static const Color textTertiary = Color(0xFF666666);

  // Status Colors
  static const Color success = Color(0xFF00D95F);
  static const Color error = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFB74D);
  static const Color info = Color(0xFF00D95F);

  // Priority Colors
  static const Color priorityHigh = Color(0xFFFF5252);
  static const Color priorityMedium = Color(0xFFFFB74D);
  static const Color priorityLow = Color(0xFF00D95F);

  // Other Colors
  static const Color border = Color(0xFF333333);
  static const Color divider = Color(0xFF1E1E1E);
  static const Color transparent = Colors.transparent;

  // Helper method for borders with opacity
  static Color borderWithOpacity([double opacity = 0.1]) {
    return Colors.white.withOpacity(opacity);
  }
}
