import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../features/auth/domain/entities/user.dart';

import '../../features/auth/presentation/pages/forgot_password_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/auth/presentation/pages/reset_password_screen.dart';
import '../../features/auth/presentation/pages/verify_account_screen.dart';
import '../../features/auth/presentation/pages/verify_reset_code_screen.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/leaderboard/presentation/pages/leaderboard_screen.dart';
import '../../features/main/presentation/pages/main_screen.dart';
import '../../features/onboarding/presentation/pages/onboarding_screen.dart';
import '../../features/onboarding/presentation/pages/welcome_screen.dart';
import '../../features/profile/presentation/pages/change_password_screen.dart';
import '../../features/profile/presentation/pages/edit_profile_screen.dart';
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
        AutoRoute(page: VerifyAccountRoute.page),
        AutoRoute(page: ForgotPasswordRoute.page),
        AutoRoute(page: VerifyResetCodeRoute.page),
        AutoRoute(page: ResetPasswordRoute.page),
        AutoRoute(page: EditProfileRoute.page),
        AutoRoute(page: ChangePasswordRoute.page),
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
