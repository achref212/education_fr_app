import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/injection_container.dart';
import '../../data/datasources/student_remote_data_source.dart';
import '../../domain/entities/student_models.dart';

@RoutePage()
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Badges'),
        centerTitle: true,
      ),
      body: FutureBuilder<StudentAchievements>(
        future: sl<StudentRemoteDataSource>().getAchievements(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const _StateMessage(
              icon: Icons.error_outline_rounded,
              title: 'Badges indisponibles',
              subtitle: 'Réessaie plus tard.',
            );
          }
          final achievements = snapshot.data;
          if (achievements == null) {
            return const _StateMessage(
              icon: Icons.military_tech_outlined,
              title: 'Aucun badge',
              subtitle:
                  'Termine des activités pour débloquer tes premiers badges.',
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
            children: [
              _AchievementHeader(achievements: achievements),
              const SizedBox(height: 16),
              if (achievements.nextBadge != null)
                _NextBadgeCard(badge: achievements.nextBadge!),
              const SizedBox(height: 18),
              Text(
                'Tous les badges',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: achievements.items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.88,
                ),
                itemBuilder: (context, index) =>
                    _BadgeTile(badge: achievements.items[index]),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AchievementHeader extends StatelessWidget {
  const _AchievementHeader({required this.achievements});

  final StudentAchievements achievements;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.accentPurple,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_rounded,
              size: 40, color: Colors.white),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              '${achievements.unlockedCount}/${achievements.totalCount} badges débloqués',
              style: AppTextStyles.titleLarge.copyWith(
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

class _NextBadgeCard extends StatelessWidget {
  const _NextBadgeCard({required this.badge});

  final StudentAchievement badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Prochain badge', style: AppTextStyles.labelMedium),
          const SizedBox(height: 8),
          Text(
            badge.title,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(badge.description),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: badge.percent.clamp(0, 1),
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
          ),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge});

  final StudentAchievement badge;

  @override
  Widget build(BuildContext context) {
    final color =
        badge.unlocked ? AppColors.warning : AppColors.lightBodySecondary;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_iconFor(badge.icon), size: 34, color: color),
          const SizedBox(height: 12),
          Text(
            badge.title,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              badge.description,
              style: AppTextStyles.bodySmall,
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: badge.percent.clamp(0, 1),
            minHeight: 7,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: 6),
          Text('${badge.progress}/${badge.target}',
              style: AppTextStyles.labelMedium),
        ],
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

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
          ],
        ),
      ),
    );
  }
}

IconData _iconFor(String icon) {
  switch (icon) {
    case 'flag':
      return Icons.flag_rounded;
    case 'sparkles':
      return Icons.auto_awesome_rounded;
    case 'flame':
      return Icons.local_fire_department_rounded;
    case 'calendar':
      return Icons.calendar_month_rounded;
    case 'check':
      return Icons.fact_check_rounded;
    case 'inbox':
      return Icons.inventory_2_rounded;
    default:
      return Icons.workspace_premium_rounded;
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
