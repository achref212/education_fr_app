import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../injection/injection_container.dart';
import '../../../auth/domain/usecases/logout_use_case.dart';
import '../../../theme/presentation/cubit/theme_cubit.dart';

@RoutePage()
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar & Name (Placeholder for now)
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: const Icon(
                Icons.person_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Mon Profil',
              style: AppTextStyles.titleLarge.copyWith(color: textColor),
            ),
          ),
          const SizedBox(height: 32),

          // Settings Group
          Text(
            'PARAMÈTRES',
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.darkBodySecondary
                  : AppColors.lightBodySecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_rounded),
                  title: const Text('Thème Sombre / Clair'),
                  trailing: BlocBuilder<ThemeCubit, ThemeMode>(
                    builder: (context, mode) {
                      return Switch(
                        value: mode == ThemeMode.dark ||
                            (mode == ThemeMode.system && isDark),
                        onChanged: (val) {
                          context.read<ThemeCubit>().toggleLightDark();
                        },
                        activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                        activeThumbColor: AppColors.primary,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Logout Button
          ElevatedButton.icon(
            onPressed: () async {
              final logout = sl<LogoutUseCase>();
              await logout(const NoParams());
              if (context.mounted) {
                context.router.replaceAll([const SplashRoute()]);
              }
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Se déconnecter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error.withValues(alpha: 0.1),
              foregroundColor: AppColors.error,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
