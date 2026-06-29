import 'package:flutter/material.dart';
import 'package:near_vibe/core/style/app_text_styles.dart';
import 'package:near_vibe/core/themes/theme_extensions.dart';

class CategoryWidget extends StatelessWidget {
  final IconData? icon;
  final String title;
  final bool isSelected;
  final Color bgColor;
  final VoidCallback? ontap;
  final Color? titleColor;
  const CategoryWidget({
    super.key,
    this.icon,
    required this.title,
    this.isSelected = false,
    required this.bgColor,
    this.ontap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isSelected
        ? Colors.white
        : titleColor;

    return GestureDetector(
      onTap: ontap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        constraints: const BoxConstraints(minWidth: 64, maxWidth: 112),
        height: 38,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isSelected
              ? context.primary
              : context.primary.withValues(alpha: 0.12),
          border: Border.all(
            color: isSelected
                ? context.primary
                : context.primary.withValues(alpha: 0.18),
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: context.primary.withValues(alpha: 0.24),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, size: 14, color: foregroundColor),
            if (icon != null) const SizedBox(width: 5),

            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
