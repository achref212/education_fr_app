import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/auth_screen_shell.dart';
import '../../../../core/presentation/widgets/phone_field.dart';
import '../../../../core/network/media_url.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/injection_container.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../theme/presentation/cubit/theme_cubit.dart';
import '../cubit/edit_profile_cubit.dart';
import '../cubit/edit_profile_state.dart';
import '../widgets/profile_picture_actions.dart';

@RoutePage()
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.user});

  final User user;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _emailCtrl;
  late User _currentUser;
  late DateTime? _dateOfBirth;
  String _phone = '';

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _firstNameCtrl = TextEditingController(text: widget.user.firstName);
    _lastNameCtrl = TextEditingController(text: widget.user.lastName);
    _emailCtrl = TextEditingController(text: widget.user.email);
    _dateOfBirth = widget.user.dateOfBirth;
    _phone = widget.user.phone ?? '';
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 12),
      firstDate: DateTime(now.year - 25),
      lastDate: DateTime(now.year - 4),
      locale: const Locale('fr', 'FR'),
      helpText: 'Date de naissance',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  void _save(BuildContext context) {
    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner votre date de naissance'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      context.read<EditProfileCubit>().save(
            firstName: _firstNameCtrl.text.trim(),
            lastName: _lastNameCtrl.text.trim(),
            phone: _phone,
            dateOfBirth: _dateOfBirth!,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary;
    final subColor =
        isDark ? AppColors.darkBodySecondary : AppColors.lightBodySecondary;
    final surfColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final formattedBirth = _dateOfBirth != null
        ? DateFormat('dd / MM / yyyy', 'fr_FR').format(_dateOfBirth!)
        : null;

    return BlocProvider.value(
      value: sl<ThemeCubit>(),
      child: BlocProvider(
        create: (_) => sl<EditProfileCubit>(),
        child: BlocConsumer<EditProfileCubit, EditProfileState>(
          listener: (context, state) {
            state.maybeWhen(
              success: (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profil mis à jour avec succès'),
                    backgroundColor: AppColors.success,
                  ),
                );
                context.router.maybePop(true);
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
              title: 'Modifier le profil',
              subtitle: 'Mettez à jour vos informations personnelles',
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Prénom',
                              hintText: 'Votre prénom',
                              controller: _firstNameCtrl,
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? 'Requis' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              label: 'Nom',
                              hintText: 'Votre nom',
                              controller: _lastNameCtrl,
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? 'Requis' : null,
                            ),
                          ),
                        ],
                      ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Adresse e-mail',
                        hintText: _currentUser.email,
                        controller: _emailCtrl,
                        readOnly: true,
                        keyboardType: TextInputType.emailAddress,
                      ).animate(delay: 150.ms).fadeIn(duration: 400.ms),
                      const SizedBox(height: 6),
                      Text(
                        'L\'e-mail ne peut pas être modifié.',
                        style:
                            AppTextStyles.bodySmall.copyWith(color: subColor),
                      ),
                      const SizedBox(height: 16),
                      _EditProfilePictureCard(
                        user: _currentUser,
                        onTap: () => _changeProfilePicture(context),
                      ).animate(delay: 80.ms).fadeIn(duration: 400.ms),
                      const SizedBox(height: 18),
                      PhoneField(
                        label: 'Numéro de téléphone',
                        initialDialCode: _extractDialCode(_phone),
                        initialNationalNumber: _extractNationalNumber(_phone),
                        onChanged: (v) => _phone = v,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Le numéro est requis';
                          }
                          return null;
                        },
                      ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                      const SizedBox(height: 16),
                      _BirthdayField(
                        label: 'Date de naissance',
                        value: formattedBirth,
                        surfaceColor: surfColor,
                        textColor: textColor,
                        hintColor: subColor,
                        onTap: _pickDateOfBirth,
                      ).animate(delay: 250.ms).fadeIn(duration: 400.ms),
                      const SizedBox(height: 32),
                      AppButton(
                        text: 'Enregistrer',
                        isLoading: isLoading,
                        onPressed: () => _save(context),
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

  String _extractDialCode(String phone) {
    if (phone.startsWith('+216')) return '+216';
    if (phone.startsWith('+33')) return '+33';
    if (phone.startsWith('+')) {
      final parts = phone.split(' ');
      return parts.isNotEmpty ? parts.first : '+216';
    }
    return '+216';
  }

  String? _extractNationalNumber(String phone) {
    if (phone.isEmpty) return null;
    final parts = phone.split(' ');
    if (parts.length <= 1) return phone.replaceAll(RegExp(r'^\+\d+\s*'), '');
    return parts.sublist(1).join(' ');
  }

  Future<void> _changeProfilePicture(BuildContext context) async {
    final updated = await showProfilePictureActions(
      context: context,
      user: _currentUser,
    );
    if (updated != null && mounted) {
      setState(() => _currentUser = updated);
    }
  }
}

class _EditProfilePictureCard extends StatelessWidget {
  const _EditProfilePictureCard({
    required this.user,
    required this.onTap,
  });

  final User user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor =
        isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary;
    final subColor =
        isDark ? AppColors.darkBodySecondary : AppColors.lightBodySecondary;
    final resolved = resolveMediaUrl(user.profilePictureUrl);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            ),
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: AppColors.primary,
                    backgroundImage:
                        resolved.isNotEmpty ? NetworkImage(resolved) : null,
                    child: resolved.isEmpty
                        ? Text(
                            user.initials,
                            style: AppTextStyles.titleLarge.copyWith(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.onPrimary, width: 2),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        size: 14,
                        color: AppColors.lightBodyPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Photo de profil',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Image, caméra ou avatar personnalisé',
                      style: AppTextStyles.bodySmall.copyWith(color: subColor),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: subColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _BirthdayField extends StatelessWidget {
  const _BirthdayField({
    required this.label,
    required this.value,
    required this.surfaceColor,
    required this.textColor,
    required this.hintColor,
    required this.onTap,
  });

  final String label;
  final String? value;
  final Color surfaceColor;
  final Color textColor;
  final Color hintColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 20, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value ?? 'Sélectionner votre date de naissance',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: value != null ? textColor : hintColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
