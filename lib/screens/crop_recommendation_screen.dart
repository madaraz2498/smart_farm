import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// CROP RECOMMENDATION SCREEN
// Layout:
//   White card: "Environmental Parameters" section header + form fields
//               (Temperature, Humidity, Rainfall, Soil Type dropdown)
//               + Recommend Crop button
//   White card: "Recommendation Result" with Recommended Crop (highlighted),
//               Expected Yield Level, explanation text
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Controller ───────────────────────────────────────────────────────────────

enum CropRecommendationStatus { idle, loading, result, error }

class CropResult {
  final String crop;
  final String yieldLevel;   // 'High', 'Medium', 'Low'
  final String explanation;
  const CropResult({
    required this.crop,
    required this.yieldLevel,
    required this.explanation,
  });
}

class CropRecommendationController extends ChangeNotifier {
  CropRecommendationStatus _status = CropRecommendationStatus.idle;
  CropResult?              _result;
  String?                  _errorMessage;
  String                   _selectedSoilType = 'Sandy';

  final temperatureCtrl = TextEditingController();
  final humidityCtrl    = TextEditingController();
  final rainfallCtrl    = TextEditingController();

  static const List<String> soilTypes = [
    'Sandy', 'Loamy', 'Clay', 'Silt', 'Peaty', 'Saline'
  ];

  CropRecommendationStatus get status          => _status;
  CropResult?              get result          => _result;
  String?                  get errorMessage    => _errorMessage;
  String                   get selectedSoilType => _selectedSoilType;

  void setSoilType(String t) { _selectedSoilType = t; notifyListeners(); }

  bool validate() =>
      temperatureCtrl.text.isNotEmpty &&
      humidityCtrl.text.isNotEmpty &&
      rainfallCtrl.text.isNotEmpty;

  // TODO: POST to YOUR_API/crop-recommend
  // Body: { temperature, humidity, rainfall, soil_type }
  // Response: { "crop": String, "yield_level": String, "explanation": String }
  Future<void> recommend() async {
    _status       = CropRecommendationStatus.loading;
    _result       = null;
    _errorMessage = null;
    notifyListeners();
    try {
      await Future.delayed(const Duration(seconds: 2));
      final temp     = temperatureCtrl.text;
      final humidity = humidityCtrl.text;
      final rainfall = rainfallCtrl.text;
      _result = CropResult(
        crop:       'Cotton',
        yieldLevel: 'Medium',
        explanation:
            'Based on the provided climate and soil conditions '
            '(Temperature: ${temp}°C, Humidity: $humidity%, '
            'Rainfall: ${rainfall}mm), Cotton is recommended with '
            'an expected medium yield potential.',
      );
      _status = CropRecommendationStatus.result;
    } catch (_) {
      _errorMessage = 'Failed to get recommendation. Please try again.';
      _status       = CropRecommendationStatus.error;
    }
    notifyListeners();
  }

