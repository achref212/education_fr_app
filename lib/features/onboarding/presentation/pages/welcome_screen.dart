import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/injection_container.dart';
import '../../../theme/presentation/cubit/theme_cubit.dart';

@RoutePage()
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<ThemeCubit>(),
      child: const _WelcomeView(),
    );
  }
}

class _WelcomeView extends StatelessWidget {
  const _WelcomeView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TopBar(),
              const SizedBox(height: 8),
              _HeroIllustration(),
              const SizedBox(height: 24),
              _HeadlineText(),
              const Spacer(),
              _PrimaryButton(),
              const SizedBox(height: 16),
              _LoginRow(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Top Bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _LogoBadge(),
        _ThemeToggleButton(),
      ],
    )
        .animate(delay: 100.ms)
        .fadeIn(duration: 500.ms)
        .slideY(begin: -0.1, end: 0, curve: Curves.easeOut);
  }
}

class _LogoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset('assets/icons/icon_screens.png', fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'DELFy',
          style: AppTextStyles.titleMedium.copyWith(
            color: isDark
                ? AppColors.darkBodyPrimary
                : AppColors.lightBodyPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) {
        return GestureDetector(
          onTap: () => context.read<ThemeCubit>().toggleLightDark(),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              color: isDark
                  ? AppColors.darkBodyPrimary
                  : AppColors.lightBodySecondary,
              size: 20,
            ),
          )
              .animate(key: ValueKey(mode))
              .rotate(
                begin: -0.1,
                end: 0,
                duration: 400.ms,
                curve: Curves.easeOut,
              )
              .fadeIn(duration: 300.ms),
        );
      },
    );
  }
}

// ── Hero Illustration ─────────────────────────────────────────────────────────

class _HeroIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      child: Center(
        child: SvgPicture.asset(
          isDark
              ? 'assets/images/welcome_hero_dark.svg'
              : 'assets/images/welcome_hero_light.svg',
          fit: BoxFit.contain,
        )
            .animate(delay: 300.ms)
            .scale(
              begin: const Offset(0.9, 0.9),
              duration: 700.ms,
              curve: Curves.easeOut,
            )
            .fadeIn(duration: 500.ms),
      ),
    );
  }
}

// ── Headline ──────────────────────────────────────────────────────────────────

class _HeadlineText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      'Apprenez le français\nen 3 minutes par jour',
      textAlign: TextAlign.center,
      style: AppTextStyles.headlineMedium.copyWith(
        color: isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary,
        height: 1.25,
      ),
    )
        .animate(delay: 600.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.3, end: 0, curve: Curves.easeOut);
  }
}

// ── Buttons ───────────────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          context.router.push(const RegisterRoute());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'Commencer à apprendre',
          style: AppTextStyles.calloutBold.copyWith(
            color: AppColors.onPrimary,
          ),
        ),
      ),
    )
        .animate(delay: 750.ms)
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.3, end: 0, curve: Curves.easeOut);
  }
}

class _LoginRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Vous avez déjà un compte?',
          style: AppTextStyles.bodyMedium.copyWith(color: textColor),
        ),
        TextButton(
          onPressed: () {
            context.router.push(const LoginRoute());
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Se connecter',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primary,
            ),
          ),
        ),
      ],
    )
        .animate(delay: 850.ms)
        .fadeIn(duration: 500.ms);
  }
}
