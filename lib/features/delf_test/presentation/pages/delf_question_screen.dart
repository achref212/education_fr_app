import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/injection_container.dart';
import '../../domain/entities/delf_test_question.dart';
import '../../domain/entities/delf_test_section.dart';
import '../../domain/entities/delf_test_session.dart';
import '../cubit/delf_test_cubit.dart';
import '../cubit/delf_test_state.dart';

@RoutePage()
class DelfQuestionScreen extends StatefulWidget {
  const DelfQuestionScreen({super.key});

  @override
  State<DelfQuestionScreen> createState() => _DelfQuestionScreenState();
}

class _DelfQuestionScreenState extends State<DelfQuestionScreen> {
  final Map<String, int> _answers = <String, int>{};
  int _currentQuestionIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return BlocProvider<DelfTestCubit>(
      create: (_) => sl<DelfTestCubit>()..loadActiveSession(),
      child: BlocConsumer<DelfTestCubit, DelfTestState>(
        listener: (context, state) {
          state.maybeWhen(
            results: (results) {
              context.router.replace(
                DelfResultRoute(sessionId: results.sessionId),
              );
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: background,
            body: SafeArea(
              child: state.when(
                initial: () => const _TestLoadingView(
                  message: 'Préparation de ton test…',
                ),
                loading: () => const _TestLoadingView(
                  message: 'Chargement des questions…',
                ),
                submitting: () => const _TestLoadingView(
                  message: 'Validation de tes réponses…',
                ),
                intro: (_, __) => const _TestLoadingView(
                  message: 'Préparation de ton test…',
                ),
                results: (_) => const _TestLoadingView(
                  message: 'Calcul de ton résultat…',
                ),
                error: (message) => _TestErrorView(
                  message: message,
                  onRetry: () =>
                      context.read<DelfTestCubit>().loadActiveSession(),
                ),
                questions: (session, section, sectionIndex, totalSections) {
                  if (_currentQuestionIndex >= section.questions.length) {
                    _currentQuestionIndex = 0;
                  }
                  return _buildQuestionView(
                    context,
                    session,
                    section,
                    sectionIndex,
                    totalSections,
                    isDark,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuestionView(
    BuildContext context,
    DelfTestSession session,
    DelfTestSection section,
    int sectionIndex,
    int totalSections,
    bool isDark,
  ) {
    if (section.questions.isEmpty) {
      return _TestErrorView(
        message: 'Cette section ne contient aucune question.',
        onRetry: () => context.read<DelfTestCubit>().loadActiveSession(),
      );
    }

    final question = section.questions[_currentQuestionIndex];
    final selectedIndex = _answers[question.id];
    final sectionProgress =
        (_currentQuestionIndex + 1) / section.questions.length;
    final overallProgress =
        ((sectionIndex - 1) + sectionProgress) / totalSections;
    final accent = _categoryAccent(section.category);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _RoundIconButton(
                icon: Icons.close_rounded,
                tooltip: 'Quitter le test',
                onPressed: () => context.router.maybePop(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test de niveau DELF',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${session.classLevel} • Objectif ${session.targetDelfLevel}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.darkBodySecondary
                            : AppColors.lightBodySecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${_currentQuestionIndex + 1}/${section.questions.length}',
                  style: AppTextStyles.calloutBold.copyWith(color: accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _ProgressHeader(
            sectionIndex: sectionIndex,
            totalSections: totalSections,
            category: section.category,
            progress: overallProgress.clamp(0, 1),
            accent: accent,
            isDark: isDark,
          ),
          const SizedBox(height: 18),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: _QuestionContent(
                key: ValueKey(question.id),
                question: question,
                selectedIndex: selectedIndex,
                accent: accent,
                isDark: isDark,
                onSelected: (index) {
                  HapticFeedback.selectionClick();
                  setState(() => _answers[question.id] = index);
                },
              ),
            ),
          ),
          const SizedBox(height: 14),
          AppButton(
            text: _currentQuestionIndex < section.questions.length - 1
                ? 'Question suivante'
                : 'Valider cette section',
            onPressed: selectedIndex == null || question.options.isEmpty
                ? null
                : () => _handleNext(context, session, section),
          ),
        ],
      ),
    );
  }

  void _handleNext(
    BuildContext context,
    DelfTestSession session,
    DelfTestSection section,
  ) {
    HapticFeedback.lightImpact();
    if (_currentQuestionIndex < section.questions.length - 1) {
      setState(() => _currentQuestionIndex++);
      return;
    }
    context.read<DelfTestCubit>().submitSection(
          session: session,
          section: section,
          answers: _answers,
        );
    setState(() {
      _answers.clear();
      _currentQuestionIndex = 0;
    });
  }
}

class _QuestionContent extends StatelessWidget {
  const _QuestionContent({
    super.key,
    required this.question,
    required this.selectedIndex,
    required this.accent,
    required this.isDark,
    required this.onSelected,
  });

  final DelfTestQuestion question;
  final int? selectedIndex;
  final Color accent;
  final bool isDark;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor =
        isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary;
    final secondary =
        isDark ? AppColors.darkBodySecondary : AppColors.lightBodySecondary;

    return ListView(
      padding: const EdgeInsets.only(bottom: 4),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: accent.withValues(alpha: isDark ? 0.34 : 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.05),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: isDark ? 0.22 : 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _categoryIcon(question.category),
                      color: accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Choisis la bonne réponse',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: isDark ? 0.18 : 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      question.level,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                question.question,
                style: AppTextStyles.titleLarge.copyWith(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (question.options.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.3),
              ),
            ),
            child: const Text(
              'Aucune option disponible pour cette question.',
              textAlign: TextAlign.center,
            ),
          )
        else
          ...List.generate(question.options.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AnswerOption(
                index: index,
                text: question.options[index],
                isSelected: selectedIndex == index,
                accent: accent,
                isDark: isDark,
                onTap: () => onSelected(index),
              )
                  .animate(
                    delay: Duration(milliseconds: 45 * index),
                  )
                  .fadeIn(duration: 280.ms)
                  .slideY(begin: 0.08, end: 0),
            );
          }),
      ],
    );
  }
}

class _AnswerOption extends StatelessWidget {
  const _AnswerOption({
    required this.index,
    required this.text,
    required this.isSelected,
    required this.accent,
    required this.isDark,
    required this.onTap,
  });

