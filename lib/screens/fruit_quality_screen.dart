import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/app_theme.dart';

enum FruitQualityStatus { idle, loading, result, error }

class FruitQualityController extends ChangeNotifier {
  FruitQualityStatus _status = FruitQualityStatus.idle;
  String? _imagePath;
  FruitResult? _result;
  String? _errorMessage;
  String _selectedFruitType = 'Apple';

  FruitQualityStatus get status => _status;
  String? get imagePath => _imagePath;
  FruitResult? get result => _result;
  String? get errorMessage => _errorMessage;
  String get selectedFruitType => _selectedFruitType;

  final List<String> fruitTypes = ['Apple', 'Mango', 'Orange', 'Tomato', 'Grape', 'Banana'];

  void setFruitType(String t) { _selectedFruitType = t; notifyListeners(); }

  Future<void> analyze(String path) async {
    _imagePath = path;
    _status = FruitQualityStatus.loading;
    _result = null; _errorMessage = null;
    notifyListeners();
    try {
      // TODO: POST to YOUR_API/fruit-quality with image + fruit_type
      // final request = http.MultipartRequest('POST', Uri.parse('YOUR_API/fruit-quality'));
      // request.fields['fruit_type'] = _selectedFruitType;
      // request.files.add(await http.MultipartFile.fromPath('image', path));
      // final response = await request.send();
      // _result = FruitResult.fromJson(jsonDecode(await response.stream.bytesToString()));
      await Future.delayed(const Duration(seconds: 2));
      _result = FruitResult(
        grade: 'A', fruitType: _selectedFruitType, ripeness: 'Ripe',
        defects: 'None detected', freshness: 0.92, overallScore: 0.89,
        details: ['No visible bruising', 'Uniform color distribution', 'Good size and shape', 'Ready for market'],
      );
      _status = FruitQualityStatus.result;
    } catch (e) {
      _errorMessage = 'Analysis failed. Please try again.';
      _status = FruitQualityStatus.error;
    }
    notifyListeners();
  }

  void reset() {
    _status = FruitQualityStatus.idle; _imagePath = null; _result = null; _errorMessage = null;
    notifyListeners();
  }
}

class FruitResult {
  final String grade, fruitType, ripeness, defects;
  final double freshness, overallScore;
  final List<String> details;
  const FruitResult({required this.grade, required this.fruitType, required this.ripeness,
      required this.defects, required this.freshness, required this.overallScore, required this.details});
}

class FruitQualityScreen extends StatefulWidget {
  const FruitQualityScreen({super.key});
  @override
  State<FruitQualityScreen> createState() => _FruitQualityScreenState();
}

class _FruitQualityScreenState extends State<FruitQualityScreen> {
  final _ctrl = FruitQualityController();
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  void _pick(String src) { _ctrl.analyze('mock_path'); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface, elevation: 0, surfaceTintColor: Colors.transparent,
        leading: IconButton(onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textDark)),
        title: Row(children: [
          Container(width: 32, height: 32,
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
              child: Center(child: SvgPicture.asset('assets/images/icons/fruit_icon.svg', width: 18, height: 18))),
          const SizedBox(width: 10),
          const Text('Fruit Quality Analysis',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        ]),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: AppColors.border)),
      ),
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 4),
              const _Lbl('Fruit Type'),
              const SizedBox(height: 10),
              _Chips(types: _ctrl.fruitTypes, selected: _ctrl.selectedFruitType, onSelect: _ctrl.setFruitType),
              const SizedBox(height: 20),
              const _Lbl('Fruit Image'),
              const SizedBox(height: 10),
              _UploadBox(imagePath: _ctrl.imagePath,
                  isLoading: _ctrl.status == FruitQualityStatus.loading, onReset: _ctrl.reset),
              const SizedBox(height: 14),
              if (_ctrl.status == FruitQualityStatus.idle || _ctrl.status == FruitQualityStatus.error)
                Row(children: [
                  Expanded(child: _PickBtn(icon: Icons.camera_alt_outlined, label: 'Camera', onTap: () => _pick('camera'))),
                  const SizedBox(width: 12),
                  Expanded(child: _PickBtn(icon: Icons.photo_library_outlined, label: 'Gallery', onTap: () => _pick('gallery'))),
                ]),
              if (_ctrl.status == FruitQualityStatus.error && _ctrl.errorMessage != null) ...[
                const SizedBox(height: 14),
                _ErrBanner(_ctrl.errorMessage!),
              ],
              if (_ctrl.status == FruitQualityStatus.result) ...[
                const SizedBox(height: 20),
                _ResultCard(result: _ctrl.result!, onReset: _ctrl.reset),
              ],
              if (_ctrl.status != FruitQualityStatus.result) ...[
                const SizedBox(height: 24),
                _Legend(),
              ],
            ]),
          )),
        ),
      ),
    );
  }
}

class _Lbl extends StatelessWidget {
  final String text;
  const _Lbl(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark));
}

class _Chips extends StatelessWidget {
  final List<String> types; final String selected; final ValueChanged<String> onSelect;
  const _Chips({required this.types, required this.selected, required this.onSelect});
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 40,
    child: ListView.separated(
      scrollDirection: Axis.horizontal, itemCount: types.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, i) {
        final sel = types[i] == selected;
        return GestureDetector(onTap: () => onSelect(types[i]),
          child: AnimatedContainer(duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: sel ? AppColors.primary : AppColors.surface, borderRadius: BorderRadius.circular(20),
              border: Border.all(color: sel ? AppColors.primary : AppColors.border)),
            child: Text(types[i], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                color: sel ? Colors.white : AppColors.textDark))));
      },
    ),
  );
}

