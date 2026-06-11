import 'package:avatar_plus/avatar_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:near_vibe/core/responsive/responsive.dart';
import 'package:near_vibe/core/style/app_text_styles.dart';
import 'package:near_vibe/core/themes/theme_extensions.dart';
import 'package:near_vibe/models/user_model.dart';
import 'package:near_vibe/providers/user_provider.dart' show UserProvider;
import 'package:near_vibe/widgets/app_loading.dart';
import 'package:near_vibe/widgets/app_scaffold.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    return AppScaffold(
      scrollable: true,
      child: switch (true) {
        // ================= LOADING =================
        _ when provider.isLoading => Center(child: threeBounceLoading(context)),

        // ================= ERROR =================
        _ when provider.exception != null => Center(
          child: Text(
            provider.exception!.message,
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),

        // ================= DATA =================
        _ => _buildProfile(context, provider),
      },
    );
  }

  Column _buildProfile(BuildContext context, UserProvider provider) {
    final UserModel? user = provider.user;
    if (user == null) {
      return Column(
        mainAxisAlignment: .center,
        crossAxisAlignment: .center,
        children: [Center(child: threeBounceLoading(context))],
      );
    }
    final joinedDate = DateFormat('MMMM yyyy').format(user.createdAt);
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        SizedBox(height: context.res.hmd),
        user.avatarUrl.isNotEmpty
            ? CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(user.avatarUrl),
              )
            : AvatarPlus(user.name.toLowerCase(), height: 100, width: 100),
        Text(
          user.name,
          style: AppTextStyles.headlineLarge,
          textAlign: TextAlign.center,
        ),

        SizedBox(height: context.res.hsm),
        _InfoTile(icon: Icons.person_outline, label: 'Name', value: user.name),

        _InfoTile(
          icon: Icons.email_outlined,
          label: 'Email',
          value: user.email,
        ),
        if (user.location.isNotEmpty)
          _InfoTile(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: user.location,
          ),

        _InfoTile(
          icon: Icons.calendar_today_outlined,
          label: 'Joined',
          value: joinedDate,
        ),
        _InfoTile(
          icon: context.isDarkMode
              ? Icons.dark_mode_outlined
              : Icons.light_mode_outlined,
          label: 'Theme',
          value: context.isDarkMode ? "Dark Mode" : "Light Mode",
        ),

        _InfoTile(icon: Icons.info_outline, label: 'About'),
        _InfoTile(icon: Icons.settings_outlined, label: 'Settings'),
        SizedBox(height: context.res.hsm),
        Text(
          "Version : v1.0",
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;

  const _InfoTile({required this.icon, required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: context.primary.withValues(alpha: 0.09),
        leading: Icon(icon, color: context.primary),
        title: Text(
          label,
          style: value == null
              ? AppTextStyles.bodyLarge
              : AppTextStyles.bodySmall.copyWith(color: context.hitText),
        ),
        subtitle: value == null
            ? null
            : Text(value!, style: AppTextStyles.bodyLarge),
      ),
    );
  }
}
