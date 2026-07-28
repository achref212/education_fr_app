import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/injection_container.dart';
import '../../data/datasources/student_remote_data_source.dart';
import '../../domain/entities/delf_mock_exam_models.dart';

@RoutePage()
class DelfMockExamResultScreen extends StatelessWidget {
  const DelfMockExamResultScreen({
    super.key,
    @PathParam('attemptId') required this.attemptId,
  });

  final String attemptId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(title: const Text('Résultat examen blanc')),
      body: FutureBuilder<StudentDelfMockAttempt>(
        future: sl<StudentRemoteDataSource>().getDelfMockAttempt(attemptId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Résultat indisponible.'));
          }
          final attempt = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              _ScoreHero(attempt: attempt),
              const SizedBox(height: 18),
              Text(
                'Détail par épreuve',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              for (final section in attempt.exam.sections) ...[
                _SectionScoreTile(
                  section: section,
                  score: attempt.sectionScores[section.sectionType] ?? 0,
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 18),
              if (attempt.weakSkills.isNotEmpty) ...[
                Text(
                  'Priorités du parcours',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                for (final skill in attempt.weakSkills.take(3)) ...[
                  _WeakSkillTile(skill: skill),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 8),
              ],
              _ParcoursStatusCard(attempt: attempt),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () => context.router.replaceAll([
                  const MainRoute(children: [ParcoursRoute()]),
                ]),
                icon: const Icon(Icons.route_rounded),
                label: const Text('Ouvrir mon parcours DELF'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => context.router.replaceAll([
                  const MainRoute(children: [ReviewCenterRoute()]),
                ]),
                icon: const Icon(Icons.psychology_alt_rounded),
                label: const Text('Réviser mes erreurs'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ScoreHero extends StatelessWidget {
  const _ScoreHero({required this.attempt});

  final StudentDelfMockAttempt attempt;

  @override
  Widget build(BuildContext context) {
    final score = (attempt.overallScore ?? 0).clamp(0, 100);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          const Icon(Icons.workspace_premium_rounded,
              color: Colors.white, size: 44),
          const SizedBox(height: 14),
          Text(
            attempt.resultMessage ??
                'Ton score estimé est d’environ $score/100',
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Score automatique approximatif pour t’aider à te situer avant la correction d’un professeur.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _WeakSkillTile extends StatelessWidget {
  const _WeakSkillTile({required this.skill});

  final StudentDelfMockWeakSkill skill;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: AppColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skill.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Renforcement: ${skill.practiceCategory}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '${skill.percent}%',
            style: AppTextStyles.calloutBold.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _ParcoursStatusCard extends StatelessWidget {
  const _ParcoursStatusCard({required this.attempt});

  final StudentDelfMockAttempt attempt;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final message = switch (attempt.parcoursAssignmentStatus) {
      'ai_generated' =>
        'Ton nouveau parcours personnalisé a été généré avec l’IA à partir de ton score et de ton niveau.',
      'matched' =>
        'Un parcours adapté à ton score et à ton niveau DELF est prêt.',
      'default' => 'Un parcours de référence adapté à ta classe est prêt.',
      _ =>
        'Ton parcours reste disponible; l’IA pourra le personnaliser dès que le service sera prêt.',
    };
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.accentMint.withValues(alpha: isDark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.accentMint.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.route_rounded, color: AppColors.accentMint),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parcours DELF personnalisé',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(message, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionScoreTile extends StatelessWidget {
  const _SectionScoreTile({required this.section, required this.score});

  final StudentDelfMockSection section;
  final int score;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percent = section.points == 0 ? 0.0 : score / section.points;
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  section.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '$score/${section.points}',
                style: AppTextStyles.calloutBold.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: percent.clamp(0, 1),
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
          ),
        ],
      ),
    );
  }
}
