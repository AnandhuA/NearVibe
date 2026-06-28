import 'package:flutter/material.dart';
import 'package:near_vibe/core/responsive/responsive.dart';
import 'package:near_vibe/core/themes/app_colors.dart';
import 'package:near_vibe/core/themes/theme_extensions.dart';
import 'package:near_vibe/core/utils/app_assets.dart';
import 'package:near_vibe/widgets/app_scaffold.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Column(
        mainAxisAlignment: .center,
        children: [
          // Orbit Animation Area
          SizedBox(
            height: context.res.h(0.3),
            width: context.res.w(0.7),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: context.res.w(0.6),
                  height: context.res.h(0.2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .08),
                    ),
                  ),
                ),
                Container(
                  width: context.res.w(0.67),
                  height: context.res.h(0.27),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .05),
                    ),
                  ),
                ),

                // Center square
                Container(
                  width: context.res.w(0.2),
                  height: context.res.h(0.09),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: AppColors.primaryGradient(context.primary),
                    image: DecorationImage(
                      image: AssetImage(AppAssets.appLogo1024),
                    ),
                  ),
                ),

                _dot(top: 35, left: 25, color: Colors.deepPurpleAccent),
                _dot(top: 35, right: 25, color: Colors.green),
                _dot(bottom: 35, left: 20, color: Colors.pink),
                _dot(bottom: 35, right: 20, color: Colors.orange),
              ],
            ),
          ),

          SizedBox(height: context.res.hlg),

          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFF181A3B),
            ),
            child: const Text(
              "Discover local events",
              style: TextStyle(
                color: Color(0xFFA78BFA),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          SizedBox(height: context.res.hsm),

          const Text(
            "Find what's\nhappening near you",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
              height: 1.15,
            ),
          ),

          SizedBox(height: context.res.hmd),

          Text(
            "Music, meetups, gaming and more —\nall within walking distance, right now.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: .65),
              fontSize: 15,
              height: 1.5,
            ),
          ),
          SizedBox(height: context.res.hmd),

          // Page Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _indicator(true),
              _indicator(false),
              _indicator(false),
              _indicator(false),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _dot({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required Color color,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: .15),
          border: Border.all(color: color.withValues(alpha: .5)),
        ),
      ),
    );
  }

  static Widget _indicator(bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 22 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF8B5CF6)
            : Colors.white.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
