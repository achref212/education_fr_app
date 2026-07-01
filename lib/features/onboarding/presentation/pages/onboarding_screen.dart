import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/injection_container.dart';

@RoutePage()
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  final int _storyCount = 3;

  final List<Map<String, String>> _onboardingData = [
    {
      'image_light': 'assets/images/welcome_hero_light.svg',
      'image_dark': 'assets/images/welcome_hero_dark.svg',
      'title': 'Apprenez le français',
      'subtitle': 'Découvrez une nouvelle façon d\'apprendre rapidement et efficacement.',
    },
    {
      'image_light': 'assets/images/find_friends_light.svg',
      'image_dark': 'assets/images/find_friends_dark.svg',
      'title': 'Trouvez des amis',
      'subtitle': 'Pratiquez avec des apprenants du monde entier et échangez ensemble.',
    },
    {
      'image_light': 'assets/images/welcome_hero_light_alt.svg',
      'image_dark': 'assets/images/welcome_hero_dark_alt.svg',
      'title': 'Progressez chaque jour',
      'subtitle': 'Suivez votre progression et atteignez vos objectifs linguistiques.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _nextStory();
        }
      });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _nextStory() {
    if (_currentIndex < _storyCount - 1) {
      setState(() {
        _currentIndex++;
      });
      _animationController.reset();
      _animationController.forward();
    } else {
      _finishOnboarding();
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _animationController.reset();
      _animationController.forward();
    } else {
      // If on first story, just reset
      _animationController.reset();
      _animationController.forward();
    }
  }

  Future<void> _finishOnboarding() async {
    _animationController.stop();
    final prefs = sl<SharedPreferences>();
    await prefs.setBool('has_seen_onboarding', true);
    if (mounted) {
      context.router.replace(const WelcomeRoute());
    }
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.stop();
  }

  void _onTapUp(TapUpDetails details) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dx = details.globalPosition.dx;
    if (dx < screenWidth / 3) {
      _previousStory();
    } else {
      _nextStory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = _onboardingData[_currentIndex];

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onLongPressStart: (_) => _animationController.stop(),
        onLongPressEnd: (_) => _animationController.forward(),
        child: Stack(
          children: [
            // Content
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  // Progress Bars
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: List.generate(_storyCount, (index) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                double progress = 0;
                                if (index < _currentIndex) {
                                  progress = 1.0;
                                } else if (index == _currentIndex) {
                                  progress = _animationController.value;
                                }
                                return LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: isDark
                                      ? AppColors.darkSurface
                                      : AppColors.lightSurface,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  minHeight: 4,
                                );
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const Spacer(),
                  // Illustration
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.45,
                    child: Center(
                      child: SvgPicture.asset(
                        isDark ? data['image_dark']! : data['image_light']!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Texts
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        Text(
                          data['title']!,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: isDark
                                ? AppColors.darkBodyPrimary
                                : AppColors.lightBodyPrimary,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          data['subtitle']!,
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
                  const Spacer(flex: 2),
                ],
              ),
            ),
            // Skip button (optional, but good UX)
            Positioned(
              top: MediaQuery.of(context).padding.top + 50,
              right: 16,
              child: TextButton(
                onPressed: _finishOnboarding,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
                child: const Text('Passer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
