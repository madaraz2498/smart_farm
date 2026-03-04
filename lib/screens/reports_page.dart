import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════════
//  ReportsPage
//
//  Layout:
//    ┌─────────────────────────────────────────────────────┐
//    │  Reports                          [Export All ↓]    │
//    │  Access and download all AI-generated analyses      │
//    ├────────────┬────────────┬────────────────────────────┤
//    │ 24 Total   │ 6 This Mo  │ +25% vs Last Month        │
//    ├────────────┴────────────┴────────────────────────────┤
//    │  ReportTile (icon | title + subtitle + date | badge │
//    │              | Download button)                      │
//    │  ─────────────────────────────────────────────────── │
//    │  ReportTile …                                        │
//    └─────────────────────────────────────────────────────┘
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Palette (no external theme dependency) ───────────────────────────────────
const _kGreen      = Color(0xFF4CAF50);
const _kGreenLight = Color(0xFFE8F5E9);
const _kBg         = Color(0xFFFAFBF7);
const _kSurface    = Colors.white;
const _kTextDark   = Color(0xFF1F2937);
const _kTextMuted  = Color(0xFF6B7280);
const _kBorder     = Color(0xFFE5E7EB);

// ─── Data model ───────────────────────────────────────────────────────────────

enum _AnalysisType { plantDisease, animalWeight, cropRecommend, soilAnalysis, fruitQuality, chatbot }

class ReportData {
  final String        title;
  final String        subtitle;
  final String        date;
  final _AnalysisType type;
  final bool          completed;

  const ReportData({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.type,
    this.completed = true,
  });
}

extension _AnalysisTypeX on _AnalysisType {
  IconData get icon {
    switch (this) {
      case _AnalysisType.plantDisease:   return Icons.local_florist_outlined;
      case _AnalysisType.animalWeight:   return Icons.monitor_weight_outlined;
      case _AnalysisType.cropRecommend:  return Icons.grass_outlined;
      case _AnalysisType.soilAnalysis:   return Icons.layers_outlined;
      case _AnalysisType.fruitQuality:   return Icons.apple_outlined;
      case _AnalysisType.chatbot:        return Icons.chat_bubble_outline;
    }
  }

  String get label {
    switch (this) {
      case _AnalysisType.plantDisease:   return 'AI Analysis';
      case _AnalysisType.animalWeight:   return 'Computer Vision';
      case _AnalysisType.cropRecommend:  return 'Machine Learning';
      case _AnalysisType.soilAnalysis:   return 'AI Analysis';
      case _AnalysisType.fruitQuality:   return 'Computer Vision';
      case _AnalysisType.chatbot:        return 'NLP';
    }
  }
}

// ─── Mock data ────────────────────────────────────────────────────────────────

const _mockReports = <ReportData>[
  ReportData(title: 'Plant Disease Analysis Report',    subtitle: '45 images analyzed · 3 diseases detected',         date: 'Dec 10, 2024', type: _AnalysisType.plantDisease),
  ReportData(title: 'Livestock Weight Monitoring',      subtitle: '156 animals tracked · avg weight 425 kg',           date: 'Dec 8, 2024',  type: _AnalysisType.animalWeight),
  ReportData(title: 'Crop Recommendation Summary',      subtitle: '3 fields analyzed · optimal crops suggested',       date: 'Dec 5, 2024',  type: _AnalysisType.cropRecommend),
  ReportData(title: 'Soil Type Analysis Report',        subtitle: 'Fertility levels assessed for all zones',           date: 'Dec 3, 2024',  type: _AnalysisType.soilAnalysis),
  ReportData(title: 'Fruit Quality — Batch 12',         subtitle: '320 fruits graded · 78 % Grade A quality',         date: 'Nov 28, 2024', type: _AnalysisType.fruitQuality),
  ReportData(title: 'Chatbot Interaction Summary',      subtitle: '234 queries answered · 96 % satisfaction rate',    date: 'Nov 25, 2024', type: _AnalysisType.chatbot),
];

