import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/app_theme.dart';

// ─── Controller ───────────────────────────────────────────────────────────────

enum AnimalWeightStatus { idle, loading, result, error }

class AnimalWeightController extends ChangeNotifier {
  AnimalWeightStatus _status = AnimalWeightStatus.idle;
  String? _imagePath;
  double? _estimatedWeight;
  String? _animalType;
  String? _errorMessage;
  String _selectedAnimalType = 'Cow';

  AnimalWeightStatus get status          => _status;
  String?            get imagePath       => _imagePath;
  double?            get estimatedWeight => _estimatedWeight;
  String?            get animalType      => _animalType;
  String?            get errorMessage    => _errorMessage;
  String             get selectedAnimalType => _selectedAnimalType;

  final List<String> animalTypes = ['Cow', 'Sheep', 'Goat', 'Horse', 'Camel'];

  void setAnimalType(String type) {
    _selectedAnimalType = type;
    notifyListeners();
  }

  /// TODO: Replace mock with real API call (multipart POST with image + animal_type)
  Future<void> estimateWeight(String path) async {
    _imagePath = path;
    _status    = AnimalWeightStatus.loading;
    _estimatedWeight = null;
    _errorMessage    = null;
    notifyListeners();

    try {
      // ── TODO: Replace with real API call ──────────────────────────────
      // final request = http.MultipartRequest('POST', Uri.parse('YOUR_API_URL/animal-weight'));
      // request.fields['animal_type'] = _selectedAnimalType;
      // request.files.add(await http.MultipartFile.fromPath('image', path));
      // final response = await request.send();
      // final body = jsonDecode(await response.stream.bytesToString());
      // _estimatedWeight = body['weight_kg'].toDouble();
      // _animalType      = body['animal_type'];
      // ─────────────────────────────────────────────────────────────────

      await Future.delayed(const Duration(seconds: 2));
      _estimatedWeight = 412.5;
      _animalType      = _selectedAnimalType;
      _status          = AnimalWeightStatus.result;
    } catch (e) {
      _errorMessage = 'Estimation failed. Please try again.';
      _status       = AnimalWeightStatus.error;
    }
    notifyListeners();
  }

