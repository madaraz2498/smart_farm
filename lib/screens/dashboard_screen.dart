import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/navigation_provider.dart';
import '../utils/app_theme.dart';
import 'feature_screens.dart';
import 'login_screen.dart';
import '../widgets/auth_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const List<_NavItem> _navItems = [
    _NavItem(icon: Icons.home_outlined, label: 'Welcome', svgPath: null, screen: null),
    _NavItem(icon: Icons.local_florist_outlined, label: 'Plant Disease Detection', svgPath: 'assets/images/icons/plant_icon.svg', screen: null),
    _NavItem(icon: Icons.monitor_weight_outlined, label: 'Animal Weight Estimation', svgPath: 'assets/images/icons/animal_icon.svg', screen: null),
    _NavItem(icon: Icons.grass_outlined, label: 'Crop Recommendation', svgPath: 'assets/images/icons/crop_icon.svg', screen: null),
    _NavItem(icon: Icons.layers_outlined, label: 'Soil Type Analysis', svgPath: 'assets/images/icons/soil_icon.svg', screen: null),
    _NavItem(icon: Icons.apple_outlined, label: 'Fruit Quality Analysis', svgPath: 'assets/images/icons/fruit_icon.svg', screen: null),
    _NavItem(icon: Icons.chat_bubble_outline, label: 'Smart Farm Chatbot', svgPath: 'assets/images/icons/chat_icon.svg', screen: null),
    _NavItem(icon: Icons.bar_chart_outlined, label: 'Reports', svgPath: null, screen: null),
    _NavItem(icon: Icons.settings_outlined, label: 'Settings', svgPath: null, screen: null),
  ];

  static const List<_FeatureItem> _features = [
    _FeatureItem(svgPath: 'assets/images/icons/plant_icon.svg', title: 'Plant Disease Detection', description: 'Detect plant diseases early using AI image analysis.', navIndex: 1),
    _FeatureItem(svgPath: 'assets/images/icons/animal_icon.svg', title: 'Animal Weight Estimation', description: 'Estimate animal weight accurately without physical scales.', navIndex: 2),
    _FeatureItem(svgPath: 'assets/images/icons/crop_icon.svg', title: 'Crop Recommendation', description: 'Get the best crop suggestions based on soil and climate data.', navIndex: 3),
    _FeatureItem(svgPath: 'assets/images/icons/soil_icon.svg', title: 'Soil Type Analysis', description: 'Analyze soil fertility and type using data or images.', navIndex: 4),
    _FeatureItem(svgPath: 'assets/images/icons/fruit_icon.svg', title: 'Fruit Quality Analysis', description: 'Classify fruit quality and detect defects automatically.', navIndex: 5),
    _FeatureItem(svgPath: 'assets/images/icons/chat_icon.svg', title: 'Smart Farm Chatbot', description: 'Ask questions and get instant farming advice.', navIndex: 6),
  ];

  static Widget _screenForIndex(int index) {
    switch (index) {
      case 1: return const PlantDiseaseScreen();
      case 2: return const AnimalWeightScreen();
      case 3: return const CropRecommendationScreen();
      case 4: return const SoilAnalysisScreen();
      case 5: return const FruitQualityScreen();
      case 6: return const ChatbotScreen();
      default: return const SizedBox.shrink();
    }
  }

  void _navigateTo(BuildContext context, int navIndex) {
    context.read<NavigationProvider>().setIndex(navIndex);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _screenForIndex(navIndex)),
    ).then((_) => context.read<NavigationProvider>().reset());
  }

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final showSidebar = screenWidth > 600;
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: showSidebar ? null : _buildDrawer(context, user?.name ?? 'User', user?.role ?? ''),
      body: Column(
        children: [
          _buildNavBar(context, user?.name ?? 'User', user?.role ?? '', showSidebar),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showSidebar) _buildSidebar(context),
                Expanded(child: _buildMain(context, screenWidth)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: showSidebar ? null : _buildBottomNav(context),
    );
  }

  // ─── Top NavBar ───────────────────────────────────────────────────────────

  Widget _buildNavBar(BuildContext context, String name, String role, bool showSidebar) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.33)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 3, offset: const Offset(0, 1))],
      ),
      padding: EdgeInsets.symmetric(horizontal: showSidebar ? 32 : 16),
      child: Row(
        children: [
          if (!showSidebar)
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded, color: AppColors.textDark),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          // Logo + name
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3))],
                ),
                child: const Icon(Icons.eco_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              if (showSidebar)
                const Text('Smart Farm AI', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            ],
          ),

          const Expanded(
            child: Center(
              child: Text('Welcome', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textDark)),
            ),
          ),

          // Actions
          Row(
            children: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, size: 20, color: AppColors.textDark),
                    onPressed: () {},
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.notifRed, shape: BoxShape.circle)),
                  ),
                ],
              ),
              if (showSidebar) ...[
                const SizedBox(width: 4),
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
                    Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                    Text(role.toLowerCase(), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ],
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.textMuted),
                tooltip: 'Logout',
                onPressed: () => _logout(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Desktop Sidebar ──────────────────────────────────────────────────────

  Widget _buildSidebar(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (_, nav, __) => Container(
        width: 256,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(right: BorderSide(color: AppColors.border, width: 1.33)),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: List.generate(_navItems.length, (i) {
            final item = _navItems[i];
            final isSelected = nav.selectedIndex == i;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _SidebarTile(
                item: item,
                isSelected: isSelected,
                onTap: () {
                  if (i > 0 && i < 7) {
                    _navigateTo(context, i);
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

  // ─── Mobile Drawer ────────────────────────────────────────────────────────

  Widget _buildDrawer(BuildContext context, String name, String role) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Row(
              children: [
                const AppLogo(size: 48, iconSize: 28, borderRadius: 12),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Smart Farm AI', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(name, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      Text(role.toLowerCase(), style: const TextStyle(color: Colors.white60, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<NavigationProvider>(
              builder: (_, nav, __) => ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: List.generate(_navItems.length, (i) {
                  final item = _navItems[i];
                  final isSelected = nav.selectedIndex == i;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: _SidebarTile(
                      item: item,
                      isSelected: isSelected,
                      onTap: () {
                        Navigator.pop(context); // close drawer
                        if (i > 0 && i < 7) {
                          _navigateTo(context, i);
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

  // ─── Main Content ─────────────────────────────────────────────────────────

  Widget _buildMain(BuildContext context, double screenWidth) {
    final availableWidth = screenWidth > 600 ? screenWidth - 256 : screenWidth;
    final crossAxisCount = availableWidth > 900 ? 3 : availableWidth > 600 ? 2 : 1;

    final user = context.watch<AuthProvider>().user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, ${user?.name ?? 'Farmer'}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark),
          ),
          const SizedBox(height: 6),
          const Text(
            'Use AI to improve your farming decisions',
            style: TextStyle(fontSize: 15, color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),
          _buildGrid(context, crossAxisCount),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, int crossAxisCount) {
    if (crossAxisCount == 1) {
      return Column(
        children: _features
            .map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _FeatureCard(
                    feature: f,
                    fixedHeight: false,
                    onTap: () => _navigateTo(context, f.navIndex),
                  ),
                ))
            .toList(),
      );
    }

    return LayoutBuilder(
      builder: (_, constraints) {
        final w = (constraints.maxWidth - (crossAxisCount - 1) * 16) / crossAxisCount;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: _features
              .map((f) => SizedBox(
                    width: w,
                    height: 192,
                    child: _FeatureCard(
                      feature: f,
                      fixedHeight: true,
                      onTap: () => _navigateTo(context, f.navIndex),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }

  // ─── Bottom Nav (mobile) ──────────────────────────────────────────────────

  Widget _buildBottomNav(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (_, nav, __) {
        final idx = nav.selectedIndex < 4 ? nav.selectedIndex : 0;
        return BottomNavigationBar(
          currentIndex: idx,
          onTap: (i) {
            if (i == 0) {
              context.read<NavigationProvider>().reset();
            } else if (i == 1) {
              _navigateTo(context, 1); // Plant Disease
            } else if (i == 2) {
              _navigateTo(context, 2); // Animal Weight
            } else if (i == 3) {
              _navigateTo(context, 6); // Chatbot
            }
          },
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          backgroundColor: AppColors.surface,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/images/icons/plant_icon.svg', width: 22, height: 22,
                  colorFilter: ColorFilter.mode(idx == 1 ? AppColors.primary : AppColors.textMuted, BlendMode.srcIn)),
              label: 'Plant',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/images/icons/animal_icon.svg', width: 22, height: 22,
                  colorFilter: ColorFilter.mode(idx == 2 ? AppColors.primary : AppColors.textMuted, BlendMode.srcIn)),
              label: 'Animal',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/images/icons/chat_icon.svg', width: 22, height: 22,
                  colorFilter: ColorFilter.mode(idx == 3 ? AppColors.primary : AppColors.textMuted, BlendMode.srcIn)),
              label: 'Chat',
            ),
          ],
        );
      },
    );
  }
}

// ─── Sidebar Tile Widget ──────────────────────────────────────────────────────

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
            item.svgPath != null
                ? SvgPicture.asset(item.svgPath!, width: 20, height: 20,
                    colorFilter: ColorFilter.mode(isSelected ? Colors.white : AppColors.primary, BlendMode.srcIn))
                : Icon(item.icon, size: 20, color: isSelected ? Colors.white : AppColors.textDark),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: item.label.length > 20 ? 12.5 : 14,
                  color: isSelected ? Colors.white : AppColors.textDark,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  letterSpacing: item.label.length > 20 ? -0.3 : 0,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Feature Card Widget ──────────────────────────────────────────────────────

class _FeatureCard extends StatelessWidget {
  final _FeatureItem feature;
  final bool fixedHeight;
  final VoidCallback onTap;

  const _FeatureCard({required this.feature, required this.fixedHeight, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 1))],
          ),
          child: Padding(
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
                  child: Center(child: SvgPicture.asset(feature.svgPath, width: 26, height: 26)),
                ),
                const SizedBox(height: 14),
                Text(feature.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                const SizedBox(height: 6),
                Text(feature.description, style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Data Classes ─────────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final String label;
  final String? svgPath;
  final Widget? screen;
  const _NavItem({required this.icon, required this.label, required this.svgPath, required this.screen});
}

class _FeatureItem {
  final String svgPath;
  final String title;
  final String description;
  final int navIndex;
  const _FeatureItem({required this.svgPath, required this.title, required this.description, required this.navIndex});
}
