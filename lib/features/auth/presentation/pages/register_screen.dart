import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/presentation/widgets/app_dropdown_field.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/injection_container.dart';
import '../cubit/register_cubit.dart';
import '../cubit/register_state.dart';

@RoutePage()
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedLevel;

  final List<String> _levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed(BuildContext context) {
    if (_formKey.currentState!.validate() && _selectedLevel != null) {
      context.read<RegisterCubit>().register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            level: _selectedLevel!,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary;

    return BlocProvider(
      create: (context) => sl<RegisterCubit>(),
      child: BlocConsumer<RegisterCubit, RegisterState>(
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
                      Text(
                        'Créer un compte',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rejoignez DELFy et commencez à apprendre',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: isDark
                              ? AppColors.darkBodySecondary
                              : AppColors.lightBodySecondary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Prénom',
                              hintText: 'Votre prénom',
                              controller: _firstNameController,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Requis';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              label: 'Nom',
                              hintText: 'Votre nom',
                              controller: _lastNameController,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Requis';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppDropdownField<String>(
                        label: 'Niveau de français',
                        hintText: 'Sélectionnez votre niveau',
                        value: _selectedLevel,
                        items: _levels.map((level) {
                          return DropdownMenuItem(
                            value: level,
                            child: Text(level),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedLevel = val;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez sélectionner un niveau';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Mot de passe',
                        hintText: 'Créez un mot de passe',
                        controller: _passwordController,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Le mot de passe est requis';
                          }
                          if (value.length < 6) {
                            return 'Minimum 6 caractères';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      AppButton(
                        text: 'S\'inscrire',
                        isLoading: isLoading,
                        onPressed: () => _onRegisterPressed(context),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Vous avez déjà un compte ?',
                            style: AppTextStyles.bodyMedium.copyWith(color: textColor),
                          ),
                          TextButton(
                            onPressed: () {
                              context.router.replace(const LoginRoute());
                            },
                            child: Text(
                              'Se connecter',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
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
