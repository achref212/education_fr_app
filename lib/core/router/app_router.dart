import 'package:auto_route/auto_route.dart';

import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/leaderboard/presentation/pages/leaderboard_screen.dart';
import '../../features/main/presentation/pages/main_screen.dart';
import '../../features/onboarding/presentation/pages/onboarding_screen.dart';
import '../../features/onboarding/presentation/pages/welcome_screen.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashRoute.page, initial: true),
        AutoRoute(page: OnboardingRoute.page),
        AutoRoute(page: WelcomeRoute.page),
        AutoRoute(page: LoginRoute.page),
        AutoRoute(page: RegisterRoute.page),
        AutoRoute(
          page: MainRoute.page,
          children: [
            AutoRoute(page: HomeRoute.page, initial: true),
            AutoRoute(page: LeaderboardRoute.page),
            AutoRoute(page: ProfileRoute.page),
          ],
        ),
      ];
}
