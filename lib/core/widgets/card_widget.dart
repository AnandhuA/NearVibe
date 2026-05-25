import 'package:flutter/material.dart';
import 'package:near_vibe/core/responsive/responsive.dart';
import 'package:near_vibe/core/style/app_text_styles.dart';
import 'package:near_vibe/core/themes/app_colors.dart';
import 'package:near_vibe/core/themes/theme_extensions.dart';
import 'package:near_vibe/core/widgets/category_widget.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.primary.withValues(alpha: 0.09),

        borderRadius: BorderRadius.circular(20),
      ),

      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Image
              Container(
                height: 180,

                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Kochi Music Festival 2026",
                      style: AppTextStyles.titleLarge.copyWith(
                        color: context.text,
                      ),
                    ),

                    SizedBox(height: context.res.hxs),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 18,
                          color: context.hitText,
                        ),

                        SizedBox(width: context.res.wxs),

                        Text(
                          "Kakkanad, Kochi",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: context.hitText,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: context.res.hxs),

                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 18,
                          color: context.hitText,
                        ),

                        SizedBox(width: context.res.wxs),

                        Text(
                          "Today • 7:30 PM",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: context.hitText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          CategoryWidget(
            icon: Icons.music_note,
            title: "Music",
            bgColor: context.secondary,
          ),
        ],
      ),
    );
  }
}
