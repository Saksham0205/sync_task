import 'package:flutter/material.dart';
import '../../constants/app_sizes.dart';
import '../../constants/app_text_styles.dart';

/// A reusable page header widget with title and optional subtitle
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    if (action != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: _buildTitleSection()),
          action!,
        ],
      );
    }

    return _buildTitleSection();
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h1),
        if (subtitle != null) ...[
          const SizedBox(height: AppSizes.paddingXXS),
          Text(subtitle!, style: AppTextStyles.caption),
        ],
      ],
    );
  }
}
