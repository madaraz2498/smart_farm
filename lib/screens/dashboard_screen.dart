import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/navigation_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/auth_widgets.dart';
import 'feature_screens.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const _navItems = [
    _NavItem(icon: Icons.home_outlined,           label: 'Welcome',                 svg: 'assets/images/icons/welcome_icon.svg'),
    _NavItem(icon: Icons.local_florist_outlined,  label: 'Plant Disease Detection',  svg: 'assets/images/icons/plant_icon.svg'),
    _NavItem(icon: Icons.monitor_weight_outlined, label: 'Animal Weight Estimation', svg: 'assets/images/icons/animal_icon.svg'),
    _NavItem(icon: Icons.grass_outlined,          label: 'Crop Recommendation',      svg: 'assets/images/icons/crop_icon.svg'),
    _NavItem(icon: Icons.layers_outlined,         label: 'Soil Type Analysis',       svg: 'assets/images/icons/soil_icon.svg'),
    _NavItem(icon: Icons.apple_outlined,          label: 'Fruit Quality Analysis',   svg: 'assets/images/icons/fruit_icon.svg'),
    _NavItem(icon: Icons.chat_bubble_outline,     label: 'Smart Farm Chatbot',       svg: 'assets/images/icons/chat_icon.svg'),
    _NavItem(icon: Icons.bar_chart_outlined,      label: 'Reports',                  svg: 'assets/images/icons/reports_icon.svg'),
    _NavItem(icon: Icons.settings_outlined,       label: 'Settings',                 svg: 'assets/images/icons/settings_icon.svg'),
  ];

  static const _features = [
    _Feature(svg: 'assets/images/icons/plant_icon.svg',  title: 'Plant Disease Detection',  desc: 'Detect plant diseases early using AI image analysis.'),
    _Feature(svg: 'assets/images/icons/animal_icon.svg', title: 'Animal Weight Estimation', desc: 'Estimate animal weight accurately without physical scales.'),
    _Feature(svg: 'assets/images/icons/crop_icon.svg',   title: 'Crop Recommendation',      desc: 'Get the best crop suggestions based on soil and climate data.'),
    _Feature(svg: 'assets/images/icons/soil_icon.svg',   title: 'Soil Type Analysis',       desc: 'Analyze soil fertility and type using data or images.'),
    _Feature(svg: 'assets/images/icons/fruit_icon.svg',  title: 'Fruit Quality Analysis',   desc: 'Classify fruit quality and detect defects automatically.'),
    _Feature(svg: 'assets/images/icons/chat_icon.svg',   title: 'Smart Farm Chatbot',       desc: 'Ask questions and get instant farming advice.'),
  ];

  static Widget _screenFor(int idx) {
    switch (idx) {
      case 1: return const PlantDiseaseScreen();
      case 2: return const AnimalWeightScreen();
      case 3: return const CropRecommendationScreen();
      case 4: return const SoilAnalysisScreen();
      case 5: return const FruitQualityScreen();
      case 6: return const ChatbotScreen();
      case 7: return const ReportsScreen();
      case 8: return const SettingsScreen();
      default: return const SizedBox.shrink();
    }
  }

  void _go(BuildContext ctx, int idx) {
    ctx.read<NavigationProvider>().setIndex(idx);
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => _screenFor(idx)))
        .then((_) => ctx.read<NavigationProvider>().reset());
  }

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _NotificationDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final showSidebar = w > 700;
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      // Mobile: burger menu opens this drawer
      drawer: showSidebar
          ? null
          : _DrawerMenu(navItems: _navItems, onTap: (i) => _go(context, i)),
      body: Column(
        children: [
          _NavBar(
            userName: user?.name ?? 'Farmer',
            userRole: user?.role ?? '',
            showBurger: !showSidebar,
            onNotificationTap: () => _showNotifications(context),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Desktop only persistent sidebar
                if (showSidebar)
                  _Sidebar(navItems: _navItems, onTap: (i) => _go(context, i)),
                Expanded(
                  child: _MainContent(features: _features, screenWidth: w),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── NavBar ───────────────────────────────────────────────────────────────────

class _NavBar extends StatelessWidget {
  final String userName;
  final String userRole;
  final bool showBurger;
  final VoidCallback onNotificationTap;

  const _NavBar({
    required this.userName,
    required this.userRole,
    required this.showBurger,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.33)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 3, offset: const Offset(0, 1))],
      ),
      padding: EdgeInsets.only(left: showBurger ? 4 : 24, right: 24),
      child: Row(
        children: [
          // Burger menu button — mobile only
          if (showBurger)
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded, color: AppColors.textDark, size: 24),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          if (showBurger) const SizedBox(width: 4),
          // Logo + name
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3))],
            ),
            child: const Icon(Icons.eco_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Text('Smart Farm AI',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),

          const Spacer(),

          // Notification bell with red dot
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 22, color: AppColors.textDark),
                onPressed: onNotificationTap,
              ),
              Positioned(
                right: 8, top: 8,
                child: Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(color: AppColors.notifRed, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),

          // User avatar + name
          Container(
            width: 32, height: 32,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userName,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
              Text(userRole.toLowerCase(),
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// ─── Notification Dialog ──────────────────────────────────────────────────────

class _NotificationDialog extends StatelessWidget {
  const _NotificationDialog();

  static const _notifications = [
    _Notif(
      icon: Icons.warning_amber_rounded,
      color: Color(0xFFF59E0B),
      title: 'Soil moisture low',
      subtitle: 'Field A moisture dropped below 30%.',
      time: '2 min ago',
    ),
    _Notif(
      icon: Icons.local_florist_rounded,
      color: AppColors.primary,
      title: 'Disease risk detected',
      subtitle: 'Possible blight risk on tomato crops.',
      time: '1 hr ago',
    ),
    _Notif(
      icon: Icons.monitor_weight_outlined,
      color: Color(0xFF6366F1),
      title: 'Weight report ready',
      subtitle: 'Animal batch #12 weight analysis done.',
      time: '3 hr ago',
    ),
    _Notif(
      icon: Icons.cloud_outlined,
      color: Color(0xFF0EA5E9),
      title: 'Weather alert',
      subtitle: 'Heavy rain expected tomorrow morning.',
      time: 'Yesterday',
    ),
    _Notif(
      icon: Icons.check_circle_outline_rounded,
      color: AppColors.primary,
      title: 'Crop recommendation ready',
      subtitle: 'Best crops for your soil type are ready.',
      time: 'Yesterday',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_rounded, color: AppColors.primary, size: 22),
                  const SizedBox(width: 10),
                  const Text('Notifications',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const Spacer(),
                  // Unread badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.notifRed,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('5',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Notification list
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _notifications.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.border),
                itemBuilder: (_, i) {
                  final n = _notifications[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    leading: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: n.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(n.icon, color: n.color, size: 20),
                    ),
                    title: Text(n.title,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(n.subtitle,
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        const SizedBox(height: 4),
                        Text(n.time,
                            style: TextStyle(fontSize: 11, color: AppColors.textMuted.withOpacity(0.7))),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Mark all as read',
                    style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sidebar ──────────────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  final List<_NavItem> navItems;
  final void Function(int) onTap;

  const _Sidebar({required this.navItems, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (_, nav, __) => Container(
        width: 256,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(right: BorderSide(color: AppColors.border, width: 1.33)),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: List.generate(navItems.length, (i) {
            final item = navItems[i];
            final selected = nav.selectedIndex == i;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _SidebarTile(
                item: item,
                isSelected: selected,
                onTap: () {
                  if (i >= 1) {
                    onTap(i);
                  } else {
                    context.read<NavigationProvider>().setIndex(i);
                  }
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─── Mobile Drawer ────────────────────────────────────────────────────────────

class _DrawerMenu extends StatelessWidget {
  final List<_NavItem> navItems;
  final void Function(int) onTap;

  const _DrawerMenu({required this.navItems, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          // Header
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.eco_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Smart Farm AI',
                          style: TextStyle(
                              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(user?.name ?? '',
                          style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      Text(user?.role.toLowerCase() ?? '',
                          style: const TextStyle(color: Colors.white60, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Nav items
          Expanded(
            child: Consumer<NavigationProvider>(
              builder: (_, nav, __) => ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: List.generate(navItems.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: _SidebarTile(
                      item: navItems[i],
                      isSelected: nav.selectedIndex == i,
                      onTap: () {
                        Navigator.pop(context); // close drawer first
                        if (i >= 1) {
                          onTap(i);
                        } else {
                          context.read<NavigationProvider>().setIndex(i);
                        }
                      },
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Main Content ─────────────────────────────────────────────────────────────

class _MainContent extends StatelessWidget {
  final List<_Feature> features;
  final double screenWidth;

  const _MainContent({required this.features, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    final showSidebar = screenWidth > 700;
    final available = showSidebar ? screenWidth - 256 : screenWidth;
    final cols = available > 900 ? 3 : available > 500 ? 2 : 1;
    final user = context.watch<AuthProvider>().user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome, ${user?.name ?? 'Farmer'}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 6),
          const Text('Use AI to improve your farming decisions',
              style: TextStyle(fontSize: 15, color: AppColors.textMuted)),
          const SizedBox(height: 24),
          cols == 1
              ? Column(
            children: features
                .map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _FeatureCard(feature: f, fixedHeight: false),
            ))
                .toList(),
          )
              : LayoutBuilder(builder: (_, c) {
            final w = (c.maxWidth - (cols - 1) * 16) / cols;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: features
                  .map((f) => SizedBox(
                width: w,
                height: 192,
                child: _FeatureCard(feature: f, fixedHeight: true),
              ))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Sidebar Tile ─────────────────────────────────────────────────────────────

class _SidebarTile extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarTile({required this.item, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 3, offset: const Offset(0, 1))]
              : null,
        ),
        child: Row(
          children: [
            item.svg != null
                ? SvgPicture.asset(item.svg!, width: 20, height: 20,
                colorFilter: ColorFilter.mode(
                    isSelected ? Colors.white : AppColors.primary, BlendMode.srcIn))
                : Icon(item.icon, size: 20,
                color: isSelected ? Colors.white : AppColors.primary),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                item.label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: item.label.length > 20 ? 12.5 : 14,
                  color: isSelected ? Colors.white : AppColors.textDark,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  letterSpacing: item.label.length > 20 ? -0.3 : 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Feature Card (non-clickable) ────────────────────────────────────────────

class _FeatureCard extends StatelessWidget {
  final _Feature feature;
  final bool fixedHeight;

  const _FeatureCard({required this.feature, required this.fixedHeight});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 1)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: fixedHeight ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: SvgPicture.asset(feature.svg, width: 26, height: 26)),
          ),
          const SizedBox(height: 14),
          Text(feature.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 6),
          Text(feature.desc,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.5)),
        ],
      ),
    );
  }
}

// ─── Data classes ─────────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final String label;
  final String? svg;
  const _NavItem({required this.icon, required this.label, required this.svg});
}

class _Feature {
  final String svg;
  final String title;
  final String desc;
  const _Feature({required this.svg, required this.title, required this.desc});
}

class _Notif {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String time;
  const _Notif({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}