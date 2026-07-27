import 'package:flutter/material.dart';

import '../../../../core/network/media_url.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class CircularProfileAvatar extends StatelessWidget {
  const CircularProfileAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.size = 48,
    this.iconSize,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String? imageUrl;
  final String? initials;
  final double size;
  final double? iconSize;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final resolved = resolveMediaUrl(imageUrl);
    final bg = backgroundColor ?? AppColors.primary.withValues(alpha: 0.14);
    final fg = foregroundColor ?? AppColors.primary;
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: resolved.isNotEmpty
              ? Image.network(
                  resolved,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _AvatarFallback(
                    initials: initials,
                    color: fg,
                    iconSize: iconSize ?? size * 0.46,
                  ),
                )
              : _AvatarFallback(
                  initials: initials,
                  color: fg,
                  iconSize: iconSize ?? size * 0.46,
                ),
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({
    required this.initials,
    required this.color,
    required this.iconSize,
  });

  final String? initials;
  final Color color;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final safeInitials = initials?.trim();
    if (safeInitials != null && safeInitials.isNotEmpty) {
      return Center(
        child: Text(
          safeInitials,
          style: AppTextStyles.titleMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
    }
    return Center(
      child: Icon(
        Icons.person_rounded,
        color: color,
        size: iconSize,
      ),
    );
  }
}
