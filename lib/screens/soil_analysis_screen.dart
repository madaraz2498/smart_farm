import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/app_theme.dart';

// ─── Controller ───────────────────────────────────────────────────────────────

enum SoilAnalysisStatus { idle, loading, result, error }
enum SoilInputMode { image, manual }

class SoilAnalysisController extends ChangeNotifier {
  SoilAnalysisStatus _status = SoilAnalysisStatus.idle;
  SoilInputMode      _mode   = SoilInputMode.image;
  String?            _imagePath;
  SoilResult?        _result;
  String?            _errorMessage;

  // Manual input controllers
  final nitrogenCtrl    = TextEditingController();
  final phosphorusCtrl  = TextEditingController();
  final potassiumCtrl   = TextEditingController();
  final phCtrl          = TextEditingController();
  final moistureCtrl    = TextEditingController();

  SoilAnalysisStatus get status       => _status;
  SoilInputMode      get mode         => _mode;
  String?            get imagePath    => _imagePath;
  SoilResult?        get result       => _result;
  String?            get errorMessage => _errorMessage;

  void setMode(SoilInputMode m) {
    _mode = m;
    notifyListeners();
  }

  /// TODO: POST image to API endpoint
  Future<void> analyzeImage(String path) async {
    _imagePath = path;
    _status    = SoilAnalysisStatus.loading;
    _result    = null;
    _errorMessage = null;
    notifyListeners();

    try {
      // ── TODO ──────────────────────────────────────────────────────────
      // final request = http.MultipartRequest('POST', Uri.parse('YOUR_API/soil-image'));
      // request.files.add(await http.MultipartFile.fromPath('image', path));
      // final response = await request.send();
      // final body = jsonDecode(await response.stream.bytesToString());
      // _result = SoilResult.fromJson(body);
      // ─────────────────────────────────────────────────────────────────
      await Future.delayed(const Duration(seconds: 2));
      _result = SoilResult(
        soilType: 'Clay Loam', fertilityLevel: 'Moderate',
        ph: 6.8, nitrogen: 42, phosphorus: 18, potassium: 35,
        moisture: 38, recommendations: ['Add organic compost', 'Good for wheat & maize', 'Moderate irrigation needed'],
      );
      _status = SoilAnalysisStatus.result;
    } catch (e) {
      _errorMessage = 'Analysis failed. Please try again.';
      _status = SoilAnalysisStatus.error;
    }
    notifyListeners();
  }

  /// TODO: POST manual values to API endpoint
  Future<void> analyzeManual() async {
    if (phCtrl.text.isEmpty) {
      _errorMessage = 'Please enter at least the pH value.';
      notifyListeners();
      return;
    }
    _status = SoilAnalysisStatus.loading;
    _result = null;
    _errorMessage = null;
    notifyListeners();

    try {
      // ── TODO ──────────────────────────────────────────────────────────
      // final response = await http.post(Uri.parse('YOUR_API/soil-manual'),
      //   body: {'ph': phCtrl.text, 'nitrogen': nitrogenCtrl.text, ...});
      // _result = SoilResult.fromJson(jsonDecode(response.body));
      // ─────────────────────────────────────────────────────────────────
      await Future.delayed(const Duration(seconds: 2));
      _result = SoilResult(
        soilType: 'Sandy Loam', fertilityLevel: 'High',
        ph: double.tryParse(phCtrl.text) ?? 6.5,
        nitrogen: int.tryParse(nitrogenCtrl.text) ?? 50,
        phosphorus: int.tryParse(phosphorusCtrl.text) ?? 25,
        potassium: int.tryParse(potassiumCtrl.text) ?? 40,
        moisture: int.tryParse(moistureCtrl.text) ?? 45,
        recommendations: ['Suitable for vegetables', 'High fertility – reduce fertilizer', 'Normal watering schedule'],
      );
      _status = SoilAnalysisStatus.result;
    } catch (e) {
      _errorMessage = 'Analysis failed. Please try again.';
      _status = SoilAnalysisStatus.error;
    }
    notifyListeners();
  }

  void reset() {
    _status = SoilAnalysisStatus.idle;
    _imagePath = null;
    _result = null;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    nitrogenCtrl.dispose();
    phosphorusCtrl.dispose();
    potassiumCtrl.dispose();
    phCtrl.dispose();
    moistureCtrl.dispose();
    super.dispose();
  }
}

class SoilResult {
  final String soilType, fertilityLevel;
  final double ph;
  final int nitrogen, phosphorus, potassium, moisture;
  final List<String> recommendations;

