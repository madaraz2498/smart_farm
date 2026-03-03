import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

/// Listens to [AuthProvider] and redirects automatically:
/// - Authenticated  → DashboardScreen
/// - Unauthenticated → LoginScreen
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    switch (auth.status) {
      case AuthStatus.authenticated:
        return const DashboardScreen();
      case AuthStatus.unauthenticated:
      case AuthStatus.unknown:
        return const LoginScreen();
    }
  }
}
