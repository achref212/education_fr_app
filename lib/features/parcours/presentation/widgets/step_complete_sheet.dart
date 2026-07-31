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
    required this.onNextStep,
    this.quizResult,
  });

  final StepCompleteResult result;
  final VoidCallback onContinue;
  final VoidCallback? onNextStep;
  final QuizResultSummary? quizResult;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary;
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                result.passed
                    ? Icons.celebration_rounded
                    : Icons.info_outline_rounded,
                color: result.passed ? AppColors.success : AppColors.warning,
                size: 48,
              ).animate().scale(
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
              if (quizResult != null) ...[
                const SizedBox(height: 16),
                _QuizResultCard(result: quizResult!),
              ],
              if (result.nextStepId != null) ...[
                const SizedBox(height: 10),
                Text(
                  'La prochaine étape est prête.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onNextStep ?? onContinue,
                  icon: Icon(
                    result.nextStepId == null
                        ? Icons.route_rounded
                        : Icons.arrow_forward_rounded,
                  ),
                  label: Text(
                    result.nextStepId == null
                        ? 'Terminer et voir mon parcours'
                        : 'Ouvrir l’étape suivante',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (result.nextStepId != null) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: onContinue,
                  child: const Text('Revenir au parcours'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class QuizResultSummary {
  const QuizResultSummary({
    required this.correctCount,
    required this.totalCount,
    required this.answers,
  });

  final int correctCount;
  final int totalCount;
  final List<QuizAnswerReview> answers;

  int get incorrectCount => totalCount - correctCount;
}

class QuizAnswerReview {
  const QuizAnswerReview({
    required this.question,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    this.explanation,
  });

  final String question;
  final String selectedAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final String? explanation;
}

class _QuizResultCard extends StatelessWidget {
  const _QuizResultCard({required this.result});

  final QuizResultSummary result;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDark ? AppColors.darkSurfaceElevated : AppColors.lightBackground;
    final border = isDark ? AppColors.darkDivider : AppColors.lightDivider;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: result.incorrectCount > 0,
            tilePadding: const EdgeInsets.symmetric(horizontal: 14),
            childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            leading:
                const Icon(Icons.fact_check_rounded, color: AppColors.primary),
            title: Text(
              'Résultat du quiz',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            subtitle: Text(
              '${result.correctCount}/${result.totalCount} réponses justes',
            ),
            children: [
              for (final answer in result.answers) ...[
                _AnswerReviewTile(answer: answer),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AnswerReviewTile extends StatelessWidget {
  const _AnswerReviewTile({required this.answer});

  final QuizAnswerReview answer;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = answer.isCorrect ? AppColors.success : AppColors.error;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.36)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                answer.isCorrect
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  answer.question,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Ta réponse : ${answer.selectedAnswer}',
              style: AppTextStyles.bodySmall),
          if (!answer.isCorrect)
            Text('Bonne réponse : ${answer.correctAnswer}',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w800,
                )),
          if (answer.explanation != null && answer.explanation!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              answer.explanation!,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.darkBodySecondary
                    : AppColors.lightBodySecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
