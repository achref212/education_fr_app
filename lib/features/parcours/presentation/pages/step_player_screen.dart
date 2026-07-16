import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/injection_container.dart';
import '../../../content/domain/entities/quiz_question.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StepPlayerCubit, StepPlayerState>(
      listener: (BuildContext context, StepPlayerState state) {
        state.maybeWhen(
          completed: (result) {
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (BuildContext ctx) => StepCompleteSheet(
                result: result,
                onContinue: () {
                  Navigator.of(ctx).pop();
                  context.router.maybePop(true);
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
                        context.read<StepPlayerCubit>().loadStep(widget.stepId),
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
            ),
            quiz: (step, questions, classLevel) => _buildQuizView(
              context,
              step.id,
              questions,
            ),
            story: (step, story, classLevel) => _buildStoryView(
              context,
              step.id,
              story.title,
              story.content,
              story.audioUrl,
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
    String content,
  ) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LearningHeaderCard(
              icon: Icons.menu_book_rounded,
              label: 'Leçon',
              title: title,
              color: AppColors.primary,
            ),
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
              text: 'Terminer',
              onPressed: () => context.read<StepPlayerCubit>().completeStep(
                    stepId: stepId,
                    score: 100,
                  ),
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
    String? audioUrl,
  ) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LearningHeaderCard(
              icon: Icons.auto_stories_rounded,
              label: audioUrl == null ? 'Histoire' : 'Histoire audio',
              title: title,
              color: AppColors.accentPurple,
            ),
            if (audioUrl != null) ...[
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
              text: 'Terminer',
              onPressed: () => context.read<StepPlayerCubit>().completeStep(
                    stepId: stepId,
                    score: 100,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizView(
    BuildContext context,
    String stepId,
    List<QuizQuestion> questions,
  ) {
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
    for (final QuizQuestion question in questions) {
      final int? selected = _answers[question.id];
      if (selected == question.correctIndex) correct++;
    }
    final int score = ((correct / questions.length) * 100).round();
    context.read<StepPlayerCubit>().completeStep(stepId: stepId, score: score);
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
