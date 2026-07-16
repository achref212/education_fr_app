import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/auth_screen_shell.dart';
import '../../../../core/presentation/widgets/phone_field.dart';
import '../../../../core/presentation/widgets/selection_bottom_sheet.dart';
import '../../../../core/presentation/widgets/tappable_picker_field.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../injection/injection_container.dart';
import '../../../theme/presentation/cubit/theme_cubit.dart';
import '../../domain/entities/school.dart';
import '../../domain/usecases/get_schools_use_case.dart';
import '../auth_constants.dart';
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
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _otherSchoolCtrl = TextEditingController();
  final _phoneFieldKey = GlobalKey<PhoneFieldState>();

  DateTime? _dateOfBirth;
  String _phone = '';
  String? _classLevel;
  String? _schoolId;
  String? _schoolLabel;
  bool _isOtherSchool = false;
  List<School> _schools = [];
  bool _isLoadingSchools = true;
  bool _showValidationErrors = false;

  @override
  void initState() {
    super.initState();
    _loadSchools();
  }

  Future<void> _loadSchools() async {
    final result = await sl<GetSchoolsUseCase>()(const NoParams());
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _isLoadingSchools = false),
      (schools) => setState(() {
        _schools = schools;
        _isLoadingSchools = false;
      }),
    );
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _otherSchoolCtrl.dispose();
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
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: AppColors.onPrimary,
            surface: Theme.of(ctx).brightness == Brightness.dark
                ? AppColors.darkBackground
                : AppColors.lightBackground,
            onSurface: Theme.of(ctx).brightness == Brightness.dark
                ? AppColors.darkBodyPrimary
                : AppColors.lightBodyPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (!mounted) return;
    setState(() {
      if (picked != null) _dateOfBirth = picked;
    });
  }

  Future<void> _pickClassLevel() async {
    final selected = await showSelectionBottomSheet(
      context: context,
      title: 'Niveau scolaire',
      items: AuthConstants.classLevels
          .map((l) => SelectionItem(id: l, label: l))
          .toList(),
    );
    if (!mounted) return;
    setState(() {
      if (selected != null) _classLevel = selected.id;
    });
  }

  Future<void> _pickSchool() async {
    if (_isLoadingSchools) return;
    final selected = await showSelectionBottomSheet(
      context: context,
      title: 'Établissement scolaire',
      searchHint: 'Rechercher une école…',
      items: _schools
          .map((s) => SelectionItem(
                id: s.id,
                label: s.name,
                subtitle: s.city,
              ))
          .toList(),
      extraItem: const SelectionItem(
        id: AuthConstants.otherSchoolId,
        label: 'Autre — Mon école n\'est pas listée',
        subtitle: 'Continuer sans établissement associé',
      ),
    );
    if (!mounted) return;
    setState(() {
      if (selected == null) return;
      if (selected.id == AuthConstants.otherSchoolId) {
        _isOtherSchool = true;
        _schoolId = null;
        _schoolLabel = selected.label;
      } else {
        _isOtherSchool = false;
        _schoolId = selected.id;
        _schoolLabel = selected.subtitle != null
            ? '${selected.label} · ${selected.subtitle}'
            : selected.label;
        _otherSchoolCtrl.clear();
      }
    });
  }

  String? _validateBirthday() {
    if (_dateOfBirth == null) return 'La date de naissance est requise';
    return null;
  }

  String? _validateSchool() {
    if (_isOtherSchool || _schoolId != null) return null;
    return 'Veuillez sélectionner un établissement';
  }

  String? _validateClassLevel() {
    if (_classLevel == null || _classLevel!.isEmpty) {
      return 'Veuillez sélectionner un niveau scolaire';
    }
    return null;
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  void _onRegisterPressed(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _showValidationErrors = true);

    final birthdayError = _validateBirthday();
    final schoolError = _validateSchool();
    final classError = _validateClassLevel();
    final formIsValid = _formKey.currentState?.validate() ?? false;

    if (!formIsValid ||
        birthdayError != null ||
        schoolError != null ||
        classError != null) {
      return;
    }

    context.read<RegisterCubit>().register(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          firstName: _firstNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
          classLevel: _classLevel!,
          schoolId: _schoolId,
          phone: _phone,
          dateOfBirth: _dateOfBirth!,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary;
    final subColor =
        isDark ? AppColors.darkBodySecondary : AppColors.lightBodySecondary;
    final surfColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final birthdayError = _showValidationErrors ? _validateBirthday() : null;
    final schoolError = _showValidationErrors ? _validateSchool() : null;
    final classError = _showValidationErrors ? _validateClassLevel() : null;

    return BlocProvider.value(
      value: sl<ThemeCubit>(),
      child: BlocProvider(
        create: (_) => sl<RegisterCubit>(),
        child: BlocConsumer<RegisterCubit, RegisterState>(
          listener: (context, state) {
            state.maybeWhen(
              success: (email, token) {
                context.router.push(VerifyAccountRoute(
                  email: email,
                  registrationStateToken: token,
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
              title: 'Créer un compte',
              subtitle: 'Rejoignez DELFy et commencez à apprendre',
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _showValidationErrors
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _animatedSection(
                        delay: 0,
                        child: Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                label: 'Prénom',
                                hintText: 'Votre prénom',
                                controller: _firstNameCtrl,
                                textInputAction: TextInputAction.next,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? 'Requis'
                                        : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: AppTextField(
                                label: 'Nom',
                                hintText: 'Votre nom',
                                controller: _lastNameCtrl,
                                textInputAction: TextInputAction.next,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? 'Requis'
                                        : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _animatedSection(
                        delay: 50,
                        child: _DatePickerField(
                          label: 'Date de naissance',
                          value: _dateOfBirth,
                          isDark: isDark,
                          surfaceColor: surfColor,
                          textColor: textColor,
                          hintColor: subColor,
                          errorText: birthdayError,
                          onTap: _pickDateOfBirth,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _animatedSection(
                        delay: 100,
                        child: PhoneField(
                          key: _phoneFieldKey,
                          label: 'Numéro de téléphone',
                          onChanged: (v) => _phone = v,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Le numéro est requis';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      _animatedSection(
                        delay: 150,
                        child: TappablePickerField(
                          label: 'Établissement scolaire',
                          hintText: _isLoadingSchools
                              ? 'Chargement des écoles…'
                              : 'Sélectionnez votre école',
                          value: _schoolLabel,
                          errorText: schoolError,
                          onTap: _pickSchool,
                        ),
                      ),
                      if (_isOtherSchool) ...[
                        const SizedBox(height: 12),
                        _animatedSection(
                          delay: 175,
                          child: AppTextField(
                            label: 'Nom de votre établissement',
                            hintText: 'Ex. Lycée Bourguiba',
                            controller: _otherSchoolCtrl,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Votre établissement pourra être associé plus tard par votre professeur.',
                          style:
                              AppTextStyles.bodySmall.copyWith(color: subColor),
                        ),
                      ],
                      const SizedBox(height: 16),
                      _animatedSection(
                        delay: 200,
                        child: TappablePickerField(
                          label: 'Niveau scolaire',
                          hintText: 'Sélectionnez votre classe',
                          value: _classLevel,
                          errorText: classError,
                          onTap: _pickClassLevel,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _animatedSection(
                        delay: 250,
                        child: AppTextField(
                          label: 'Adresse e-mail',
                          hintText: 'Entrez votre e-mail',
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'L\'e-mail est requis';
                            }
                            if (!_isValidEmail(v.trim())) {
                              return 'E-mail invalide';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      _animatedSection(
                        delay: 300,
                        child: AppTextField(
                          label: 'Mot de passe',
                          hintText: 'Créez un mot de passe',
                          controller: _passwordCtrl,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Le mot de passe est requis';
                            }
                            if (v.length < 8) {
                              return 'Minimum 8 caractères';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      _animatedSection(
                        delay: 350,
                        child: AppButton(
                          text: "S'inscrire",
                          isLoading: isLoading,
                          onPressed: isLoading
                              ? null
                              : () => _onRegisterPressed(context),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Vous avez déjà un compte ?',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: textColor),
                          ),
                          TextButton(
                            onPressed: () =>
                                context.router.replace(const LoginRoute()),
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

  Widget _animatedSection({required int delay, required Widget child}) {
    return child
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.08, end: 0, curve: Curves.easeOut);
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.value,
    required this.isDark,
    required this.surfaceColor,
    required this.textColor,
    required this.hintColor,
    required this.onTap,
    this.errorText,
  });

  final String label;
  final DateTime? value;
  final bool isDark;
  final Color surfaceColor;
  final Color textColor;
  final Color hintColor;
  final VoidCallback onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final formatted = value != null
        ? DateFormat('dd / MM / yyyy', 'fr_FR').format(value!)
        : null;
    final hasError = errorText != null && errorText!.isNotEmpty;

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
              border: Border.all(
                color: hasError
                    ? AppColors.error
                    : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 20, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    formatted ?? 'Sélectionner votre date de naissance',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: formatted != null ? textColor : hintColor,
                    ),
                  ),
                ),
                if (value != null)
                  const Icon(Icons.check_circle_rounded,
                      size: 18, color: AppColors.success),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}
