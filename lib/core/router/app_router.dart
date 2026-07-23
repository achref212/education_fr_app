import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../features/auth/domain/entities/user.dart';

import '../../features/auth/presentation/pages/forgot_password_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/auth/presentation/pages/reset_password_screen.dart';
import '../../features/auth/presentation/pages/verify_account_screen.dart';
import '../../features/auth/presentation/pages/verify_reset_code_screen.dart';
import '../../features/delf_test/presentation/pages/delf_intro_screen.dart';
import '../../features/delf_test/presentation/pages/delf_question_screen.dart';
import '../../features/delf_test/presentation/pages/delf_result_screen.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/leaderboard/presentation/pages/leaderboard_screen.dart';
import '../../features/main/presentation/pages/main_screen.dart';
import '../../features/onboarding/presentation/pages/onboarding_screen.dart';
import '../../features/onboarding/presentation/pages/welcome_screen.dart';
import '../../features/parcours/presentation/pages/parcours_screen.dart';
import '../../features/parcours/presentation/pages/step_player_screen.dart';
import '../../features/profile/presentation/pages/change_password_screen.dart';
import '../../features/profile/presentation/pages/edit_profile_screen.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';
import '../../features/student/presentation/pages/achievements_screen.dart';
import '../../features/student/presentation/pages/delf_history_screen.dart';
import '../../features/student/presentation/pages/delf_mock_exam_attempt_screen.dart';
import '../../features/student/presentation/pages/delf_mock_exam_detail_screen.dart';
import '../../features/student/presentation/pages/delf_mock_exam_list_screen.dart';
import '../../features/student/presentation/pages/delf_mock_exam_result_screen.dart';
import '../../features/student/presentation/pages/personalized_parcours_reveal_screen.dart';
import '../../features/student/presentation/pages/review_center_screen.dart';

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
        AutoRoute(page: DelfIntroRoute.page),
        AutoRoute(page: DelfQuestionRoute.page),
        AutoRoute(page: DelfResultRoute.page, path: '/delf-result/:sessionId'),
        AutoRoute(
          page: PersonalizedParcoursRevealRoute.page,
          path: '/personalized-parcours/:sessionId',
        ),
        AutoRoute(page: AchievementsRoute.page),
        AutoRoute(page: DelfHistoryRoute.page),
        AutoRoute(page: DelfMockExamListRoute.page),
        AutoRoute(
          page: DelfMockExamDetailRoute.page,
          path: '/delf-mock-exams/:examId',
        ),
        AutoRoute(
          page: DelfMockExamAttemptRoute.page,
          path: '/delf-mock-attempts/:attemptId',
        ),
        AutoRoute(
          page: DelfMockExamResultRoute.page,
          path: '/delf-mock-results/:attemptId',
        ),
        AutoRoute(page: StepPlayerRoute.page, path: '/step/:stepId'),
        AutoRoute(
          page: MainRoute.page,
          children: [
            AutoRoute(page: HomeRoute.page, initial: true),
            AutoRoute(page: ParcoursRoute.page),
            AutoRoute(page: ReviewCenterRoute.page),
            AutoRoute(page: LeaderboardRoute.page),
            AutoRoute(page: ProfileRoute.page),
          ],
        ),
      ];
}
