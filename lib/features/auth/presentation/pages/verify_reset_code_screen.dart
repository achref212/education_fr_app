import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/presentation/widgets/auth_screen_shell.dart';
import '../../../../core/presentation/widgets/otp_code_input.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/injection_container.dart';
import '../../../theme/presentation/cubit/theme_cubit.dart';
import '../cubit/verify_reset_code_cubit.dart';
import '../cubit/verify_reset_code_state.dart';

@RoutePage()
class VerifyResetCodeScreen extends StatefulWidget {
  const VerifyResetCodeScreen({
    super.key,
    required this.email,
    required this.resetStateToken,
  });

  final String email;
  final String resetStateToken;

  @override
  State<VerifyResetCodeScreen> createState() => _VerifyResetCodeScreenState();
}

class _VerifyResetCodeScreenState extends State<VerifyResetCodeScreen> {
  final _otpKey = GlobalKey<OtpCodeInputState>();

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
        create: (_) => sl<VerifyResetCodeCubit>(),
        child: BlocConsumer<VerifyResetCodeCubit, VerifyResetCodeState>(
          listener: (context, state) {
            state.maybeWhen(
              success: (resetToken) {
                context.router.push(ResetPasswordRoute(
                  email: widget.email,
                  resetToken: resetToken,
                ));
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

            return AuthScreenShell(
              title: 'Code de réinitialisation',
              subtitle: 'Entrez le code envoyé à ${widget.email}',
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Saisissez le code à 6 chiffres',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vérifiez votre boîte e-mail.',
                      style: AppTextStyles.bodyMedium.copyWith(color: subColor),
                    ),
                    const SizedBox(height: 24),
                    OtpCodeInput(
                      key: _otpKey,
                      onCompleted: (code) {
                        context.read<VerifyResetCodeCubit>().verify(
                              email: widget.email,
                              code: code,
                              resetStateToken: widget.resetStateToken,
                            );
                      },
                    )
                        .animate(delay: 100.ms)
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.08, end: 0),
                    const Spacer(),
                    AppButton(
                      text: 'Continuer',
                      isLoading: isLoading,
                      onPressed: isLoading
                          ? () {}
                          : () {
                              final code = _otpKey.currentState?.code ?? '';
                              if (code.length == 6) {
                                context.read<VerifyResetCodeCubit>().verify(
                                      email: widget.email,
                                      code: code,
                                      resetStateToken: widget.resetStateToken,
                                    );
                              }
                            },
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
}