  const SoilResult({
    required this.soilType, required this.fertilityLevel,
    required this.ph, required this.nitrogen, required this.phosphorus,
    required this.potassium, required this.moisture, required this.recommendations,
  });
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

  void _pickImage(String src) {
    // TODO: use image_picker
    _ctrl.analyzeImage('mock_path');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _appBar(context),
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: _ctrl.status == SoilAnalysisStatus.result
                  ? _ResultView(result: _ctrl.result!, onReset: _ctrl.reset)
                  : _InputView(ctrl: _ctrl, onPickImage: _pickImage),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) => AppBar(
    backgroundColor: AppColors.surface, elevation: 0, surfaceTintColor: Colors.transparent,
    leading: IconButton(
      onPressed: () => Navigator.pop(context),
      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textDark),
    ),
    title: Row(children: [
      Container(width: 32, height: 32,
        decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
        child: Center(child: SvgPicture.asset('assets/images/icons/soil_icon.svg', width: 18, height: 18)),
      ),
      const SizedBox(width: 10),
      const Text('Soil Type Analysis', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
    ]),
    bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: AppColors.border)),
  );
}

// ─── Input view (tabs: image / manual) ────────────────────────────────────────

class _InputView extends StatelessWidget {
  final SoilAnalysisController ctrl;
  final void Function(String) onPickImage;
  const _InputView({required this.ctrl, required this.onPickImage});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        // ── Mode toggle ────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              _ModeTab(label: 'Image Analysis', icon: Icons.image_outlined,
                  selected: ctrl.mode == SoilInputMode.image,
                  onTap: () => ctrl.setMode(SoilInputMode.image)),
              _ModeTab(label: 'Manual Input', icon: Icons.edit_outlined,
                  selected: ctrl.mode == SoilInputMode.manual,
                  onTap: () => ctrl.setMode(SoilInputMode.manual)),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Image mode ─────────────────────────────────────────────────
        if (ctrl.mode == SoilInputMode.image) ...[
          _ImageUploadArea(
            imagePath: ctrl.imagePath,
            isLoading: ctrl.status == SoilAnalysisStatus.loading,
            onReset: ctrl.reset,
          ),
          const SizedBox(height: 14),
          if (ctrl.status != SoilAnalysisStatus.loading)
            Row(children: [
              Expanded(child: _Btn(icon: Icons.camera_alt_outlined, label: 'Camera', onTap: () => onPickImage('camera'))),
              const SizedBox(width: 12),
              Expanded(child: _Btn(icon: Icons.photo_library_outlined, label: 'Gallery', onTap: () => onPickImage('gallery'))),
            ]),
        ],

        // ── Manual mode ────────────────────────────────────────────────
        if (ctrl.mode == SoilInputMode.manual) ...[
          _ManualForm(ctrl: ctrl),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: ctrl.status == SoilAnalysisStatus.loading ? null : ctrl.analyzeManual,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: ctrl.status == SoilAnalysisStatus.loading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : const Text('Analyze Soil', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],

        if (ctrl.status == SoilAnalysisStatus.error && ctrl.errorMessage != null) ...[
          const SizedBox(height: 14),
          _ErrorBanner(ctrl.errorMessage!),
        ],
      ],
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _ModeTab({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : AppColors.textMuted),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.textMuted)),
          ],
        ),
      ),
    ),
  );
}

class _ImageUploadArea extends StatelessWidget {
  final String? imagePath;
  final bool isLoading;
  final VoidCallback onReset;
  const _ImageUploadArea({required this.imagePath, required this.isLoading, required this.onReset});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, height: 200,
    decoration: BoxDecoration(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.primary.withOpacity(0.25), width: 1.5),
    ),
    child: isLoading
        ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
            SizedBox(height: 14),
            Text('Analyzing soil sample...', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
          ])
        : imagePath != null
            ? Stack(children: [
                ClipRRect(borderRadius: BorderRadius.circular(15),
                    child: Container(width: double.infinity, height: double.infinity,
                        color: Colors.grey.shade200,
                        child: const Center(child: Icon(Icons.landscape_rounded, size: 60, color: Colors.grey)))),
                Positioned(top: 8, right: 8,
                    child: GestureDetector(onTap: onReset,
                        child: Container(padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.close_rounded, size: 16)))),
              ])
            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(width: 60, height: 60,
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.upload_rounded, size: 30, color: AppColors.primary)),
                const SizedBox(height: 12),
                const Text('Upload soil sample image', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                const SizedBox(height: 4),
                const Text('Clear photo of soil surface or cross-section', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ]),
  );
}

