import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? MockAuthService();

  // ── State ──────────────────────────────────────────────────────────────
  AuthStatus _status = AuthStatus.unauthenticated;
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // ── Getters ────────────────────────────────────────────────────────────
  AuthStatus get status => _status;
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // ── Login ──────────────────────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.login(email, password);

    if (result.success && result.user != null) {
      _user = result.user;
      _status = AuthStatus.authenticated;
      _setLoading(false);
      return true;
    } else {
      _errorMessage = result.error;
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      return false;
    }
  }

  // ── Register ───────────────────────────────────────────────────────────
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.register(
      name: name,
      email: email,
      password: password,
      role: role,
    );

    if (result.success && result.user != null) {
      _user = result.user;
      _status = AuthStatus.authenticated;
      _setLoading(false);
      return true;
    } else {
      _errorMessage = result.error;
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      return false;
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _clearError();
    notifyListeners();
  }

  // ── Helpers ────────────────────────────────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}