  void reset() {
    _status       = CropRecommendationStatus.idle;
    _result       = null;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    temperatureCtrl.dispose();
    humidityCtrl.dispose();
    rainfallCtrl.dispose();
    super.dispose();
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class CropRecommendationScreen extends StatefulWidget {
  const CropRecommendationScreen({super.key});
  @override
  State<CropRecommendationScreen> createState() =>
      _CropRecommendationScreenState();
}

class _CropRecommendationScreenState extends State<CropRecommendationScreen> {
  final _ctrl = CropRecommendationController();
  String? _validationError;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _submit() {
    if (!_ctrl.validate()) {
      setState(() => _validationError =
          'Please fill in Temperature, Humidity, and Rainfall.');
      return;
    }
    setState(() => _validationError = null);
    _ctrl.recommend();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const FeatureAppBar(
        title:   'Crop Recommendation (ML)',
        svgPath: 'assets/images/icons/crop_icon.svg',
      ),
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) => _Body(
          ctrl:            _ctrl,
          onSubmit:        _submit,
          validationError: _validationError,
        ),
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final CropRecommendationController ctrl;
  final VoidCallback                 onSubmit;
  final String?                      validationError;

  const _Body({
    required this.ctrl,
    required this.onSubmit,
    this.validationError,
  });

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
              // Form card
              _FormCard(
                ctrl:            ctrl,
                onSubmit:        onSubmit,
                validationError: validationError,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Result card
              if (ctrl.status == CropRecommendationStatus.result &&
                  ctrl.result != null)
                _ResultCard(result: ctrl.result!),

              if (ctrl.status == CropRecommendationStatus.error &&
                  ctrl.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.xl),
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
  final CropRecommendationController ctrl;
  final VoidCallback                 onSubmit;
  final String?                      validationError;

  const _FormCard({
    required this.ctrl,
    required this.onSubmit,
    this.validationError,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

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
          // Section header
          Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color:        AppColors.primaryLight,
                borderRadius: AppRadius.radiusMd,
              ),
              child: const Icon(Icons.eco_outlined,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Text('Environmental Parameters',
                style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark)),
          ]),
          const SizedBox(height: AppSpacing.xl),

          // Temperature
          _FieldLabel('Temperature (°C)'),
          const SizedBox(height: AppSpacing.sm),
          _TextField(
              controller: ctrl.temperatureCtrl,
              hint:       '25',
              type:       TextInputType.number),
          const SizedBox(height: AppSpacing.lg),

          // Humidity
          _FieldLabel('Humidity (%)'),
          const SizedBox(height: AppSpacing.sm),
          _TextField(
              controller: ctrl.humidityCtrl,
              hint:       '65',
              type:       TextInputType.number),
          const SizedBox(height: AppSpacing.lg),

          // Rainfall
          _FieldLabel('Rainfall (mm)'),
          const SizedBox(height: AppSpacing.sm),
          _TextField(
              controller: ctrl.rainfallCtrl,
              hint:       '120',
              type:       TextInputType.number),
          const SizedBox(height: AppSpacing.lg),

          // Soil Type dropdown
          _FieldLabel('Soil Type'),
          const SizedBox(height: AppSpacing.sm),
          _SoilDropdown(ctrl: ctrl),
          const SizedBox(height: AppSpacing.xl),

          // Validation error
          if (validationError != null) ...[
            _ErrorBanner(validationError!),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: ctrl.status == CropRecommendationStatus.loading
                  ? null
                  : onSubmit,
              style: ElevatedButton.styleFrom(
                padding:         const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape:           RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusFull),
                elevation: 0,
              ),
              child: ctrl.status == CropRecommendationStatus.loading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Recommend Crop',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Soil dropdown ────────────────────────────────────────────────────────────

class _SoilDropdown extends StatelessWidget {
  final CropRecommendationController ctrl;
  const _SoilDropdown({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        AppColors.surfaceAlt,
        borderRadius: AppRadius.radiusMd,
        border:       Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value:     ctrl.selectedSoilType,
          isExpanded: true,
          icon:      const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textMuted),
          style:     const TextStyle(
              fontSize: 14, color: AppColors.textDark),
          dropdownColor: AppColors.surface,
          borderRadius:  BorderRadius.circular(12),
          items: CropRecommendationController.soilTypes
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (v) {
            if (v != null) ctrl.setSoilType(v);
          },
        ),
      ),
    );
  }
}

// ─── Result card ──────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  final CropResult result;
  const _ResultCard({required this.result});

  Color get _yieldColor {
    switch (result.yieldLevel) {
      case 'High':   return AppColors.primary;
      case 'Medium': return AppColors.warning;
      default:       return AppColors.error;
    }
  }

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
          Text('Recommendation Result',
              style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: AppSpacing.lg),

          // Recommended crop highlighted box
          Container(
            width:   double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color:        AppColors.primaryLight,
              borderRadius: AppRadius.radiusMd,
              border:       Border.all(
                  color: AppColors.primary.withOpacity(0.25)),
            ),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color:        AppColors.primary.withOpacity(0.15),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: const Icon(Icons.eco_outlined,
                    color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recommended Crop',
                      style: tt.bodySmall?.copyWith(
                          color: AppColors.primary)),
                  const SizedBox(height: 2),
                  Text(result.crop,
                      style: tt.titleMedium?.copyWith(
                        color:      AppColors.textDark,
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ),
            ]),
          ),
          const SizedBox(height: AppSpacing.md),

          // Expected Yield Level
          Container(
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
                  const TextSpan(
                      text: 'Expected Yield Level: ',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  TextSpan(
                      text: result.yieldLevel,
                      style: TextStyle(
                          color: _yieldColor,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Explanation text
          Container(
            width:   double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color:        AppColors.surface,
              borderRadius: AppRadius.radiusMd,
              border:       Border.all(color: AppColors.border),
            ),
            child: Text(result.explanation,
                style: tt.bodySmall?.copyWith(
                    color: AppColors.textMuted, height: 1.5)),
          ),
        ],
      ),
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
  final TextInputType         type;
  const _TextField(
      {required this.controller, required this.hint, required this.type});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller:  controller,
      keyboardType: type,
      style: const TextStyle(fontSize: 14, color: AppColors.textDark),
      decoration: InputDecoration(
        hintText:         hint,
        hintStyle: const TextStyle(
            fontSize: 14, color: AppColors.textDisabled),
        filled:           true,
        fillColor:        AppColors.surfaceAlt,
        contentPadding:   const EdgeInsets.symmetric(
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
