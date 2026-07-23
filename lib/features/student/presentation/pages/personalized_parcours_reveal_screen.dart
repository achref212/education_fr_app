import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/injection_container.dart';
import '../../../delf_test/domain/entities/delf_test_results.dart';
import '../../../delf_test/domain/usecases/get_delf_results_use_case.dart';
import '../../data/datasources/student_remote_data_source.dart';
import '../../domain/entities/student_models.dart';

@RoutePage()
class PersonalizedParcoursRevealScreen extends StatelessWidget {
  const PersonalizedParcoursRevealScreen({
    super.key,
    @PathParam('sessionId') required this.sessionId,
  });

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: FutureBuilder<_RevealData>(
          future: _load(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _RevealLoading();
            }
            if (snapshot.hasError || snapshot.data == null) {
              return _RevealFallback(
                onOpenParcours: () => _openParcours(context),
              );
            }
            return _RevealSummary(
              data: snapshot.data!,
              onOpenParcours: () => _openParcours(context),
            );
          },
        ),
      ),
    );
  }

  Future<_RevealData> _load() async {
    await Future<void>.delayed(const Duration(milliseconds: 2300));
    final resultsEither = await sl<GetDelfResultsUseCase>()(
      GetDelfResultsParams(sessionId: sessionId),
    );
    final results = resultsEither.fold(
      (failure) => throw Exception(failure.message),
      (value) => value,
    );
    final hub = await sl<StudentRemoteDataSource>().getHub();
    return _RevealData(results: results, hub: hub);
  }

  void _openParcours(BuildContext context) {
    context.router.replaceAll([
      const MainRoute(children: [ParcoursRoute()]),
    ]);
  }
}

class _RevealData {
  const _RevealData({required this.results, required this.hub});

  final DelfTestResults results;
  final StudentHub hub;
}

class _RevealLoading extends StatelessWidget {
  const _RevealLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.auto_awesome_rounded,
                  size: 70, color: AppColors.accent)
              .animate(onPlay: (controller) => controller.repeat())
              .rotate(duration: 1600.ms),
          const SizedBox(height: 28),
          Text(
            'Création de ton parcours personnalisé',
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'On analyse ton résultat DELF pour préparer un parcours 100% conçu pour toi.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          for (final step in const [
            'Analyse de ton score DELF',
            'Repérage de tes catégories faibles',
            'Préparation des leçons et quiz',
            'Construction de ton chemin personnalisé',
          ]) ...[
            _LoadingStep(label: step),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _LoadingStep extends StatelessWidget {
  const _LoadingStep({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(context),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.08, end: 0);
  }
}

class _RevealSummary extends StatelessWidget {
  const _RevealSummary({
    required this.data,
    required this.onOpenParcours,
  });

  final _RevealData data;
  final VoidCallback onOpenParcours;

  @override
  Widget build(BuildContext context) {
    final weak = data.results.categoryScores.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    final hasAssignedPath =
        data.results.parcoursAssignmentStatus != 'unavailable';
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.route_rounded,
                      color: Colors.white,
                      size: 54,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Ton parcours est prêt',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hasAssignedPath
                          ? 'Parcours 100% conçu pour toi à partir de ton test DELF.'
                          : 'Parcours adapté à ta classe et à ton résultat DELF.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 350.ms).scale(
                    begin: const Offset(0.96, 0.96),
                    curve: Curves.easeOutBack,
                  ),
              const SizedBox(height: 18),
              _FactTile(
                icon: Icons.workspace_premium_rounded,
                title: 'Niveau DELF',
                value: data.results.achievedDelfLevel ?? 'À consolider',
              ),
              _FactTile(
                icon: Icons.flag_rounded,
                title: 'Prochaine étape',
                value: data.hub.nextStepTitle ?? 'Continuer ton parcours',
              ),
              _FactTile(
                icon: Icons.timeline_rounded,
                title: 'Objectif',
                value:
                    '${data.hub.completedSteps}/${data.hub.totalSteps} étapes • ${data.hub.parcoursPercent.round()}%',
              ),
              if (weak.isNotEmpty)
                _FactTile(
                  icon: Icons.psychology_alt_rounded,
                  title: 'Priorité',
                  value: '${weak.first.key} (${weak.first.value}%)',
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onOpenParcours,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Ouvrir mon parcours'),
            ),
          ),
        ),
      ],
    );
  }
}

class _RevealFallback extends StatelessWidget {
  const _RevealFallback({required this.onOpenParcours});

  final VoidCallback onOpenParcours;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.route_rounded, size: 64, color: AppColors.primary),
          const SizedBox(height: 18),
          Text(
            'Ton parcours est disponible',
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'On utilise ton niveau et ta classe pour te proposer le meilleur chemin disponible.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: onOpenParcours,
            child: const Text('Ouvrir mon parcours'),
          ),
        ],
      ),
    );
  }
}

class _FactTile extends StatelessWidget {
  const _FactTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(context),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.labelMedium),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return BoxDecoration(
    color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurface,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
    ),
  );
}
