import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/injection_container.dart';
import '../../domain/entities/parcours_step.dart';
import '../cubit/parcours_cubit.dart';
import '../cubit/parcours_state.dart';
import '../widgets/parcours_node.dart';

@RoutePage()
class ParcoursScreen extends StatelessWidget {
  const ParcoursScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ParcoursCubit>(
      create: (_) => sl<ParcoursCubit>()..loadParcours(),
      child: const _ParcoursView(),
    );
  }
}

class _ParcoursView extends StatelessWidget {
  const _ParcoursView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Mon Parcours'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<ParcoursCubit, ParcoursState>(
        builder: (BuildContext context, ParcoursState state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            empty: () =>
                const Center(child: Text('Parcours bientôt disponible')),
            error: (String message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<ParcoursCubit>().loadParcours(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
            loaded: (parcours) => RefreshIndicator(
              onRefresh: () => context.read<ParcoursCubit>().loadParcours(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _ParcoursHeroCard(
                    title: parcours.title,
                    subtitle:
                        'DELF ${parcours.delfTargetLevel} • ${parcours.steps.length} étapes',
                    percent: parcours.completionPercent,
                  ),
                  const SizedBox(height: 18),
                  _buildDifficultySelector(
                    context,
                    parcours.preferredDifficulty,
                  ),
                  const SizedBox(height: 26),
                  Text(
                    'Étapes du parcours',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: isDark
                          ? AppColors.darkBodyPrimary
                          : AppColors.lightBodyPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...List<Widget>.generate(parcours.steps.length, (int index) {
                    final ParcoursStep step = parcours.steps[index];
                    return ParcoursNode(
                      step: step,
                      isLast: index == parcours.steps.length - 1,
                      animationDelay: Duration(milliseconds: index * 60),
                      onTap: step.canStart
                          ? () => context.router.push(
                                StepPlayerRoute(stepId: step.id),
                              )
                          : null,
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDifficultySelector(BuildContext context, String current) {
    const List<String> options = <String>['easy', 'medium', 'hard'];
    const Map<String, String> labels = <String, String>{
      'easy': 'Facile',
      'medium': 'Moyen',
      'hard': 'Difficile',
    };
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
      ),
      child: Row(
        children: options.map((String option) {
          final bool isSelected = current == option;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextButton(
                  onPressed: isSelected
                      ? null
                      : () => context
                          .read<ParcoursCubit>()
                          .updateDifficulty(option),
                  style: TextButton.styleFrom(
                    foregroundColor: isSelected
                        ? AppColors.onPrimary
                        : isDark
                            ? AppColors.darkBodyPrimary
                            : AppColors.lightBodyPrimary,
                    textStyle: AppTextStyles.calloutBold,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(labels[option] ?? option),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ParcoursHeroCard extends StatelessWidget {
  const _ParcoursHeroCard({
    required this.title,
    required this.subtitle,
    required this.percent,
  });

  final String title;
  final String subtitle;
  final double percent;

  @override
  Widget build(BuildContext context) {
    final progress = (percent / 100).clamp(0.0, 1.0);
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
            color: AppColors.primary.withValues(alpha: 0.26),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.route_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${percent.round()}% complété',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
