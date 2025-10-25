import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_text_styles.dart';
import '../cubits/auth/auth_cubit.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signUp() {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      context.read<AuthCubit>().signUp(username, email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSizes.paddingXXXL),
              const Text('Create Account', style: AppTextStyles.h1),
              const SizedBox(height: AppSizes.paddingXS),
              const Text(
                'Join SyncTask to start managing tasks with friends',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: AppSizes.paddingXXL),
              const Text('Username', style: AppTextStyles.label),
              const SizedBox(height: AppSizes.paddingXS),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  hintText: 'Choose a username',
                ),
              ),
              const SizedBox(height: AppSizes.paddingLG),
              const Text('Email', style: AppTextStyles.label),
              const SizedBox(height: AppSizes.paddingXS),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(hintText: 'Enter your email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSizes.paddingLG),
              const Text('Password', style: AppTextStyles.label),
              const SizedBox(height: AppSizes.paddingXS),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  hintText: 'Create a password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: AppSizes.paddingXL),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _signUp,
                  child: const Text('Create Account'),
                ),
              ),
              const SizedBox(height: AppSizes.paddingLG),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
