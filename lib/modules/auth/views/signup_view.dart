import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/widgets/app_theme.dart';
import '../../../app/widgets/pltform_loader.dart';
import '../controllers/auth_controller.dart';

class SignupView extends StatelessWidget {
  SignupView({super.key});

  final controller = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppTheme.textDark),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.h),

              const Text(
                'Create\naccount.',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                  height: 1.1,
                  letterSpacing: -1.5,
                ),
              ),

              SizedBox(height: 8.h),

              const Text(
                'Start capturing your thoughts today.',
                style: TextStyle(color: AppTheme.textLight, fontSize: 15),
              ),

              SizedBox(height: 40.h),

              _buildLabel('Email address'),
              SizedBox(height: 8.h),
              TextField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                style: const TextStyle(color: AppTheme.textDark, fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'you@example.com',
                  prefixIcon: Icon(Icons.mail_outline_rounded,
                      color: AppTheme.textLight, size: 20),
                ),
              ),

              SizedBox(height: 20.h),

              _buildLabel('Password'),
              SizedBox(height: 8.h),
              Obx(() => TextField(
                controller: controller.passwordController,
                obscureText: controller.obscurePassword.value,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => controller.signup(),
                style:
                const TextStyle(color: AppTheme.textDark, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'At least 6 characters',
                  prefixIcon: const Icon(Icons.lock_outline_rounded,
                      color: AppTheme.textLight, size: 20),
                  suffixIcon: GestureDetector(
                    onTap: () => controller.obscurePassword.toggle(),
                    child: Icon(
                      controller.obscurePassword.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppTheme.textLight,
                      size: 20,
                    ),
                  ),
                ),
              )),

              SizedBox(height: 36.h),

              Obx(() => controller.isLoading.value
                  ? const PlatformLoader()
                  : SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: controller.signup,
                  child: const Text('Create Account'),
                ),
              )),

              SizedBox(height: 24.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(color: AppTheme.textLight, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        color: AppTheme.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textDark,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }
}