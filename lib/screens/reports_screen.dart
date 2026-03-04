import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// REPORTS SCREEN
// Layout (matches screenshot):
//   "Reports" heading + subtitle  |  "Export All" green button
//   3 stat cards: Total Reports / This Month / vs Last Month
//   List of report rows, each:
//     green doc icon  |  title + subtitle + date + type badge + Completed badge
//     "Download" full-width button below
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Data model ───────────────────────────────────────────────────────────────

class _ReportItem {
  final String title;
  final String subtitle;
  final String date;
  final String type;       // badge label
  const _ReportItem({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.type,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  static const _stats = [
    _Stat(value: '24', label: 'Total Reports',  icon: Icons.description_outlined),
    _Stat(value: '6',  label: 'This Month',     icon: Icons.calendar_today_outlined),
    _Stat(value: '+25%', label: 'vs Last Month', icon: Icons.trending_up_rounded),
  ];

  static const _reports = [
    _ReportItem(
      title:    'Plant Disease Analysis Report',
      subtitle: '45 images analyzed, 3 diseases detected',
      date:     'December 10, 2024',
      type:     'AI Analysis',
    ),
    _ReportItem(
      title:    'Livestock Weight Monitoring',
      subtitle: '156 animals tracked, avg weight: 425kg',
      date:     'December 8, 2024',
      type:     'Computer Vision',
    ),
    _ReportItem(
      title:    'Crop Recommendation Summary',
      subtitle: '3 fields analyzed, recommendations provided',
      date:     'December 5, 2024',
      type:     'Machine Learning',
    ),
    _ReportItem(
      title:    'Soil Analysis Report',
      subtitle: 'Fertility levels assessed for all zones',
      date:     'December 3, 2024',
      type:     'AI Analysis',
    ),
    _ReportItem(
      title:    'Fruit Quality Grading',
      subtitle: '320 fruits graded, 78% Grade A quality',
      date:     'November 28, 2024',
      type:     'Computer Vision',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const FeatureAppBar(
        title:   'Reports',
        svgPath: 'assets/images/icons/plant_icon.svg',
        showBack: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xxxl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Page heading row ──────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Reports',
                              style: tt.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark)),
                          const SizedBox(height: 4),
                          Text(
                            'Access and download all AI-generated reports and analyses',
                            style: tt.bodySmall
                                ?.copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download_rounded, size: 16),
                      label: const Text('Export All',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.radiusMd),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── 3 stat cards ──────────────────────────────────────
                LayoutBuilder(builder: (_, c) {
                  final cols = c.maxWidth > 500 ? 3 : 1;
                  final w = (c.maxWidth - (cols - 1) * AppSpacing.md) / cols;
                  return Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: _stats.map((s) => SizedBox(
                      width: w,
                      child: _StatCard(stat: s),
                    )).toList(),
                  );
                }),
                const SizedBox(height: AppSpacing.xl),

                // ── Report list ───────────────────────────────────────
                ..._reports.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _ReportCard(report: r),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Stat card ────────────────────────────────────────────────────────────────

class _Stat {
  final String value, label;
  final IconData icon;
  const _Stat({required this.value, required this.label, required this.icon});
}

class _StatCard extends StatelessWidget {
  final _Stat stat;
  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: AppRadius.radiusLg,
        border:       Border.all(color: AppColors.border),
        boxShadow:    AppShadows.sm,
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color:        AppColors.primaryLight,
            borderRadius: AppRadius.radiusMd,
          ),
          child: Icon(stat.icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(stat.value,
                style: tt.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            Text(stat.label,
                style: tt.bodySmall?.copyWith(
                    color: AppColors.textMuted)),
          ],
        ),
      ]),
    );
  }
}

// ─── Report card ──────────────────────────────────────────────────────────────

class _ReportCard extends StatelessWidget {
  final _ReportItem report;
  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: AppRadius.radiusLg,
        border:       Border.all(color: AppColors.border),
        boxShadow:    AppShadows.sm,
      ),
      child: Column(
        children: [
          // Top row: icon + text + badges
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doc icon
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color:        AppColors.primaryLight,
                    borderRadius: AppRadius.radiusMd,
                  ),
                  child: const Icon(Icons.description_outlined,
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(report.title,
                          style: tt.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark)),
                      const SizedBox(height: 4),
                      Text(report.subtitle,
                          style: tt.bodySmall?.copyWith(
                              color: AppColors.textMuted)),
                      const SizedBox(height: AppSpacing.sm),
                      // Date + type badge + completed badge
                      Wrap(
                        spacing:    AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          // Calendar + date
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.calendar_today_outlined,
                                size: 12, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(report.date,
                                style: tt.bodySmall?.copyWith(
                                    color: AppColors.textMuted)),
                          ]),
                          // Type badge (grey)
                          _Badge(
                              label: report.type,
                              bgColor: const Color(0xFFF3F4F6),
                              textColor: AppColors.textMuted),
                          // Completed badge (green)
                          _Badge(
                              label: 'Completed',
                              bgColor: AppColors.primaryLight,
                              textColor: AppColors.primary),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, color: AppColors.border),

          // Download button
          InkWell(
            onTap:         () {},
            borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.download_outlined,
                      size: 16, color: AppColors.textMuted),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Download',
                      style: tt.bodyMedium?.copyWith(
                          color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Badge ────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color  bgColor, textColor;
  const _Badge(
      {required this.label,
      required this.bgColor,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color:        bgColor,
        borderRadius: AppRadius.radiusFull,
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: textColor)),
    );
  }
}
