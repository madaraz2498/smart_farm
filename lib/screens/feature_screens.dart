import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/app_theme.dart';

// ─── Individual Feature Screens ───────────────────────────────────────────────

class PlantDiseaseScreen extends StatelessWidget {
  const PlantDiseaseScreen({super.key});
  @override
  Widget build(BuildContext context) => FeatureScaffold(
        title: 'Plant Disease Detection',
        svgPath: 'assets/images/icons/plant_icon.svg',
        subtitle: 'Detect plant diseases early using AI image analysis',
        description: 'Upload a photo of your plant leaf and our AI-powered CNN model will analyze it to detect diseases early, helping you reduce production loss.',
        buttonLabel: 'Upload Plant Image',
        onButtonPressed: () {},
      );
}

class AnimalWeightScreen extends StatelessWidget {
  const AnimalWeightScreen({super.key});
  @override
  Widget build(BuildContext context) => FeatureScaffold(
        title: 'Animal Weight Estimation',
        svgPath: 'assets/images/icons/animal_icon.svg',
        subtitle: 'Estimate animal weight accurately without physical scales',
        description: 'Take a photo of your animal and our computer vision model will estimate its weight using image-based dimension extraction.',
        buttonLabel: 'Upload Animal Image',
        onButtonPressed: () {},
      );
}

class CropRecommendationScreen extends StatelessWidget {
  const CropRecommendationScreen({super.key});
  @override
  Widget build(BuildContext context) => FeatureScaffold(
        title: 'Crop Recommendation',
        svgPath: 'assets/images/icons/crop_icon.svg',
        subtitle: 'Get the best crop suggestions based on soil and climate data',
        description: 'Enter your environmental factors like temperature, humidity, soil type, and rainfall to get AI-powered crop recommendations for maximum yield.',
        buttonLabel: 'Get Recommendation',
        onButtonPressed: () {},
      );
}

class SoilAnalysisScreen extends StatelessWidget {
  const SoilAnalysisScreen({super.key});
  @override
  Widget build(BuildContext context) => FeatureScaffold(
        title: 'Soil Type Analysis',
        svgPath: 'assets/images/icons/soil_icon.svg',
        subtitle: 'Analyze soil fertility and type using data or images',
        description: 'Upload a soil image or enter chemical properties to identify your soil type and fertility level, integrated with crop recommendations.',
        buttonLabel: 'Analyze Soil',
        onButtonPressed: () {},
      );
}

class FruitQualityScreen extends StatelessWidget {
  const FruitQualityScreen({super.key});
  @override
  Widget build(BuildContext context) => FeatureScaffold(
        title: 'Fruit Quality Analysis',
        svgPath: 'assets/images/icons/fruit_icon.svg',
        subtitle: 'Classify fruit quality and detect defects automatically',
        description: 'Upload a fruit image and our deep learning model will detect defects, assess ripeness, and classify quality into grades A, B, or C.',
        buttonLabel: 'Upload Fruit Image',
        onButtonPressed: () {},
      );
}

class ChatbotScreen extends StatelessWidget {
  const ChatbotScreen({super.key});
  @override
  Widget build(BuildContext context) => FeatureScaffold(
        title: 'Smart Farm Chatbot',
        svgPath: 'assets/images/icons/chat_icon.svg',
        subtitle: 'Ask questions and get instant farming advice',
        description: 'Chat with our AI-powered assistant trained on agricultural knowledge. Get instant advice on crop care, animal health, and farming schedules in Arabic or English.',
        buttonLabel: 'Start Chat',
        onButtonPressed: () {},
      );
}

// ─── Shared Feature Scaffold ──────────────────────────────────────────────────

class FeatureScaffold extends StatelessWidget {
  final String title;
  final String svgPath;
  final String subtitle;
  final String description;
  final String buttonLabel;
  final VoidCallback onButtonPressed;

  const FeatureScaffold({
    super.key,
    required this.title,
    required this.svgPath,
    required this.subtitle,
    required this.description,
    required this.buttonLabel,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
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
              child: Center(child: SvgPicture.asset(svgPath, width: 18, height: 18)),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                // Icon hero
                Container(
                  width: 88, height: 88,
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(22)),
                  child: Center(child: SvgPicture.asset(svgPath, width: 44, height: 44)),
                ),
                const SizedBox(height: 20),
                Text(title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 8),
                Text(subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: AppColors.textMuted, height: 1.5)),
                const SizedBox(height: 28),

                // Main card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Upload area
                      Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_outlined, size: 38, color: Colors.grey.shade400),
                            const SizedBox(height: 10),
                            Text('Tap to upload or drag & drop',
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                            const SizedBox(height: 4),
                            Text('PNG, JPG up to 10MB',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.6)),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: onButtonPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Text(buttonLabel,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
