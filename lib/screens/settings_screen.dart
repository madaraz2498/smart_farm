import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Toggles
  bool _notifDisease    = true;
  bool _notifWeather    = true;
  bool _notifReports    = false;
  bool _darkMode        = false;
  bool _autoScan        = true;
  bool _biometric       = false;
  String _language      = 'English';
  String _units         = 'Metric (kg, °C)';

  final List<String> _languages = ['English', 'Arabic', 'French'];
  final List<String> _unitSystems = ['Metric (kg, °C)', 'Imperial (lb, °F)'];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textDark),
        ),
        title: const Text('Settings',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Profile card ─────────────────────────────────────────
              _buildProfileCard(user?.name ?? 'Farmer', user?.email ?? '', user?.role ?? ''),
              const SizedBox(height: 24),

              // ── Notifications ────────────────────────────────────────
              _sectionTitle('Notifications'),
              const SizedBox(height: 10),
              _SettingsCard(children: [
                _ToggleTile(
                  icon: Icons.bug_report_outlined,
                  color: const Color(0xFFEF4444),
                  title: 'Disease Alerts',
                  subtitle: 'Get notified when diseases are detected',
                  value: _notifDisease,
                  onChanged: (v) => setState(() => _notifDisease = v),
                ),
                _divider(),
                _ToggleTile(
                  icon: Icons.cloud_outlined,
                  color: const Color(0xFF0EA5E9),
                  title: 'Weather Alerts',
                  subtitle: 'Receive weather warnings for your farm',
                  value: _notifWeather,
                  onChanged: (v) => setState(() => _notifWeather = v),
                ),
                _divider(),
                _ToggleTile(
                  icon: Icons.bar_chart_outlined,
                  color: const Color(0xFF6366F1),
                  title: 'Weekly Reports',
                  subtitle: 'Get a summary every week',
                  value: _notifReports,
                  onChanged: (v) => setState(() => _notifReports = v),
                ),
              ]),
              const SizedBox(height: 20),

              // ── Preferences ──────────────────────────────────────────
              _sectionTitle('Preferences'),
              const SizedBox(height: 10),
              _SettingsCard(children: [
                _DropdownTile(
                  icon: Icons.language_rounded,
                  color: AppColors.primary,
                  title: 'Language',
                  value: _language,
                  items: _languages,
                  onChanged: (v) => setState(() => _language = v!),
                ),
                _divider(),
                _DropdownTile(
                  icon: Icons.straighten_rounded,
                  color: const Color(0xFFF59E0B),
                  title: 'Units',
                  value: _units,
                  items: _unitSystems,
                  onChanged: (v) => setState(() => _units = v!),
                ),
                _divider(),
                _ToggleTile(
                  icon: Icons.dark_mode_outlined,
                  color: const Color(0xFF6366F1),
                  title: 'Dark Mode',
                  subtitle: 'Switch to dark theme',
                  value: _darkMode,
                  onChanged: (v) => setState(() => _darkMode = v),
                ),
                _divider(),
                _ToggleTile(
                  icon: Icons.qr_code_scanner_rounded,
                  color: AppColors.primary,
                  title: 'Auto Scan',
                  subtitle: 'Automatically start scan when image is loaded',
                  value: _autoScan,
                  onChanged: (v) => setState(() => _autoScan = v),
                ),
              ]),
              const SizedBox(height: 20),

              // ── Security ─────────────────────────────────────────────
              _sectionTitle('Security'),
              const SizedBox(height: 10),
              _SettingsCard(children: [
                _ToggleTile(
                  icon: Icons.fingerprint_rounded,
                  color: const Color(0xFF0EA5E9),
                  title: 'Biometric Login',
                  subtitle: 'Use fingerprint or face ID to sign in',
                  value: _biometric,
                  onChanged: (v) => setState(() => _biometric = v),
                ),
                _divider(),
                _ActionTile(
                  icon: Icons.lock_outline_rounded,
                  color: const Color(0xFF8B5CF6),
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                  onTap: () => _showChangePasswordDialog(context),
                ),
              ]),
              const SizedBox(height: 20),

              // ── About ────────────────────────────────────────────────
              _sectionTitle('About'),
              const SizedBox(height: 10),
              _SettingsCard(children: [
                _ActionTile(
                  icon: Icons.info_outline_rounded,
                  color: AppColors.primary,
                  title: 'App Version',
                  subtitle: 'Smart Farm AI v1.0.0',
                  onTap: null,
                ),
                _divider(),
                _ActionTile(
                  icon: Icons.description_outlined,
                  color: const Color(0xFF6366F1),
                  title: 'Terms of Service',
                  subtitle: 'Read our terms and conditions',
                  onTap: () {},
                ),
                _divider(),
                _ActionTile(
                  icon: Icons.privacy_tip_outlined,
                  color: const Color(0xFF0EA5E9),
                  title: 'Privacy Policy',
                  subtitle: 'How we handle your data',
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 28),

              // ── Logout button ─────────────────────────────────────────
              _buildLogoutButton(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Profile card ───────────────────────────────────────────────────────────
  Widget _buildProfileCard(String name, String email, String role) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64, height: 64,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 34),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text(email,
                    style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(role,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ),
              ],
            ),
          ),
          // Edit button
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  // ── Logout button ──────────────────────────────────────────────────────────
  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout_rounded, size: 18, color: Color(0xFFEF4444)),
        label: const Text('Sign Out',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFEF4444))),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: const Color(0xFFFEF2F2),
        ),
      ),
    );
  }

  // ── Logout confirmation dialog ─────────────────────────────────────────────
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 22),
            SizedBox(width: 10),
            Text('Sign Out',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          ],
        ),
        content: const Text(
          'Are you sure you want to sign out of Smart Farm AI?',
          style: TextStyle(fontSize: 14, color: AppColors.textMuted, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w500)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ── Change password dialog ────────────────────────────────────────────────
  void _showChangePasswordDialog(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Change Password',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogField(currentCtrl, 'Current password', obscure: true),
            const SizedBox(height: 12),
            _dialogField(newCtrl, 'New password', obscure: true),
            const SizedBox(height: 12),
            _dialogField(confirmCtrl, 'Confirm new password', obscure: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Update', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(TextEditingController c, String hint, {bool obscure = false}) {
    return TextField(
      controller: c,
      obscureText: obscure,
      style: const TextStyle(fontSize: 14, color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark));

  Widget _divider() => Divider(height: 1, color: AppColors.border);
}

// ─── Settings card wrapper ────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
      ),
      child: Column(children: children),
    );
  }
}

// ─── Toggle tile ──────────────────────────────────────────────────────────────

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon, required this.color, required this.title,
    this.subtitle, required this.value, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                if (subtitle != null)
                  Text(subtitle!,
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

// ─── Dropdown tile ────────────────────────────────────────────────────────────

class _DropdownTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownTile({
    required this.icon, required this.color, required this.title,
    required this.value, required this.items, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isDense: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted, size: 18),
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
              dropdownColor: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Action tile ──────────────────────────────────────────────────────────────

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon, required this.color, required this.title,
    required this.subtitle, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
