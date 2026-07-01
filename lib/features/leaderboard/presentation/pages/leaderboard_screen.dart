import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

@RoutePage()
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Classement'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Bientôt disponible !',
              style: AppTextStyles.titleLarge.copyWith(color: textColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Affrontez vos amis et montez dans le classement.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.darkBodySecondary
                    : AppColors.lightBodySecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
