import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/parcours_step.dart';

class ParcoursNode extends StatelessWidget {
  const ParcoursNode({
    super.key,
    required this.step,
    required this.isLast,
    this.onTap,
    this.animationDelay = Duration.zero,
  });

  final ParcoursStep step;
  final bool isLast;
  final VoidCallback? onTap;
  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary;
    final secondaryColor =
        isDark ? AppColors.darkBodySecondary : AppColors.lightBodySecondary;
    final Color nodeColor = _resolveNodeColor();
    final IconData icon = _resolveIcon();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            GestureDetector(
              onTap: step.canStart ? onTap : null,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: nodeColor.withValues(alpha: step.isLocked ? 0.15 : 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: nodeColor, width: 2),
                ),
                child: Icon(
                  icon,
                  color: nodeColor,
                  size: 22,
                ),
              ),
            )
                .animate(delay: animationDelay)
                .fadeIn(duration: 350.ms)
                .slideX(begin: -0.1, end: 0),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                color: step.isCompleted
                    ? AppColors.success.withValues(alpha: 0.5)
                    : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: step.isLocked ? secondaryColor : textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _resolveSubtitle(),
                  style: AppTextStyles.bodySmall.copyWith(color: secondaryColor),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _resolveNodeColor() {
    if (step.isCompleted) return AppColors.success;
    if (step.isInProgress) return AppColors.warning;
    if (step.isAvailable) return AppColors.primary;
    return AppColors.lightBodySecondary;
  }

  IconData _resolveIcon() {
    if (step.isLocked) return Icons.lock_rounded;
    if (step.isCompleted) return Icons.check_rounded;
    switch (step.stepType) {
      case 'quiz':
        return Icons.quiz_rounded;
      case 'story':
        return Icons.auto_stories_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }

  String _resolveSubtitle() {
    if (step.isLocked) return 'Verrouillé';
    if (step.isCompleted) {
      return 'Terminé • ${step.score ?? 0}% • +${step.xpReward} XP';
    }
    if (step.isInProgress) return 'En cours • +${step.xpReward} XP';
    return 'Disponible • +${step.xpReward} XP';
  }
}
