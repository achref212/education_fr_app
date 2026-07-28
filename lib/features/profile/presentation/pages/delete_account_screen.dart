import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/auth_screen_shell.dart';
import '../../../../core/presentation/widgets/otp_code_input.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/injection_container.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../theme/presentation/cubit/theme_cubit.dart';
import '../cubit/delete_account_cubit.dart';
import '../cubit/delete_account_state.dart';

@RoutePage()
class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key, required this.user});

  final User user;

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _passwordFormKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _otpKey = GlobalKey<OtpCodeInputState>();

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<ThemeCubit>(),
      child: BlocProvider(
        create: (_) => sl<DeleteAccountCubit>(),
        child: BlocConsumer<DeleteAccountCubit, DeleteAccountState>(
          listener: (context, state) {
            final error = state.errorMessage;
            if (error != null && error.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error), backgroundColor: AppColors.error),
              );
            }
            if (state.step == DeleteAccountStep.success) {
              context.router.replaceAll([const SplashRoute()]);
            }
          },
          builder: (context, state) {
            return AuthScreenShell(
              title: 'Supprimer mon compte',
              subtitle: 'Une confirmation par mot de passe et e-mail est requise',
              child: SafeArea(
                top: false,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: switch (state.step) {
                    DeleteAccountStep.password => _PasswordStep(
                        key: const ValueKey('delete-password-step'),
                        formKey: _passwordFormKey,
                        passwordCtrl: _passwordCtrl,
                        isLoading: state.isLoading,
                        email: widget.user.email,
                        onSubmit: () {
                          if (_passwordFormKey.currentState!.validate()) {
                            context
                                .read<DeleteAccountCubit>()
                                .verifyPassword(_passwordCtrl.text);
                          }
                        },
                        onForgotPassword: () async {
                          final resetDone = await context.router.push<bool>(
                            AccountDeletionPasswordRecoveryRoute(
                              email: widget.user.email,
                            ),
                          );
                          if (resetDone == true && context.mounted) {
                            _passwordCtrl.clear();
                            context
                                .read<DeleteAccountCubit>()
                                .returnToPasswordStep();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Mot de passe réinitialisé. Entrez-le pour continuer.',
                                ),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        },
                      ),
                    DeleteAccountStep.confirmIntent => _ConfirmIntentStep(
                        key: const ValueKey('delete-confirm-step'),
                        isLoading: state.isLoading,
                        email: widget.user.email,
                        onCancel: () => context.router.maybePop(),
                        onConfirm: () => context
                            .read<DeleteAccountCubit>()
                            .requestEmailCode(),
                      ),
                    DeleteAccountStep.code => _CodeStep(
                        key: const ValueKey('delete-code-step'),
                        otpKey: _otpKey,
                        isLoading: state.isLoading,
                        email: widget.user.email,
                        onSubmit: () {
                          final code = _otpKey.currentState?.code ?? '';
                          if (code.length == 6) {
                            context
                                .read<DeleteAccountCubit>()
                                .confirmDeletion(code);
                          }
                        },
                      ),
                    DeleteAccountStep.success => const SizedBox.shrink(),
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PasswordStep extends StatelessWidget {
  const _PasswordStep({
    super.key,
    required this.formKey,
    required this.passwordCtrl,
    required this.isLoading,
    required this.email,
    required this.onSubmit,
    required this.onForgotPassword,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController passwordCtrl;
  final bool isLoading;
  final String email;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _WarningPanel(
              icon: Icons.delete_forever_rounded,
              title: 'Suppression définitive',
              message:
                  'Le compte $email, les progrès et les données élève seront supprimés après le code e-mail.',
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: 'Mot de passe actuel',
              hintText: 'Entrez votre mot de passe',
              controller: passwordCtrl,
              obscureText: true,
              textInputAction: TextInputAction.done,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Mot de passe requis' : null,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: isLoading ? null : onForgotPassword,
                child: const Text('Mot de passe oublié ?'),
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Continuer',
              isLoading: isLoading,
              onPressed: isLoading ? null : onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmIntentStep extends StatelessWidget {
  const _ConfirmIntentStep({
    super.key,
    required this.isLoading,
    required this.email,
    required this.onCancel,
    required this.onConfirm,
  });

  final bool isLoading;
  final String email;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary;
    final subColor =
        isDark ? AppColors.darkBodySecondary : AppColors.lightBodySecondary;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _WarningPanel(
            icon: Icons.mark_email_read_outlined,
            title: 'Confirmer la demande',
            message:
                'Nous allons envoyer un code à $email. La suppression sera lancée uniquement après ce code.',
          ),
          const SizedBox(height: 24),
          Text(
            'Voulez-vous vraiment continuer ?',
            style: AppTextStyles.titleLarge.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cette étape protège votre compte si quelqu’un a accès à votre téléphone.',
            style: AppTextStyles.bodyMedium.copyWith(color: subColor),
          ),
          const Spacer(),
          AppButton(
            text: 'Oui, envoyer le code',
            isLoading: isLoading,
            onPressed: isLoading ? null : onConfirm,
          ),
          const SizedBox(height: 12),
          AppButton(
            text: 'Annuler',
            isSecondary: true,
            onPressed: isLoading ? null : onCancel,
          ),
        ],
      ),
    );
  }
}

class _CodeStep extends StatelessWidget {
  const _CodeStep({
    super.key,
    required this.otpKey,
    required this.isLoading,
    required this.email,
    required this.onSubmit,
  });

  final GlobalKey<OtpCodeInputState> otpKey;
  final bool isLoading;
  final String email;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary;
    final subColor =
        isDark ? AppColors.darkBodySecondary : AppColors.lightBodySecondary;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Code de suppression',
            style: AppTextStyles.titleLarge.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Entrez le code à 6 chiffres envoyé à $email.',
            style: AppTextStyles.bodyMedium.copyWith(color: subColor),
          ),
          const SizedBox(height: 24),
          OtpCodeInput(
            key: otpKey,
            onCompleted: (code) {
              if (!isLoading) onSubmit();
            },
          ),
          const Spacer(),
          const _WarningPanel(
            icon: Icons.warning_amber_rounded,
            title: 'Dernière confirmation',
            message:
                'Après validation, la session sera fermée et le compte ne pourra pas être restauré.',
          ),
          const SizedBox(height: 18),
          AppButton(
            text: 'Supprimer définitivement',
            isLoading: isLoading,
            onPressed: isLoading ? null : onSubmit,
          ),
        ],
      ),
    );
  }
}

class _WarningPanel extends StatelessWidget {
  const _WarningPanel({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary;
    final subColor =
        isDark ? AppColors.darkBodySecondary : AppColors.lightBodySecondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: isDark ? 0.16 : 0.08),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.28)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.error, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: AppTextStyles.bodyMedium.copyWith(color: subColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
