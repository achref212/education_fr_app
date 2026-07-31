import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/network/media_url.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/injection_container.dart';
import '../../../content/domain/entities/quiz_question.dart';
import '../../domain/entities/parcours_step.dart';
import '../../domain/usecases/complete_step_use_case.dart';
import '../cubit/step_player_cubit.dart';
import '../cubit/step_player_state.dart';
import '../widgets/step_complete_sheet.dart';

@RoutePage()
class StepPlayerScreen extends StatelessWidget {
  const StepPlayerScreen({
    super.key,
    @PathParam('stepId') required this.stepId,
  });

  final String stepId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StepPlayerCubit>(
      create: (_) => sl<StepPlayerCubit>()..loadStep(stepId),
      child: _StepPlayerView(stepId: stepId),
    );
  }
}

class _StepPlayerView extends StatefulWidget {
  const _StepPlayerView({required this.stepId});

  final String stepId;

  @override
  State<_StepPlayerView> createState() => _StepPlayerViewState();
}

class _StepPlayerViewState extends State<_StepPlayerView> {
  final Map<String, int> _answers = <String, int>{};
  int _currentQuestionIndex = 0;
  late String _activeStepId;
  QuizResultSummary? _lastQuizResult;

  @override
  void initState() {
    super.initState();
    _activeStepId = widget.stepId;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StepPlayerCubit, StepPlayerState>(
      listener: (BuildContext context, StepPlayerState state) {
        state.maybeWhen(
          completed: (result) {
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              isDismissible: false,
              enableDrag: false,
              backgroundColor: Colors.transparent,
              builder: (BuildContext ctx) => StepCompleteSheet(
                result: result,
                quizResult: _lastQuizResult,
                onContinue: () {
                  Navigator.of(ctx).pop();
                  context.router.maybePop(true);
                },
                onNextStep: result.nextStepId == null
                    ? null
                    : () {
                        Navigator.of(ctx).pop();
                        _openNextStep(context, result.nextStepId!);
                      },
              ),
            );
          },
          orElse: () {},
        );
      },
      builder: (BuildContext context, StepPlayerState state) {
        return Scaffold(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkBackground
              : AppColors.lightBackground,
          appBar: AppBar(
            title: const Text('Session'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            completing: () => const Center(child: CircularProgressIndicator()),
            completed: (_) => const SizedBox.shrink(),
            error: (String message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<StepPlayerCubit>().loadStep(_activeStepId),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
            lesson: (step, lesson, classLevel) => _buildLessonView(
              context,
              step.id,
              lesson.title,
              lesson.content,
              isReview: step.isCompleted,
              score: step.score,
            ),
            quiz: (step, questions, classLevel) => _buildQuizView(
              context,
              step.id,
              questions,
              isReview: step.isCompleted,
              score: step.score,
              savedAnswers: step.answers,
            ),
            story: (step, story, classLevel) => _buildStoryView(
              context,
              step.id,
              story.title,
              story.content,
              story.audioUrl,
              isReview: step.isCompleted,
              score: step.score,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLessonView(
    BuildContext context,
    String stepId,
    String title,
    String content, {
    required bool isReview,
    int? score,
  }) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LearningHeaderCard(
              icon: Icons.menu_book_rounded,
              label: isReview ? 'Leçon terminée' : 'Leçon',
              title: title,
              color: AppColors.primary,
            ),
            if (isReview) ...[
              const SizedBox(height: 12),
              _CompletedReviewBanner(score: score),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: _ReadableContentCard(
                child: SingleChildScrollView(
                  child: Text(
                    content,
                    style: AppTextStyles.bodyLarge.copyWith(height: 1.45),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              text: isReview ? 'Revenir au parcours' : 'Terminer',
              onPressed: () {
                if (isReview) {
                  context.router.maybePop(false);
                  return;
                }
                setState(() => _lastQuizResult = null);
                context.read<StepPlayerCubit>().completeStep(
                      stepId: stepId,
                      score: 100,
                    );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryView(
    BuildContext context,
    String stepId,
    String title,
    String content,
    String? audioUrl, {
    required bool isReview,
    int? score,
  }) {
    final resolvedAudioUrl = resolveMediaUrl(audioUrl);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LearningHeaderCard(
              icon: Icons.auto_stories_rounded,
              label: isReview
                  ? 'Histoire terminée'
                  : audioUrl == null
                      ? 'Histoire'
                      : 'Histoire audio',
              title: title,
              color: AppColors.accentPurple,
            ),
            if (isReview) ...[
              const SizedBox(height: 12),
              _CompletedReviewBanner(score: score),
            ],
            if (resolvedAudioUrl.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.headphones_rounded,
                      color: AppColors.accentPurple),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Audio disponible',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.accentPurple,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: _ReadableContentCard(
                child: SingleChildScrollView(
                  child: Text(
                    content,
                    style: AppTextStyles.bodyLarge.copyWith(height: 1.45),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              text: isReview ? 'Revenir au parcours' : 'Terminer',
              onPressed: () {
                if (isReview) {
                  context.router.maybePop(false);
                  return;
                }
                setState(() => _lastQuizResult = null);
                context.read<StepPlayerCubit>().completeStep(
                      stepId: stepId,
                      score: 100,
                    );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizView(
    BuildContext context,
    String stepId,
    List<QuizQuestion> questions, {
    required bool isReview,
    int? score,
    List<ParcoursStepAnswer> savedAnswers = const <ParcoursStepAnswer>[],
  }) {
    if (isReview) {
      return _buildQuizReviewView(context, questions, score, savedAnswers);
    }
    final QuizQuestion question = questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / questions.length;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _QuizProgressHeader(
              current: _currentQuestionIndex + 1,
              total: questions.length,
              progress: progress,
            ),
            const SizedBox(height: 18),
            _ReadableContentCard(
              child: Text(
                question.question,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: question.options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (BuildContext context, int index) {
                  final bool isSelected = _answers[question.id] == index;
                  return _QuizOptionTile(
                    text: question.options[index],
                    index: index,
                    isSelected: isSelected,
                    onTap: () => setState(() => _answers[question.id] = index),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              text: _currentQuestionIndex < questions.length - 1
                  ? 'Suivant'
                  : 'Terminer le quiz',
              onPressed: _answers.containsKey(question.id)
                  ? () => _handleQuizNext(context, stepId, questions)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizReviewView(
    BuildContext context,
    List<QuizQuestion> questions,
    int? score,
    List<ParcoursStepAnswer> savedAnswers,
  ) {
    final answersByQuestionId = {
      for (final answer in savedAnswers)
        answer.questionId: answer.selectedIndex,
    };
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _LearningHeaderCard(
              icon: Icons.fact_check_rounded,
              label: 'Quiz terminé',
              title: 'Résultat et correction',
              color: AppColors.success,
            ),
            const SizedBox(height: 12),
            _CompletedReviewBanner(
              score: score,
              message:
                  'Tu peux revoir les réponses correctes et les explications.',
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: questions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (BuildContext context, int index) {
                  return _QuizCorrectionTile(
                    question: questions[index],
                    index: index,
                    selectedIndex: answersByQuestionId[questions[index].id],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Revenir au parcours',
              onPressed: () => context.router.maybePop(false),
            ),
          ],
        ),
      ),
    );
  }

  void _handleQuizNext(
    BuildContext context,
    String stepId,
    List<QuizQuestion> questions,
  ) {
    if (_currentQuestionIndex < questions.length - 1) {
      setState(() => _currentQuestionIndex++);
      return;
    }
    int correct = 0;
    final reviews = <QuizAnswerReview>[];
    for (final QuizQuestion question in questions) {
      final int? selected = _answers[question.id];
      if (selected == null) continue;
      final bool isCorrect = selected == question.correctIndex;
      if (isCorrect) correct++;
      reviews.add(
        QuizAnswerReview(
          question: question.question,
          selectedAnswer: question.options[selected],
          correctAnswer: question.options[question.correctIndex],
          isCorrect: isCorrect,
          explanation: question.explanation,
        ),
      );
    }
    final int score = ((correct / questions.length) * 100).round();
    final answers = questions
        .where((QuizQuestion question) => _answers.containsKey(question.id))
        .map(
          (QuizQuestion question) => StepAnswer(
            questionId: question.id,
            selectedIndex: _answers[question.id]!,
          ),
        )
        .toList();
    setState(() {
      _lastQuizResult = QuizResultSummary(
        correctCount: correct,
        totalCount: questions.length,
        answers: reviews,
      );
    });
    context.read<StepPlayerCubit>().completeStep(
          stepId: stepId,
          score: score,
          answers: answers,
        );
  }

  void _openNextStep(BuildContext context, String stepId) {
    setState(() {
      _activeStepId = stepId;
      _answers.clear();
      _currentQuestionIndex = 0;
      _lastQuizResult = null;
    });
    context.read<StepPlayerCubit>().loadStep(stepId);
  }
}

class _LearningHeaderCard extends StatelessWidget {
  const _LearningHeaderCard({
    required this.icon,
    required this.label,
    required this.title,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.86), color],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadableContentCard extends StatelessWidget {
  const _ReadableContentCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
      ),
      child: child,
    );
  }
}

class _CompletedReviewBanner extends StatelessWidget {
  const _CompletedReviewBanner({
    required this.score,
    this.message =
        'Étape terminée. Tu peux la relire sans perdre ta progression.',
  });

  final int? score;
  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: isDark ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.36)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.success),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  score == null
                      ? 'Résultat enregistré'
                      : 'Résultat enregistré : $score%',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.darkBodySecondary
                        : AppColors.lightBodySecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizCorrectionTile extends StatelessWidget {
  const _QuizCorrectionTile({
    required this.question,
    required this.index,
    required this.selectedIndex,
  });

  final QuizQuestion question;
  final int index;
  final int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface =
        isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurface;
    final border = isDark ? AppColors.darkDivider : AppColors.lightDivider;
    final textColor =
        isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary;
    final correctAnswer = question.options[question.correctIndex];
    final hasSelectedAnswer =
        selectedIndex != null && selectedIndex! < question.options.length;
    final selectedAnswer =
        hasSelectedAnswer ? question.options[selectedIndex!] : null;
    final isCorrect = selectedIndex == question.correctIndex;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${index + 1}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question.question,
            style: AppTextStyles.bodyMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          if (selectedAnswer != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isCorrect ? AppColors.success : AppColors.error)
                    .withValues(alpha: isDark ? 0.18 : 0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: (isCorrect ? AppColors.success : AppColors.error)
                      .withValues(alpha: 0.34),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isCorrect
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: isCorrect ? AppColors.success : AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ta réponse : $selectedAnswer',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ] else ...[
            Text(
              'Ta réponse enregistrée n’est pas disponible pour cette question.',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.darkBodySecondary
                    : AppColors.lightBodySecondary,
              ),
            ),
            const SizedBox(height: 10),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: isDark ? 0.18 : 0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.34),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bonne réponse : $correctAnswer',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (question.explanation != null &&
              question.explanation!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              question.explanation!,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.darkBodySecondary
                    : AppColors.lightBodySecondary,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuizProgressHeader extends StatelessWidget {
  const _QuizProgressHeader({
    required this.current,
    required this.total,
    required this.progress,
  });

  final int current;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Question $current/$total',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Spacer(),
            Icon(
              Icons.quiz_rounded,
              color: isDark
                  ? AppColors.darkBodySecondary
                  : AppColors.lightBodySecondary,
            ),
          ],
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor:
                isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurface,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _QuizOptionTile extends StatelessWidget {
  const _QuizOptionTile({
    required this.text,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  final String text;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface =
        isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurface;
    final borderColor = isSelected
        ? AppColors.primary
        : isDark
            ? AppColors.darkDivider
            : AppColors.lightDivider;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.12)
              : surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : isDark
                          ? AppColors.darkBodySecondary
                          : AppColors.lightBodySecondary,
                ),
              ),
              child: Text(
                String.fromCharCode(65 + index),
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected
                      ? AppColors.onPrimary
                      : isDark
                          ? AppColors.darkBodySecondary
                          : AppColors.lightBodySecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.darkBodyPrimary
                      : AppColors.lightBodyPrimary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
