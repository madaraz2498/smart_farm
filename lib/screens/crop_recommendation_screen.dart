import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/app_theme.dart';

// ─── Controller ───────────────────────────────────────────────────────────────

enum CropRecommendationStatus { idle, loading, result, error }

class CropRecommendationController extends ChangeNotifier {
  CropRecommendationStatus _status = CropRecommendationStatus.idle;
  List<_CropResult>? _results;
  String? _errorMessage;

  // Form fields
  final temperatureCtrl = TextEditingController();
  final humidityCtrl    = TextEditingController();
  final phCtrl          = TextEditingController();
  final rainfallCtrl    = TextEditingController();
  final nitrogenCtrl    = TextEditingController();
  final phosphorusCtrl  = TextEditingController();
  final potassiumCtrl   = TextEditingController();

  String _selectedSoilType = 'Loamy';
  final soilTypes = ['Sandy', 'Loamy', 'Clay', 'Silt', 'Peaty', 'Saline'];

  CropRecommendationStatus get status       => _status;
  List<_CropResult>?       get results      => _results;
  String?                  get errorMessage => _errorMessage;
  String                   get selectedSoilType => _selectedSoilType;

  void setSoilType(String type) {
    _selectedSoilType = type;
    notifyListeners();
  }

  bool validate() {
    return temperatureCtrl.text.isNotEmpty &&
        humidityCtrl.text.isNotEmpty &&
        phCtrl.text.isNotEmpty &&
        rainfallCtrl.text.isNotEmpty;
  }

  /// TODO: Replace mock with real API call (POST form data)
  Future<void> getRecommendation() async {
    if (!validate()) return;
    _status       = CropRecommendationStatus.loading;
    _results      = null;
    _errorMessage = null;
    notifyListeners();

    try {
      // ── TODO: Replace with real API call ──────────────────────────────
      // final response = await http.post(Uri.parse('YOUR_API_URL/crop-recommend'),
      //   body: {
      //     'temperature': temperatureCtrl.text,
      //     'humidity': humidityCtrl.text,
      //     'ph': phCtrl.text,
      //     'rainfall': rainfallCtrl.text,
      //     'nitrogen': nitrogenCtrl.text,
      //     'phosphorus': phosphorusCtrl.text,
      //     'potassium': potassiumCtrl.text,
      //     'soil_type': _selectedSoilType,
      //   },
      // );
      // final body = jsonDecode(response.body);
      // _results = (body['recommendations'] as List).map((r) =>
      //   _CropResult(name: r['crop'], suitability: r['score'].toDouble(), reason: r['reason'])
      // ).toList();
      // ─────────────────────────────────────────────────────────────────

      await Future.delayed(const Duration(seconds: 2));
      _results = [
        _CropResult(name: 'Wheat',   suitability: 0.94, reason: 'Ideal temperature and rainfall match'),
        _CropResult(name: 'Barley',  suitability: 0.87, reason: 'Good soil pH compatibility'),
        _CropResult(name: 'Lentils', suitability: 0.78, reason: 'Suitable humidity levels'),
      ];
      _status = CropRecommendationStatus.result;
    } catch (e) {
      _errorMessage = 'Failed to get recommendation. Please try again.';
      _status       = CropRecommendationStatus.error;
    }
    notifyListeners();
  }

  void reset() {
    _status       = CropRecommendationStatus.idle;
    _results      = null;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    temperatureCtrl.dispose();
    humidityCtrl.dispose();
    phCtrl.dispose();
    rainfallCtrl.dispose();
    nitrogenCtrl.dispose();
    phosphorusCtrl.dispose();
    potassiumCtrl.dispose();
    super.dispose();
  }
}

