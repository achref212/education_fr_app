part of 'splash_cubit.dart';

sealed class SplashState {}

final class SplashInitial extends SplashState {}

final class SplashLoading extends SplashState {}

/// The user is authenticated — navigate to the main app.
final class SplashAuthenticated extends SplashState {}

/// No valid session — navigate to onboarding / login.
final class SplashUnauthenticated extends SplashState {
  SplashUnauthenticated({required this.hasSeenOnboarding});
  final bool hasSeenOnboarding;
}
