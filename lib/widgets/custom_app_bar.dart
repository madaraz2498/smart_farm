import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FeatureAppBar
//
// The standard AppBar used by every feature screen (Plant Disease, Animal
// Weight, Crop Recommendation, Soil Analysis, Fruit Quality, Chatbot).
//
// Usage:
//   @override
//   PreferredSizeWidget build(BuildContext context) => FeatureAppBar(
//         title:   'Animal Weight Estimation',
//         svgPath: 'assets/images/icons/animal_icon.svg',
//       );
//
//   Or inside Scaffold:
//   appBar: FeatureAppBar(
//     title:   'Plant Disease Detection',
//     svgPath: 'assets/images/icons/plant_icon.svg',
//     actions: [IconButton(...)],
//   ),
// ─────────────────────────────────────────────────────────────────────────────

class FeatureAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Screen title displayed in the AppBar.
  final String title;

  /// Path to the SVG icon shown in the leading logo-chip.
  final String svgPath;

  /// Optional extra actions on the trailing side.
  final List<Widget>? actions;

  /// Whether to show the back arrow. Defaults to true.
  final bool showBack;

  const FeatureAppBar({
    super.key,
    required this.title,
    required this.svgPath,
    this.actions,
    this.showBack = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return AppBar(
      // Leading: back button or nothing
      automaticallyImplyLeading: false,
      leading: showBack
          ? IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppColors.textDark,
              ),
            )
          : null,

      // Title: icon chip + text
      title: Row(
        children: [
          _IconChip(svgPath: svgPath, cs: cs),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: tt.titleLarge?.copyWith(
                color:      AppColors.textDark,
                fontWeight: FontWeight.w600,
                fontSize:   15,
              ),
            ),
          ),
        ],
      ),

      actions: actions,

      // Bottom 1-px divider
      bottom: const _BottomDivider(),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _IconChip extends StatelessWidget {
  final String svgPath;
  final ColorScheme cs;

  const _IconChip({required this.svgPath, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color:         cs.primaryContainer,
        borderRadius:  AppRadius.radiusSm,
      ),
      child: Center(
        child: SvgPicture.asset(svgPath, width: 18, height: 18),
      ),
    );
  }
}

class _BottomDivider extends StatelessWidget implements PreferredSizeWidget {
  const _BottomDivider();

  @override
  Size get preferredSize => const Size.fromHeight(1);

  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: AppColors.border);
}

// ─────────────────────────────────────────────────────────────────────────────
// DashboardNavBar
//
// The top navigation bar shown on the Dashboard / Welcome screen.
// Handles: logo+title, centered page title, notifications bell, theme
// toggle placeholder, and user avatar chip.
// ─────────────────────────────────────────────────────────────────────────────

class DashboardNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String userRole;
  final bool showBurger;
  final VoidCallback onNotificationTap;

  const DashboardNavBar({
    super.key,
    required this.userName,
    required this.userRole,
    required this.showBurger,
    required this.onNotificationTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1.33),
        ),
        boxShadow: AppShadows.sm,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // ── Burger (mobile) ──────────────────────────────────────────
          if (showBurger)
            Builder(
              builder: (ctx) => IconButton(
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                icon: const Icon(Icons.menu_rounded, color: AppColors.textDark, size: 22),
              ),
            ),

          // ── Logo + App name ──────────────────────────────────────────
          _LogoChip(cs: cs),
          const SizedBox(width: 10),
          if (!showBurger)
            Text(
              'Smart Farm AI',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textDark,
                  ),
            ),

          const Spacer(),

          // ── Notification bell ────────────────────────────────────────
          _NotifBell(onTap: onNotificationTap),
          const SizedBox(width: 4),

          // ── Theme toggle (placeholder) ───────────────────────────────
          const _ThemeToggle(),
          const SizedBox(width: 4),

          // ── User chip ────────────────────────────────────────────────
          _UserChip(name: userName, role: userRole, cs: cs),
        ],
      ),
    );
  }
}

class _LogoChip extends StatelessWidget {
  final ColorScheme cs;
  const _LogoChip({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color:        cs.primary,
        shape:        BoxShape.circle,
        boxShadow:    AppShadows.primaryGlow,
      ),
      child: const Icon(Icons.eco_rounded, color: Colors.white, size: 20),
    );
  }
}

class _NotifBell extends StatelessWidget {
  final VoidCallback onTap;
  const _NotifBell({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          onPressed: onTap,
          icon: const Icon(
            Icons.notifications_outlined,
            size: 22,
            color: AppColors.textDark,
          ),
        ),
        Positioned(
          right: 6, top: 6,
          child: Container(
            width: 8, height: 8,
            decoration: const BoxDecoration(
              color: AppColors.notifRed,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();
  @override
  Widget build(BuildContext context) {
    // TODO: wire up with a ThemeProvider for real dark-mode toggle
    return IconButton(
      onPressed: () {},
      icon: const Icon(Icons.wb_sunny_outlined, size: 20, color: AppColors.textDark),
    );
  }
}

class _UserChip extends StatelessWidget {
  final String name;
  final String role;
  final ColorScheme cs;
  const _UserChip({required this.name, required this.role, required this.cs});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
          child: const Icon(Icons.person_rounded, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: tt.labelMedium?.copyWith(color: AppColors.textDark)),
            Text(role, style: tt.labelSmall?.copyWith(color: AppColors.textMuted)),
          ],
        ),
      ],
    );
  }
}