class _CropResult {
  final String name;
  final double suitability;
  final String reason;
  const _CropResult({required this.name, required this.suitability, required this.reason});
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class CropRecommendationScreen extends StatefulWidget {
  const CropRecommendationScreen({super.key});

  @override
  State<CropRecommendationScreen> createState() => _CropRecommendationScreenState();
}

class _CropRecommendationScreenState extends State<CropRecommendationScreen> {
  final _controller = CropRecommendationController();
  String? _validationError;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_controller.validate()) {
      setState(() => _validationError = 'Please fill in at least Temperature, Humidity, pH, and Rainfall.');
      return;
    }
    setState(() => _validationError = null);
    _controller.getRecommendation();
  }

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
        title: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
              child: Center(child: SvgPicture.asset('assets/images/icons/crop_icon.svg', width: 18, height: 18)),
            ),
            const SizedBox(width: 10),
            const Text('Crop Recommendation',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  if (_controller.status != CropRecommendationStatus.result) ...[
                    // ── Soil type ─────────────────────────────────────
                    _SectionLabel('Soil Type'),
                    const SizedBox(height: 10),
                    _SoilTypeSelector(
                      types: _controller.soilTypes,
                      selected: _controller.selectedSoilType,
                      onSelect: _controller.setSoilType,
                    ),
                    const SizedBox(height: 20),

                    // ── Required fields ───────────────────────────────
                    _SectionLabel('Climate & Soil Data'),
                    const SizedBox(height: 4),
                    const Text('* Required fields',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    const SizedBox(height: 12),

                    Row(children: [
                      Expanded(child: _FormField(
                        controller: _controller.temperatureCtrl,
                        label: 'Temperature *',
                        hint: 'e.g. 25',
                        suffix: '°C',
                        keyboardType: TextInputType.number,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _FormField(
                        controller: _controller.humidityCtrl,
                        label: 'Humidity *',
                        hint: 'e.g. 70',
                        suffix: '%',
                        keyboardType: TextInputType.number,
                      )),
                    ]),
                    const SizedBox(height: 12),

                    Row(children: [
                      Expanded(child: _FormField(
                        controller: _controller.phCtrl,
                        label: 'Soil pH *',
                        hint: 'e.g. 6.5',
                        suffix: 'pH',
                        keyboardType: TextInputType.number,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _FormField(
                        controller: _controller.rainfallCtrl,
                        label: 'Rainfall *',
                        hint: 'e.g. 200',
                        suffix: 'mm',
                        keyboardType: TextInputType.number,
                      )),
                    ]),
                    const SizedBox(height: 20),

                    // ── Optional NPK ──────────────────────────────────
                    _SectionLabel('NPK Values (Optional)'),
                    const SizedBox(height: 12),

                    Row(children: [
                      Expanded(child: _FormField(
                        controller: _controller.nitrogenCtrl,
                        label: 'Nitrogen',
                        hint: 'e.g. 40',
                        suffix: 'kg/ha',
                        keyboardType: TextInputType.number,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _FormField(
                        controller: _controller.phosphorusCtrl,
                        label: 'Phosphorus',
                        hint: 'e.g. 20',
                        suffix: 'kg/ha',
                        keyboardType: TextInputType.number,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _FormField(
                        controller: _controller.potassiumCtrl,
                        label: 'Potassium',
                        hint: 'e.g. 30',
                        suffix: 'kg/ha',
                        keyboardType: TextInputType.number,
                      )),
                    ]),
                    const SizedBox(height: 20),

                    // ── Validation error ──────────────────────────────
                    if (_validationError != null) ...[
                      _ErrorBanner(_validationError!),
                      const SizedBox(height: 12),
                    ],
                    if (_controller.status == CropRecommendationStatus.error) ...[
                      _ErrorBanner(_controller.errorMessage!),
                      const SizedBox(height: 12),
                    ],

                    // ── Submit button ─────────────────────────────────
                    SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton(
                        onPressed: _controller.status == CropRecommendationStatus.loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
                        ),
                        child: _controller.status == CropRecommendationStatus.loading
                            ? const SizedBox(width: 22, height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                            : const Text('Get Recommendation',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],

                  // ── Results ───────────────────────────────────────
                  if (_controller.status == CropRecommendationStatus.result) ...[
                    _ResultsSection(results: _controller.results!, onReset: _controller.reset),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark));
}

class _SoilTypeSelector extends StatelessWidget {
  final List<String> types;
  final String selected;
  final ValueChanged<String> onSelect;

  const _SoilTypeSelector({required this.types, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types.map((t) {
        final isSelected = t == selected;
        return GestureDetector(
          onTap: () => onSelect(t),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
            ),
            child: Text(t,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textDark)),
          ),
        );
      }).toList(),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String suffix;
  final TextInputType keyboardType;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.suffix,
    required this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textDark)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            suffixText: suffix,
            suffixStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _ResultsSection extends StatelessWidget {
  final List<_CropResult> results;
  final VoidCallback onReset;

  const _ResultsSection({required this.results, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recommended Crops',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            TextButton(
              onPressed: onReset,
              child: const Text('Try Again', style: TextStyle(color: AppColors.primary, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...results.asMap().entries.map((e) {
          final rank   = e.key + 1;
          final result = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: rank == 1 ? AppColors.primaryLight : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: rank == 1 ? AppColors.primary.withOpacity(0.4) : AppColors.border,
                  width: rank == 1 ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: rank == 1 ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text('#$rank',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: rank == 1 ? Colors.white : AppColors.textMuted)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(result.name,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                        const SizedBox(height: 2),
                        Text(result.reason,
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: result.suitability,
                            minHeight: 5,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${(result.suitability * 100).toInt()}%',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner(this.message);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFEF2F2),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFFECACA)),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline, size: 16, color: Color(0xFFEF4444)),
        const SizedBox(width: 8),
        Expanded(child: Text(message, style: const TextStyle(fontSize: 13, color: Color(0xFFEF4444)))),
      ],
    ),
  );
}
