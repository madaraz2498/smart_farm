import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// FRUIT QUALITY ANALYSIS SCREEN
// Layout:
//   Page heading + subtitle
//   White card: apple icon / image preview / Choose Image + Analyze Fruit
//   White card: "Analysis Results" with Quality Grade (highlighted), Ripeness,
//               Defect Detection rows
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Controller ───────────────────────────────────────────────────────────────

enum FruitQualityStatus { idle, loading, result, error }

class FruitResult {
  final String grade;        // 'A', 'B', 'C'
  final String gradeLabel;   // 'Premium quality - Ready for market'
  final String ripeness;
  final String defects;
  const FruitResult({
    required this.grade,
    required this.gradeLabel,
    required this.ripeness,
    required this.defects,
  });
}

class FruitQualityController extends ChangeNotifier {
  FruitQualityStatus _status = FruitQualityStatus.idle;
  String?            _imagePath;
  FruitResult?       _result;
  String?            _errorMessage;

  FruitQualityStatus get status       => _status;
  String?            get imagePath    => _imagePath;
  FruitResult?       get result       => _result;
  String?            get errorMessage => _errorMessage;

  // TODO: POST multipart to YOUR_API/fruit-quality
  // Response: { "grade": "A", "grade_label": String, "ripeness": String,
  //             "defects": String }
  Future<void> analyze(String path) async {
    _imagePath    = path;
    _status       = FruitQualityStatus.loading;
    _result       = null;
    _errorMessage = null;
    notifyListeners();
    try {
      await Future.delayed(const Duration(seconds: 2));
      _result = const FruitResult(
        grade:      'A',
        gradeLabel: 'Premium quality - Ready for market',
        ripeness:   'Ripe',
        defects:    'Minor surface blemishes',
      );
      _status = FruitQualityStatus.result;
    } catch (_) {
      _errorMessage = 'Analysis failed. Please try again.';
      _status       = FruitQualityStatus.error;
    }
    notifyListeners();
  }

  void reset() {
    _status       = FruitQualityStatus.idle;
    _imagePath    = null;
    _result       = null;
    _errorMessage = null;
    notifyListeners();
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class FruitQualityScreen extends StatefulWidget {
  const FruitQualityScreen({super.key});
  @override
  State<FruitQualityScreen> createState() => _FruitQualityScreenState();
}

class _FruitQualityScreenState extends State<FruitQualityScreen> {
  final _ctrl = FruitQualityController();
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _pickImage() => _ctrl.analyze('mock_path');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const FeatureAppBar(
        title:   'Fruit Quality Analysis',
        svgPath: 'assets/images/icons/fruit_icon.svg',
      ),
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) => _Body(ctrl: _ctrl, onPick: _pickImage),
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final FruitQualityController ctrl;
  final VoidCallback onPick;
  const _Body({required this.ctrl, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xxxl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PageHeading(
                title:    'Fruit Quality Analysis',
                subtitle: 'Upload fruit image for computer vision-based quality grading',
              ),
              const SizedBox(height: AppSpacing.xl),

              _ImageCard(
                imagePath:    ctrl.imagePath,
                isLoading:    ctrl.status == FruitQualityStatus.loading,
                onPick:       onPick,
                analyzeLabel: 'Analyze Fruit',
              ),
              const SizedBox(height: AppSpacing.xl),

              if (ctrl.status == FruitQualityStatus.result &&
                  ctrl.result != null) ...[
                _AnalysisResultCard(result: ctrl.result!),
                const SizedBox(height: AppSpacing.xl),
              ],

              if (ctrl.status == FruitQualityStatus.error &&
                  ctrl.errorMessage != null)
                _ErrorBanner(ctrl.errorMessage!),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Page heading ─────────────────────────────────────────────────────────────

class _PageHeading extends StatelessWidget {
  final String title, subtitle;
  const _PageHeading({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.w600, color: AppColors.textDark)),
        const SizedBox(height: 4),
        Text(subtitle,
            style: tt.bodySmall?.copyWith(color: AppColors.textMuted)),
      ],
    );
  }
}

// ─── Image card ───────────────────────────────────────────────────────────────

class _ImageCard extends StatelessWidget {
  final String?      imagePath;
  final bool         isLoading;
  final VoidCallback onPick;
  final String       analyzeLabel;