class _UploadBox extends StatelessWidget {
  final String? imagePath; final bool isLoading; final VoidCallback onReset;
  const _UploadBox({required this.imagePath, required this.isLoading, required this.onReset});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, height: 200,
    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.25), width: 1.5)),
    child: isLoading
        ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
            SizedBox(height: 14),
            Text('Analyzing fruit quality...', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
          ])
        : imagePath != null
            ? Stack(children: [
                ClipRRect(borderRadius: BorderRadius.circular(15),
                    child: Container(width: double.infinity, height: double.infinity, color: Colors.grey.shade200,
                        child: const Center(child: Icon(Icons.apple_rounded, size: 60, color: Colors.grey)))),
                Positioned(top: 8, right: 8, child: GestureDetector(onTap: onReset,
                    child: Container(padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.close_rounded, size: 16)))),
              ])
            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(width: 60, height: 60,
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.upload_rounded, size: 30, color: AppColors.primary)),
                const SizedBox(height: 12),
                const Text('Upload fruit image', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                const SizedBox(height: 4),
                const Text('Clear photo of the entire fruit', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ]),
  );
}

class _PickBtn extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _PickBtn({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: Container(padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)]),
      child: Column(children: [
        Icon(icon, color: AppColors.primary, size: 26),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
      ])));
}

class _ResultCard extends StatelessWidget {
  final FruitResult result; final VoidCallback onReset;
  const _ResultCard({required this.result, required this.onReset});
  Color get _gc => result.grade == 'A' ? AppColors.primary : result.grade == 'B' ? const Color(0xFFF59E0B) : const Color(0xFFEF4444);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(width: double.infinity, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: _gc.withOpacity(0.07), borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _gc.withOpacity(0.3))),
      child: Column(children: [
        Container(width: 72, height: 72, decoration: BoxDecoration(color: _gc, shape: BoxShape.circle),
            child: Center(child: Text(result.grade, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)))),
        const SizedBox(height: 10),
        Text('Grade ${result.grade} — ${result.fruitType}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 4),
        Text('Overall Score: ${(result.overallScore * 100).toInt()}%',
            style: TextStyle(fontSize: 13, color: _gc, fontWeight: FontWeight.w600)),
      ]),
    ),
    const SizedBox(height: 14),
    Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(children: [
        Row(children: [
          const Icon(Icons.water_drop_outlined, size: 16, color: Color(0xFF0EA5E9)), const SizedBox(width: 8),
          const SizedBox(width: 80, child: Text('Freshness', style: TextStyle(fontSize: 13, color: AppColors.textMuted))),
          Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(value: result.freshness, minHeight: 6,
                  backgroundColor: const Color(0xFF0EA5E9).withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF0EA5E9))))),
          const SizedBox(width: 10),
          Text('${(result.freshness * 100).toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0EA5E9))),
        ]),
        const Divider(height: 16),
        Row(children: [
          const Icon(Icons.thermostat_outlined, size: 16, color: Color(0xFFF59E0B)), const SizedBox(width: 8),
          const SizedBox(width: 80, child: Text('Ripeness', style: TextStyle(fontSize: 13, color: AppColors.textMuted))),
          Text(result.ripeness, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        ]),
        const Divider(height: 16),
        Row(children: [
          const Icon(Icons.search_outlined, size: 16, color: Color(0xFFEF4444)), const SizedBox(width: 8),
          const SizedBox(width: 80, child: Text('Defects', style: TextStyle(fontSize: 13, color: AppColors.textMuted))),
          Text(result.defects, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        ]),
      ]),
    ),
    const SizedBox(height: 14),
    Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Analysis Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        const SizedBox(height: 10),
        ...result.details.map((d) => Padding(padding: const EdgeInsets.only(bottom: 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.check_circle_rounded, size: 15, color: AppColors.primary), const SizedBox(width: 8),
            Expanded(child: Text(d, style: const TextStyle(fontSize: 12, color: AppColors.textDark, height: 1.4))),
          ]))),
      ]),
    ),
    const SizedBox(height: 16),
    SizedBox(width: double.infinity, height: 50,
      child: OutlinedButton.icon(onPressed: onReset,
        icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
        label: const Text('Analyze Another Fruit', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
  ]);
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Quality Grades', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
      const SizedBox(height: 8),
      Row(children: [
        _P('A', AppColors.primary, 'Premium'), const SizedBox(width: 8),
        _P('B', const Color(0xFFF59E0B), 'Standard'), const SizedBox(width: 8),
        _P('C', const Color(0xFFEF4444), 'Low Quality'),
      ]),
    ]),
  );
}

class _P extends StatelessWidget {
  final String g, lbl; final Color c;
  const _P(this.g, this.c, this.lbl);
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 22, height: 22, decoration: BoxDecoration(color: c, shape: BoxShape.circle),
        child: Center(child: Text(g, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)))),
    const SizedBox(width: 5),
    Text(lbl, style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w500)),
  ]);
}

class _ErrBanner extends StatelessWidget {
  final String message;
  const _ErrBanner(this.message);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFECACA))),
    child: Row(children: [
      const Icon(Icons.error_outline, size: 16, color: Color(0xFFEF4444)), const SizedBox(width: 8),
      Expanded(child: Text(message, style: const TextStyle(fontSize: 13, color: Color(0xFFEF4444)))),
    ]),
  );
}
