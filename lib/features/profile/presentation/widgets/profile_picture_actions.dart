import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection/injection_container.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/generate_profile_avatar_use_case.dart';
import '../../../auth/domain/usecases/set_profile_picture_use_case.dart';
import 'avatar_creator_dialog.dart';
import 'avatar_preview.dart';

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
    _PictureAction.avatar => _createAvatar(context),
  };
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
  return _savePictureBytes(
    context: context,
    bytes: bytes,
    filename: _safeFilename(image.name, imageSource),
    contentType: _contentTypeFor(image),
  );
}

Future<User?> _createAvatar(BuildContext context) async {
  final result = await showAvatarCreatorDialog(context);
  if (result == null || !context.mounted) return null;
  if (result.useAi) {
    return _generateAiAvatar(context: context, result: result);
  }
  return _savePictureBytes(
    context: context,
    bytes: result.bytes!,
    filename: 'avatar.png',
    contentType: 'image/png',
  );
}

Future<User?> _savePictureBytes({
  required BuildContext context,
  required Uint8List bytes,
  required String filename,
  required String contentType,
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
      if (context.mounted) _showSuccess(context, 'Photo de profil mise à jour');
      return updatedUser;
    },
  );
}

Future<User?> _generateAiAvatar({
  required BuildContext context,
  required AvatarCreationResult result,
}) async {
  _showBusyDialog(context, 'Génération de l\'avatar IA...');
  final response = await sl<GenerateProfileAvatarUseCase>()(
    GenerateProfileAvatarParams(
      style: result.customization.style.apiValue,
      customization: result.customization.toPromptMap(),
      prompt: result.prompt,
    ),
  );
  if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
  return response.fold(
    (failure) {
      if (context.mounted) _showError(context, failure.message);
      return null;
    },
    (updatedUser) {
      if (context.mounted) _showSuccess(context, 'Avatar IA enregistré');
      return updatedUser;
    },
  );
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

String _safeFilename(String name, ImageSource source) {
  if (name.trim().isNotEmpty) return name;
  return source == ImageSource.camera ? 'camera-profile.jpg' : 'profile.jpg';
}

String _contentTypeFor(XFile image) {
  final mime = image.mimeType;
  if (mime == 'image/png' || mime == 'image/jpeg' || mime == 'image/webp') {
    return mime!;
  }
  final lower = image.name.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  return 'image/jpeg';
}

enum _PictureAction { gallery, camera, avatar }

class _PictureActionSheet extends StatelessWidget {
  const _PictureActionSheet();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
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
              icon: Icons.face_retouching_natural_outlined,
              title: 'Créer un avatar',
              subtitle: 'Personnaliser ou générer une version IA',
              action: _PictureAction.avatar,
            ),
          ],
        ),
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
