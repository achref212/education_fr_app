import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../core/network/media_url.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/injection_container.dart';
import '../../../student/data/datasources/student_remote_data_source.dart';
import '../../../student/domain/entities/student_models.dart';

@RoutePage()
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String _scope = 'class';
  late Future<StudentLeaderboard> _future;

  StudentRemoteDataSource get _dataSource => sl<StudentRemoteDataSource>();

  @override
  void initState() {
    super.initState();
    _future = _dataSource.getLeaderboard(_scope);
  }

  void _load(String scope) {
    setState(() {
      _scope = scope;
      _future = _dataSource.getLeaderboard(scope);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Classement'),
        centerTitle: true,
      ),
      body: FutureBuilder<StudentLeaderboard>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorState(onRetry: () => _load(_scope));
          }
          final leaderboard = snapshot.data;
          if (leaderboard == null || leaderboard.entries.isEmpty) {
            return _EmptyState(onRetry: () => _load(_scope));
          }
          return RefreshIndicator(
            onRefresh: () async => _load(_scope),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'class',
                      label: Text('Classe'),
                      icon: Icon(Icons.groups_rounded),
                    ),
                    ButtonSegment(
                      value: 'school',
                      label: Text('École'),
                      icon: Icon(Icons.school_rounded),
                    ),
                  ],
                  selected: {_scope},
                  onSelectionChanged: (values) => _load(values.first),
                ),
                const SizedBox(height: 16),
                if (leaderboard.currentStudent != null)
                  _RankHero(entry: leaderboard.currentStudent!),
                const SizedBox(height: 18),
                Text(
                  'Top étudiants',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                for (final entry in leaderboard.entries) ...[
                  _LeaderboardTile(entry: entry),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RankHero extends StatelessWidget {
  const _RankHero({required this.entry});

  final StudentLeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _Avatar(url: entry.profilePictureUrl, size: 56),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ton rang',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '#${entry.rank} • ${entry.totalXp} XP',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 34),
        ],
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({required this.entry});

  final StudentLeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: entry.isCurrentUser
            ? AppColors.primary.withValues(alpha: 0.12)
            : isDark
                ? AppColors.darkSurfaceElevated
                : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: entry.isCurrentUser
              ? AppColors.primary
              : isDark
                  ? AppColors.darkDivider
                  : AppColors.lightDivider,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(
              '#${entry.rank}',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w900,
                color: entry.rank <= 3 ? AppColors.warning : null,
              ),
            ),
          ),
          _Avatar(url: entry.profilePictureUrl, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.firstName} ${entry.lastName}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.currentStreak} j de série • ${entry.completedSteps} étapes',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.totalXp}',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text('XP', style: AppTextStyles.labelMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.size});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final resolved = resolveMediaUrl(url);
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.primary.withValues(alpha: 0.14),
      backgroundImage: resolved.isEmpty ? null : NetworkImage(resolved),
      child: resolved.isEmpty
          ? const Icon(Icons.person_rounded, color: AppColors.primary)
          : null,
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => _StateMessage(
        icon: Icons.error_outline_rounded,
        title: 'Classement indisponible',
        subtitle: 'Réessaie dans un instant.',
        onRetry: onRetry,
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => _StateMessage(
        icon: Icons.emoji_events_outlined,
        title: 'Aucun classement',
        subtitle: 'Les élèves apparaîtront ici dès qu’ils auront gagné des XP.',
        onRetry: onRetry,
      );
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onRetry,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onRetry;

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
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Actualiser')),
          ],
        ),
      ),
    );
  }
}
