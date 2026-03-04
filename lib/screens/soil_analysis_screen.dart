import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// SOIL TYPE ANALYSIS SCREEN
// Layout:
//   White card: "Manual Soil Properties Input" header + form fields
//               (pH, Moisture, Nitrogen, Phosphorus, Potassium)
//               + Analyze Soil Properties button
//   Two side-by-side result cards: Soil Type | Fertility Level
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Controller ───────────────────────────────────────────────────────────────

enum SoilAnalysisStatus { idle, loading, result, error }

class SoilResult {
  final String soilType;
  final String fertilityLevel; // 'High', 'Moderate', 'Low'
  const SoilResult({required this.soilType, required this.fertilityLevel});
}

class SoilAnalysisController extends ChangeNotifier {
  SoilAnalysisStatus _status = SoilAnalysisStatus.idle;
  SoilResult?        _result;
  String?            _errorMessage;

  final phCtrl         = TextEditingController();
  final moistureCtrl   = TextEditingController();
  final nitrogenCtrl   = TextEditingController();
  final phosphorusCtrl = TextEditingController();
  final potassiumCtrl  = TextEditingController();

  SoilAnalysisStatus get status       => _status;
  SoilResult?        get result       => _result;
  String?            get errorMessage => _errorMessage;

  bool validate() => phCtrl.text.isNotEmpty;

  // TODO: POST to YOUR_API/soil-manual
  // Body: { ph, moisture, nitrogen, phosphorus, potassium }
  // Response: { "soil_type": String, "fertility_level": String }
  Future<void> analyze() async {
    if (!validate()) {
      _errorMessage = 'Please enter at least the pH value.';
      notifyListeners();
      return;
    }
    _status       = SoilAnalysisStatus.loading;
    _result       = null;
    _errorMessage = null;
    notifyListeners();
    try {
      await Future.delayed(const Duration(seconds: 2));
      _result = const SoilResult(soilType: 'Sandy', fertilityLevel: 'Low');
      _status = SoilAnalysisStatus.result;
    } catch (_) {
      _errorMessage = 'Analysis failed. Please try again.';
      _status       = SoilAnalysisStatus.error;
    }
    notifyListeners();
  }

  void reset() {
    _status       = SoilAnalysisStatus.idle;
    _result       = null;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final c in [
      phCtrl, moistureCtrl, nitrogenCtrl, phosphorusCtrl, potassiumCtrl
    ]) c.dispose();
    super.dispose();
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class SoilAnalysisScreen extends StatefulWidget {
  const SoilAnalysisScreen({super.key});
  @override
  State<SoilAnalysisScreen> createState() => _SoilAnalysisScreenState();
}

class _SoilAnalysisScreenState extends State<SoilAnalysisScreen> {
  final _ctrl = SoilAnalysisController();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const FeatureAppBar(
        title:   'Soil Type Analysis',
        svgPath: 'assets/images/icons/soil_icon.svg',
      ),
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) => _Body(ctrl: _ctrl),
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final SoilAnalysisController ctrl;
  const _Body({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xxxl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page heading
              Text('Soil Type Analysis',
                  style: tt.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark)),
              const SizedBox(height: 4),
              Text('Analyze soil properties using AI by entering the soil data below',
                  style: tt.bodySmall?.copyWith(color: AppColors.textMuted)),
              const SizedBox(height: AppSpacing.xl),

              // Form card
              _FormCard(ctrl: ctrl),
              const SizedBox(height: AppSpacing.xl),

              // Result row
              if (ctrl.status == SoilAnalysisStatus.result &&
                  ctrl.result != null)
                _ResultRow(result: ctrl.result!),

              if (ctrl.status == SoilAnalysisStatus.error &&
                  ctrl.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.sm),
                _ErrorBanner(ctrl.errorMessage!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Form card ────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final SoilAnalysisController ctrl;
  const _FormCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

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
          // Header
          Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color:        AppColors.primaryLight,
                borderRadius: AppRadius.radiusMd,
              ),
              child: const Icon(Icons.straighten_outlined,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Text('Manual Soil Properties Input',
                style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark)),
          ]),
          const SizedBox(height: AppSpacing.xl),

          _FieldLabel('Soil pH'),
          const SizedBox(height: AppSpacing.sm),
          _TextField(controller: ctrl.phCtrl, hint: '6.5'),
          const SizedBox(height: AppSpacing.lg),

          _FieldLabel('Moisture Level (%)'),
          const SizedBox(height: AppSpacing.sm),
          _TextField(controller: ctrl.moistureCtrl, hint: '48'),
          const SizedBox(height: AppSpacing.lg),

          _FieldLabel('Nitrogen (N)'),
          const SizedBox(height: AppSpacing.sm),
          _TextField(controller: ctrl.nitrogenCtrl, hint: '20'),
          const SizedBox(height: AppSpacing.lg),

          _FieldLabel('Phosphorus (P)'),
          const SizedBox(height: AppSpacing.sm),
          _TextField(controller: ctrl.phosphorusCtrl, hint: '30'),
          const SizedBox(height: AppSpacing.lg),

          _FieldLabel('Potassium (K)'),
          const SizedBox(height: AppSpacing.sm),
          _TextField(controller: ctrl.potassiumCtrl, hint: '25'),
          const SizedBox(height: AppSpacing.xl),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: ctrl.status == SoilAnalysisStatus.loading
                  ? null
                  : ctrl.analyze,
              style: ElevatedButton.styleFrom(
                padding:         const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape:           RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusFull),
                elevation: 0,
              ),
              child: ctrl.status == SoilAnalysisStatus.loading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Analyze Soil Properties',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Result row (two cards side by side) ─────────────────────────────────────

