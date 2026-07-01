import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.label,
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.value,
    this.validator,
  });

  final String label;
  final String hintText;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final T? value;
  final String? Function(T?)? validator;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final hintColor =
        isDark ? AppColors.darkBodySecondary : AppColors.lightBodySecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          icon: Icon(Icons.arrow_drop_down, color: hintColor),
          dropdownColor: surfaceColor,
          style: AppTextStyles.bodyLarge.copyWith(color: textColor),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.bodyLarge.copyWith(color: hintColor),
            filled: true,
            fillColor: surfaceColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
