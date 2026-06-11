import 'package:flutter/material.dart';
import 'package:near_vibe/core/exceptions/app_exception.dart';
import 'package:near_vibe/core/responsive/responsive.dart';
import 'package:near_vibe/core/style/app_text_styles.dart';
import 'package:near_vibe/core/themes/theme_extensions.dart';
import 'package:near_vibe/core/utils/validators.dart';
import 'package:near_vibe/widgets/app_loading.dart';
import 'package:near_vibe/widgets/app_scaffold.dart';
import 'package:near_vibe/widgets/app_snackbar.dart';
import 'package:near_vibe/providers/auth_provider.dart';
import 'package:near_vibe/screens/layout/main_layout.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void onLogin() async {
    if (_formKey.currentState!.validate()) {
      try {
        await context.read<AuthProvider>().login(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainLayoutScreen()),
          (route) => false,
        );
      } on AppException catch (e) {
        if (!mounted) return;

        AppSnackBar.error(context, e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      scrollable: true,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: context.res.hlg),
            Text(
              "Login",
              style: AppTextStyles.headlineLarge.copyWith(
                color: context.primary,
              ),
            ),
            SizedBox(height: context.res.hlg),
            TextFormField(
              controller: emailController,
              validator: AppValidator.email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: "Email"),
            ),
            SizedBox(height: context.res.hsm),
            TextFormField(
              controller: passwordController,
              validator: AppValidator.password,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(labelText: "Password"),
            ),
            SizedBox(height: context.res.hmd),
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return ElevatedButton(
                  onPressed: onLogin,
                  child: authProvider.isLoading
                      ? threeBounceLoading(context)
                      : Text("Login", style: AppTextStyles.titleMedium),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
