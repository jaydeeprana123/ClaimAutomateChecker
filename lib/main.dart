import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';

void main() {
  runApp(const ClaimAutomateApp());
}

class ClaimAutomateApp extends StatelessWidget {
  const ClaimAutomateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Claim Automate Checker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
