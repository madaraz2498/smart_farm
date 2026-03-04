import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FeatureCard
//
// The card shown in the Welcome/Dashboard grid. Currently non-tappable
// (displays only); set [onTap] to make it navigate.
//
// Usage — non-clickable (display only):
//   FeatureCard(
//     svgPath:     'assets/images/icons/plant_icon.svg',
//     title:       'Plant Disease Detection',
//     description: 'Detect plant diseases early using AI image analysis.',
//   )
//
// Usage — clickable:
//   FeatureCard(
//     svgPath:     'assets/images/icons/animal_icon.svg',
//     title:       'Animal Weight Estimation',
//     description: 'Estimate weight accurately without physical scales.',
//     onTap:       () => Navigator.push(context, ...),
//   )
// ─────────────────────────────────────────────────────────────────────────────

class FeatureCard extends StatelessWidget {
  final String svgPath;
  final String title;
  final String description;

  /// When provided the card becomes tappable (InkWell ripple + arrow icon).
  final VoidCallback? onTap;

  /// Fixed height mode: set true when rendering inside a Wrap with SizedBox.
  final bool fixedHeight;

  const FeatureCard({
    super.key,
    required this.svgPath,
    required this.title,
    required this.description,
    this.onTap,
    this.fixedHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final card = Container(
      decoration: BoxDecoration(
        color:         cs.surface,
        borderRadius:  AppRadius.radiusLg,
        border:        Border.all(color: AppColors.border),
        boxShadow:     AppShadows.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: fixedHeight ? MainAxisSize.max : MainAxisSize.min,
        children: [
          // Icon chip
          _IconChip(svgPath: svgPath, cs: cs),
          const SizedBox(height: AppSpacing.lg),

          // Title row
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: cs.primary),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Description
          Text(
            description,
            style: tt.bodySmall,
            maxLines: fixedHeight ? 2 : null,
            overflow: fixedHeight ? TextOverflow.ellipsis : null,
          ),
        ],
      ),
    );

    if (onTap == null) return card;

    // Tappable variant
    return Material(
      color:        Colors.transparent,
      borderRadius: AppRadius.radiusLg,
      child: InkWell(
        onTap:        onTap,
        borderRadius: AppRadius.radiusLg,
        splashColor:  cs.primary.withOpacity(0.08),
        child: card,
      ),
    );
  }
}

// ─── Icon chip ────────────────────────────────────────────────────────────────

class _IconChip extends StatelessWidget {
  final String svgPath;
  final ColorScheme cs;

  const _IconChip({required this.svgPath, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52, height: 52,
      decoration: BoxDecoration(
        color:         cs.primaryContainer,
        borderRadius:  AppRadius.radiusMd,
      ),
      child: Center(
        child: SvgPicture.asset(svgPath, width: 26, height: 26),
      ),
    );
  }
}
