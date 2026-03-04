import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// SMART FARM AI — DESIGN TOKENS
// Single source of truth for every color, spacing, radius and shadow used
// across the app. No screen should reference a raw Color() literal directly.
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Color Palette ────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF4CAF50); // Signature green
  static const Color primaryDark = Color(0xFF388E3C); // Pressed / active state
  static const Color primaryLight = Color(0xFFE8F5E9); // Tinted backgrounds
  static const Color primaryMuted =
      Color(0xFFA5D6A7); // Disabled / muted accents

  // Secondary — warm amber used for warnings / highlights
  static const Color secondary = Color(0xFFF59E0B);
  static const Color secondaryLight = Color(0xFFFEF3C7);

  // Semantic
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color errorBorder = Color(0xFFFECACA);
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFF0FDF4);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color info = Color(0xFF0EA5E9);
  static const Color infoLight = Color(0xFFE0F2FE);

  // Notification badge
  static const Color notifRed = Color(0xFFFB2C36);

  // Neutrals
  static const Color background = Color(0xFFFAFBF7); // App scaffold bg
  static const Color surface = Colors.white; // Cards, inputs, navbar
  static const Color surfaceAlt = Color(0xFFF9FAFB); // Input fill
  static const Color border = Color(0x14000000); // 8% black
  static const Color borderStrong = Color(0x29000000); // 16% black
  static const Color divider = Color(0xFFE5E7EB);

  // Text
  static const Color textDark = Color(0xFF1F2937); // Primary text
  static const Color textBody = Color(0xFF374151); // Body text
  static const Color textMuted = Color(0xFF6B7280); // Secondary / hints
  static const Color textDisabled = Color(0xFF9CA3AF); // Placeholder
  static const Color textOnPrimary = Colors.white; // Text on green bg

  // Gradient stops used in result / header cards
  static const List<Color> primaryGradient = [
    Color(0xFF4CAF50),
    Color(0xFF2E7D32),
  ];
}

// ─── Typography ───────────────────────────────────────────────────────────────

class AppTextStyles {
  AppTextStyles._();

  // Display – used sparingly for hero numbers (e.g. weight result)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
    letterSpacing: -1.0,
    height: 1.1,
  );
  static const TextStyle displayMedium = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
    letterSpacing: -0.5,
    height: 1.2,
  );

  // Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    letterSpacing: -0.3,
    height: 1.3,
  );
  static const TextStyle h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    letterSpacing: -0.2,
    height: 1.3,
  );
  static const TextStyle h3 = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    height: 1.4,
  );
  static const TextStyle h4 = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    height: 1.4,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textBody,
    height: 1.6,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textBody,
    height: 1.6,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.5,
  );

  // Labels & captions
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    letterSpacing: 0.1,
  );
  static const TextStyle labelMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );
  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.4,
  );

  // Navbar / AppBar title
  static const TextStyle navTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  // Button text
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    letterSpacing: 0.2,
  );
  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    letterSpacing: 0.1,
  );
}

// ─── Spacing ──────────────────────────────────────────────────────────────────

class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
}

// ─── Border Radius ────────────────────────────────────────────────────────────

class AppRadius {
  AppRadius._();

  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double full = 999.0; // pill shape

  static BorderRadius get radiusSm => BorderRadius.circular(sm);

  static BorderRadius get radiusMd => BorderRadius.circular(md);

  static BorderRadius get radiusLg => BorderRadius.circular(lg);

  static BorderRadius get radiusXl => BorderRadius.circular(xl);

  static BorderRadius get radiusFull => BorderRadius.circular(full);
}

// ─── Shadows ──────────────────────────────────────────────────────────────────

class AppShadows {
  AppShadows._();

  static List<BoxShadow> get sm => [
        BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1)),
      ];

  static List<BoxShadow> get md => [
        BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2)),
        BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 3,
            offset: const Offset(0, 1)),
      ];

  static List<BoxShadow> get lg => [
        BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, 6)),
        BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2)),
      ];

  static List<BoxShadow> get primaryGlow => [
        BoxShadow(
            color: AppColors.primary.withOpacity(0.30),
            blurRadius: 12,
            offset: const Offset(0, 4)),
      ];
}