  final int index;
  final String text;
  final bool isSelected;
  final Color accent;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final divider = isDark ? AppColors.darkDivider : AppColors.lightDivider;
    final textColor =
        isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary;
    final letter = String.fromCharCode(65 + index);

    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Réponse $letter, $text',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isSelected
              ? accent.withValues(alpha: isDark ? 0.24 : 0.1)
              : surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? accent : divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: accent.withValues(alpha: 0.16),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? accent
                          : accent.withValues(alpha: isDark ? 0.18 : 0.09),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Text(
                      letter,
                      style: AppTextStyles.calloutBold.copyWith(
                        color: isSelected ? Colors.white : accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      text,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: textColor,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: isSelected
                        ? Icon(
                            Icons.check_circle_rounded,
                            key: const ValueKey('selected'),
                            color: accent,
                            size: 25,
                          )
                        : Icon(
                            Icons.radio_button_unchecked_rounded,
                            key: const ValueKey('unselected'),
                            color: divider,
                            size: 24,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.sectionIndex,
    required this.totalSections,
    required this.category,
    required this.progress,
    required this.accent,
    required this.isDark,
  });

  final int sectionIndex;
  final int totalSections;
  final String category;
  final double progress;
  final Color accent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final secondary =
        isDark ? AppColors.darkBodySecondary : AppColors.lightBodySecondary;
    final track = isDark ? AppColors.darkDivider : AppColors.lightDivider;

    return Column(
      children: [
        Row(
          children: [
            Icon(_categoryIcon(category), size: 18, color: accent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                category,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              'Étape $sectionIndex sur $totalSections',
              style: AppTextStyles.bodySmall.copyWith(
                color: secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 550),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => LinearProgressIndicator(
              minHeight: 9,
              value: value,
              backgroundColor: track,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
        foregroundColor:
            isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary,
        minimumSize: const Size(44, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),
        ),
      ),
      icon: Icon(icon),
    );
  }
}

class _TestLoadingView extends StatelessWidget {
  const _TestLoadingView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: 20),
          Text(message, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

class _TestErrorView extends StatelessWidget {
  const _TestErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sentiment_dissatisfied_rounded,
                color: AppColors.error,
                size: 36,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Oups, un problème est survenu',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.darkBodySecondary
                    : AppColors.lightBodySecondary,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: 210,
              child: AppButton(text: 'Réessayer', onPressed: onRetry),
            ),
          ],
        ),
      ),
    );
  }
}

Color _categoryAccent(String category) {
  final normalized = category.toLowerCase();
  if (normalized.contains('gram')) return AppColors.accentPurple;
  if (normalized.contains('vocab')) return AppColors.accentMint;
  if (normalized.contains('compr')) return AppColors.accentPink;
  if (normalized.contains('orth')) return AppColors.warning;
  return AppColors.primary;
}

IconData _categoryIcon(String category) {
  final normalized = category.toLowerCase();
  if (normalized.contains('gram')) return Icons.account_tree_rounded;
  if (normalized.contains('vocab')) return Icons.chat_bubble_rounded;
  if (normalized.contains('compr')) return Icons.menu_book_rounded;
  if (normalized.contains('orth')) return Icons.spellcheck_rounded;
  return Icons.quiz_rounded;
}
