import 'package:flutter/material.dart';
import 'package:near_vibe/core/responsive/responsive.dart';
import 'package:near_vibe/core/style/app_text_styles.dart';
import 'package:near_vibe/core/themes/theme_extensions.dart';
import 'package:near_vibe/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Theme"),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Theme mode", style: AppTextStyles.bodyLarge),
            SizedBox(height: context.res.hxs),

            _ThemeCard(
              title: "Light",
              subtitle: "Always use light theme",
              icon: Icons.light_mode_rounded,
              selected: themeProvider.themeMode == ThemeMode.light,
              onTap: () {
                themeProvider.setTheme(ThemeMode.light);
              },
            ),

            SizedBox(height: context.res.hxs),

            _ThemeCard(
              title: "Dark",
              subtitle: "Always use dark theme",
              icon: Icons.dark_mode_rounded,
              selected: themeProvider.themeMode == ThemeMode.dark,
              onTap: () {
                themeProvider.setTheme(ThemeMode.dark);
              },
            ),
            SizedBox(height: context.res.hxs),

            _ThemeCard(
              title: "Follow System",
              subtitle: "Use device theme settings",
              icon: Icons.phone_android_rounded,
              selected: themeProvider.themeMode == ThemeMode.system,
              onTap: () {
                themeProvider.setTheme(ThemeMode.system);
              },
            ),

            SizedBox(height: context.res.hxs),
            Text("Accent color", style: AppTextStyles.bodyLarge),
            SizedBox(height: context.res.hxs),

            Wrap(
              spacing: context.res.w(0.03),
              runSpacing: context.res.hxs,
              children: ThemeProvider.accentColors.map((color) {
                return _AccentColorButton(
                  color: color,
                  selected: themeProvider.accentColor == color,
                  onTap: () {
                    themeProvider.setAccentColor(color);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccentColorButton extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _AccentColorButton({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 52,
        width: 52,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? context.text : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: selected
            ? const Icon(Icons.check_rounded, color: Colors.white)
            : null,
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? context.primary.withValues(alpha: 0.12)
          : context.primary.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? context.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 28, color: context.primary),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.bodyLarge),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: context.hitText,
                      ),
                    ),
                  ],
                ),
              ),

              if (selected) Icon(Icons.check_circle, color: context.primary),
            ],
          ),
        ),
      ),
    );
  }
}