  void reset() {
    _status          = AnimalWeightStatus.idle;
    _imagePath       = null;
    _estimatedWeight = null;
    _animalType      = null;
    _errorMessage    = null;
    notifyListeners();
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class AnimalWeightScreen extends StatefulWidget {
  const AnimalWeightScreen({super.key});

  @override
  State<AnimalWeightScreen> createState() => _AnimalWeightScreenState();
}

class _AnimalWeightScreenState extends State<AnimalWeightScreen> {
  final _controller = AnimalWeightController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pickImage(String source) {
    // TODO: Replace with image_picker
    // final picker = ImagePicker();
    // final file = source == 'camera'
    //     ? await picker.pickImage(source: ImageSource.camera)
    //     : await picker.pickImage(source: ImageSource.gallery);
    // if (file != null) _controller.estimateWeight(file.path);
    _controller.estimateWeight('mock_path');
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
              child: Center(child: SvgPicture.asset('assets/images/icons/animal_icon.svg', width: 18, height: 18)),
            ),
            const SizedBox(width: 10),
            const Text('Animal Weight Estimation',
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

                  // ── Animal type selector ────────────────────────────
                  const Text('Animal Type',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  const SizedBox(height: 10),
                  _AnimalTypeSelector(
                    types: _controller.animalTypes,
                    selected: _controller.selectedAnimalType,
                    onSelect: _controller.setAnimalType,
                  ),
                  const SizedBox(height: 20),

                  // ── Upload card ─────────────────────────────────────
                  const Text('Animal Image',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  const SizedBox(height: 10),
                  _UploadCard(
                    imagePath: _controller.imagePath,
                    isLoading: _controller.status == AnimalWeightStatus.loading,
                    onReset: _controller.reset,
                  ),
                  const SizedBox(height: 16),

                  // ── Action buttons ──────────────────────────────────
                  if (_controller.status == AnimalWeightStatus.idle ||
                      _controller.status == AnimalWeightStatus.error) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _ActionBtn(
                            icon: Icons.camera_alt_outlined,
                            label: 'Camera',
                            onTap: () => _pickImage('camera'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionBtn(
                            icon: Icons.photo_library_outlined,
                            label: 'Gallery',
                            onTap: () => _pickImage('gallery'),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // ── Error ───────────────────────────────────────────
                  if (_controller.status == AnimalWeightStatus.error) ...[
                    const SizedBox(height: 14),
                    _ErrorBanner(_controller.errorMessage!),
                  ],

                  // ── Result ──────────────────────────────────────────
                  if (_controller.status == AnimalWeightStatus.result) ...[
                    const SizedBox(height: 20),
                    _WeightResultCard(
                      weight: _controller.estimatedWeight!,
                      animalType: _controller.animalType!,
                      onReset: _controller.reset,
                    ),
                  ],

                  // ── How it works ────────────────────────────────────
                  const SizedBox(height: 24),
                  _HowItWorksCard(),
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

class _AnimalTypeSelector extends StatelessWidget {
  final List<String> types;
  final String selected;
  final ValueChanged<String> onSelect;

  const _AnimalTypeSelector({required this.types, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: types.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final isSelected = types[i] == selected;
          return GestureDetector(
            onTap: () => onSelect(types[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                types[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textDark,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  final String? imagePath;
  final bool isLoading;
  final VoidCallback onReset;

  const _UploadCard({required this.imagePath, required this.isLoading, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: imagePath != null ? Colors.grey.shade100 : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          style: BorderStyle.solid,
          width: 1.5,
        ),
      ),
      child: isLoading
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
                SizedBox(height: 14),
                Text('Estimating weight...', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
              ],
            )
          : imagePath != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        width: double.infinity, height: double.infinity,
                        color: Colors.grey.shade200,
                        child: const Center(child: Icon(Icons.pets_rounded, size: 60, color: Colors.grey)),
                      ),
                    ),
                    Positioned(
                      top: 8, right: 8,
                      child: GestureDetector(
                        onTap: onReset,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.close_rounded, size: 16),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.upload_rounded, size: 30, color: AppColors.primary),
                    ),
                    const SizedBox(height: 12),
                    const Text('Upload animal image',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    const SizedBox(height: 4),
                    const Text('Take or choose a full-body side photo',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 26),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
          ],
        ),
      ),
    );
  }
}

class _WeightResultCard extends StatelessWidget {
  final double weight;
  final String animalType;
  final VoidCallback onReset;

  const _WeightResultCard({required this.weight, required this.animalType, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 40),
          const SizedBox(height: 10),
          Text('Estimated Weight',
              style: TextStyle(fontSize: 13, color: AppColors.primary.withOpacity(0.8), fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text('${weight.toStringAsFixed(1)} kg',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.primary)),
          const SizedBox(height: 4),
          Text(animalType,
              style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
          const SizedBox(height: 16),
          // Weight category
          _WeightRange(weight: weight, animalType: animalType),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onReset,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Weigh Another Animal',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _WeightRange extends StatelessWidget {
  final double weight;
  final String animalType;

  const _WeightRange({required this.weight, required this.animalType});

  String get _category {
    if (animalType == 'Cow') {
      if (weight < 300) return 'Underweight';
      if (weight < 500) return 'Normal';
      return 'Overweight';
    }
    return 'Normal';
  }

  Color get _color {
    switch (_category) {
      case 'Underweight': return const Color(0xFFF59E0B);
      case 'Overweight':  return const Color(0xFFEF4444);
      default:            return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(_category,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _color)),
    );
  }
}

class _HowItWorksCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final steps = [
      ('1', 'Select animal type from the chips above'),
      ('2', 'Take a clear side-view photo of the animal'),
      ('3', 'AI extracts body dimensions from the image'),
      ('4', 'Weight is estimated using a regression model'),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
            SizedBox(width: 6),
            Text('How it works', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ]),
          const SizedBox(height: 12),
          ...steps.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20, height: 20,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: Center(child: Text(s.$1, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700))),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(s.$2, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4))),
              ],
            ),
          )),
        ],
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
}
