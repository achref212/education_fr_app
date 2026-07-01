import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

@RoutePage()
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AutoTabsScaffold(
      routes: const [
        HomeRoute(),
        LeaderboardRoute(),
        ProfileRoute(),
      ],
      bottomNavigationBuilder: (context, tabsRouter) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                width: 1,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: tabsRouter.activeIndex,
            onTap: tabsRouter.setActiveIndex,
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: isDark
                ? AppColors.darkBodySecondary
                : AppColors.lightBodySecondary,
            selectedLabelStyle: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: AppTextStyles.bodySmall,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                activeIcon: Icon(Icons.home_rounded, size: 28),
                label: 'Accueil',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.emoji_events_rounded),
                activeIcon: Icon(Icons.emoji_events_rounded, size: 28),
                label: 'Classement',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                activeIcon: Icon(Icons.person_rounded, size: 28),
                label: 'Profil',
              ),
            ],
          ),
        );
      },
    );
  }
}
