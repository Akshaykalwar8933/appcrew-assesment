import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/widgets/app_theme.dart';
import '../../../app/widgets/pltform_loader.dart';
import '../controllers/auth_controller.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final controller = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60.h),

              // Logo + Header
              Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: const Icon(
                      Icons.edit_note_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  const Text(
                    'Notes App',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 48.h),

              const Text(
                'Welcome\nback.',
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
                'Sign in to continue to your notes.',
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 15,
                ),
              ),

              SizedBox(height: 40.h),

              // Email Field
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

              // Password Field
              _buildLabel('Password'),
              SizedBox(height: 8.h),
              Obx(() => TextField(
                controller: controller.passwordController,
                obscureText: controller.obscurePassword.value,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => controller.login(),
                style:
                 TextStyle(color: AppTheme.textDark, fontSize: 15.sp),
                decoration: InputDecoration(
                  hintText: '••••••••',
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

              // Login Button
              Obx(() => controller.isLoading.value
                  ? const PlatformLoader()
                  : SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: controller.login,
                  child: const Text('Sign In'),
                ),
              )),

              SizedBox(height: 24.h),

              // Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text(
                    "Don't have an account? ",
                    style: TextStyle(color: AppTheme.textLight, fontSize: 14.sp),
                  ),
                  GestureDetector(
                    onTap: () {
                      controller.emailController.clear();
                      controller.passwordController.clear();
                      Get.toNamed(AppRoutes.signup);

                    },
                    child: const Text(
                      'Sign up',
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