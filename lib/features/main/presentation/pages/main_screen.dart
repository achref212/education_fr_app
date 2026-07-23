import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';

@RoutePage()
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AutoTabsScaffold(
      routes: const [
        HomeRoute(),
        ParcoursRoute(),
        ReviewCenterRoute(),
        LeaderboardRoute(),
        ProfileRoute(),
      ],
      bottomNavigationBuilder: (context, tabsRouter) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceElevated
                    : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color:
                      isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: NavigationBar(
                  height: 70,
                  selectedIndex: tabsRouter.activeIndex,
                  onDestinationSelected: tabsRouter.setActiveIndex,
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home_rounded),
                      label: 'Accueil',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.route_outlined),
                      selectedIcon: Icon(Icons.route_rounded),
                      label: 'Parcours',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.psychology_alt_outlined),
                      selectedIcon: Icon(Icons.psychology_alt_rounded),
                      label: 'Réviser',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.emoji_events_outlined),
                      selectedIcon: Icon(Icons.emoji_events_rounded),
                      label: 'Classement',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person_outline_rounded),
                      selectedIcon: Icon(Icons.person_rounded),
                      label: 'Profil',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
