import 'package:flutter/material.dart';
import 'package:near_vibe/core/responsive/responsive.dart';
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
    this.titleColor
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: isSelected ? context.primary : bgColor,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, size: 18,color: titleColor,),
            if (icon != null) SizedBox(width: context.res.wxs),

            Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                color: titleColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
