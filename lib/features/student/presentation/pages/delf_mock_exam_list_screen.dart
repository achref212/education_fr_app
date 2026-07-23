import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/injection_container.dart';
import '../../data/datasources/student_remote_data_source.dart';
import '../../domain/entities/delf_mock_exam_models.dart';

@RoutePage()
class DelfMockExamListScreen extends StatelessWidget {
  const DelfMockExamListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Examen blanc'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<StudentDelfMockExam>>(
        future: sl<StudentRemoteDataSource>().getDelfMockExams(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _StateMessage(
              icon: Icons.error_outline_rounded,
              title: 'Examens indisponibles',
              subtitle: 'Réessaie dans un instant.',
              onRetry: () => context.router.replace(
                const DelfMockExamListRoute(),
              ),
            );
          }
          final exams = snapshot.data ?? const <StudentDelfMockExam>[];
          if (exams.isEmpty) {
            return const _StateMessage(
              icon: Icons.school_outlined,
              title: 'Aucun examen blanc publié',
              subtitle:
                  'Ton école n’a pas encore publié d’examen blanc pour le moment.',
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              _HeroCard(count: exams.length),
              const SizedBox(height: 16),
              for (final exam in exams) ...[
                _ExamTile(exam: exam),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_rounded,
              color: Colors.white, size: 40),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              '$count examen(s) blanc(s) pour t’entraîner en conditions DELF.',
              style: AppTextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamTile extends StatelessWidget {
  const _ExamTile({required this.exam});

  final StudentDelfMockExam exam;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => context.router.push(
        DelfMockExamDetailRoute(examId: exam.id),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accentPurple.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.assignment_rounded,
                color: AppColors.accentPurple,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exam.title,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'DELF ${exam.track} ${exam.level} • ${exam.totalDurationMinutes} min • ${exam.totalPoints} pts',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onRetry,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center, style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                child: const Text('Réessayer'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
