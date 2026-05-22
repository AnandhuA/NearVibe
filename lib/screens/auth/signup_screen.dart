import 'package:flutter/material.dart';
import 'package:near_vibe/core/responsive/responsive.dart';
import 'package:near_vibe/core/style/app_text_styles.dart';
import 'package:near_vibe/core/themes/theme_extensions.dart';
import 'package:near_vibe/core/utils/validators.dart';
import 'package:near_vibe/core/widgets/app_scaffold.dart';
import 'package:near_vibe/core/widgets/app_snackbar.dart';
import 'package:near_vibe/screens/layout/main_layout.dart';

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

  void onSignUp() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainLayoutScreen()),
        (route) => false,
      );
      AppSnackBar.success(context, "Login Success");
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
            ElevatedButton(
              onPressed: onSignUp,
              child: Text("Create Account", style: AppTextStyles.titleMedium),
            ),
          ],
        ),
      ),
    );
  }
}
