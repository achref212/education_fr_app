import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/auth_screen_shell.dart';
import '../../../../core/presentation/widgets/otp_code_input.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/injection_container.dart';
import '../../../auth/domain/usecases/forgot_password_use_case.dart';
import '../../../auth/domain/usecases/reset_password_use_case.dart';
import '../../../auth/domain/usecases/verify_reset_code_use_case.dart';
import '../../../theme/presentation/cubit/theme_cubit.dart';

enum _RecoveryStep { email, code, newPassword }

@RoutePage()
class AccountDeletionPasswordRecoveryScreen extends StatefulWidget {
  const AccountDeletionPasswordRecoveryScreen({
    super.key,
    required this.email,
  });

  final String email;

  @override
  State<AccountDeletionPasswordRecoveryScreen> createState() =>
      _AccountDeletionPasswordRecoveryScreenState();
}

class _AccountDeletionPasswordRecoveryScreenState
    extends State<AccountDeletionPasswordRecoveryScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordFormKey = GlobalKey<FormState>();
  final _otpKey = GlobalKey<OtpCodeInputState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  _RecoveryStep _step = _RecoveryStep.email;
  bool _isLoading = false;
  String? _resetStateToken;
  String? _resetToken;

  @override
  void initState() {
    super.initState();
    _emailCtrl.text = widget.email;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<ThemeCubit>(),
      child: AuthScreenShell(
        title: 'Réinitialiser le mot de passe',
        subtitle: 'Restez dans l’application pour reprendre la suppression',
        child: SafeArea(
          top: false,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: switch (_step) {
              _RecoveryStep.email => _EmailStep(
                  key: const ValueKey('delete-recovery-email'),
                  emailCtrl: _emailCtrl,
                  isLoading: _isLoading,
                  onSubmit: _requestResetCode,
                ),
              _RecoveryStep.code => _CodeStep(
                  key: const ValueKey('delete-recovery-code'),
                  email: widget.email,
                  otpKey: _otpKey,
                  isLoading: _isLoading,
                  onSubmit: _verifyCode,
                ),
              _RecoveryStep.newPassword => _NewPasswordStep(
                  key: const ValueKey('delete-recovery-password'),
                  formKey: _passwordFormKey,
                  passwordCtrl: _passwordCtrl,
                  confirmCtrl: _confirmCtrl,
                  isLoading: _isLoading,
                  onSubmit: _resetPassword,
                ),
            },
          ),
        ),
      ),
    );
  }

  Future<void> _requestResetCode() async {
    setState(() => _isLoading = true);
    final result = await sl<ForgotPasswordUseCase>()(
      ForgotPasswordParams(email: widget.email),
    );
    if (!mounted) return;
    result.fold(
      (failure) => _showError(failure.message),
      (token) {
        if (token == null) {
          _showError('Impossible d’envoyer le code pour ce compte.');
          return;
        }
        setState(() {
          _resetStateToken = token;
          _step = _RecoveryStep.code;
        });
      },
    );
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _verifyCode() async {
    final code = _otpKey.currentState?.code ?? '';
    if (code.length != 6 || _resetStateToken == null) return;
    setState(() => _isLoading = true);
    final result = await sl<VerifyResetCodeUseCase>()(
      VerifyResetCodeParams(
        email: widget.email,
        code: code,
        resetStateToken: _resetStateToken!,
      ),
    );
    if (!mounted) return;
    result.fold(
      (failure) => _showError(failure.message),
      (token) {
        setState(() {
          _resetToken = token;
          _step = _RecoveryStep.newPassword;
        });
      },
    );
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _resetPassword() async {
    if (!_passwordFormKey.currentState!.validate() || _resetToken == null) {
      return;
    }
    setState(() => _isLoading = true);
    final result = await sl<ResetPasswordUseCase>()(
      ResetPasswordParams(
        email: widget.email,
        resetToken: _resetToken!,
        newPassword: _passwordCtrl.text,
      ),
    );
    if (!mounted) return;
    result.fold(
      (failure) => _showError(failure.message),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mot de passe réinitialisé.'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true);
      },
    );
    if (mounted) setState(() => _isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }
}

class _EmailStep extends StatelessWidget {
  const _EmailStep({
    super.key,
    required this.emailCtrl,
    required this.isLoading,
    required this.onSubmit,
  });

  final TextEditingController emailCtrl;
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subColor =
        isDark ? AppColors.darkBodySecondary : AppColors.lightBodySecondary;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Adresse e-mail du compte',
            hintText: 'Adresse e-mail',
            controller: emailCtrl,
            readOnly: true,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          Text(
            'Un code de réinitialisation sera envoyé à cette adresse avant de reprendre la suppression.',
            style: AppTextStyles.bodySmall.copyWith(color: subColor),
          ),
          const Spacer(),
          AppButton(
            text: 'Envoyer le code',
            isLoading: isLoading,
            onPressed: isLoading ? null : onSubmit,
          ),
        ],
      ),
    );
  }
}

class _CodeStep extends StatelessWidget {
  const _CodeStep({
    super.key,
    required this.email,
    required this.otpKey,
    required this.isLoading,
    required this.onSubmit,
  });

  final String email;
  final GlobalKey<OtpCodeInputState> otpKey;
  final bool isLoading;
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
            'Code reçu par e-mail',
            style: AppTextStyles.titleLarge.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Entrez le code envoyé à $email.',
            style: AppTextStyles.bodyMedium.copyWith(color: subColor),
          ),
          const SizedBox(height: 24),
          OtpCodeInput(
            key: otpKey,
            onCompleted: (_) {
              if (!isLoading) onSubmit();
            },
          ),
          const Spacer(),
          AppButton(
            text: 'Vérifier',
            isLoading: isLoading,
            onPressed: isLoading ? null : onSubmit,
          ),
        ],
      ),
    );
  }
}

class _NewPasswordStep extends StatelessWidget {
  const _NewPasswordStep({
    super.key,
    required this.formKey,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.isLoading,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: 'Nouveau mot de passe',
              hintText: 'Minimum 8 caractères',
              controller: passwordCtrl,
              obscureText: true,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Requis';
                if (value.length < 8) return 'Minimum 8 caractères';
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Confirmer le mot de passe',
              hintText: 'Répétez le mot de passe',
              controller: confirmCtrl,
              obscureText: true,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value != passwordCtrl.text) {
                  return 'Les mots de passe ne correspondent pas';
                }
                return null;
              },
            ),
            const Spacer(),
            AppButton(
              text: 'Réinitialiser et revenir',
              isLoading: isLoading,
              onPressed: isLoading ? null : onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