// ═══════════════════════════════════════════════════════════════════════════════
// APP THEME
// Compose all tokens into a single ThemeData consumed by MaterialApp.
// ═══════════════════════════════════════════════════════════════════════════════

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',

        // ── Color Scheme ──────────────────────────────────────────────────
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.primary,
          onPrimary: AppColors.textOnPrimary,
          primaryContainer: AppColors.primaryLight,
          onPrimaryContainer: AppColors.primaryDark,
          secondary: AppColors.secondary,
          onSecondary: Colors.white,
          secondaryContainer: AppColors.secondaryLight,
          onSecondaryContainer: Color(0xFF78350F),
          error: AppColors.error,
          onError: Colors.white,
          errorContainer: AppColors.errorLight,
          onErrorContainer: AppColors.error,
          surface: AppColors.surface,
          onSurface: AppColors.textDark,
          surfaceContainerHighest: AppColors.surfaceAlt,
          outline: AppColors.border,
        ),

        scaffoldBackgroundColor: AppColors.background,

        // ── Typography ────────────────────────────────────────────────────
        textTheme: const TextTheme(
          displayLarge: AppTextStyles.displayLarge,
          displayMedium: AppTextStyles.displayMedium,
          headlineLarge: AppTextStyles.h1,
          headlineMedium: AppTextStyles.h2,
          headlineSmall: AppTextStyles.h3,
          titleLarge: AppTextStyles.h4,
          titleMedium: AppTextStyles.labelLarge,
          titleSmall: AppTextStyles.labelMedium,
          bodyLarge: AppTextStyles.bodyLarge,
          bodyMedium: AppTextStyles.bodyMedium,
          bodySmall: AppTextStyles.bodySmall,
          labelLarge: AppTextStyles.labelLarge,
          labelMedium: AppTextStyles.labelMedium,
          labelSmall: AppTextStyles.labelSmall,
        ),

        // ── AppBar ────────────────────────────────────────────────────────
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textDark,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          iconTheme: IconThemeData(color: AppColors.textDark, size: 22),
          titleTextStyle: AppTextStyles.navTitle,
          toolbarHeight: 64,
        ),

        // ── ElevatedButton ────────────────────────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            disabledBackgroundColor: AppColors.primaryMuted,
            disabledForegroundColor: Colors.white70,
            elevation: 0,
            shadowColor: Colors.transparent,
            minimumSize: const Size(double.infinity, 52),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.full), // 30 ≈ pill
            ),
            textStyle: AppTextStyles.buttonLarge,
          ),
        ),

        // ── OutlinedButton ────────────────────────────────────────────────
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            minimumSize: const Size(double.infinity, 52),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            textStyle:
                AppTextStyles.buttonLarge.copyWith(color: AppColors.primary),
          ),
        ),

        // ── TextButton ────────────────────────────────────────────────────
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle:
                AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
          ),
        ),

        // ── Card ──────────────────────────────────────────────────────────
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusLg,
            side: const BorderSide(color: AppColors.border),
          ),
        ),

        // ── Input Decoration ──────────────────────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceAlt,
          hintStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textDisabled),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: AppRadius.radiusFull,
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusFull,
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusFull,
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusFull,
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusFull,
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
        ),

        // ── Divider ───────────────────────────────────────────────────────
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 1,
        ),

        // ── Bottom Navigation ─────────────────────────────────────────────
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),

        // ── Checkbox ──────────────────────────────────────────────────────
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? AppColors.primary
                  : Colors.transparent),
          checkColor: WidgetStateProperty.all(Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),

        // ── Switch ────────────────────────────────────────────────────────
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? AppColors.primary
                  : Colors.grey.shade400),
          trackColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? AppColors.primary.withOpacity(0.35)
                  : Colors.grey.shade200),
        ),

        // ── Progress Indicator ────────────────────────────────────────────
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
          linearTrackColor: AppColors.primaryLight,
          circularTrackColor: AppColors.primaryLight,
        ),

        // ── Chip ──────────────────────────────────────────────────────────
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surface,
          selectedColor: AppColors.primary,
          labelStyle: AppTextStyles.labelMedium,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusFull),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),

        // ── Dialog ────────────────────────────────────────────────────────
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surface,
          elevation: 16,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusXl),
        ),

        // ── SnackBar ──────────────────────────────────────────────────────
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.textDark,
          contentTextStyle:
              AppTextStyles.bodySmall.copyWith(color: Colors.white),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
          behavior: SnackBarBehavior.floating,
        ),
      );
}

// ─── TextTheme extension ──────────────────────────────────────────────────────
// Adds a non-deprecated `.caption` getter so screens can call `tt.caption`
// instead of the removed M3 accessor.

extension AppTextThemeX on TextTheme {
  TextStyle? get caption => AppTextStyles.caption.copyWith();
}
