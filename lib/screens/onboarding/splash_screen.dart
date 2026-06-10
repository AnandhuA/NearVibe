import 'package:flutter/material.dart';
import 'package:near_vibe/core/responsive/responsive.dart';
import 'package:near_vibe/repositories/local_storage_repository.dart';
import 'package:near_vibe/screens/auth/login_screen.dart';
import 'package:near_vibe/widgets/app_loading.dart';
import 'package:near_vibe/screens/layout/main_layout.dart';
import 'package:near_vibe/widgets/app_scaffold.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final LocalStorageRepository _localStorage = LocalStorageRepository();
  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    await Future.delayed(const Duration(seconds: 2));

    final user = await _localStorage.getUser();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            user != null ? const MainLayoutScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, size: 80),
            SizedBox(height: context.res.hsm),
            threeBounceLoading(context),
          ],
        ),
      ),
    );
  }
}
