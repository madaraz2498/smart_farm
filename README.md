# Smart Farm AI — Flutter App

A production-ready Flutter mobile app with Provider state management, MockAuthService, protected routes, and a responsive dashboard.

---

## 📁 Folder Structure

```
lib/
├── main.dart                    # Entry point — MultiProvider setup
├── models/
│   └── user_model.dart          # UserModel data class
├── providers/
│   ├── auth_provider.dart       # Auth state (login/register/logout)
│   └── navigation_provider.dart # Sidebar/BottomNav selected index
├── screens/
│   ├── auth_wrapper.dart        # Protected route — redirects based on auth state
│   ├── login_screen.dart        # Login UI with validation
│   ├── register_screen.dart     # Register UI with validation
│   ├── dashboard_screen.dart    # Main dashboard (sidebar + grid)
│   └── feature_screens.dart     # All 6 AI feature screens
├── services/
│   └── auth_service.dart        # MockAuthService (swap with Firebase later)
├── utils/
│   └── app_theme.dart           # AppColors + AppTheme
└── widgets/
    └── auth_widgets.dart        # Reusable: AppLogo, SmartTextField, PrimaryButton…
```

---

## 🚀 Setup

### 1. Add dependencies to `pubspec.yaml`
```yaml
dependencies:
  provider: ^6.1.2
  flutter_svg: ^2.0.10+1
```

### 2. Copy all files into your `lib/` folder

Replace your existing:
- `lib/main.dart`
- All other files go into their respective folders

### 3. Run
```bash
flutter pub get
flutter run
```

---

## 🔐 Auth Flow

### Mock credentials (pre-seeded)
| Email | Password |
|-------|----------|
| john@farm.com | password123 |

You can also register a new account from the Register screen.

### Replacing MockAuthService with Firebase
Open `lib/services/auth_service.dart` and replace `MockAuthService` with a `FirebaseAuthService` that implements the same `AuthService` abstract class. Then pass it into `AuthProvider`:

```dart
// In main.dart
ChangeNotifierProvider(
  create: (_) => AuthProvider(authService: FirebaseAuthService()),
),
```

---

## ✅ Features

- **Protected Routes** — `AuthWrapper` blocks unauthenticated access to dashboard
- **Field Validation** — email format, password length, confirm match, role required
- **Error Banners** — server-level errors displayed inline
- **Loading States** — button shows spinner during async calls
- **Responsive Layout**
  - Mobile (< 600px): Single-column grid + Drawer + BottomNavigationBar
  - Tablet (600–900px): 2-column grid + Sidebar
  - Desktop (> 900px): 3-column grid + expanded Sidebar
- **SVG Icons** — custom green icons for all 6 features
- **Card Navigation** — each dashboard card navigates to its AI feature screen
- **Logout** — top-right logout button clears auth state and returns to Login
