import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'avatar_preview.dart';

class AvatarCreationResult {
  const AvatarCreationResult.local({
    required this.bytes,
    required this.customization,
  })  : useAi = false,
        prompt = null;

  const AvatarCreationResult.ai({
    required this.customization,
    this.prompt,
  })  : useAi = true,
        bytes = null;

  final bool useAi;
  final Uint8List? bytes;
  final AvatarCustomization customization;
  final String? prompt;
}

Future<AvatarCreationResult?> showAvatarCreatorDialog(
  BuildContext context,
) {
  return showModalBottomSheet<AvatarCreationResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AvatarCreatorDialog(),
  );
}

class _AvatarCreatorDialog extends StatefulWidget {
  const _AvatarCreatorDialog();

  @override
  State<_AvatarCreatorDialog> createState() => _AvatarCreatorDialogState();
}

class _AvatarCreatorDialogState extends State<_AvatarCreatorDialog> {
  final _previewKey = GlobalKey();
  final _promptController = TextEditingController();
  AvatarCustomization _avatar =
      AvatarCustomization.defaults(AvatarStyle.friendlySchool);
  bool _isExporting = false;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _saveLocal() async {
    setState(() => _isExporting = true);
    try {
      final boundary = _previewKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      final image = await boundary?.toImage(pixelRatio: 3);
      final bytes = await image
          ?.toByteData(format: ui.ImageByteFormat.png)
          .then((value) => value?.buffer.asUint8List());
      if (!mounted) return;
      if (bytes == null || bytes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de préparer cet avatar.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      Navigator.pop(
        context,
        AvatarCreationResult.local(bytes: bytes, customization: _avatar),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _generateAi() {
    Navigator.pop(
      context,
      AvatarCreationResult.ai(
        customization: _avatar,
        prompt: _promptController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor =
        isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary;
    final subColor =
        isDark ? AppColors.darkBodySecondary : AppColors.lightBodySecondary;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.72,
      maxChildSize: 0.96,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: subColor.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Créer un avatar',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Choisissez un style puis personnalisez votre image de profil.',
                style: AppTextStyles.bodyMedium.copyWith(color: subColor),
              ),
              const SizedBox(height: 18),
              Center(
                child: RepaintBoundary(
                  key: _previewKey,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: avatarBackgroundColors[_avatar.backgroundColor],
                    ),
                    child: AvatarPreview(customization: _avatar, size: 190),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _StyleSelector(
                selected: _avatar.style,
                onSelected: (style) {
                  setState(() {
                    _avatar = AvatarCustomization.defaults(style)
                        .copyWith(style: style);
                  });
                },
              ),
              const SizedBox(height: 18),
              _SwatchControl(
                label: 'Teint',
                colors: avatarSkinTones,
                selected: _avatar.skinTone,
                onSelected: (value) => setState(
                  () => _avatar = _avatar.copyWith(skinTone: value),
                ),
              ),
              _SwatchControl(
                label: 'Cheveux',
                colors: avatarHairColors,
                selected: _avatar.hairColor,
                onSelected: (value) => setState(
                  () => _avatar = _avatar.copyWith(hairColor: value),
                ),
              ),
              _SwatchControl(
                label: 'Tenue',
                colors: avatarOutfitColors,
                selected: _avatar.outfitColor,
                onSelected: (value) => setState(
                  () => _avatar = _avatar.copyWith(outfitColor: value),
                ),
              ),
              _SwatchControl(
                label: 'Fond',
                colors: avatarBackgroundColors,
                selected: _avatar.backgroundColor,
                onSelected: (value) => setState(
                  () => _avatar = _avatar.copyWith(backgroundColor: value),
                ),
              ),
              _OptionGrid(
                items: [
                  _OptionItem(
                    label: 'Visage',
                    icon: Icons.face_rounded,
                    value: _avatar.faceShape,
                    max: 2,
                    onChanged: (value) => setState(
                      () => _avatar = _avatar.copyWith(faceShape: value),
                    ),
                  ),
                  _OptionItem(
                    label: 'Coiffure',
                    icon: Icons.content_cut_rounded,
                    value: _avatar.hairStyle,
                    max: 3,
                    onChanged: (value) => setState(
                      () => _avatar = _avatar.copyWith(hairStyle: value),
                    ),
                  ),
                  _OptionItem(
                    label: 'Yeux',
                    icon: Icons.visibility_outlined,
                    value: _avatar.eyeStyle,
                    max: 2,
                    onChanged: (value) => setState(
                      () => _avatar = _avatar.copyWith(eyeStyle: value),
                    ),
                  ),
                  _OptionItem(
                    label: 'Sourcils',
                    icon: Icons.remove_red_eye_outlined,
                    value: _avatar.eyebrowStyle,
                    max: 1,
                    onChanged: (value) => setState(
                      () => _avatar = _avatar.copyWith(eyebrowStyle: value),
                    ),
                  ),
                  _OptionItem(
                    label: 'Sourire',
                    icon: Icons.sentiment_satisfied_alt_rounded,
                    value: _avatar.mouthStyle,
                    max: 2,
                    onChanged: (value) => setState(
                      () => _avatar = _avatar.copyWith(mouthStyle: value),
                    ),
                  ),
                  _OptionItem(
                    label: 'Tenue',
                    icon: Icons.school_outlined,
                    value: _avatar.outfitStyle,
                    max: 2,
                    onChanged: (value) => setState(
                      () => _avatar = _avatar.copyWith(outfitStyle: value),
                    ),
                  ),
                  _OptionItem(
                    label: 'Fond',
                    icon: Icons.wallpaper_rounded,
                    value: _avatar.backgroundStyle,
                    max: 2,
                    onChanged: (value) => setState(
                      () => _avatar = _avatar.copyWith(backgroundStyle: value),
                    ),
                  ),
                  _OptionItem(
                    label: 'Chapeau',
                    icon: Icons.workspace_premium_outlined,
                    value: _avatar.headwearStyle,
                    max: 2,
                    onChanged: (value) => setState(
                      () => _avatar = _avatar.copyWith(headwearStyle: value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _FeatureChip(
                    label: 'Lunettes',
                    icon: Icons.remove_red_eye_rounded,
                    selected: _avatar.hasGlasses,
                    onTap: () => setState(
                      () => _avatar =
                          _avatar.copyWith(hasGlasses: !_avatar.hasGlasses),
                    ),
                  ),
                  _FeatureChip(
                    label: 'Taches de rousseur',
                    icon: Icons.auto_awesome_rounded,
                    selected: _avatar.hasFreckles,
                    onTap: () => setState(
                      () => _avatar =
                          _avatar.copyWith(hasFreckles: !_avatar.hasFreckles),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _promptController,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Détail IA optionnel',
                  hintText: 'ex: lunettes bleues, style très doux',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 18),
              AppButton(
                text: 'Enregistrer cet avatar',
                isLoading: _isExporting,
                onPressed: _saveLocal,
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _generateAi,
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text('Générer une version IA'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StyleSelector extends StatelessWidget {
  const _StyleSelector({
    required this.selected,
    required this.onSelected,
  });

  final AvatarStyle selected;
  final ValueChanged<AvatarStyle> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final style in AvatarStyle.values) ...[
          Expanded(
            child: _StyleCard(
              style: style,
              isSelected: selected == style,
              onTap: () => onSelected(style),
            ),
          ),
          if (style != AvatarStyle.values.last) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _StyleCard extends StatelessWidget {
  const _StyleCard({
    required this.style,
    required this.isSelected,
    required this.onTap,
  });

  final AvatarStyle style;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.darkDivider : AppColors.lightDivider);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Column(
          children: [
            AvatarPreview(
              customization: AvatarCustomization.defaults(style),
              size: 58,
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                style.label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected ? AppColors.primary : null,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwatchControl extends StatelessWidget {
  const _SwatchControl({
    required this.label,
    required this.colors,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final List<Color> colors;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 9,
              runSpacing: 9,
              children: [
                for (var i = 0; i < colors.length; i++)
                  _ColorSwatch(
                    color: colors[i],
                    isSelected: i == selected,
                    onTap: () => onSelected(i),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionGrid extends StatelessWidget {
  const _OptionGrid({required this.items});

  final List<_OptionItem> items;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 2.65,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items,
    );
  }
}

class _OptionItem extends StatelessWidget {
  const _OptionItem({
    required this.label,
    required this.icon,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final nextLabel = '${value + 1}/${max + 1}';
    return OutlinedButton.icon(
      onPressed: () => onChanged(value >= max ? 0 : value + 1),
      icon: Icon(icon, size: 18),
      label: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text('$label $nextLabel'),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      avatar: Icon(
        icon,
        size: 18,
        color: selected ? AppColors.onPrimary : AppColors.primary,
      ),
      label: Text(label),
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      checkmarkColor: AppColors.onPrimary,
      labelStyle: TextStyle(
        color: selected ? AppColors.onPrimary : null,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
