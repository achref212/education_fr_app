// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [ChangePasswordScreen]
class ChangePasswordRoute extends PageRouteInfo<void> {
  const ChangePasswordRoute({List<PageRouteInfo>? children})
    : super(ChangePasswordRoute.name, initialChildren: children);

  static const String name = 'ChangePasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChangePasswordScreen();
    },
  );
}

/// generated route for
/// [DelfIntroScreen]
class DelfIntroRoute extends PageRouteInfo<void> {
  const DelfIntroRoute({List<PageRouteInfo>? children})
    : super(DelfIntroRoute.name, initialChildren: children);

  static const String name = 'DelfIntroRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DelfIntroScreen();
    },
  );
}

/// generated route for
/// [DelfQuestionScreen]
class DelfQuestionRoute extends PageRouteInfo<void> {
  const DelfQuestionRoute({List<PageRouteInfo>? children})
    : super(DelfQuestionRoute.name, initialChildren: children);

  static const String name = 'DelfQuestionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DelfQuestionScreen();
    },
  );
}

/// generated route for
/// [DelfResultScreen]
class DelfResultRoute extends PageRouteInfo<DelfResultRouteArgs> {
  DelfResultRoute({
    Key? key,
    required String sessionId,
    List<PageRouteInfo>? children,
  }) : super(
         DelfResultRoute.name,
         args: DelfResultRouteArgs(key: key, sessionId: sessionId),
         rawPathParams: {'sessionId': sessionId},
         initialChildren: children,
       );

  static const String name = 'DelfResultRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<DelfResultRouteArgs>(
        orElse: () =>
            DelfResultRouteArgs(sessionId: pathParams.getString('sessionId')),
      );
      return DelfResultScreen(key: args.key, sessionId: args.sessionId);
    },
  );
}

class DelfResultRouteArgs {
  const DelfResultRouteArgs({this.key, required this.sessionId});

  final Key? key;

  final String sessionId;

  @override
  String toString() {
    return 'DelfResultRouteArgs{key: $key, sessionId: $sessionId}';
  }
}

/// generated route for
/// [EditProfileScreen]
class EditProfileRoute extends PageRouteInfo<EditProfileRouteArgs> {
  EditProfileRoute({
    Key? key,
    required User user,
    List<PageRouteInfo>? children,
  }) : super(
         EditProfileRoute.name,
         args: EditProfileRouteArgs(key: key, user: user),
         initialChildren: children,
       );

  static const String name = 'EditProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditProfileRouteArgs>();
      return EditProfileScreen(key: args.key, user: args.user);
    },
  );
}

class EditProfileRouteArgs {
  const EditProfileRouteArgs({this.key, required this.user});

  final Key? key;

  final User user;

  @override
  String toString() {
    return 'EditProfileRouteArgs{key: $key, user: $user}';
  }
}

/// generated route for
/// [ForgotPasswordScreen]
class ForgotPasswordRoute extends PageRouteInfo<void> {
  const ForgotPasswordRoute({List<PageRouteInfo>? children})
    : super(ForgotPasswordRoute.name, initialChildren: children);

  static const String name = 'ForgotPasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ForgotPasswordScreen();
    },
  );
}

/// generated route for
/// [HomeScreen]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomeScreen();
    },
  );
}

/// generated route for
/// [LeaderboardScreen]
class LeaderboardRoute extends PageRouteInfo<void> {
  const LeaderboardRoute({List<PageRouteInfo>? children})
    : super(LeaderboardRoute.name, initialChildren: children);

  static const String name = 'LeaderboardRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LeaderboardScreen();
    },
  );
}

/// generated route for
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginScreen();
    },
  );
}

/// generated route for
/// [MainScreen]
class MainRoute extends PageRouteInfo<void> {
  const MainRoute({List<PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainScreen();
    },
  );
}

/// generated route for
/// [OnboardingScreen]
class OnboardingRoute extends PageRouteInfo<void> {
  const OnboardingRoute({List<PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OnboardingScreen();
    },
  );
}

/// generated route for
/// [ParcoursScreen]
class ParcoursRoute extends PageRouteInfo<void> {
  const ParcoursRoute({List<PageRouteInfo>? children})
    : super(ParcoursRoute.name, initialChildren: children);

  static const String name = 'ParcoursRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ParcoursScreen();
    },
  );
}

/// generated route for
/// [ProfileScreen]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileScreen();
    },
  );
}

/// generated route for
/// [RegisterScreen]
class RegisterRoute extends PageRouteInfo<void> {
  const RegisterRoute({List<PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RegisterScreen();
    },
  );
}

