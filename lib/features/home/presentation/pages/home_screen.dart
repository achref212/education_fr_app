import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/injection_container.dart';
import '../../../auth/domain/usecases/logout_use_case.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../theme/presentation/cubit/theme_cubit.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: () {
              context.read<ThemeCubit>().toggleLightDark();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final logout = sl<LogoutUseCase>();
              await logout(const NoParams());
              if (context.mounted) {
                // Clear the stack and go back to Splash
                context.router.replaceAll([const SplashRoute()]);
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Bienvenue dans DELFy !',
          style: AppTextStyles.headlineSmall.copyWith(color: textColor),
        ),
      ),
    );
  }
}