// ═══════════════════════════════════════════════════════════════════════════════
//  ReportsPage
// ═══════════════════════════════════════════════════════════════════════════════

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  // Stats shown in the 3-card top row
  static const _stats = [
    _StatData(Icons.description_outlined,       '24',   'Total Reports'),
    _StatData(Icons.calendar_month_outlined,     '6',    'This Month'),
    _StatData(Icons.trending_up_rounded,         '+25%', 'vs Last Month'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kBg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Heading row ─────────────────────────────────────────
                _HeadingRow(),
                const SizedBox(height: 20),

                // ── 3 summary stat cards ─────────────────────────────────
                LayoutBuilder(builder: (_, c) {
                  final cols = c.maxWidth > 500 ? 3 : 1;
                  final gap  = 12.0;
                  final w    = (c.maxWidth - gap * (cols - 1)) / cols;
                  return Wrap(
                    spacing: gap, runSpacing: gap,
                    children: _stats
                        .map((s) => SizedBox(width: w, child: _StatCard(data: s)))
                        .toList(),
                  );
                }),
                const SizedBox(height: 20),

                // ── Report list ──────────────────────────────────────────
                ListView.separated(
                  shrinkWrap:       true,
                  physics:          const NeverScrollableScrollPhysics(),
                  itemCount:        _mockReports.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder:      (_, i)  => ReportTile(report: _mockReports[i]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Heading row ──────────────────────────────────────────────────────────────

class _HeadingRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Reports',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _kTextDark)),
            SizedBox(height: 4),
            Text('Access and download all AI-generated analyses',
                style: TextStyle(fontSize: 13, color: _kTextMuted)),
          ]),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () {},
          icon:  const Icon(Icons.download_rounded, size: 16),
          label: const Text('Export All',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _kGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
        ),
      ],
    );
  }
}

// ─── Stat card ────────────────────────────────────────────────────────────────

class _StatData {
  final IconData icon;
  final String   value;
  final String   label;
  const _StatData(this.icon, this.value, this.label);
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:        _kSurface,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: _kBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Row(children: [
        // Icon chip
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color:        _kGreenLight,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(data.icon, color: _kGreen, size: 20),
        ),
        const SizedBox(width: 14),

        // Value + label
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(data.value,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w700, color: _kTextDark)),
            const SizedBox(height: 1),
            Text(data.label,
                style: const TextStyle(fontSize: 12, color: _kTextMuted)),
          ],
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  ReportTile  —  used in ListView.builder
// ═══════════════════════════════════════════════════════════════════════════════

class ReportTile extends StatelessWidget {
  final ReportData report;
  const ReportTile({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        _kSurface,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: _kBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Column(children: [
        // ── Main content row ───────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Analysis-type icon chip
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color:        _kGreenLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(report.type.icon, color: _kGreen, size: 22),
            ),
            const SizedBox(width: 14),

            // Text block
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(report.title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _kTextDark)),
                const SizedBox(height: 4),

                // Subtitle
                Text(report.subtitle,
                    style: const TextStyle(fontSize: 12, color: _kTextMuted)),
                const SizedBox(height: 10),

                // Date + badges
                Wrap(
                  spacing: 8, runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Date
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 11, color: _kTextMuted),
                      const SizedBox(width: 3),
                      Text(report.date,
                          style: const TextStyle(fontSize: 11, color: _kTextMuted)),
                    ]),

                    // Analysis type badge (grey)
                    _Badge(
                      label:     report.type.label,
                      bgColor:   const Color(0xFFF3F4F6),
                      textColor: _kTextMuted,
                    ),

                    // "Completed" badge (green) — shown when completed
                    if (report.completed)
                      const _Badge(
                        label:     'Completed',
                        bgColor:   _kGreenLight,
                        textColor: _kGreen,
                      ),
                  ],
                ),
              ],
            )),
          ]),
        ),

        // ── Divider + action row ───────────────────────────────────────
        const Divider(height: 1, thickness: 1, color: _kBorder),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(children: [
            // View button
            _ActionButton(
              icon:  Icons.visibility_outlined,
              label: 'View',
              onTap: () {},
            ),

            // Separator
            Container(
              width: 1, height: 18,
              color: _kBorder,
              margin: const EdgeInsets.symmetric(horizontal: 6),
            ),

            // Download button
            _ActionButton(
              icon:  Icons.download_outlined,
              label: 'Download',
              onTap: () {},
            ),
          ]),
        ),
      ]),
    );
  }
}

// ─── Badge ────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color  bgColor;
  final Color  textColor;
  const _Badge({required this.label, required this.bgColor, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color:        bgColor,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize:   11,
              fontWeight: FontWeight.w500,
              color:      textColor)),
    );
  }
}

// ─── Action button (bottom row) ───────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon:  Icon(icon, size: 14, color: _kTextMuted),
      label: Text(label,
          style: const TextStyle(fontSize: 13, color: _kTextMuted)),
      style: TextButton.styleFrom(
        padding:       const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        minimumSize:   Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