/// generated route for
/// [ResetPasswordScreen]
class ResetPasswordRoute extends PageRouteInfo<ResetPasswordRouteArgs> {
  ResetPasswordRoute({
    Key? key,
    required String email,
    required String resetToken,
    List<PageRouteInfo>? children,
  }) : super(
         ResetPasswordRoute.name,
         args: ResetPasswordRouteArgs(
           key: key,
           email: email,
           resetToken: resetToken,
         ),
         initialChildren: children,
       );

  static const String name = 'ResetPasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ResetPasswordRouteArgs>();
      return ResetPasswordScreen(
        key: args.key,
        email: args.email,
        resetToken: args.resetToken,
      );
    },
  );
}

class ResetPasswordRouteArgs {
  const ResetPasswordRouteArgs({
    this.key,
    required this.email,
    required this.resetToken,
  });

  final Key? key;

  final String email;

  final String resetToken;

  @override
  String toString() {
    return 'ResetPasswordRouteArgs{key: $key, email: $email, resetToken: $resetToken}';
  }
}

/// generated route for
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashScreen();
    },
  );
}

/// generated route for
/// [StepPlayerScreen]
class StepPlayerRoute extends PageRouteInfo<StepPlayerRouteArgs> {
  StepPlayerRoute({
    Key? key,
    required String stepId,
    List<PageRouteInfo>? children,
  }) : super(
         StepPlayerRoute.name,
         args: StepPlayerRouteArgs(key: key, stepId: stepId),
         rawPathParams: {'stepId': stepId},
         initialChildren: children,
       );

  static const String name = 'StepPlayerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<StepPlayerRouteArgs>(
        orElse: () =>
            StepPlayerRouteArgs(stepId: pathParams.getString('stepId')),
      );
      return StepPlayerScreen(key: args.key, stepId: args.stepId);
    },
  );
}

class StepPlayerRouteArgs {
  const StepPlayerRouteArgs({this.key, required this.stepId});

  final Key? key;

  final String stepId;

  @override
  String toString() {
    return 'StepPlayerRouteArgs{key: $key, stepId: $stepId}';
  }
}

/// generated route for
/// [VerifyAccountScreen]
class VerifyAccountRoute extends PageRouteInfo<VerifyAccountRouteArgs> {
  VerifyAccountRoute({
    Key? key,
    required String email,
    required String registrationStateToken,
    List<PageRouteInfo>? children,
  }) : super(
         VerifyAccountRoute.name,
         args: VerifyAccountRouteArgs(
           key: key,
           email: email,
           registrationStateToken: registrationStateToken,
         ),
         initialChildren: children,
       );

  static const String name = 'VerifyAccountRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VerifyAccountRouteArgs>();
      return VerifyAccountScreen(
        key: args.key,
        email: args.email,
        registrationStateToken: args.registrationStateToken,
      );
    },
  );
}

class VerifyAccountRouteArgs {
  const VerifyAccountRouteArgs({
    this.key,
    required this.email,
    required this.registrationStateToken,
  });

  final Key? key;

  final String email;

  final String registrationStateToken;

  @override
  String toString() {
    return 'VerifyAccountRouteArgs{key: $key, email: $email, registrationStateToken: $registrationStateToken}';
  }
}

/// generated route for
/// [VerifyResetCodeScreen]
class VerifyResetCodeRoute extends PageRouteInfo<VerifyResetCodeRouteArgs> {
  VerifyResetCodeRoute({
    Key? key,
    required String email,
    required String resetStateToken,
    List<PageRouteInfo>? children,
  }) : super(
         VerifyResetCodeRoute.name,
         args: VerifyResetCodeRouteArgs(
           key: key,
           email: email,
           resetStateToken: resetStateToken,
         ),
         initialChildren: children,
       );

  static const String name = 'VerifyResetCodeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VerifyResetCodeRouteArgs>();
      return VerifyResetCodeScreen(
        key: args.key,
        email: args.email,
        resetStateToken: args.resetStateToken,
      );
    },
  );
}

class VerifyResetCodeRouteArgs {
  const VerifyResetCodeRouteArgs({
    this.key,
    required this.email,
    required this.resetStateToken,
  });

  final Key? key;

  final String email;

  final String resetStateToken;

  @override
  String toString() {
    return 'VerifyResetCodeRouteArgs{key: $key, email: $email, resetStateToken: $resetStateToken}';
  }
}

/// generated route for
/// [WelcomeScreen]
class WelcomeRoute extends PageRouteInfo<void> {
  const WelcomeRoute({List<PageRouteInfo>? children})
    : super(WelcomeRoute.name, initialChildren: children);

  static const String name = 'WelcomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const WelcomeScreen();
    },
  );
}
