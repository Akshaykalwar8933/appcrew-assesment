import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'app_theme.dart';

class PlatformLoader extends StatelessWidget {
  final Color? color;
  const PlatformLoader({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Platform.isIOS
          ? CupertinoActivityIndicator(color: color ?? AppTheme.primary)
          : CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppTheme.accent,
        ),
        strokeWidth: 2.5,
      ),
    );
  }
}