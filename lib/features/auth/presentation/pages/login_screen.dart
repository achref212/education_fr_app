import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/injection_container.dart';
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary;

    return BlocProvider(
      create: (context) => sl<LoginCubit>(),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          state.maybeWhen(
            success: () {
              context.router.replaceAll([const HomeRoute()]);
            },
            error: (message) {
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
          final isLoading = state.maybeWhen(
            loading: () => true,
            orElse: () => false,
          );

          return Scaffold(
            backgroundColor:
                isDark ? AppColors.darkBackground : AppColors.lightBackground,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: textColor),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 32),
                      Text(
                        'Heureux de vous revoir !',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Connectez-vous pour continuer votre apprentissage',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: isDark
                              ? AppColors.darkBodySecondary
                              : AppColors.lightBodySecondary,
                        ),
                      ),
                      const SizedBox(height: 48),
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
                      ),
                      const SizedBox(height: 24),
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
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Mot de passe oublié ?',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      AppButton(
                        text: 'Se connecter',
                        isLoading: isLoading,
                        onPressed: () => _onLoginPressed(context),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Vous n\'avez pas de compte ?',
                            style: AppTextStyles.bodyMedium.copyWith(color: textColor),
                          ),
                          TextButton(
                            onPressed: () {
                              context.router.replace(const RegisterRoute());
                            },
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
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
