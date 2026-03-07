import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait for at least 2 seconds so the splash isn't instantly skipped
    final minDelay = Future.delayed(const Duration(seconds: 2));

    // Check for saved login session
    final authProvider = context.read<AuthProvider>();
    final authCheck = authProvider.checkLoginStatus();

    // Wait for both to finish
    final results = await Future.wait([minDelay, authCheck]);
    final bool isLoggedIn = results[1] as bool;

    if (!mounted) return;

    // Navigate accordingly
    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 100, color: AppTheme.onPrimary),
            SizedBox(height: 24),
            Text(
              'Smart Campus',
              style: TextStyle(
                color: AppTheme.onPrimary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Operations System',
              style: TextStyle(
                color: AppTheme.onPrimary,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
