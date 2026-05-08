import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  static ConnectivityService get instance => Get.find();

  final Connectivity _connectivity = Connectivity();

  RxBool isConnected = true.obs;

  StreamSubscription? _subscription;

  @override
  void onInit() {
    super.onInit();
    _checkNow();
    _subscription = _connectivity.onConnectivityChanged.listen(_onChanged);
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  Future<void> _checkNow() async {
    final result = await _connectivity.checkConnectivity();
    _onChanged(result);
  }

  void _onChanged(List<ConnectivityResult> results) {
    isConnected.value = results.any((r) => r != ConnectivityResult.none);
  }

  /// Call before any network operation.
  /// Returns true if online, shows snackbar and returns false if offline.
  bool checkAndAlert() {
    if (!isConnected.value) {
      _showNoInternetSnackbar();
      return false;
    }
    return true;
  }

  void _showNoInternetSnackbar() {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.snackbar(
      'No Internet Connection',
      'Please check your Wi-Fi or mobile data and try again.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1A1A2E),
      colorText: const Color(0xFFFFFFFF),
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.wifi_off_rounded, color: Colors.white),
    );
  }
}