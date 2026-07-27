import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/media_url.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../injection/injection_container.dart';
import '../../../auth/domain/entities/profile_image_asset.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/generate_profile_avatar_use_case.dart';
import '../../../auth/domain/usecases/list_profile_images_use_case.dart';
import '../../../auth/domain/usecases/set_profile_picture_use_case.dart';
import 'avatar_creator_dialog.dart';
import 'avatar_preview.dart';
import 'profile_image_adjust_dialog.dart';

Future<User?> showProfilePictureActions({
  required BuildContext context,
  required User user,
}) async {
  final source = await showModalBottomSheet<_PictureAction>(
    context: context,
    showDragHandle: true,
    builder: (_) => const _PictureActionSheet(),
  );
  if (source == null || !context.mounted) return null;

  return switch (source) {
    _PictureAction.gallery => _pickAndSave(
        context: context,
        imageSource: ImageSource.gallery,
      ),
    _PictureAction.camera => _pickAndSave(
        context: context,
        imageSource: ImageSource.camera,
      ),
    _PictureAction.previous => _reusePreviousPicture(context),
    _PictureAction.avatar => _createAvatar(context),
  };
}

Future<User?> showAvatarCreatorProfileFlow({
  required BuildContext context,
}) {
  return _createAvatar(context);
}

Future<User?> _pickAndSave({
  required BuildContext context,
  required ImageSource imageSource,
}) async {
  final picker = ImagePicker();
  final image = await picker.pickImage(
    source: imageSource,
    imageQuality: 88,
    maxWidth: 1024,
    maxHeight: 1024,
  );
  if (image == null || !context.mounted) return null;
  final bytes = await image.readAsBytes();
  if (!context.mounted) return null;
  return _adjustAndSavePictureBytes(
    context: context,
    bytes: bytes,
    successMessage: 'Photo de profil mise à jour',
  );
}

Future<User?> _createAvatar(BuildContext context) async {
  final result = await showAvatarCreatorDialog(context);
  if (result == null || !context.mounted) return null;
  if (result.useAi) {
    return _generateAiAvatar(context: context, result: result);
  }
  return _adjustAndSavePictureBytes(
    context: context,
    bytes: result.bytes!,
    successMessage: 'Avatar enregistré',
  );
}

Future<User?> _reusePreviousPicture(BuildContext context) async {
  _showBusyDialog(context, 'Chargement des photos...');
  final result = await sl<ListProfileImagesUseCase>()(const NoParams());
  if (context.mounted) Navigator.of(context, rootNavigator: true).pop();

  return result.fold<Future<User?>>(
    (failure) async {
      if (context.mounted) _showError(context, failure.message);
      return null;
    },
    (assets) async {
      if (!context.mounted) return null;
      if (assets.isEmpty) {
        _showError(context, 'Aucune photo déjà utilisée.');
        return null;
      }
      final selected = await showModalBottomSheet<ProfileImageAsset>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (_) => _PreviousProfileImageSheet(assets: assets),
      );
      if (selected == null || !context.mounted) return null;
      final bytes = await _downloadProfileImage(
        context: context,
        url: selected.url,
      );
      if (bytes == null || !context.mounted) return null;
      return _adjustAndSavePictureBytes(
        context: context,
        bytes: bytes,
        successMessage: 'Photo de profil réutilisée',
      );
    },
  );
}

Future<User?> _adjustAndSavePictureBytes({
  required BuildContext context,
  required Uint8List bytes,
  required String successMessage,
}) async {
  final adjusted = await showProfileImageAdjustDialog(
    context: context,
    bytes: bytes,
  );
  if (adjusted == null || !context.mounted) return null;
  return _savePictureBytes(
    context: context,
    bytes: adjusted,
    filename: 'profile-picture.png',
    contentType: 'image/png',
    successMessage: successMessage,
  );
}

Future<User?> _savePictureBytes({
  required BuildContext context,
  required Uint8List bytes,
  required String filename,
  required String contentType,
  String successMessage = 'Photo de profil mise à jour',
}) async {
  _showBusyDialog(context, 'Enregistrement de la photo...');
  final result = await sl<SetProfilePictureUseCase>()(
    SetProfilePictureParams(
      bytes: bytes,
      filename: filename,
      contentType: contentType,
    ),
  );
  if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
  return result.fold(
    (failure) {
      if (context.mounted) _showError(context, failure.message);
      return null;
    },
    (updatedUser) {
      if (context.mounted) _showSuccess(context, successMessage);
      return updatedUser;
    },
  );
}

