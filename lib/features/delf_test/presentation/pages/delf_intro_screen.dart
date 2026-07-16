import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/injection_container.dart';
import '../cubit/delf_test_cubit.dart';
import '../cubit/delf_test_state.dart';

@RoutePage()
class DelfIntroScreen extends StatelessWidget {
  const DelfIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DelfTestCubit>(
      create: (_) => sl<DelfTestCubit>()..loadIntro(),
      child: const _DelfIntroView(),
    );
  }
}

class _DelfIntroView extends StatelessWidget {
  const _DelfIntroView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          Positioned(
            top: -90,
            right: -70,
            child: _DecorativeOrb(
              size: 230,
              color: AppColors.primary.withValues(
                alpha: isDark ? 0.16 : 0.1,
              ),
            ),
          ),
          Positioned(
            bottom: 130,
            left: -70,
            child: _DecorativeOrb(
              size: 170,
              color: AppColors.accentMint.withValues(
                alpha: isDark ? 0.12 : 0.13,
              ),
            ),
          ),
          SafeArea(
            child: BlocConsumer<DelfTestCubit, DelfTestState>(
              listener: (context, state) {
                state.maybeWhen(
                  questions: (_, __, ___, ____) {
                    context.router.replace(const DelfQuestionRoute());
                  },
                  orElse: () {},
                );
              },
              builder: (context, state) {
                return state.when(
                  initial: () => const _IntroLoadingView(),
                  loading: () => const _IntroLoadingView(),
                  submitting: () => const _IntroLoadingView(),
                  questions: (_, __, ___, ____) => const _IntroLoadingView(),
                  results: (_) => const _IntroLoadingView(),
                  error: (message) => _IntroErrorView(
                    message: message,
                    onRetry: () => context.read<DelfTestCubit>().loadIntro(),
                  ),
                  intro: (classLevel, targetDelfLevel) => _IntroContent(
                    classLevel: classLevel,
                    targetDelfLevel: targetDelfLevel,
                    isDark: isDark,
                    onStart: () => context.read<DelfTestCubit>().startTest(),
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

class _IntroContent extends StatelessWidget {
  const _IntroContent({
    required this.classLevel,
    required this.targetDelfLevel,
    required this.isDark,
    required this.onStart,
  });

  final String classLevel;
  final String targetDelfLevel;
  final bool isDark;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final textColor =
        isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary;
    final secondary =
        isDark ? AppColors.darkBodySecondary : AppColors.lightBodySecondary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Retour',
                      onPressed: () => context.router.maybePop(),
                      style: IconButton.styleFrom(
                        backgroundColor: surface,
                        foregroundColor: textColor,
                        minimumSize: const Size(46, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: isDark
                                ? AppColors.darkDivider
                                : AppColors.lightDivider,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentMint.withValues(
                          alpha: isDark ? 0.18 : 0.11,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            color: AppColors.accentMint,
                            size: 17,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Test personnalisé',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.accentMint,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Center(
                  child: _HeroBadge(isDark: isDark)
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(
                        begin: const Offset(0.82, 0.82),
                        curve: Curves.easeOutBack,
                      ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Découvrons ton niveau de français',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: textColor,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.18,
                  ),
                ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.08, end: 0),
                const SizedBox(height: 12),
                Text(
                  'Réponds tranquillement aux questions. Ton parcours sera ensuite adapté à ce que tu sais déjà.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: secondary,
                    height: 1.55,
                  ),
                ).animate(delay: 160.ms).fadeIn(),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _InfoChip(
                      icon: Icons.school_rounded,
                      label: classLevel,
                      color: AppColors.primary,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 10),
                    _InfoChip(
                      icon: Icons.flag_rounded,
                      label: 'Objectif $targetDelfLevel',
                      color: AppColors.accentPurple,
                      isDark: isDark,
                    ),
                  ],
                ).animate(delay: 220.ms).fadeIn().slideY(begin: 0.08, end: 0),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkDivider
                          : AppColors.lightDivider,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.1 : 0.04,
                        ),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Column(
                    children: [
                      _FeatureRow(
                        icon: Icons.touch_app_rounded,
                        color: AppColors.primary,
                        title: 'Choisis une réponse',
                        subtitle: 'Les options sont grandes et faciles à lire.',
                      ),
                      SizedBox(height: 14),
                      _FeatureRow(
                        icon: Icons.self_improvement_rounded,
                        color: AppColors.accentMint,
                        title: 'Avance à ton rythme',
                        subtitle:
                            'Prends le temps de réfléchir à chaque question.',
                      ),
                      SizedBox(height: 14),
                      _FeatureRow(
                        icon: Icons.insights_rounded,
                        color: AppColors.accentPurple,
                        title: 'Reçois ton résultat',
                        subtitle: 'Découvre tes points forts et ton parcours.',
                      ),
                    ],
                  ),
                ).animate(delay: 280.ms).fadeIn().slideY(begin: 0.08, end: 0),
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
            text: 'Je commence le test',
            onPressed: onStart,
          ),
        ),
      ],
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 116,
            height: 116,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryLight, AppColors.primary],
              ),
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: const Icon(
              Icons.psychology_alt_rounded,
              color: Colors.white,
              size: 58,
            ),
          ),
          Positioned(
            top: 2,
            right: 1,
            child: _FloatingIcon(
              icon: Icons.star_rounded,
              color: AppColors.accent,
              isDark: isDark,
            ),
          ),
          Positioned(
            bottom: 2,
            left: 0,
            child: _FloatingIcon(
              icon: Icons.check_rounded,
              color: AppColors.accentMint,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingIcon extends StatelessWidget {
  const _FloatingIcon({
    required this.icon,
    required this.color,
    required this.isDark,
  });

  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurface,
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 14,
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 23),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.24)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 17),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
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
    );
  }
}

class _IntroLoadingView extends StatelessWidget {
  const _IntroLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: CircularProgressIndicator(strokeWidth: 4),
          ),
          SizedBox(height: 20),
          Text('Préparation de ton test…'),
        ],
      ),
    );
  }
}

class _IntroErrorView extends StatelessWidget {
  const _IntroErrorView({required this.message, required this.onRetry});

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
              Icons.cloud_off_rounded,
              color: AppColors.error,
              size: 62,
            ),
            const SizedBox(height: 18),
            Text(
              'Le test ne peut pas être chargé',
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

class _DecorativeOrb extends StatelessWidget {
  const _DecorativeOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
