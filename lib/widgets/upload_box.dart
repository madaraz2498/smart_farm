import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// UploadBox
//
// A reusable image-upload area used by Plant Disease, Animal Weight,
// Soil Analysis, and Fruit Quality screens.
//
// States:
//   • idle      → shows icon + label + hint text
//   • hasImage  → shows a preview placeholder + close (reset) button
//   • loading   → shows a centred CircularProgressIndicator + status label
//
// Usage:
//   UploadBox(
//     imagePath:    _ctrl.imagePath,
//     isLoading:    _ctrl.status == MyStatus.loading,
//     loadingLabel: 'Analyzing image...',
//     icon:         Icons.add_photo_alternate_outlined,
//     previewIcon:  Icons.pets_rounded,
//     label:        'Upload animal image',
//     hint:         'Take or choose a full-body side photo',
//     onReset:      _ctrl.reset,
//   )
// ─────────────────────────────────────────────────────────────────────────────

class UploadBox extends StatelessWidget {
  /// File path (or URL) of the selected image.
  /// When non-null the widget shows the preview state.
  final String? imagePath;

  /// Whether an API call is in-flight.
  final bool isLoading;

  /// Label shown beneath the spinner in loading state.
  final String loadingLabel;

  /// Icon shown in the idle state inside the tinted icon-box.
  final IconData icon;

  /// Icon shown as placeholder when [imagePath] is set but before the real
  /// image is displayed. Replace with Image.file(File(imagePath)) once
  /// image_picker is wired up.
  final IconData previewIcon;

  /// Primary label in idle state.
  final String label;

  /// Secondary hint text in idle state.
  final String hint;

  /// Called when the user taps the × button in preview state.
  final VoidCallback onReset;

  /// Height of the box. Defaults to 200.
  final double height;

  const UploadBox({
    super.key,
    required this.imagePath,
    required this.isLoading,
    required this.onReset,
    this.loadingLabel = 'Analyzing...',
    this.icon         = Icons.upload_rounded,
    this.previewIcon  = Icons.image_rounded,
    this.label        = 'Upload image',
    this.hint         = 'PNG or JPG, max 10 MB',
    this.height       = 200,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width:  double.infinity,
      height: height,
      decoration: BoxDecoration(
        color:         imagePath != null
            ? cs.surfaceContainerHighest
            : cs.primaryContainer,
        borderRadius:  AppRadius.radiusLg,
        border: Border.all(
          color: cs.primary.withOpacity(0.28),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.radiusLg,
        child: _buildContent(context, cs),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ColorScheme cs) {
    if (isLoading) return _LoadingState(label: loadingLabel, cs: cs);
    if (imagePath != null) return _PreviewState(icon: previewIcon, onReset: onReset);
    return _IdleState(icon: icon, label: label, hint: hint, cs: cs);
  }
}

// ─── Internal states ─────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  final String loadingLabel;
  final ColorScheme cs;

  const _LoadingState({required String label, required this.cs})
      : loadingLabel = label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: cs.primary, strokeWidth: 3),
        const SizedBox(height: 14),
        Text(
          loadingLabel,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _PreviewState extends StatelessWidget {
  final IconData icon;
  final VoidCallback onReset;

  const _PreviewState({required this.icon, required this.onReset});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace the grey placeholder with:
    //   Image.file(File(imagePath), fit: BoxFit.cover,
    //       width: double.infinity, height: double.infinity)
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: Colors.grey.shade200,
          child: Icon(icon, size: 64, color: Colors.grey.shade400),
        ),
        Positioned(
          top: 8, right: 8,
          child: _CloseButton(onTap: onReset),
        ),
      ],
    );
  }
}

class _IdleState extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final ColorScheme cs;

  const _IdleState({
    required this.icon,
    required this.label,
    required this.hint,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            color:         cs.primary.withOpacity(0.15),
            borderRadius:  AppRadius.radiusLg,
          ),
          child: Icon(icon, size: 30, color: cs.primary),
        ),
        const SizedBox(height: 14),
        Text(label,  style: tt.titleSmall),
        const SizedBox(height: 4),
        Text(hint,   style: tt.bodySmall),
      ],
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close_rounded, size: 16, color: AppColors.textDark),
      ),
    );
  }
}
