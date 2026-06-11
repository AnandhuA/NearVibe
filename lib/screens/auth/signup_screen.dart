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
import 'package:near_vibe/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController nameController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void onSignUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        await context.read<AuthProvider>().createAccount(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          name: nameController.text.trim(),
        );
        AppSnackBar.success(context, "Account created");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      } on AppException catch (e) {
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
              "Create Account",
              style: AppTextStyles.headlineLarge.copyWith(
                color: context.primary,
              ),
            ),
            SizedBox(height: context.res.hlg),
            TextFormField(
              controller: nameController,
              validator: AppValidator.name,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(labelText: "Name"),
            ),
            SizedBox(height: context.res.hsm),
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
            SizedBox(height: context.res.hsm),
            TextFormField(
              controller: confirmPasswordController,
              validator: (_) => AppValidator.confirmPassword(
                password: passwordController.text,
                confirmPassword: confirmPasswordController.text,
              ),
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(labelText: "ConfirmPassword"),
            ),
            SizedBox(height: context.res.hmd),
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return ElevatedButton(
                  onPressed: onSignUp,
                  child: authProvider.isLoading
                      ? threeBounceLoading(context)
                      : Text(
                          "Create Account",
                          style: AppTextStyles.titleMedium,
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
