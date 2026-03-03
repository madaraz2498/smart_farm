import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/app_theme.dart';

// ─── Provider / Controller ────────────────────────────────────────────────────

enum PlantScanStatus { idle, loading, result, error }

class PlantDiseaseController extends ChangeNotifier {
  PlantScanStatus _status = PlantScanStatus.idle;
  String? _imagePath;
  String? _resultLabel;
  double? _confidence;
  String? _errorMessage;

  PlantScanStatus get status      => _status;
  String?         get imagePath   => _imagePath;
  String?         get resultLabel => _resultLabel;
  double?         get confidence  => _confidence;
  String?         get errorMessage => _errorMessage;

  /// Call this with the picked image path, then hit the API.
  /// Replace the body of this method with your actual API call.
  Future<void> analyzeImage(String path) async {
    _imagePath = path;
    _status    = PlantScanStatus.loading;
    _resultLabel = null;
    _errorMessage = null;
    notifyListeners();

    try {
      // ── TODO: Replace with real API call ──────────────────────────────
      // final request = http.MultipartRequest('POST', Uri.parse('YOUR_API_URL'));
      // request.files.add(await http.MultipartFile.fromPath('image', path));
      // final response = await request.send();
      // final body = jsonDecode(await response.stream.bytesToString());
      // _resultLabel = body['disease'];
      // _confidence  = body['confidence'];
      // ─────────────────────────────────────────────────────────────────

      // Mock result for now
      await Future.delayed(const Duration(seconds: 2));
      _resultLabel = 'Early Blight';
      _confidence  = 0.91;
      _status      = PlantScanStatus.result;
    } catch (e) {
      _errorMessage = 'Analysis failed. Please try again.';
      _status       = PlantScanStatus.error;
    }
    notifyListeners();
  }

  void reset() {
    _status       = PlantScanStatus.idle;
    _imagePath    = null;
    _resultLabel  = null;
    _confidence   = null;
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
  final _controller = PlantDiseaseController();

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
    // if (file != null) _controller.analyzeImage(file.path);

    // Mock trigger for now
    _controller.analyzeImage('mock_path');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
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
            child: Center(child: SvgPicture.asset('assets/images/icons/plant_icon.svg', width: 18, height: 18)),
          ),
          const SizedBox(width: 10),
          const Text('Plant Disease Detection',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ── Image preview area ──────────────────────────────────
              _ImagePreviewCard(
                imagePath: _controller.imagePath,
                isLoading: _controller.status == PlantScanStatus.loading,
                onReset: _controller.reset,
              ),
              const SizedBox(height: 16),

              // ── Pick source buttons ─────────────────────────────────
              if (_controller.status == PlantScanStatus.idle ||
                  _controller.status == PlantScanStatus.error) ...[
                Row(
                  children: [
                    Expanded(
                      child: _SourceButton(
                        icon: Icons.camera_alt_outlined,
                        label: 'Take Photo',
                        onTap: () => _pickImage('camera'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SourceButton(
                        icon: Icons.photo_library_outlined,
                        label: 'From Gallery',
                        onTap: () => _pickImage('gallery'),
                      ),
                    ),
                  ],
                ),
              ],

              // ── Error ───────────────────────────────────────────────
              if (_controller.status == PlantScanStatus.error) ...[
                const SizedBox(height: 14),
                _ErrorBanner(_controller.errorMessage ?? 'Unknown error'),
              ],

              // ── Result card ─────────────────────────────────────────
              if (_controller.status == PlantScanStatus.result) ...[
                const SizedBox(height: 16),
                _PlantResultCard(
                  label: _controller.resultLabel!,
                  confidence: _controller.confidence!,
                  onScanAgain: _controller.reset,
                ),
              ],

              // ── Tips ────────────────────────────────────────────────
              const SizedBox(height: 24),
              _TipsCard(tips: const [
                'Use clear, well-lit photos of affected leaves.',
                'Capture both the front and back of the leaf.',
                'Avoid shadows or blurry images.',
                'One leaf per image gives best accuracy.',
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class _ImagePreviewCard extends StatelessWidget {
  final String? imagePath;
  final bool isLoading;
  final VoidCallback onReset;

  const _ImagePreviewCard({required this.imagePath, required this.isLoading, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.25), width: 1.5),
      ),
      child: isLoading
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
                SizedBox(height: 14),
                Text('Analyzing image...', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
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
                        child: const Center(child: Icon(Icons.image_rounded, size: 60, color: Colors.grey)),
                      ),
                    ),
                    Positioned(
                      top: 8, right: 8,
                      child: GestureDetector(
                        onTap: onReset,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.close_rounded, size: 16, color: AppColors.textDark),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.add_photo_alternate_outlined, size: 32, color: AppColors.primary),
                    ),
                    const SizedBox(height: 12),
                    const Text('Upload a leaf image', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    const SizedBox(height: 4),
                    const Text('JPG or PNG, max 10MB', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceButton({required this.icon, required this.label, required this.onTap});

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

class _PlantResultCard extends StatelessWidget {
  final String label;
  final double confidence;
  final VoidCallback onScanAgain;

  const _PlantResultCard({required this.label, required this.confidence, required this.onScanAgain});

  bool get _isHealthy => label.toLowerCase().contains('healthy');

  @override
  Widget build(BuildContext context) {
    final color = _isHealthy ? AppColors.primary : const Color(0xFFEF4444);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_isHealthy ? Icons.check_circle_rounded : Icons.warning_amber_rounded, color: color, size: 22),
              const SizedBox(width: 8),
              Text('Detection Result', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Confidence: ', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
              Text('${(confidence * 100).toStringAsFixed(1)}%',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: confidence, minHeight: 6,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onScanAgain,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Scan Another Image', style: TextStyle(color: color, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  final List<String> tips;
  const _TipsCard({required this.tips});

  @override
  Widget build(BuildContext context) {
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
            Icon(Icons.lightbulb_outline_rounded, size: 16, color: Color(0xFFF59E0B)),
            SizedBox(width: 6),
            Text('Tips for best results', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ]),
          const SizedBox(height: 10),
          ...tips.map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                Expanded(child: Text(t, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4))),
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
