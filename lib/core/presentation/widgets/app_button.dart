import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAvailable = onPressed != null;
    final useActiveStyle = isAvailable || isLoading;

    final backgroundColor = isSecondary
        ? (isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurface)
        : AppColors.primary;

    final textColor = isSecondary
        ? (isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary)
        : AppColors.onPrimary;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: isSecondary || !useActiveStyle
            ? null
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading || onPressed == null ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            disabledBackgroundColor: isLoading
                ? backgroundColor.withValues(alpha: 0.82)
                : (isDark
                    ? AppColors.darkSurfaceElevated
                    : AppColors.lightSurface),
            foregroundColor: textColor,
            disabledForegroundColor: isDark
                ? AppColors.darkBodySecondary
                : AppColors.lightBodySecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 0,
          ),
          child: isLoading
              ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: textColor,
                  ),
                )
              : Text(
                  text,
                  style: AppTextStyles.calloutBold.copyWith(
                    color: isAvailable
                        ? textColor
                        : (isDark
                            ? AppColors.darkBodySecondary
                            : AppColors.lightBodySecondary),
                  ),
                ),
        ),
      ),
    );
  }
}
