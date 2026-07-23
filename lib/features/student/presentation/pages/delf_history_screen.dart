import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../injection/injection_container.dart';
import '../../../delf_test/domain/entities/delf_test_history.dart';
import '../../../delf_test/domain/usecases/get_delf_history_use_case.dart';

@RoutePage()
class DelfHistoryScreen extends StatelessWidget {
  const DelfHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Historique DELF'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<DelfTestHistory>>(
        future: _loadHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const _StateMessage(
              icon: Icons.error_outline_rounded,
              title: 'Historique indisponible',
              subtitle: 'Réessaie plus tard.',
            );
          }
          final items = snapshot.data ?? const <DelfTestHistory>[];
          if (items.isEmpty) {
            return _StateMessage(
              icon: Icons.workspace_premium_outlined,
              title: 'Aucun test terminé',
              subtitle: 'Lance un test DELF pour suivre ton évolution.',
              action: FilledButton.icon(
                onPressed: () =>
                    context.router.push(const DelfMockExamListRoute()),
                icon: const Icon(Icons.assignment_rounded),
                label: const Text('Examen blanc'),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
            children: [
              FilledButton.icon(
                onPressed: () =>
                    context.router.push(const DelfMockExamListRoute()),
                icon: const Icon(Icons.assignment_rounded),
                label: const Text('Passer un examen blanc'),
              ),
              const SizedBox(height: 12),
              _TrendCard(items: items),
              const SizedBox(height: 18),
              Text(
                'Tests terminés',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              for (final item in items) ...[
                _HistoryTile(item: item),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<List<DelfTestHistory>> _loadHistory() async {
    final result = await sl<GetDelfHistoryUseCase>()(const NoParams());
    return result.fold(
      (failure) => throw Exception(failure.message),
      (items) => items,
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.items});

  final List<DelfTestHistory> items;

  @override
  Widget build(BuildContext context) {
    final best = items
        .map((item) => item.overallScore ?? 0)
        .fold<int>(0, (best, score) => score > best ? score : best);
    final latest = items.first.overallScore ?? 0;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.accentMint,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.show_chart_rounded, color: Colors.white, size: 40),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dernier score: $latest%',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Meilleur score: $best% • ${items.length} test(s)',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item});

  final DelfTestHistory item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => context.router.push(
        DelfResultRoute(sessionId: item.sessionId),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'DELF ${item.targetDelfLevel}',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${item.overallScore ?? 0}%',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Atteint: ${item.achievedDelfLevel ?? '-'} • ${item.comparisonToTarget}',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: item.categoryScores.entries
                  .map(
                    (entry) => Chip(
                      label: Text('${entry.key}: ${entry.value}%'),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
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
    this.action,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

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
            Text(title, style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: 18),
              action!,
            ],
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
    borderRadius: BorderRadius.circular(22),
    border: Border.all(
      color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
    ),
  );
}
