import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/injection_container.dart';
import '../../domain/entities/delf_test_results.dart';
import '../cubit/delf_test_cubit.dart';
import '../cubit/delf_test_state.dart';

@RoutePage()
class DelfResultScreen extends StatelessWidget {
  const DelfResultScreen({
    super.key,
    @PathParam('sessionId') required this.sessionId,
  });

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DelfTestCubit>(
      create: (_) => sl<DelfTestCubit>()..loadResults(sessionId),
      child: _DelfResultView(sessionId: sessionId),
    );
  }
}

class _DelfResultView extends StatelessWidget {
  const _DelfResultView({required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          const Positioned(
            top: 100,
            left: 28,
            child: _CelebrationDot(
              color: AppColors.accent,
              size: 12,
            ),
          ),
          const Positioned(
            top: 165,
            right: 34,
            child: _CelebrationDot(
              color: AppColors.accentPink,
              size: 15,
            ),
          ),
          const Positioned(
            top: 280,
            left: 52,
            child: _CelebrationDot(
              color: AppColors.accentMint,
              size: 9,
            ),
          ),
          SafeArea(
            child: BlocBuilder<DelfTestCubit, DelfTestState>(
              builder: (context, state) {
                return state.when(
                  initial: () => const _ResultLoadingView(),
                  loading: () => const _ResultLoadingView(),
                  submitting: () => const _ResultLoadingView(),
                  intro: (_, __) => const _ResultLoadingView(),
                  questions: (_, __, ___, ____) => const _ResultLoadingView(),
                  error: (message) => _ResultErrorView(
                    message: message,
                    onRetry: () =>
                        context.read<DelfTestCubit>().loadResults(sessionId),
                  ),
                  results: (results) => _ResultContent(
                    results: results,
                    isDark: isDark,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultContent extends StatelessWidget {
  const _ResultContent({required this.results, required this.isDark});

  final DelfTestResults results;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final score = (results.overallScore ?? 0).clamp(0, 100);
    final level = results.achievedDelfLevel ?? 'À découvrir';
    final textColor =
        isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary;
    final secondary =
        isDark ? AppColors.darkBodySecondary : AppColors.lightBodySecondary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(
                          alpha: isDark ? 0.2 : 0.1,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Test terminé',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${results.classLevel} • Objectif ${results.targetDelfLevel}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.accent,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? const [Color(0xFF244A79), Color(0xFF252F5A)]
                          : const [Color(0xFFE6F2FF), Color(0xFFF0EBFF)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.14),
                        blurRadius: 30,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          'Bravo, beau travail !',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark
                                ? const Color(0xFFFFD66B)
                                : const Color(0xFF9A6800),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _AnimatedScoreRing(score: score, isDark: isDark),
                      const SizedBox(height: 20),
                      Text(
                        'Ton niveau DELF',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        level,
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: isDark
                              ? AppColors.primaryLight
                              : AppColors.primary,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 420.ms).scale(
                      begin: const Offset(0.96, 0.96),
                      curve: Curves.easeOutBack,
                    ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkDivider
                          : AppColors.lightDivider,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.accentPurple.withValues(
                            alpha: isDark ? 0.22 : 0.1,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.insights_rounded,
                          color: AppColors.accentPurple,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ce que dit ton résultat',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              results.comparisonToTarget,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: secondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 180.ms).fadeIn().slideY(begin: 0.08, end: 0),
                const SizedBox(height: 26),
                Text(
                  'Tes résultats par catégorie',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ces scores nous aident à choisir les meilleures activités pour toi.',
                  style: AppTextStyles.bodySmall.copyWith(color: secondary),
                ),
                const SizedBox(height: 14),
                if (results.categoryScores.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      'Les détails par catégorie seront bientôt disponibles.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: secondary,
                      ),
                    ),
                  )
                else
                  ...results.categoryScores.entries.indexed.map((item) {
                    final index = item.$1;
                    final entry = item.$2;
                    final color = _resultColors[index % _resultColors.length];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CategoryScoreCard(
                        category: entry.key,
                        score: entry.value.clamp(0, 100),
                        color: color,
                        isDark: isDark,
                      )
                          .animate(
                            delay: Duration(milliseconds: 240 + (index * 55)),
                          )
                          .fadeIn()
                          .slideY(begin: 0.08, end: 0),
                    );
                  }),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
          decoration: BoxDecoration(
            color:
                (isDark ? AppColors.darkBackground : AppColors.lightBackground)
                    .withValues(alpha: 0.96),
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              ),
            ),
          ),
          child: AppButton(
            text: 'Découvrir mon parcours',
            onPressed: () => context.router.replaceAll([const MainRoute()]),
          ),
        ),
      ],
    );
  }
}

class _AnimatedScoreRing extends StatelessWidget {
  const _AnimatedScoreRing({required this.score, required this.isDark});

  final int score;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: score / 100),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return SizedBox(
          width: 150,
          height: 150,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 13,
                  strokeCap: StrokeCap.round,
                  backgroundColor: isDark
                      ? AppColors.darkDivider
                      : Colors.white.withValues(alpha: 0.8),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(value * 100).round()}%',
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'score global',
                      style: AppTextStyles.labelMedium.copyWith(
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
      },
    );
  }
}

class _CategoryScoreCard extends StatelessWidget {
  const _CategoryScoreCard({
    required this.category,
    required this.score,
    required this.color,
    required this.isDark,
  });

  final String category;
  final int score;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final secondary =
        isDark ? AppColors.darkBodySecondary : AppColors.lightBodySecondary;
    final track = isDark ? AppColors.darkDivider : AppColors.lightDivider;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_scoreIcon(category), color: color, size: 20),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  category,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$score%',
                style: AppTextStyles.calloutBold.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: score / 100),
              duration: const Duration(milliseconds: 850),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                minHeight: 8,
                value: value,
                backgroundColor: track,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _scoreMessage(score),
              style: AppTextStyles.labelMedium.copyWith(color: secondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultLoadingView extends StatelessWidget {
  const _ResultLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(strokeWidth: 4),
          ),
          SizedBox(height: 20),
          Text('Calcul de ton résultat…'),
        ],
      ),
    );
  }
}

class _ResultErrorView extends StatelessWidget {
  const _ResultErrorView({required this.message, required this.onRetry});

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
            const Icon(
              Icons.sentiment_dissatisfied_rounded,
              color: AppColors.error,
              size: 62,
            ),
            const SizedBox(height: 18),
            Text(
              'Ton résultat est momentanément indisponible',
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

class _CelebrationDot extends StatelessWidget {
  const _CelebrationDot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(
            begin: const Offset(0.75, 0.75),
            end: const Offset(1.15, 1.15),
            duration: 1200.ms,
          ),
    );
  }
}

const _resultColors = [
  AppColors.primary,
  AppColors.accentPurple,
  AppColors.accentMint,
  AppColors.accentPink,
  AppColors.warning,
];

IconData _scoreIcon(String category) {
  final normalized = category.toLowerCase();
  if (normalized.contains('gram')) return Icons.account_tree_rounded;
  if (normalized.contains('vocab')) return Icons.chat_bubble_rounded;
  if (normalized.contains('compr')) return Icons.menu_book_rounded;
  if (normalized.contains('orth')) return Icons.spellcheck_rounded;
  return Icons.quiz_rounded;
}

String _scoreMessage(int score) {
  if (score >= 80) return 'Excellent, continue comme ça !';
  if (score >= 60) return 'Très bien, tu progresses vite.';
  if (score >= 40) return 'Bon début, ton parcours va t’aider.';
  return 'Chaque exercice va te faire progresser.';
}
