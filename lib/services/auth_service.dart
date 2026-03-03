import '../models/user_model.dart';

class AuthResult {
  final bool success;
  final String? error;
  final UserModel? user;

  const AuthResult({required this.success, this.error, this.user});
  factory AuthResult.ok(UserModel user) => AuthResult(success: true, user: user);
  factory AuthResult.fail(String error) => AuthResult(success: false, error: error);
}

abstract class AuthService {
  Future<AuthResult> login(String email, String password);
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String role,
  });
  Future<void> logout();
}

class MockAuthService implements AuthService {
  static final List<Map<String, String>> _users = [
    {
      'id': 'u_001',
      'name': 'John Farmer',
      'email': 'john@farm.com',
      'password': 'password123',
      'role': 'Farmer',
    },
  ];

  @override
  Future<AuthResult> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Trim both sides to catch autocomplete spaces
    final cleanEmail = email.trim().toLowerCase();
    final cleanPass  = password.trim();

    final match = _users.where(
          (u) => u['email']!.toLowerCase() == cleanEmail && u['password'] == cleanPass,
    );

    if (match.isEmpty) {
      // Check if email exists to give a more helpful message
      final emailExists = _users.any((u) => u['email']!.toLowerCase() == cleanEmail);
      if (!emailExists) {
        return AuthResult.fail('No account found with this email.\nTry registering first.');
      }
      return AuthResult.fail('Incorrect password. Please try again.');
    }

    final u = match.first;
    return AuthResult.ok(
      UserModel(id: u['id']!, name: u['name']!, email: u['email']!, role: u['role']!),
    );
  }

  @override
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final cleanEmail = email.trim().toLowerCase();
    final exists = _users.any((u) => u['email']!.toLowerCase() == cleanEmail);

    if (exists) {
      return AuthResult.fail('An account with this email already exists.\nPlease sign in instead.');
    }

    final newUser = {
      'id': 'u_${DateTime.now().millisecondsSinceEpoch}',
      'name': name.trim(),
      'email': cleanEmail,
      'password': password.trim(),
      'role': role,
    };
    _users.add(newUser);

    return AuthResult.ok(
      UserModel(
        id: newUser['id']!,
        name: newUser['name']!,
        email: newUser['email']!,
        role: newUser['role']!,
      ),
    );
  }

  @override
  Future<void> logout() async => Future.delayed(const Duration(milliseconds: 200));
}