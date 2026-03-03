import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'This Month';
  final List<String> _periods = ['This Week', 'This Month', 'Last 3 Months', 'This Year'];

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Reports',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
        actions: [
          // Period selector
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPeriod,
                  isDense: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primary, size: 16),
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                  dropdownColor: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  items: _periods
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedPeriod = v!),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Summary cards ───────────────────────────────────────────
            _sectionTitle('Overview'),
            const SizedBox(height: 12),
            _buildSummaryRow(),
            const SizedBox(height: 24),

            // ── AI Usage chart ──────────────────────────────────────────
            _sectionTitle('AI Feature Usage'),
            const SizedBox(height: 12),
            _buildUsageChart(),
            const SizedBox(height: 24),

            // ── Recent activity ─────────────────────────────────────────
            _sectionTitle('Recent Activity'),
            const SizedBox(height: 12),
            _buildActivityList(),
            const SizedBox(height: 24),

            // ── Detection results ───────────────────────────────────────
            _sectionTitle('Detection Results Summary'),
            const SizedBox(height: 12),
            _buildDetectionResults(),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark));
  }

  // ── Summary row ────────────────────────────────────────────────────────────
  Widget _buildSummaryRow() {
    final cards = [
      _SummaryData(label: 'Total Scans', value: '248', icon: Icons.qr_code_scanner_rounded, color: AppColors.primary, change: '+12%'),
      _SummaryData(label: 'Diseases Found', value: '34', icon: Icons.bug_report_outlined, color: const Color(0xFFEF4444), change: '-5%'),
      _SummaryData(label: 'Crops Recommended', value: '89', icon: Icons.grass_outlined, color: const Color(0xFF6366F1), change: '+8%'),
      _SummaryData(label: 'Animals Weighed', value: '57', icon: Icons.monitor_weight_outlined, color: const Color(0xFFF59E0B), change: '+3%'),
    ];

    return LayoutBuilder(builder: (_, c) {
      final cols = c.maxWidth > 600 ? 4 : 2;
      final w = (c.maxWidth - (cols - 1) * 12) / cols;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: cards.map((d) => SizedBox(
          width: w,
          child: _SummaryCard(data: d),
        )).toList(),
      );
    });
  }

  // ── Bar chart (manual, no package) ────────────────────────────────────────
  Widget _buildUsageChart() {
    final bars = [
      _BarData(label: 'Plant', value: 0.85, count: 89, color: AppColors.primary),
      _BarData(label: 'Animal', value: 0.55, count: 57, color: const Color(0xFF6366F1)),
      _BarData(label: 'Crop', value: 0.72, count: 74, color: const Color(0xFFF59E0B)),
      _BarData(label: 'Soil', value: 0.40, count: 41, color: const Color(0xFF8B5CF6)),
      _BarData(label: 'Fruit', value: 0.65, count: 67, color: const Color(0xFFEC4899)),
      _BarData(label: 'Chat', value: 0.30, count: 31, color: const Color(0xFF0EA5E9)),
    ];

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Number of uses per feature',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: bars.map((b) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('${b.count}',
                            style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          height: 130 * b.value,
                          decoration: BoxDecoration(
                            color: b.color,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(b.label,
                            style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Recent activity list ───────────────────────────────────────────────────
  Widget _buildActivityList() {
    final items = [
      _ActivityData(icon: Icons.local_florist_rounded, color: AppColors.primary,
          title: 'Plant disease scan', subtitle: 'Tomato leaf — Blight detected', time: '10 min ago', status: 'Alert'),
      _ActivityData(icon: Icons.monitor_weight_outlined, color: const Color(0xFF6366F1),
          title: 'Animal weight estimation', subtitle: 'Cow batch #7 — Avg 412 kg', time: '1 hr ago', status: 'Done'),
      _ActivityData(icon: Icons.grass_outlined, color: const Color(0xFFF59E0B),
          title: 'Crop recommendation', subtitle: 'Sandy loam — Wheat suggested', time: '3 hr ago', status: 'Done'),
      _ActivityData(icon: Icons.apple_outlined, color: const Color(0xFFEC4899),
          title: 'Fruit quality check', subtitle: 'Mangoes — 78% Grade A', time: '5 hr ago', status: 'Done'),
      _ActivityData(icon: Icons.layers_outlined, color: const Color(0xFF8B5CF6),
          title: 'Soil analysis', subtitle: 'Field B — Clay loam, pH 6.8', time: 'Yesterday', status: 'Done'),
    ];

    return _Card(
      child: Column(
        children: items.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          return Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon, color: item.color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                        const SizedBox(height: 2),
                        Text(item.subtitle,
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: item.status == 'Alert'
                              ? const Color(0xFFFEF2F2)
                              : AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(item.status,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: item.status == 'Alert'
                                  ? const Color(0xFFEF4444)
                                  : AppColors.primary,
                            )),
                      ),
                      const SizedBox(height: 4),
                      Text(item.time,
                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
              if (i < items.length - 1) ...[
                const SizedBox(height: 12),
                Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 12),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Detection results doughnut-style ───────────────────────────────────────
  Widget _buildDetectionResults() {
    final results = [
      _ResultData(label: 'Healthy plants', percent: 72, color: AppColors.primary),
      _ResultData(label: 'Disease detected', percent: 18, color: const Color(0xFFEF4444)),
      _ResultData(label: 'Needs attention', percent: 10, color: const Color(0xFFF59E0B)),
    ];

    return _Card(
      child: Column(
        children: [
          const Text('Plant scan outcomes this period',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 16),
          ...results.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Container(
                              width: 10, height: 10,
                              decoration: BoxDecoration(color: r.color, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text(r.label,
                              style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
                        ]),
                        Text('${r.percent}%',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600, color: r.color)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: r.percent / 100,
                        minHeight: 8,
                        backgroundColor: r.color.withOpacity(0.12),
                        valueColor: AlwaysStoppedAnimation(r.color),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ─── Reusable card wrapper ────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }
}

// ─── Summary card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final _SummaryData data;
  const _SummaryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final isPositive = data.change.startsWith('+');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(data.value,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 2),
          Text(data.label,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 6),
          Row(children: [
            Icon(
              isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              size: 12,
              color: isPositive ? AppColors.primary : const Color(0xFFEF4444),
            ),
            const SizedBox(width: 2),
            Text(data.change,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? AppColors.primary : const Color(0xFFEF4444),
                )),
            const SizedBox(width: 4),
            const Text('vs last period',
                style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ]),
        ],
      ),
    );
  }
}

// ─── Data classes ─────────────────────────────────────────────────────────────

class _SummaryData {
  final String label, value, change;
  final IconData icon;
  final Color color;
  const _SummaryData(
      {required this.label, required this.value, required this.icon, required this.color, required this.change});
}

class _BarData {
  final String label;
  final double value;
  final int count;
  final Color color;
  const _BarData({required this.label, required this.value, required this.count, required this.color});
}

class _ActivityData {
  final IconData icon;
  final Color color;
  final String title, subtitle, time, status;
  const _ActivityData(
      {required this.icon, required this.color, required this.title,
       required this.subtitle, required this.time, required this.status});
}

class _ResultData {
  final String label;
  final int percent;
  final Color color;
  const _ResultData({required this.label, required this.percent, required this.color});
}
