import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/auth_widgets.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass    = true;
  bool _obscureConfirm = true;
  String? _selectedRole;

  final List<String> _roles = ['Farmer', 'Admin'];

  String? _nameError, _emailError, _passError, _confirmError, _roleError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    bool ok = true;
    setState(() {
      _nameError = _emailError = _passError = _confirmError = _roleError = null;

      // Name
      if (_nameCtrl.text.trim().isEmpty) {
        _nameError = 'Full name is required.';
        ok = false;
      } else if (_nameCtrl.text.trim().length < 2) {
        _nameError = 'Name must be at least 2 characters.';
        ok = false;
      }

      // Email
      final email = _emailCtrl.text.trim();
      if (email.isEmpty) {
        _emailError = 'Email is required.';
        ok = false;
      } else if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(email)) {
        _emailError = 'Enter a valid email address.';
        ok = false;
      }

      // Password — only min length, no number requirement
      final pass = _passCtrl.text;
      if (pass.isEmpty) {
        _passError = 'Password is required.';
        ok = false;
      } else if (pass.length < 6) {
        _passError = 'Password must be at least 6 characters.';
        ok = false;
      }

      // Confirm
      if (_confirmCtrl.text.isEmpty) {
        _confirmError = 'Please confirm your password.';
        ok = false;
      } else if (_confirmCtrl.text != _passCtrl.text) {
        _confirmError = 'Passwords do not match.';
        ok = false;
      }

      // Role
      if (_selectedRole == null) {
        _roleError = 'Please select your role.';
        ok = false;
      }
    });
    return ok;
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    final auth = context.read<AuthProvider>();
    auth.clearError();
    await auth.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      role: _selectedRole!,
    );
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
                    child: Text('Create Account',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  ),
                  const SizedBox(height: 6),
                  const Center(
                    child: Text('Join Smart Farm AI today',
                        style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
                  ),
                  const SizedBox(height: 28),

                  // Error banner (server-level)
                  Consumer<AuthProvider>(
                    builder: (_, auth, __) => auth.errorMessage != null
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ErrorBanner(auth.errorMessage!),
                          )
                        : const SizedBox.shrink(),
                  ),

                  // Full Name
                  const FieldLabel('Full Name'),
                  SmartTextField(
                    controller: _nameCtrl,
                    hint: 'Enter your full name',
                    textInputAction: TextInputAction.next,
                    errorText: _nameError,
                    onChanged: (_) => setState(() => _nameError = null),
                  ),
                  const SizedBox(height: 16),

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

                  // Password — hint shows requirement clearly
                  const FieldLabel('Password'),
                  SmartTextField(
                    controller: _passCtrl,
                    hint: 'Min 6 characters',
                    obscureText: _obscurePass,
                    textInputAction: TextInputAction.next,
                    errorText: _passError,
                    onChanged: (_) => setState(() => _passError = null),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 20, color: AppColors.textMuted,
                      ),
                      onPressed: () => setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password
                  const FieldLabel('Confirm Password'),
                  SmartTextField(
                    controller: _confirmCtrl,
                    hint: 'Re-enter your password',
                    obscureText: _obscureConfirm,
                    textInputAction: TextInputAction.done,
                    errorText: _confirmError,
                    onChanged: (_) => setState(() => _confirmError = null),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 20, color: AppColors.textMuted,
                      ),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Role
                  const FieldLabel('Role'),
                  RoleDropdown(
                    value: _selectedRole,
                    items: _roles,
                    errorText: _roleError,
                    onChanged: (val) => setState(() {
                      _selectedRole = val;
                      _roleError = null;
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Button
                  Consumer<AuthProvider>(
                    builder: (_, auth, __) => PrimaryButton(
                      label: 'Create Account',
                      isLoading: auth.isLoading,
                      onPressed: _submit,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sign in link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? ',
                          style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                            context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                        child: const Text('Sign in',
                            style: TextStyle(
                                fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w600)),
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
