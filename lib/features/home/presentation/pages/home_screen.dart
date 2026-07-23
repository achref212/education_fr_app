import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/network/media_url.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/injection_container.dart';
import '../../../parcours/domain/entities/parcours.dart';
import '../../../parcours/domain/entities/parcours_summary.dart';
import '../../../parcours/domain/entities/parcours_step.dart';
import '../../../parcours/presentation/widgets/completion_ring.dart';
import '../../../parcours/presentation/widgets/parcours_path_preview.dart';
import '../../../parcours/presentation/widgets/streak_chip.dart';
import '../../../parcours/presentation/widgets/xp_chip.dart';
import '../../../student/data/datasources/student_remote_data_source.dart';
import '../../../student/domain/entities/student_models.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeCubit>(
      create: (_) => sl<HomeCubit>()..loadHome(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Stack(
        children: [
          const _DashboardBackground(),
          BlocBuilder<HomeCubit, HomeState>(
            builder: (BuildContext context, HomeState state) {
              return state.when(
                initial: () => const Center(child: CircularProgressIndicator()),
                loading: () => const Center(child: CircularProgressIndicator()),
                empty: () => _buildEmptyState(context),
                error: (String message) => _buildErrorState(context, message),
                loaded: (summary, parcours) => RefreshIndicator(
                  onRefresh: () => context.read<HomeCubit>().loadHome(),
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      MediaQuery.of(context).padding.top + 12,
                      16,
                      118,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    children: [
                      _HubHeader(
                        fallbackStreak: summary.currentStreak,
                        fallbackXp: summary.totalXp,
                      ),
                      const SizedBox(height: 20),
                      _buildDailyGoalCard(context, summary),
                      const SizedBox(height: 16),
                      _buildStatsStrip(context, summary),
                      const SizedBox(height: 28),
                      _buildParcoursHeading(context, summary, parcours),
                      const SizedBox(height: 16),
                      _PathCard(
                        child: ParcoursPathPreview(
                          steps: parcours.steps,
                          onStepTap: (ParcoursStep step) =>
                              _openStep(context, step.id),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildProgressCard(context, summary, parcours),
                      const SizedBox(height: 28),
                      _buildSectionTitle(context, 'Activités rapides'),
                      const SizedBox(height: 14),
                      _buildActivitiesList(context),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.04, end: 0),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDailyGoalCard(BuildContext context, ParcoursSummary summary) {
    final String title = summary.nextStepTitle ?? 'Parcours terminé';
    final bool hasNext = summary.nextStepId != null;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryLight,
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -34,
            top: -34,
            child: _DecorativeCircle(
              size: 118,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'OBJECTIF DU JOUR',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (hasNext)
                      SizedBox(
                        width: 150,
                        height: 46,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _openStep(context, summary.nextStepId!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text(
                            'Continuer',
                            style: AppTextStyles.calloutBold.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.menu_book_rounded,
                size: 80,
                color: Colors.white,
              )
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .moveY(
                    begin: -5,
                    end: 5,
                    duration: 1500.ms,
                    curve: Curves.easeInOut,
                  ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.08, end: 0);
  }

  Widget _buildStatsStrip(BuildContext context, ParcoursSummary summary) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.local_fire_department_rounded,
            label: 'Série',
            value: '${summary.currentStreak} j',
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            icon: Icons.bolt_rounded,
            label: 'XP',
            value: '${summary.totalXp}',
            color: AppColors.accentPurple,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            icon: Icons.flag_rounded,
            label: 'Niveau',
            value: 'DELF ${summary.delfTargetLevel}',
            color: AppColors.accentMint,
          ),
        ),
      ],
    );
  }

  Widget _buildParcoursHeading(
    BuildContext context,
    ParcoursSummary summary,
    Parcours parcours,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, 'Votre parcours'),
              const SizedBox(height: 6),
              Text(
                '${parcours.title} • ${summary.classLevel}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.darkBodySecondary
                      : AppColors.lightBodySecondary,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () => AutoTabsRouter.of(context).setActiveIndex(1),
          child: const Text('Tout voir'),
        ),
      ],
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    ParcoursSummary summary,
    Parcours parcours,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary;
    return InkWell(
      onTap: () => AutoTabsRouter.of(context).setActiveIndex(1),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: _softCardDecoration(context),
        child: Row(
          children: [
            CompletionRing(percent: summary.completionPercent),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progression globale',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Niveau ${summary.delfTargetLevel} • ${summary.completedSteps}/${summary.totalSteps} étapes',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.darkBodySecondary
                          : AppColors.lightBodySecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark
                  ? AppColors.darkBodySecondary
                  : AppColors.lightBodySecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesList(BuildContext context) {
    return Column(
      children: [
        _ActivityTile(
          title: 'Examen blanc',
          subtitle: 'Passe un DELF complet et reçois un score estimé',
          icon: Icons.assignment_rounded,
          color: AppColors.primary,
          onTap: () => context.router.push(const DelfMockExamListRoute()),
        ),
        const SizedBox(height: 12),
        _ActivityTile(
          title: 'Réviser mes erreurs',
          subtitle: 'Cartes issues des quiz et tests DELF',
          icon: Icons.psychology_alt_rounded,
          color: AppColors.accentMint,
          onTap: () => AutoTabsRouter.of(context).setActiveIndex(2),
        ),
        const SizedBox(height: 12),
        _ActivityTile(
          title: 'Historique DELF',
          subtitle: 'Scores, tendances et détails',
          icon: Icons.workspace_premium_rounded,
          color: AppColors.accentPurple,
          onTap: () => context.router.push(const DelfHistoryRoute()),
        ),
        const SizedBox(height: 12),
        _ActivityTile(
          title: 'Mes badges',
          subtitle: 'Objectifs débloqués et prochains défis',
          icon: Icons.military_tech_rounded,
          color: AppColors.warning,
          onTap: () => context.router.push(const AchievementsRoute()),
        ),
        const SizedBox(height: 12),
        _ActivityTile(
          title: 'Classement',
          subtitle: 'Compare XP, série et progression',
          icon: Icons.emoji_events_rounded,
          color: AppColors.accentPink,
          onTap: () => AutoTabsRouter.of(context).setActiveIndex(3),
        ),
        const SizedBox(height: 12),
        _ActivityTile(
          title: 'Voir tout le parcours',
          subtitle: 'Explorez toutes vos étapes',
          icon: Icons.route_rounded,
          color: AppColors.primary,
          onTap: () => AutoTabsRouter.of(context).setActiveIndex(1),
        ),
      ],
    );
  }

  BoxDecoration _softCardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: AppTextStyles.titleMedium.copyWith(
        color: isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.route_rounded, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text(
              'Parcours bientôt disponible',
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Votre parcours sera disponible dès qu\'il sera configuré pour votre niveau.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.lightBodySecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<HomeCubit>().loadHome(),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<HomeCubit>().loadHome(),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  void _openStep(BuildContext context, String stepId) {
    final HomeCubit homeCubit = context.read<HomeCubit>();
    context.router.push(StepPlayerRoute(stepId: stepId)).then((Object? result) {
      if (result == true) {
        homeCubit.loadHome();
      }
    });
  }
}

class _HubHeader extends StatelessWidget {
  const _HubHeader({
    required this.fallbackStreak,
    required this.fallbackXp,
  });

  final int fallbackStreak;
  final int fallbackXp;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StudentHub>(
      future: sl<StudentRemoteDataSource>().getHub(),
      builder: (context, snapshot) {
        final hub = snapshot.data;
        final String? firstName = hub?.firstName;
        final String avatarUrl = resolveMediaUrl(hub?.profilePictureUrl);
        final int streak = hub?.currentStreak ?? fallbackStreak;
        final int xp = hub?.totalXp ?? fallbackXp;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.14),
                    backgroundImage:
                        avatarUrl.isEmpty ? null : NetworkImage(avatarUrl),
                    child: avatarUrl.isEmpty
                        ? const Icon(
                            Icons.person_rounded,
                            color: AppColors.primary,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstName == null || firstName.isEmpty
                              ? 'Bonjour'
                              : 'Bonjour $firstName',
                          style: AppTextStyles.bodySmall.copyWith(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.darkBodySecondary
                                    : AppColors.lightBodySecondary,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hub?.nextAction.title ?? 'Prêt à progresser ?',
                          style: AppTextStyles.titleLarge.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Row(
              children: [
                StreakChip(streak: streak),
                const SizedBox(width: 8),
                XpChip(totalXp: xp),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurface;
    final textColor =
        isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary;
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark
                ? AppColors.darkBodySecondary
                : AppColors.lightBodySecondary,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: isDark
              ? AppColors.darkBodySecondary
              : AppColors.lightBodySecondary,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _DashboardBackground extends StatelessWidget {
  const _DashboardBackground();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -70,
            child: _DecorativeCircle(
              size: 230,
              color: AppColors.primary.withValues(alpha: isDark ? 0.14 : 0.10),
            ),
          ),
          Positioned(
            top: 190,
            left: -90,
            child: _DecorativeCircle(
              size: 190,
              color: AppColors.accent.withValues(alpha: isDark ? 0.10 : 0.14),
            ),
          ),
        ],
      ),
    );
  }
}

class _PathCard extends StatelessWidget {
  const _PathCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
      ),
      child: child,
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.calloutBold.copyWith(
              color: isDark
                  ? AppColors.darkBodyPrimary
                  : AppColors.lightBodyPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.labelMedium),
        ],
      ),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
