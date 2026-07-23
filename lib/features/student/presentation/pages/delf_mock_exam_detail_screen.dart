import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../core/network/media_url.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/injection_container.dart';
import '../../data/datasources/student_remote_data_source.dart';
import '../../domain/entities/delf_mock_exam_models.dart';

@RoutePage()
class DelfMockExamDetailScreen extends StatelessWidget {
  const DelfMockExamDetailScreen({
    super.key,
    @PathParam('examId') required this.examId,
  });

  final String examId;

  @override
  Widget build(BuildContext context) {
    final dataSource = sl<StudentRemoteDataSource>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(title: const Text('Détail examen')),
      body: FutureBuilder<StudentDelfMockExam>(
        future: dataSource.getDelfMockExam(examId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Examen blanc introuvable.'));
          }
          final exam = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
            children: [
              _ExamHero(exam: exam),
              const SizedBox(height: 16),
              if (exam.description != null) _InfoCard(text: exam.description!),
              const SizedBox(height: 16),
              Text(
                '4 épreuves DELF',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              for (final section in exam.sections) ...[
                _SectionTile(section: section),
                const SizedBox(height: 10),
              ],
              if (exam.assets.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  'Ressources',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                for (final asset in exam.assets) _AssetTile(asset: asset),
              ],
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton.icon(
            onPressed: () async {
              final attempt = await dataSource.createDelfMockAttempt(examId);
              if (!context.mounted) return;
              await context.router.push(
                DelfMockExamAttemptRoute(attemptId: attempt.attemptId),
              );
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Commencer l’examen'),
          ),
        ),
      ),
    );
  }
}

class _ExamHero extends StatelessWidget {
  const _ExamHero({required this.exam});

  final StudentDelfMockExam exam;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accentPurple,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.workspace_premium_rounded,
              color: Colors.white, size: 42),
          const SizedBox(height: 14),
          Text(
            exam.title,
            style: AppTextStyles.headlineSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'DELF ${exam.track} ${exam.level} • ${exam.totalDurationMinutes} min • ${exam.totalPoints} points',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(context),
      child: Text(text),
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({required this.section});

  final StudentDelfMockSection section;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(context),
      child: Row(
        children: [
          Icon(_iconFor(section.sectionType), color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${section.durationMinutes} min • ${section.points} pts • ${section.items.length} exercice(s)',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          if (resolveMediaUrl(section.audioUrl).isNotEmpty)
            const Icon(Icons.headphones_rounded, color: AppColors.accentMint),
        ],
      ),
    );
  }
}

class _AssetTile extends StatelessWidget {
  const _AssetTile({required this.asset});

  final StudentDelfMockAsset asset;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.attach_file_rounded),
      title: Text(asset.title),
      subtitle: Text(resolveMediaUrl(asset.url)),
    );
  }
}

IconData _iconFor(String type) {
  switch (type) {
    case 'listening':
      return Icons.hearing_rounded;
    case 'reading':
      return Icons.menu_book_rounded;
    case 'writing':
      return Icons.edit_rounded;
    case 'speaking':
      return Icons.mic_rounded;
    default:
      return Icons.assignment_rounded;
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