class _ResultRow extends StatelessWidget {
  final SoilResult result;
  const _ResultRow({required this.result});

  Color get _fertilityColor {
    switch (result.fertilityLevel) {
      case 'High':     return AppColors.primary;
      case 'Moderate': return AppColors.warning;
      default:         return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt            = Theme.of(context).textTheme;
    final fertilityColor = _fertilityColor;

    return Row(
      children: [
        // Soil Type card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color:        AppColors.surface,
              borderRadius: AppRadius.radiusLg,
              border:       Border.all(color: AppColors.border),
              boxShadow:    AppShadows.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color:        AppColors.primaryLight,
                      borderRadius: AppRadius.radiusSm,
                    ),
                    child: const Icon(Icons.straighten_outlined,
                        color: AppColors.primary, size: 16),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Soil Type',
                      style: tt.bodySmall?.copyWith(
                          color: AppColors.textMuted)),
                ]),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width:   double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color:        AppColors.primaryLight,
                    borderRadius: AppRadius.radiusMd,
                    border:       Border.all(
                        color: AppColors.primary.withOpacity(0.25)),
                  ),
                  child: Center(
                    child: Text(result.soilType,
                        style: tt.titleSmall?.copyWith(
                            color:      AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),

        // Fertility Level card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color:        AppColors.surface,
              borderRadius: AppRadius.radiusLg,
              border:       Border.all(color: AppColors.border),
              boxShadow:    AppShadows.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color:        AppColors.primaryLight,
                      borderRadius: AppRadius.radiusSm,
                    ),
                    child: const Icon(Icons.straighten_outlined,
                        color: AppColors.primary, size: 16),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Fertility Level',
                      style: tt.bodySmall?.copyWith(
                          color: AppColors.textMuted)),
                ]),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width:   double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color:        fertilityColor.withOpacity(0.08),
                    borderRadius: AppRadius.radiusMd,
                    border:       Border.all(
                        color: fertilityColor.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(result.fertilityLevel,
                        style: tt.titleSmall?.copyWith(
                            color:      fertilityColor,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: Theme.of(context)
          .textTheme
          .bodyMedium
          ?.copyWith(color: AppColors.textDark));
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String                hint;
  const _TextField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller:   controller,
      keyboardType: TextInputType.number,
      style:        const TextStyle(
          fontSize: 14, color: AppColors.textDark),
      decoration: InputDecoration(
        hintText:   hint,
        hintStyle:  const TextStyle(
            fontSize: 14, color: AppColors.textDisabled),
        filled:     true,
        fillColor:  AppColors.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: AppRadius.radiusMd,
            borderSide:   const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusMd,
            borderSide:   const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusMd,
            borderSide:   const BorderSide(
                color: AppColors.primary, width: 1.5)),
      ),
    );
  }
}

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
