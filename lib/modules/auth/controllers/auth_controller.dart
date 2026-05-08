import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/services/network_service.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  RxBool isLoading = false.obs;
  RxBool obscurePassword = true.obs;

  String get currentUserEmail => _auth.currentUser?.email ?? '';

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // ── Validation ───────────────────────────────────────────────────────────────

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required.';
    if (!GetUtils.isEmail(value.trim()))
      return 'Please enter a valid email address.';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Password is required.';
    if (value.trim().length < 6)
      return 'Password must be at least 6 characters.';
    return null;
  }

  // ── Signup ───────────────────────────────────────────────────────────────────

  Future<void> signup() async {
    // 1. Validate fields first (no internet needed)
    final emailErr = validateEmail(emailController.text);
    final passErr = validatePassword(passwordController.text);
    if (emailErr != null) { _showError(emailErr); return; }
    if (passErr != null)  { _showError(passErr);  return; }

    // 2. Check internet before hitting Firebase
    if (!ConnectivityService.instance.checkAndAlert()) return;

    try {
      isLoading.value = true;
      await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      _clearFields();
      Get.offAllNamed(AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      _showError(_signupErrorMessage(e.code));
    } catch (e) {
      _showError('Something unexpected happened. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Login ────────────────────────────────────────────────────────────────────

  Future<void> login() async {
    // 1. Validate fields first (no internet needed)
    final emailErr = validateEmail(emailController.text);
    final passErr = validatePassword(passwordController.text);
    if (emailErr != null) { _showError(emailErr); return; }
    if (passErr != null)  { _showError(passErr);  return; }

    // 2. Check internet before hitting Firebase
    if (!ConnectivityService.instance.checkAndAlert()) return;

    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      _clearFields();
      Get.offAllNamed(AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      _showError(_loginErrorMessage(e.code));
    } catch (e) {
      _showError('Something unexpected happened. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Logout ───────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    // Logout works offline too — just clears local session
    await _auth.signOut();
    Get.offAllNamed(AppRoutes.login);
  }

  // ── Error messages ───────────────────────────────────────────────────────────

  String _loginErrorMessage(String code) {
    switch (code) {
      case 'invalid-credential':
        return 'Email or password is incorrect. Please check and try again.';
      case 'user-not-found':
        return 'No account found with this email. Please sign up first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'The email address you entered is not valid.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please wait a few minutes and try again.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network and try again.';
      case 'operation-not-allowed':
        return 'Email/password login is not enabled. Please contact support.';
      default:
        return 'Login failed. Please check your email and password.';
    }
  }

  String _signupErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account with this email already exists. Please log in instead.';
      case 'invalid-email':
        return 'The email address you entered is not valid.';
      case 'weak-password':
        return 'Your password is too weak. Please use at least 6 characters.';
      case 'operation-not-allowed':
        return 'Account creation is currently disabled. Please contact support.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a few minutes and try again.';
      default:
        return 'Could not create account. Please try again.';
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  void _clearFields() {
    emailController.clear();
    passwordController.clear();
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: const Color(0xFFE94560),
      colorText: const Color(0xFFFFFFFF),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
    );
  }
}