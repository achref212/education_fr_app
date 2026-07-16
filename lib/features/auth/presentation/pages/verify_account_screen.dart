import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/presentation/widgets/auth_screen_shell.dart';
import '../../../../core/presentation/widgets/otp_code_input.dart';
import '../../../../core/navigation/post_auth_navigator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/injection_container.dart';
import '../../../theme/presentation/cubit/theme_cubit.dart';
import '../cubit/verify_account_cubit.dart';
import '../cubit/verify_account_state.dart';

@RoutePage()
class VerifyAccountScreen extends StatefulWidget {
  const VerifyAccountScreen({
    super.key,
    required this.email,
    required this.registrationStateToken,
  });

  final String email;
  final String registrationStateToken;

  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  final _otpKey = GlobalKey<OtpCodeInputState>();
  int _resendCooldown = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary;
    final subColor =
        isDark ? AppColors.darkBodySecondary : AppColors.lightBodySecondary;

    return BlocProvider.value(
      value: sl<ThemeCubit>(),
      child: BlocProvider(
        create: (_) {
          final cubit = sl<VerifyAccountCubit>();
          cubit.setRegistrationStateToken(widget.registrationStateToken);
          return cubit;
        },
        child: BlocConsumer<VerifyAccountCubit, VerifyAccountState>(
          listener: (context, state) {
            state.maybeWhen(
              success: () => navigateAfterAuth(context.router),
              resendSuccess: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Un nouveau code a été envoyé.'),
                    backgroundColor: AppColors.success,
                  ),
                );
                _otpKey.currentState?.clear();
                _startResendCooldown();
              },
              error: (msg) => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(msg), backgroundColor: AppColors.error),
              ),
              orElse: () {},
            );
          },
          builder: (context, state) {
            final isLoading =
                state.maybeWhen(loading: () => true, orElse: () => false);
            final isResending =
                state.maybeWhen(resending: () => true, orElse: () => false);

            return AuthScreenShell(
              title: 'Vérifiez votre compte',
              subtitle: 'Entrez le code à 6 chiffres envoyé à ${widget.email}',
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfacePrimary
                            : AppColors.lightSurfacePrimary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.mark_email_read_outlined,
                            size: 48,
                            color: AppColors.primary,
                          )
                              .animate()
                              .scale(
                                begin: const Offset(0.8, 0.8),
                                duration: 500.ms,
                                curve: Curves.easeOutBack,
                              )
                              .fadeIn(),
                          const SizedBox(height: 16),
                          Text(
                            'Code de vérification',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Consultez votre boîte e-mail et saisissez le code reçu.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: subColor,
                            ),
                          ),
                          const SizedBox(height: 24),
                          OtpCodeInput(
                            key: _otpKey,
                            onCompleted: (code) {
                              context.read<VerifyAccountCubit>().verify(
                                    email: widget.email,
                                    code: code,
                                  );
                            },
                          ),
                        ],
                      ),
                    )
                        .animate(delay: 100.ms)
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 32),
                    AppButton(
                      text: 'Vérifier',
                      isLoading: isLoading,
                      onPressed: isLoading
                          ? () {}
                          : () {
                              final code = _otpKey.currentState?.code ?? '';
                              if (code.length == 6) {
                                context.read<VerifyAccountCubit>().verify(
                                      email: widget.email,
                                      code: code,
                                    );
                              }
                            },
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _resendCooldown > 0 || isResending
                          ? null
                          : () => context
                              .read<VerifyAccountCubit>()
                              .resend(email: widget.email),
                      child: Text(
                        _resendCooldown > 0
                            ? 'Renvoyer le code (${_resendCooldown}s)'
                            : 'Renvoyer le code',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: _resendCooldown > 0 || isResending
                              ? subColor
                              : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _startResendCooldown() {
    setState(() => _resendCooldown = 60);
    Future.doWhile(() async {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendCooldown--);
      return _resendCooldown > 0;
    });
  }
}
