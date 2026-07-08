import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/auth_screen_shell.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection/injection_container.dart';
import '../../../theme/presentation/cubit/theme_cubit.dart';
import '../cubit/change_password_cubit.dart';
import '../cubit/change_password_state.dart';

@RoutePage()
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  @override
  void dispose() {
    _oldPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<ThemeCubit>(),
      child: BlocProvider(
        create: (_) => sl<ChangePasswordCubit>(),
        child: BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
          listener: (context, state) {
            state.maybeWhen(
              success: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mot de passe modifié avec succès'),
                    backgroundColor: AppColors.success,
                  ),
                );
                context.router.maybePop();
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
              title: 'Changer le mot de passe',
              subtitle: 'Utilisez un mot de passe fort d\'au moins 8 caractères',
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        label: 'Mot de passe actuel',
                        hintText: 'Entrez votre mot de passe actuel',
                        controller: _oldPasswordCtrl,
                        obscureText: true,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Requis' : null,
                      )
                          .animate(delay: 100.ms)
                          .fadeIn(duration: 400.ms),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Nouveau mot de passe',
                        hintText: 'Minimum 8 caractères',
                        controller: _newPasswordCtrl,
                        obscureText: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Requis';
                          if (v.length < 8) return 'Minimum 8 caractères';
                          return null;
                        },
                      )
                          .animate(delay: 150.ms)
                          .fadeIn(duration: 400.ms),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Confirmer le mot de passe',
                        hintText: 'Répétez le nouveau mot de passe',
                        controller: _confirmPasswordCtrl,
                        obscureText: true,
                        validator: (v) {
                          if (v != _newPasswordCtrl.text) {
                            return 'Les mots de passe ne correspondent pas';
                          }
                          return null;
                        },
                      )
                          .animate(delay: 200.ms)
                          .fadeIn(duration: 400.ms),
                      const SizedBox(height: 32),
                      AppButton(
                        text: 'Mettre à jour',
                        isLoading: isLoading,
                        onPressed: isLoading
                            ? () {}
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  context
                                      .read<ChangePasswordCubit>()
                                      .changePassword(
                                        oldPassword: _oldPasswordCtrl.text,
                                        newPassword: _newPasswordCtrl.text,
                                      );
                                }
                              },
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