Future<User?> _generateAiAvatar({
  required BuildContext context,
  required AvatarCreationResult result,
}) async {
  _showBusyDialog(context, 'Génération de l\'avatar IA...');
  final response = await sl<GenerateProfileAvatarAssetUseCase>()(
    GenerateProfileAvatarParams(
      style: result.customization.style.apiValue,
      customization: result.customization.toPromptMap(),
      prompt: result.prompt,
      selfieBytes: result.selfieBytes,
      selfieFilename: result.selfieFilename,
      selfieContentType: result.selfieContentType,
    ),
  );
  if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
  return response.fold<Future<User?>>(
    (failure) async {
      if (context.mounted) _showError(context, failure.message);
      return null;
    },
    (generatedUrl) async {
      if (!context.mounted) return null;
      final bytes = await _downloadGeneratedAvatar(
        context: context,
        url: generatedUrl,
      );
      if (bytes == null || !context.mounted) return null;
      return _adjustAndSavePictureBytes(
        context: context,
        bytes: bytes,
        successMessage: 'Avatar IA enregistré',
      );
    },
  );
}

Future<Uint8List?> _downloadGeneratedAvatar({
  required BuildContext context,
  required String url,
}) async {
  _showBusyDialog(context, 'Préparation de l\'avatar...');
  try {
    final response = await sl<Dio>().get<List<int>>(
      resolveMediaUrl(url),
      options: Options(responseType: ResponseType.bytes),
    );
    final data = response.data;
    if (data == null || data.isEmpty) {
      throw StateError('empty avatar image');
    }
    return Uint8List.fromList(data);
  } catch (_) {
    if (context.mounted) {
      _showError(context, 'Impossible de préparer l\'avatar IA.');
    }
    return null;
  } finally {
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
  }
}

Future<Uint8List?> _downloadProfileImage({
  required BuildContext context,
  required String url,
}) async {
  _showBusyDialog(context, 'Préparation de la photo...');
  try {
    final response = await sl<Dio>().get<List<int>>(
      resolveMediaUrl(url),
      options: Options(responseType: ResponseType.bytes),
    );
    final data = response.data;
    if (data == null || data.isEmpty) {
      throw StateError('empty profile image');
    }
    return Uint8List.fromList(data);
  } catch (_) {
    if (context.mounted) {
      _showError(context, 'Impossible de préparer cette photo.');
    }
    return null;
  } finally {
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
  }
}

void _showBusyDialog(BuildContext context, String message) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      content: Row(
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(message)),
        ],
      ),
    ),
  );
}

void _showSuccess(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: AppColors.success),
  );
}

void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: AppColors.error),
  );
}

enum _PictureAction { gallery, camera, previous, avatar }

class _PictureActionSheet extends StatelessWidget {
  const _PictureActionSheet();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionTile(
                icon: Icons.photo_library_outlined,
                title: 'Importer une image',
                subtitle: 'Choisir depuis la galerie',
                action: _PictureAction.gallery,
              ),
              _ActionTile(
                icon: Icons.photo_camera_outlined,
                title: 'Prendre une photo',
                subtitle: 'Utiliser la caméra maintenant',
                action: _PictureAction.camera,
              ),
              _ActionTile(
                icon: Icons.collections_outlined,
                title: 'Photos déjà utilisées',
                subtitle: 'Réutiliser et ajuster une ancienne photo',
                action: _PictureAction.previous,
              ),
              _ActionTile(
                icon: Icons.face_retouching_natural_outlined,
                title: 'Créer un avatar',
                subtitle: 'Personnaliser ou générer une version IA',
                action: _PictureAction.avatar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviousProfileImageSheet extends StatelessWidget {
  const _PreviousProfileImageSheet({required this.assets});

  final List<ProfileImageAsset> assets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary;
    final subColor =
        isDark ? AppColors.darkBodySecondary : AppColors.lightBodySecondary;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Photos déjà utilisées',
              style: theme.textTheme.titleLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Choisissez une photo puis ajustez son cadrage.',
              style: theme.textTheme.bodyMedium?.copyWith(color: subColor),
            ),
            const SizedBox(height: 18),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.55,
              ),
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.82,
                ),
                itemCount: assets.length,
                itemBuilder: (context, index) {
                  final asset = assets[index];
                  return _PreviousProfileImageTile(asset: asset);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviousProfileImageTile extends StatelessWidget {
  const _PreviousProfileImageTile({required this.asset});

  final ProfileImageAsset asset;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor =
        isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.pop(context, asset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.35),
                width: 2,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              resolveMediaUrl(asset.url),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(
                Icons.person_rounded,
                color: AppColors.primary.withValues(alpha: 0.75),
                size: 34,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            asset.title?.trim().isNotEmpty == true
                ? asset.title!.trim()
                : 'Photo profil',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: labelColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.action,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final _PictureAction action;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.12),
        foregroundColor: AppColors.primary,
        child: Icon(icon),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => Navigator.pop(context, action),
    );
  }
}
