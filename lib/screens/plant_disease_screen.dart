import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// PLANT DISEASE DETECTION SCREEN
// Layout:
//   Page heading + subtitle
//   White card: leaf icon / image preview / Choose Image + Analyze Image
//   White card: "Analysis Result" with Status badge row + Confidence bar
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Controller ───────────────────────────────────────────────────────────────

enum PlantScanStatus { idle, loading, result, error }

class PlantDiseaseResult {
  final String  status;     // e.g. "Healthy Plant" or disease name
  final bool    isHealthy;
  final double  confidence; // 0.0 – 1.0
  const PlantDiseaseResult({
    required this.status,
    required this.isHealthy,
    required this.confidence,
  });
}

class PlantDiseaseController extends ChangeNotifier {
  PlantScanStatus     _status = PlantScanStatus.idle;
  String?             _imagePath;
  PlantDiseaseResult? _result;
  String?             _errorMessage;

  PlantScanStatus     get status       => _status;
  String?             get imagePath    => _imagePath;
  PlantDiseaseResult? get result       => _result;
  String?             get errorMessage => _errorMessage;

  // TODO: POST multipart to YOUR_API/plant-disease
  // Response: { "status": String, "is_healthy": bool, "confidence": double }
  Future<void> analyzeImage(String path) async {
    _imagePath    = path;
    _status       = PlantScanStatus.loading;
    _result       = null;
    _errorMessage = null;
    notifyListeners();
    try {
      await Future.delayed(const Duration(seconds: 2));
      _result = const PlantDiseaseResult(
        status:     'Healthy Plant',
        isHealthy:  true,
        confidence: 0.95,
      );
      _status = PlantScanStatus.result;
    } catch (_) {
      _errorMessage = 'Analysis failed. Please try again.';
      _status       = PlantScanStatus.error;
    }
    notifyListeners();
  }

  void reset() {
    _status       = PlantScanStatus.idle;
    _imagePath    = null;
    _result       = null;
    _errorMessage = null;
    notifyListeners();
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class PlantDiseaseScreen extends StatefulWidget {
  const PlantDiseaseScreen({super.key});
  @override
  State<PlantDiseaseScreen> createState() => _PlantDiseaseScreenState();
}

class _PlantDiseaseScreenState extends State<PlantDiseaseScreen> {
  final _ctrl = PlantDiseaseController();
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _pickImage() => _ctrl.analyzeImage('mock_path');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const FeatureAppBar(
        title:   'Plant Disease Detection (CNN)',
        svgPath: 'assets/images/icons/plant_icon.svg',
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
  final PlantDiseaseController ctrl;
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
                title:    'Plant Disease Detection',
                subtitle: 'Upload a plant leaf image for AI-powered disease diagnosis using CNN',
              ),
              const SizedBox(height: AppSpacing.xl),

              _ImageCard(
                imagePath: ctrl.imagePath,
                isLoading: ctrl.status == PlantScanStatus.loading,
                onPick:    onPick,
                iconData:  Icons.eco_outlined,
                analyzeLabel: 'Analyze Image',
              ),
              const SizedBox(height: AppSpacing.xl),

              if (ctrl.status == PlantScanStatus.result &&
                  ctrl.result != null) ...[
                _AnalysisResultCard(result: ctrl.result!),
                const SizedBox(height: AppSpacing.xl),
              ],

              if (ctrl.status == PlantScanStatus.error &&
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

// ─── Image card (shared pattern) ─────────────────────────────────────────────

class _ImageCard extends StatelessWidget {
  final String?      imagePath;
  final bool         isLoading;
  final VoidCallback onPick;
  final IconData     iconData;
  final String       analyzeLabel;

  const _ImageCard({
    required this.imagePath,
    required this.isLoading,
    required this.onPick,
    required this.iconData,
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
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color:        AppColors.primaryLight,
              borderRadius: AppRadius.radiusMd,
            ),
            child: Icon(iconData, color: AppColors.primary, size: 28),
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
  final PlantDiseaseResult result;
  const _AnalysisResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final tt    = Theme.of(context).textTheme;
    final color = result.isHealthy ? AppColors.primary : AppColors.error;
    final bgCol = result.isHealthy ? AppColors.primaryLight : AppColors.errorLight;
    final borderCol = result.isHealthy
        ? AppColors.primary.withOpacity(0.25)
        : AppColors.errorBorder;

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
          Text('Analysis Result',
              style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: AppSpacing.lg),

          // Status badge row
          Container(
            width:   double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color:        bgCol,
              borderRadius: AppRadius.radiusMd,
              border:       Border.all(color: borderCol),
            ),
            child: Row(children: [
              Icon(result.isHealthy
                  ? Icons.check_circle_outline
                  : Icons.warning_amber_outlined,
                  color: color, size: 20),
              const SizedBox(width: AppSpacing.sm),
              RichText(
                text: TextSpan(
                  style: tt.bodyMedium,
                  children: [
                    TextSpan(
                        text: 'Status: ',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark)),
                    TextSpan(
                        text: result.status,
                        style: TextStyle(
                            color: color, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ]),
          ),
          const SizedBox(height: AppSpacing.md),

          // Confidence
          Container(
            width:   double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color:        AppColors.surface,
              borderRadius: AppRadius.radiusMd,
              border:       Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: tt.bodyMedium?.copyWith(color: AppColors.textDark),
                    children: [
                      const TextSpan(
                          text: 'Confidence: ',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(
                          text:
                              '${(result.confidence * 100).toStringAsFixed(0)}%'),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: AppRadius.radiusFull,
                  child: LinearProgressIndicator(
                    value:           result.confidence,
                    minHeight:       8,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
          ),
        ],
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
