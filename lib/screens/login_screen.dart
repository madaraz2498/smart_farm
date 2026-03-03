import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/auth_widgets.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure       = true;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    bool ok = true;
    setState(() {
      _emailError = _passwordError = null;

      if (_emailCtrl.text.trim().isEmpty) {
        _emailError = 'Email is required.';
        ok = false;
      } else if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(_emailCtrl.text.trim())) {
        _emailError = 'Enter a valid email address.';
        ok = false;
      }

      if (_passwordCtrl.text.trim().isEmpty) {
        _passwordError = 'Password is required.';
        ok = false;
      } else if (_passwordCtrl.text.trim().length < 6) {
        _passwordError = 'Password must be at least 6 characters.';
        ok = false;
      }
    });
    return ok;
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    final auth = context.read<AuthProvider>();
    auth.clearError();
    // trim both to remove accidental spaces from autocomplete
    await auth.login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text.trim(),
    );
  }

  /// Fills demo credentials with one tap
  void _fillDemo() {
    setState(() {
      _emailCtrl.text    = 'john@farm.com';
      _passwordCtrl.text = 'password123';
      _emailError = _passwordError = null;
    });
    context.read<AuthProvider>().clearError();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 448),
            child: AuthCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  const Center(child: AppLogo()),
                  const SizedBox(height: 20),

                  // Title
                  const Center(
                    child: Text('Smart Farm AI',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  ),
                  const SizedBox(height: 6),
                  const Center(
                    child: Text('Sign in to manage your smart farm',
                        style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
                  ),
                  const SizedBox(height: 20),

                  // ── Demo credentials hint ──────────────────────────────
                  GestureDetector(
                    onTap: _fillDemo,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Demo account',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary)),
                                SizedBox(height: 2),
                                Text('john@farm.com  /  password123',
                                    style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                          const Text('Tap to fill',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Error banner
                  Consumer<AuthProvider>(
                    builder: (_, auth, __) => auth.errorMessage != null
                        ? Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ErrorBanner(auth.errorMessage!),
                    )
                        : const SizedBox.shrink(),
                  ),

                  // Email
                  const FieldLabel('Email'),
                  SmartTextField(
                    controller: _emailCtrl,
                    hint: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    errorText: _emailError,
                    onChanged: (_) => setState(() => _emailError = null),
                  ),
                  const SizedBox(height: 16),

                  // Password
                  const FieldLabel('Password'),
                  SmartTextField(
                    controller: _passwordCtrl,
                    hint: 'Enter your password',
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    errorText: _passwordError,
                    onChanged: (_) => setState(() => _passwordError = null),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 20,
                        color: AppColors.textMuted,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign In button
                  Consumer<AuthProvider>(
                    builder: (_, auth, __) => PrimaryButton(
                      label: 'Sign In',
                      isLoading: auth.isLoading,
                      onPressed: _submit,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? ",
                          style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
                      GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const RegisterScreen())),
                        child: const Text('Sign up',
                            style: TextStyle(
                                fontSize: 14,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}