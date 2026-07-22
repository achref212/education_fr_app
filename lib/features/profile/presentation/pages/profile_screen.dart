import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/network/media_url.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../injection/injection_container.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/logout_use_case.dart';
import '../../../theme/presentation/cubit/theme_cubit.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/profile_widgets.dart';

@RoutePage()
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<ThemeCubit>(),
      child: BlocProvider(
        create: (_) => sl<ProfileCubit>()..loadProfile(),
        child: const _ProfileView(),
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: bgColor,
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (message) => _ProfileError(
              message: message,
              onRetry: () => context.read<ProfileCubit>().loadProfile(),
            ),
            loaded: (user, schoolName) => _ProfileContent(
              user: user,
              schoolName: schoolName,
            ),
          );
        },
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({
    required this.user,
    this.schoolName,
  });

  final User user;
  final String? schoolName;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary;
    final subColor =
        isDark ? AppColors.darkBodySecondary : AppColors.lightBodySecondary;
    final birthLabel = user.dateOfBirth != null
        ? DateFormat('dd MMMM yyyy', 'fr_FR').format(user.dateOfBirth!)
        : 'Non renseignée';

    return RefreshIndicator(
      onRefresh: () => context.read<ProfileCubit>().loadProfile(),
      color: AppColors.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor:
                isDark ? AppColors.darkSurface : AppColors.lightSurfacePrimary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            AppColors.darkSurfacePrimary,
                            AppColors.darkBackground,
                          ]
                        : [
                            AppColors.lightSurfacePrimary,
                            AppColors.lightBackground,
                          ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      _AvatarBadge(
                        initials: user.initials,
                        imageUrl: user.profilePictureUrl,
                      )
                          .animate()
                          .scale(
                            begin: const Offset(0.85, 0.85),
                            duration: 500.ms,
                            curve: Curves.easeOutBack,
                          )
                          .fadeIn(),
                      const SizedBox(height: 14),
                      Text(
                        user.displayName,
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (user.classLevel != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user.classLevel!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  final updated = await context.router.push<bool>(
                    EditProfileRoute(user: user),
                  );
                  if (updated == true && context.mounted) {
                    context.read<ProfileCubit>().loadProfile();
                  }
                },
                icon: const Icon(Icons.edit_rounded),
                tooltip: 'Modifier le profil',
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  'INFORMATIONS',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: subColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                )
                    .animate(delay: 100.ms)
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 10),
                ProfileSectionCard(
                  children: [
                    ProfileInfoTile(
                      icon: Icons.email_outlined,
                      label: 'E-mail',
                      value: user.email,
                    ),
                    ProfileInfoTile(
                      icon: Icons.phone_outlined,
                      label: 'Téléphone',
                      value: user.phone ?? 'Non renseigné',
                    ),
                    ProfileInfoTile(
                      icon: Icons.cake_outlined,
                      label: 'Date de naissance',
                      value: birthLabel,
                    ),
                    ProfileInfoTile(
                      icon: Icons.school_outlined,
                      label: 'Établissement',
                      value: schoolName ?? 'Non associé',
                    ),
                    ProfileInfoTile(
                      icon: Icons.menu_book_outlined,
                      label: 'Niveau scolaire',
                      value: user.classLevel ?? user.level,
                    ),
                  ],
                )
                    .animate(delay: 150.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.06, end: 0),
                const SizedBox(height: 24),
                Text(
                  'COMPTE',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: subColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 10),
                ProfileSectionCard(
                  children: [
                    ProfileActionTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Changer le mot de passe',
                      subtitle: 'Mettre à jour votre mot de passe',
                      onTap: () =>
                          context.router.push(const ChangePasswordRoute()),
                    ),
                    ProfileActionTile(
                      icon: Icons.palette_outlined,
                      title: 'Thème',
                      subtitle: 'Mode clair ou sombre',
                      onTap: () => context.read<ThemeCubit>().toggleLightDark(),
                    ),
                  ],
                )
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.06, end: 0),
                const SizedBox(height: 24),
                ProfileSectionCard(
                  children: [
                    ProfileActionTile(
                      icon: Icons.logout_rounded,
                      title: 'Se déconnecter',
                      isDestructive: true,
                      onTap: () => _logout(context),
                    ),
                  ],
                )
                    .animate(delay: 250.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.06, end: 0),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Se déconnecter'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Déconnexion',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await sl<LogoutUseCase>()(const NoParams());
    if (context.mounted) {
      context.router.replaceAll([const SplashRoute()]);
    }
  }
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({
    required this.initials,
    this.imageUrl,
  });

  final String initials;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final resolvedImageUrl = resolveMediaUrl(imageUrl);
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: resolvedImageUrl.isNotEmpty
          ? ClipOval(
              child: Image.network(
                resolvedImageUrl,
                width: 88,
                height: 88,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _InitialsText(initials: initials),
              ),
            )
          : _InitialsText(initials: initials),
    );
  }
}

class _InitialsText extends StatelessWidget {
  const _InitialsText({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Text(
      initials,
      style: AppTextStyles.headlineMedium.copyWith(
        color: AppColors.onPrimary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