  const _ImageCard({
    required this.imagePath,
    required this.isLoading,
    required this.onPick,
    required this.analyzeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: AppRadius.radiusLg,
        border:       Border.all(color: AppColors.border),
        boxShadow:    AppShadows.sm,
      ),
      child: Column(
        children: [
          // Apple icon chip
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color:        AppColors.primaryLight,
              borderRadius: AppRadius.radiusMd,
            ),
            child: const Icon(Icons.apple_outlined,
                color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: AppSpacing.lg),

          ClipRRect(
            borderRadius: AppRadius.radiusMd,
            child: isLoading
                ? Container(
                    width: double.infinity, height: 190,
                    color: AppColors.surfaceAlt,
                    child: const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary)))
                : imagePath != null
                    ? Image.asset(imagePath!,
                        width: double.infinity, height: 190,
                        fit:   BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder())
                    : _placeholder(),
          ),
          const SizedBox(height: AppSpacing.xl),

          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onPick,
                style: OutlinedButton.styleFrom(
                  padding:         const EdgeInsets.symmetric(vertical: 14),
                  side:            const BorderSide(color: AppColors.primary),
                  shape:           RoundedRectangleBorder(
                      borderRadius: AppRadius.radiusFull),
                  backgroundColor: AppColors.primaryLight,
                ),
                child: const Text('Choose Image',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ElevatedButton(
                onPressed: onPick,
                style: ElevatedButton.styleFrom(
                  padding:         const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape:           RoundedRectangleBorder(
                      borderRadius: AppRadius.radiusFull),
                  elevation: 0,
                ),
                child: Text(analyzeLabel,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        width: double.infinity, height: 190, color: AppColors.surfaceAlt,
        child: const Icon(Icons.image_outlined,
            color: AppColors.textDisabled, size: 52));
}

// ─── Analysis result card ─────────────────────────────────────────────────────

class _AnalysisResultCard extends StatelessWidget {
  final FruitResult result;
  const _AnalysisResultCard({required this.result});

  Color get _gradeColor {
    switch (result.grade) {
      case 'A': return AppColors.primary;
      case 'B': return AppColors.warning;
      default:  return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt    = Theme.of(context).textTheme;
    final color = _gradeColor;

    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: AppRadius.radiusLg,
        border:       Border.all(color: AppColors.border),
        boxShadow:    AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Analysis Results',
              style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: AppSpacing.lg),

          // Quality Grade highlighted box
          Container(
            width:   double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color:        color.withOpacity(0.08),
              borderRadius: AppRadius.radiusMd,
              border:       Border.all(color: color.withOpacity(0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quality Grade',
                    style: tt.bodySmall?.copyWith(
                        color: AppColors.textMuted)),
                const SizedBox(height: 4),
                Text('Grade ${result.grade}',
                    style: tt.titleLarge?.copyWith(
                      color:      color,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 2),
                Text(result.gradeLabel,
                    style: tt.bodySmall?.copyWith(
                        color: AppColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Ripeness Level
          _InfoRow(label: 'Ripeness Level', value: result.ripeness),
          const SizedBox(height: AppSpacing.md),

          // Defect Detection
          _InfoRow(label: 'Defect Detection', value: result.defects),
        ],
      ),
    );
  }
}

// ─── Info row ─────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: AppRadius.radiusMd,
        border:       Border.all(color: AppColors.border),
      ),
      child: RichText(
        text: TextSpan(
          style: tt.bodyMedium?.copyWith(color: AppColors.textDark),
          children: [
            TextSpan(
                text: '$label: ',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

// ─── Error banner ─────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color:        AppColors.errorLight,
        borderRadius: AppRadius.radiusMd,
        border:       Border.all(color: AppColors.errorBorder),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline, size: 16, color: AppColors.error),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(message,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.error)),
        ),
      ]),
    );
  }
}