class _ManualForm extends StatelessWidget {
  final SoilAnalysisController ctrl;
  const _ManualForm({required this.ctrl});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(children: [
        Expanded(child: _Field(ctrl: ctrl.phCtrl, label: 'pH *', hint: '6.5', suffix: 'pH')),
        const SizedBox(width: 12),
        Expanded(child: _Field(ctrl: ctrl.moistureCtrl, label: 'Moisture', hint: '40', suffix: '%')),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _Field(ctrl: ctrl.nitrogenCtrl, label: 'Nitrogen', hint: '40', suffix: 'mg/kg')),
        const SizedBox(width: 12),
        Expanded(child: _Field(ctrl: ctrl.phosphorusCtrl, label: 'Phosphorus', hint: '20', suffix: 'mg/kg')),
        const SizedBox(width: 12),
        Expanded(child: _Field(ctrl: ctrl.potassiumCtrl, label: 'Potassium', hint: '30', suffix: 'mg/kg')),
      ]),
    ],
  );
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint, suffix;
  const _Field({required this.ctrl, required this.label, required this.hint, required this.suffix});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textDark)),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 14, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: hint, suffixText: suffix,
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          suffixStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          filled: true, fillColor: AppColors.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    ],
  );
}

class _Btn extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _Btn({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)]),
      child: Column(children: [
        Icon(icon, color: AppColors.primary, size: 26),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
      ]),
    ),
  );
}

// ─── Result view ──────────────────────────────────────────────────────────────

class _ResultView extends StatelessWidget {
  final SoilResult result;
  final VoidCallback onReset;
  const _ResultView({required this.result, required this.onReset});

  Color get _fertilityColor {
    switch (result.fertilityLevel) {
      case 'High':     return AppColors.primary;
      case 'Moderate': return const Color(0xFFF59E0B);
      default:         return const Color(0xFFEF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header result card ─────────────────────────────────────────
        Container(
          width: double.infinity, padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: [
            const Icon(Icons.landscape_rounded, color: Colors.white, size: 36),
            const SizedBox(height: 10),
            Text(result.soilType, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
              child: Text(result.fertilityLevel + ' Fertility',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // ── NPK + pH gauges ────────────────────────────────────────────
        _SectionLabel('Soil Properties'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
          child: Column(children: [
            _PropertyRow('pH Level',    '${result.ph}',            result.ph / 14,              const Color(0xFF6366F1)),
            const SizedBox(height: 10),
            _PropertyRow('Nitrogen',    '${result.nitrogen} mg/kg', result.nitrogen / 100,       AppColors.primary),
            const SizedBox(height: 10),
            _PropertyRow('Phosphorus',  '${result.phosphorus} mg/kg', result.phosphorus / 100,  const Color(0xFFF59E0B)),
            const SizedBox(height: 10),
            _PropertyRow('Potassium',   '${result.potassium} mg/kg', result.potassium / 100,    const Color(0xFFEC4899)),
            const SizedBox(height: 10),
            _PropertyRow('Moisture',    '${result.moisture}%',     result.moisture / 100,        const Color(0xFF0EA5E9)),
          ]),
        ),
        const SizedBox(height: 16),

        // ── Recommendations ────────────────────────────────────────────
        _SectionLabel('Recommendations'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
          child: Column(
            children: result.recommendations.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(r, style: const TextStyle(fontSize: 13, color: AppColors.textDark, height: 1.4))),
              ]),
            )).toList(),
          ),
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity, height: 50,
          child: OutlinedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            label: const Text('Analyze Another Sample', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark));
}

class _PropertyRow extends StatelessWidget {
  final String label, value;
  final double progress;
  final Color color;
  const _PropertyRow(this.label, this.value, this.progress, this.color);

  @override
  Widget build(BuildContext context) => Row(children: [
    SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
    Expanded(child: ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(value: progress.clamp(0.0, 1.0), minHeight: 7,
          backgroundColor: color.withOpacity(0.12), valueColor: AlwaysStoppedAnimation(color)),
    )),
    const SizedBox(width: 10),
    Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
  ]);
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner(this.message);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFECACA))),
    child: Row(children: [
      const Icon(Icons.error_outline, size: 16, color: Color(0xFFEF4444)),
      const SizedBox(width: 8),
      Expanded(child: Text(message, style: const TextStyle(fontSize: 13, color: Color(0xFFEF4444)))),
    ]),
  );
}
