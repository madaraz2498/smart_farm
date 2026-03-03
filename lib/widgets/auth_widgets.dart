import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

// ─── SmartFarm Logo Icon ──────────────────────────────────────────────────────
class AppLogo extends StatelessWidget {
  final double size;
  final double iconSize;
  final double borderRadius;

  const AppLogo({
    super.key,
    this.size = 64,
    this.iconSize = 40,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(Icons.eco_rounded, color: Colors.white, size: iconSize),
    );
  }
}

// ─── Auth Card Container ──────────────────────────────────────────────────────
class AuthCard extends StatelessWidget {
  final Widget child;

  const AuthCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: child,
    );
  }
}

// ─── Form Field Label ─────────────────────────────────────────────────────────
class FieldLabel extends StatelessWidget {
  final String text;

  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
        ),
      ),
    );
  }
}

// ─── Smart Text Field ─────────────────────────────────────────────────────────
class SmartTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? errorText;
  final void Function(String)? onChanged;
  final TextInputAction? textInputAction;

  const SmartTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.errorText,
    this.onChanged,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: errorText != null
                  ? AppColors.error
                  : AppColors.border,
              width: errorText != null ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            textInputAction: textInputAction,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 15, color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 15,
                color: Color(0xFF9CA3AF),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon: suffixIcon,
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.error_outline,
                  size: 13, color: AppColors.error),
              const SizedBox(width: 4),
              Text(
                errorText!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ─── Role Dropdown ────────────────────────────────────────────────────────────
class RoleDropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? errorText;

  const RoleDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: errorText != null ? AppColors.error : AppColors.border,
              width: errorText != null ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: const Text(
                'Select your role',
                style: TextStyle(fontSize: 15, color: Color(0xFF9CA3AF)),
              ),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textMuted),
              style: const TextStyle(fontSize: 15, color: AppColors.textDark),
              borderRadius: BorderRadius.circular(12),
              items: items
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.error_outline, size: 13, color: AppColors.error),
              const SizedBox(width: 4),
              Text(errorText!,
                  style: const TextStyle(fontSize: 12, color: AppColors.error)),
            ],
          ),
        ],
      ],
    );
  }
}

// ─── Primary Button ───────────────────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.7),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 1,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

// ─── Error Banner ─────────────────────────────────────────────────────────────
class ErrorBanner extends StatelessWidget {
  final String message;

  const ErrorBanner(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 16, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
