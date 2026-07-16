import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/step_complete_result.dart';

class StepCompleteSheet extends StatelessWidget {
  const StepCompleteSheet({
    super.key,
    required this.result,
    required this.onContinue,
  });

  final StepCompleteResult result;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            result.passed ? Icons.celebration_rounded : Icons.info_outline_rounded,
            color: result.passed ? AppColors.success : AppColors.warning,
            size: 48,
          )
              .animate()
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1, 1),
                duration: 500.ms,
                curve: Curves.elasticOut,
              ),
          const SizedBox(height: 16),
          Text(
            result.passed ? 'Bravo !' : 'Presque !',
            style: AppTextStyles.titleLarge.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Score : ${result.score}% • +${result.xpEarned} XP',
            style: AppTextStyles.bodyMedium.copyWith(color: textColor),
          ),
          const SizedBox(height: 4),
          Text(
            'Parcours : ${result.parcoursPercent.round()}%',
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.darkBodySecondary
                  : AppColors.lightBodySecondary,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Continuer'),
            ),
          ),
        ],
      ),
    );
  }
}
