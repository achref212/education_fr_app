import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/auth_screen_shell.dart';
import '../../../../core/navigation/post_auth_navigator.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/injection_container.dart';
import '../../../theme/presentation/cubit/theme_cubit.dart';
import '../../domain/usecases/resend_activation_use_case.dart';
import '../cubit/login_cubit.dart';
import '../cubit/login_state.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<LoginCubit>().login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  Future<void> _handleInactiveAccount(BuildContext context, String email) async {
    final shouldVerify = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Compte non activé'),
        content: const Text(
          'Votre compte n\'est pas encore activé. '
          'Souhaitez-vous recevoir un nouveau code de vérification ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Recevoir le code'),
          ),
        ],
      ),
    );
    if (shouldVerify != true || !context.mounted) return;
    final result = await sl<ResendActivationUseCase>()(
      ResendActivationParams(email: email),
    );
    if (!context.mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message), backgroundColor: AppColors.error),
      ),
      (token) {
        if (token == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Impossible d\'envoyer le code.')),
          );
          return;
        }
        context.router.push(VerifyAccountRoute(
          email: email,
          registrationStateToken: token,
        ));
      },
    );
  }

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
        create: (_) => sl<LoginCubit>(),
        child: BlocConsumer<LoginCubit, LoginState>(
          listener: (context, state) {
            state.maybeWhen(
              success: () => navigateAfterAuth(context.router),
              error: (message) {
                final email = _emailController.text.trim();
                if (message.toLowerCase().contains('désactivé') &&
                    email.isNotEmpty) {
                  _handleInactiveAccount(context, email);
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: AppColors.error,
                  ),
                );
              },
              orElse: () {},
            );
          },
          builder: (context, state) {
            final isLoading =
                state.maybeWhen(loading: () => true, orElse: () => false);

            return AuthScreenShell(
              showBackButton: true,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _LogoHeader(isDark: isDark, textColor: textColor)
                          .animate(delay: 100.ms)
                          .fadeIn(duration: 500.ms)
                          .slideY(begin: -0.1, end: 0),
                      const SizedBox(height: 24),
                      Text(
                        'Connectez-vous pour continuer votre apprentissage',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                          .animate(delay: 200.ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.08, end: 0),
                      const SizedBox(height: 32),
                      AppTextField(
                        label: 'Adresse e-mail',
                        hintText: 'Entrez votre e-mail',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'L\'e-mail est requis';
                          }
                          if (!value.contains('@')) {
                            return 'Veuillez entrer un e-mail valide';
                          }
                          return null;
                        },
                      )
                          .animate(delay: 250.ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.08, end: 0),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Mot de passe',
                        hintText: 'Entrez votre mot de passe',
                        controller: _passwordController,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Le mot de passe est requis';
                          }
                          return null;
                        },
                      )
                          .animate(delay: 300.ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.08, end: 0),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () =>
                              context.router.push(const ForgotPasswordRoute()),
                          child: Text(
                            'Mot de passe oublié ?',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        text: 'Se connecter',
                        isLoading: isLoading,
                        onPressed: () => _onLoginPressed(context),
                      )
                          .animate(delay: 350.ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.08, end: 0),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Vous n\'avez pas de compte ?',
                            style:
                                AppTextStyles.bodyMedium.copyWith(color: textColor),
                          ),
                          TextButton(
                            onPressed: () =>
                                context.router.replace(const RegisterRoute()),
                            child: Text(
                              'S\'inscrire',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'En vous connectant, vous acceptez nos conditions d\'utilisation.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(color: subColor),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LogoHeader extends StatelessWidget {
  const _LogoHeader({required this.isDark, required this.textColor});

  final bool isDark;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/icons/icon_screens.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Hello!',
          style: AppTextStyles.headlineMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 32,
          ),
        ),
      ],
    );
  }
}
