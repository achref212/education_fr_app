import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

Future<Uint8List?> showProfileImageAdjustDialog({
  required BuildContext context,
  required Uint8List bytes,
}) {
  return showModalBottomSheet<Uint8List>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ProfileImageAdjustDialog(bytes: bytes),
  );
}

class _ProfileImageAdjustDialog extends StatefulWidget {
  const _ProfileImageAdjustDialog({required this.bytes});

  final Uint8List bytes;

  @override
  State<_ProfileImageAdjustDialog> createState() =>
      _ProfileImageAdjustDialogState();
}

class _ProfileImageAdjustDialogState extends State<_ProfileImageAdjustDialog> {
  final _boundaryKey = GlobalKey();
  final _transformController = TransformationController();
  double _zoom = 1.0;
  int _quarterTurns = 0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _transformController.addListener(_syncZoomFromGesture);
  }

  @override
  void dispose() {
    _transformController.removeListener(_syncZoomFromGesture);
    _transformController.dispose();
    super.dispose();
  }

  void _syncZoomFromGesture() {
    final scale = _transformController.value.getMaxScaleOnAxis();
    if ((scale - _zoom).abs() < 0.03) return;
    setState(() => _zoom = scale.clamp(1.0, 3.0));
  }

  void _setZoom(double value) {
    setState(() => _zoom = value);
    _transformController.value = Matrix4.diagonal3Values(value, value, 1);
  }

  void _rotate() {
    setState(() => _quarterTurns = (_quarterTurns + 1) % 4);
    _setZoom(1);
  }

  void _reset() {
    setState(() {
      _quarterTurns = 0;
      _zoom = 1;
    });
    _transformController.value = Matrix4.identity();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final boundary = _boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      final image = await boundary?.toImage(pixelRatio: 2);
      final data = await image?.toByteData(format: ui.ImageByteFormat.png);
      final bytes = data?.buffer.asUint8List();
      if (!mounted) return;
      if (bytes == null || bytes.isEmpty) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(
            content: Text('Impossible de préparer cette image.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      Navigator.pop(context, bytes);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor =
        isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary;
    final subColor =
        isDark ? AppColors.darkBodySecondary : AppColors.lightBodySecondary;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: subColor.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ajuster l\'image',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Réinitialiser',
                onPressed: _reset,
                icon: const Icon(Icons.restart_alt_rounded),
              ),
              IconButton(
                tooltip: 'Tourner',
                onPressed: _rotate,
                icon: const Icon(Icons.rotate_90_degrees_cw_rounded),
              ),
            ],
          ),
          const SizedBox(height: 18),
          RepaintBoundary(
            key: _boundaryKey,
            child: SizedBox.square(
              dimension: 280,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.lightSurfacePrimary,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: InteractiveViewer(
                    transformationController: _transformController,
                    minScale: 1,
                    maxScale: 3,
                    boundaryMargin: const EdgeInsets.all(90),
                    child: RotatedBox(
                      quarterTurns: _quarterTurns,
                      child: Image.memory(
                        widget.bytes,
                        width: 280,
                        height: 280,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(Icons.zoom_out_rounded),
              Expanded(
                child: Slider(
                  value: _zoom,
                  min: 1,
                  max: 3,
                  divisions: 20,
                  label: 'Zoom ${_zoom.toStringAsFixed(1)}x',
                  onChanged: _setZoom,
                ),
              ),
              const Icon(Icons.zoom_in_rounded),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving ? null : () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_rounded),
                  label: const Text('Enregistrer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
