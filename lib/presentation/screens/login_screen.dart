// =============================================================================
// presentation/screens/login_screen.dart
// =============================================================================
// Role-based mock login form.
//
// FLOW:
//   User enters email + password → AuthProvider.login() →
//   success: Navigator.pushReplacementNamed → '/home'
//   failure: show inline error message
//
// VIVA POINT:
//   "We never navigate unless AuthProvider confirms login. The Provider
//    sits between the UI and the domain — the screen never touches the
//    database or mock data directly."
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  bool _isLoading = false;
  String? _errorMsg;
  bool _obscurePass = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Login action
  // ---------------------------------------------------------------------------
  Future<void> _submit() async {
    // Validate form fields first
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMsg  = null;
    });

    final auth    = context.read<AuthProvider>();
    final success = await auth.login(_emailCtrl.text, _passCtrl.text);

    if (!mounted) return;

    if (success) {
      // Replace login with home so back button doesn't return to login
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      setState(() {
        _isLoading = false;
        _errorMsg  = 'Invalid email or password. Please try again.';
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- Logo / branding ----------
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.school,
                        color: AppTheme.onPrimary, size: 44),
                  ),
                ),
                const SizedBox(height: 28),

                const Text(
                  'Smart Campus',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Sign in to continue',
                  style: TextStyle(
                      fontSize: 15, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 36),

                // ---------- Email ----------
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'Enter a valid email'
                      : null,
                ),
                const SizedBox(height: 16),

                // ---------- Password ----------
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscurePass,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePass
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Enter your password'
                      : null,
                ),
                const SizedBox(height: 10),

                // ---------- Error message ----------
                if (_errorMsg != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMsg!,
                      style: const TextStyle(
                          color: AppTheme.error, fontSize: 13),
                    ),
                  ),

                const SizedBox(height: 24),

                // ---------- Sign in button ----------
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.onPrimary,
                          ),
                        )
                      : const Text('Sign In',
                          style: TextStyle(fontSize: 16)),
                ),

                const SizedBox(height: 36),

                // ---------- Demo credentials hint ----------
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppTheme.secondary.withValues(alpha: 0.3)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Demo credentials',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppTheme.primary)),
                      SizedBox(height: 6),
                      Text('Student: student@campus.lk / 1234',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary)),
                      Text('Staff:   staff@campus.lk / 1234',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
