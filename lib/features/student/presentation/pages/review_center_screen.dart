import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/injection_container.dart';
import '../../data/datasources/student_remote_data_source.dart';
import '../../domain/entities/student_models.dart';

@RoutePage()
class ReviewCenterScreen extends StatefulWidget {
  const ReviewCenterScreen({super.key});

  @override
  State<ReviewCenterScreen> createState() => _ReviewCenterScreenState();
}

class _ReviewCenterScreenState extends State<ReviewCenterScreen> {
  late Future<StudentReview> _future;

  StudentRemoteDataSource get _dataSource => sl<StudentRemoteDataSource>();

  @override
  void initState() {
    super.initState();
    _future = _dataSource.getReview();
  }

  void _reload() {
    setState(() => _future = _dataSource.getReview());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Réviser'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: FutureBuilder<StudentReview>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _MessageState(
                icon: Icons.error_outline_rounded,
                title: 'Impossible de charger les révisions',
                subtitle: snapshot.error.toString(),
                actionLabel: 'Réessayer',
                onAction: _reload,
              );
            }
            final review = snapshot.data;
            if (review == null || review.totalOpen == 0) {
              return _MessageState(
                icon: Icons.check_circle_rounded,
                title: 'Tout est révisé',
                subtitle:
                    'Les prochaines erreurs apparaîtront ici après un quiz ou un test DELF.',
                actionLabel: 'Actualiser',
                onAction: _reload,
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
              children: [
                _ReviewSummary(review: review),
                const SizedBox(height: 16),
                for (final group in review.groups) ...[
                  _SectionTitle('${group.category} (${group.openCount})'),
                  const SizedBox(height: 10),
                  for (final item in group.items) ...[
                    _ReviewCard(
                      item: item,
                      onComplete: () => _complete(item),
                      onHint: () => _showHint(item),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _complete(StudentReviewItem item) async {
    await _dataSource.completeReviewItem(item.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Révision terminée')),
    );
    _reload();
  }

  Future<void> _showHint(StudentReviewItem item) async {
    final hint = await _dataSource.getReviewHint(item.id);
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hint.source == 'ai' ? 'Indice guidé' : 'Explication',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(hint.hint, style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _ReviewSummary extends StatelessWidget {
  const _ReviewSummary({required this.review});

  final StudentReview review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(context),
      child: Row(
        children: [
          const Icon(Icons.psychology_alt_rounded, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${review.totalOpen} carte(s) à revoir',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  review.weakCategories.isEmpty
                      ? 'Commence par la première carte.'
                      : 'Priorité: ${review.weakCategories.first.category}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '${review.totalCompleted} faites',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatefulWidget {
  const _ReviewCard({
    required this.item,
    required this.onComplete,
    required this.onHint,
  });

  final StudentReviewItem item;
  final VoidCallback onComplete;
  final VoidCallback onHint;

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SourceChip(source: item.sourceType),
              const Spacer(),
              IconButton(
                tooltip: 'Indice',
                onPressed: widget.onHint,
                icon: const Icon(Icons.lightbulb_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.question,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text('Ta réponse: ${item.selectedAnswer ?? '-'}'),
          if (_revealed) ...[
            const SizedBox(height: 8),
            Text(
              'Bonne réponse: ${item.correctAnswer ?? '-'}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            if (item.explanation != null) ...[
              const SizedBox(height: 8),
              Text(item.explanation!, style: AppTextStyles.bodySmall),
            ],
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _revealed = !_revealed),
                  icon: Icon(
                    _revealed
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                  ),
                  label: Text(_revealed ? 'Masquer' : 'Voir la réponse'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: widget.onComplete,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Terminé'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SourceChip extends StatelessWidget {
  const _SourceChip({required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.accentMint.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        source == 'delf_test' ? 'DELF' : 'Parcours',
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.accentMint,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 90),
        Icon(icon, size: 64, color: AppColors.primary),
        const SizedBox(height: 16),
        Text(title,
            textAlign: TextAlign.center, style: AppTextStyles.titleLarge),
        const SizedBox(height: 8),
        Text(subtitle, textAlign: TextAlign.center),
        const SizedBox(height: 18),
        Center(
          child: FilledButton(
            onPressed: onAction,
            child: Text(actionLabel),
          ),
        ),
      ],
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
