import 'package:flutter/material.dart';

class AvatarCustomization {
  const AvatarCustomization({
    required this.style,
    required this.skinTone,
    required this.faceShape,
    required this.hairStyle,
    required this.hairColor,
    required this.eyeStyle,
    required this.eyebrowStyle,
    required this.mouthStyle,
    required this.outfitStyle,
    required this.outfitColor,
    required this.backgroundStyle,
    required this.backgroundColor,
    required this.hasGlasses,
    required this.hasFreckles,
    required this.headwearStyle,
  });

  factory AvatarCustomization.defaults(AvatarStyle style) {
    return AvatarCustomization(
      style: style,
      skinTone: style == AvatarStyle.realistic ? 1 : 2,
      faceShape: style == AvatarStyle.cartoon ? 2 : 0,
      hairStyle: style == AvatarStyle.realistic ? 3 : 1,
      hairColor: style == AvatarStyle.cartoon ? 5 : 0,
      eyeStyle: style == AvatarStyle.cartoon ? 2 : 0,
      eyebrowStyle: 0,
      mouthStyle: style == AvatarStyle.cartoon ? 2 : 1,
      outfitStyle: style == AvatarStyle.friendlySchool ? 1 : 0,
      outfitColor: style == AvatarStyle.realistic ? 3 : 0,
      backgroundStyle: style == AvatarStyle.cartoon ? 2 : 0,
      backgroundColor: style == AvatarStyle.realistic ? 4 : 0,
      hasGlasses: false,
      hasFreckles: style == AvatarStyle.cartoon,
      headwearStyle: 0,
    );
  }

  final AvatarStyle style;
  final int skinTone;
  final int faceShape;
  final int hairStyle;
  final int hairColor;
  final int eyeStyle;
  final int eyebrowStyle;
  final int mouthStyle;
  final int outfitStyle;
  final int outfitColor;
  final int backgroundStyle;
  final int backgroundColor;
  final bool hasGlasses;
  final bool hasFreckles;
  final int headwearStyle;

  AvatarCustomization copyWith({
    AvatarStyle? style,
    int? skinTone,
    int? faceShape,
    int? hairStyle,
    int? hairColor,
    int? eyeStyle,
    int? eyebrowStyle,
    int? mouthStyle,
    int? outfitStyle,
    int? outfitColor,
    int? backgroundStyle,
    int? backgroundColor,
    bool? hasGlasses,
    bool? hasFreckles,
    int? headwearStyle,
  }) {
    return AvatarCustomization(
      style: style ?? this.style,
      skinTone: skinTone ?? this.skinTone,
      faceShape: faceShape ?? this.faceShape,
      hairStyle: hairStyle ?? this.hairStyle,
      hairColor: hairColor ?? this.hairColor,
      eyeStyle: eyeStyle ?? this.eyeStyle,
      eyebrowStyle: eyebrowStyle ?? this.eyebrowStyle,
      mouthStyle: mouthStyle ?? this.mouthStyle,
      outfitStyle: outfitStyle ?? this.outfitStyle,
      outfitColor: outfitColor ?? this.outfitColor,
      backgroundStyle: backgroundStyle ?? this.backgroundStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      hasGlasses: hasGlasses ?? this.hasGlasses,
      hasFreckles: hasFreckles ?? this.hasFreckles,
      headwearStyle: headwearStyle ?? this.headwearStyle,
    );
  }

  Map<String, dynamic> toPromptMap() => {
        'style': style.apiValue,
        'skinTone': skinTone,
        'faceShape': faceShape,
        'hairStyle': hairStyle,
        'hairColor': hairColor,
        'eyeStyle': eyeStyle,
        'eyebrowStyle': eyebrowStyle,
        'mouthStyle': mouthStyle,
        'outfitStyle': outfitStyle,
        'outfitColor': outfitColor,
        'backgroundStyle': backgroundStyle,
        'backgroundColor': backgroundColor,
        'glasses': hasGlasses,
        'freckles': hasFreckles,
        'headwearStyle': headwearStyle,
      };
}

enum AvatarStyle { friendlySchool, realistic, cartoon }

extension AvatarStyleLabel on AvatarStyle {
  String get label => switch (this) {
        AvatarStyle.friendlySchool => 'École',
        AvatarStyle.realistic => 'Portrait',
        AvatarStyle.cartoon => 'Cartoon',
      };

  String get apiValue => switch (this) {
        AvatarStyle.friendlySchool => 'friendly_school',
        AvatarStyle.realistic => 'realistic',
        AvatarStyle.cartoon => 'cartoon',
      };
}

const avatarSkinTones = [
  Color(0xFFFFD7B5),
  Color(0xFFEAB184),
  Color(0xFFC97C52),
  Color(0xFF9B5A3C),
  Color(0xFF70402E),
];

const avatarHairColors = [
  Color(0xFF2A211C),
  Color(0xFF6B3F25),
  Color(0xFFC77934),
  Color(0xFFF1C45B),
  Color(0xFF5C6675),
  Color(0xFF7C5CFF),
];

const avatarOutfitColors = [
  Color(0xFF007AFF),
  Color(0xFFFF4D8D),
  Color(0xFF2ED3B7),
  Color(0xFF7C5CFF),
  Color(0xFFFFB800),
  Color(0xFF263238),
];

const avatarBackgroundColors = [
  Color(0xFFE6F2FF),
  Color(0xFFFFF0C6),
  Color(0xFFE9FFF8),
  Color(0xFFFFEAF2),
  Color(0xFFECE7FF),
  Color(0xFFEAF0F6),
];

class AvatarPreview extends StatelessWidget {
  const AvatarPreview({
    super.key,
    required this.customization,
    this.size = 160,
  });

  final AvatarCustomization customization;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _AvatarPainter(customization),
      ),
    );
  }
}

class _AvatarPainter extends CustomPainter {
  const _AvatarPainter(this.avatar);

  final AvatarCustomization avatar;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 256;
    canvas.save();
    canvas.scale(scale);
    _drawBackground(canvas);
    _drawBody(canvas);
    _drawFace(canvas);
    _drawHair(canvas);
    _drawFeatures(canvas);
    _drawAccessories(canvas);
    canvas.restore();
  }

  void _drawBackground(Canvas canvas) {
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          avatarBackgroundColors[avatar.backgroundColor],
          avatarBackgroundColors[
              (avatar.backgroundColor + 2) % avatarBackgroundColors.length],
        ],
      ).createShader(const Rect.fromLTWH(0, 0, 256, 256));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 256, 256),
        const Radius.circular(44),
      ),
      bgPaint,
    );

    final accent = Paint()
      ..color = Colors.white.withValues(alpha: 0.36)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    if (avatar.backgroundStyle == 1) {
      for (var y = 38.0; y < 240; y += 42) {
        canvas.drawLine(Offset(16, y), Offset(240, y - 36), accent);
      }
    } else if (avatar.backgroundStyle == 2) {
      for (final center in const [
        Offset(44, 58),
        Offset(210, 72),
        Offset(54, 200),
        Offset(208, 198),
      ]) {
        canvas.drawCircle(center, 18, accent);
      }
    } else {
      canvas.drawCircle(const Offset(214, 44), 40, accent);
      canvas.drawCircle(const Offset(38, 218), 52, accent);
    }
  }

  void _drawBody(Canvas canvas) {
    final outfit = avatarOutfitColors[avatar.outfitColor];
    final bodyPaint = Paint()..color = outfit;
    final collarPaint = Paint()..color = Colors.white.withValues(alpha: 0.92);
    final bodyPath = Path()
      ..moveTo(74, 245)
      ..quadraticBezierTo(128, 184, 182, 245)
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);
    if (avatar.outfitStyle == 1) {
      canvas.drawPath(
        Path()
          ..moveTo(104, 196)
          ..lineTo(128, 224)
          ..lineTo(152, 196)
          ..quadraticBezierTo(128, 206, 104, 196),
        collarPaint,
      );
    } else if (avatar.outfitStyle == 2) {
      canvas.drawCircle(const Offset(128, 220), 10, collarPaint);
    }
  }

  void _drawFace(Canvas canvas) {
    final facePaint = Paint()..color = avatarSkinTones[avatar.skinTone];
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final faceRect = switch (avatar.faceShape) {
      1 => const Rect.fromLTWH(70, 64, 116, 132),
      2 => const Rect.fromLTWH(62, 58, 132, 132),
      _ => const Rect.fromLTWH(66, 58, 124, 138),
    };
    final radius = switch (avatar.faceShape) {
      1 => const Radius.circular(54),
      2 => const Radius.circular(66),
      _ => const Radius.circular(62),
    };
    canvas.drawRRect(
      RRect.fromRectAndRadius(faceRect.translate(0, 4), radius),
      shadowPaint,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(faceRect, radius), facePaint);
  }

  void _drawHair(Canvas canvas) {
    final hairPaint = Paint()..color = avatarHairColors[avatar.hairColor];
    if (avatar.hairStyle == 0) {
      canvas.drawArc(
        const Rect.fromLTWH(64, 48, 128, 92),
        3.05,
        3.18,
        true,
        hairPaint,
      );
    } else if (avatar.hairStyle == 1) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(58, 48, 140, 72),
          const Radius.circular(42),
        ),
        hairPaint,
      );
      canvas.drawCircle(const Offset(92, 78), 30, hairPaint);
      canvas.drawCircle(const Offset(154, 74), 34, hairPaint);
    } else if (avatar.hairStyle == 2) {
      for (var x = 72.0; x <= 176; x += 18) {
        canvas.drawCircle(Offset(x, 68 + (x % 3) * 4), 20, hairPaint);
      }
    } else {
      canvas.drawPath(
        Path()
          ..moveTo(66, 104)
          ..quadraticBezierTo(86, 36, 132, 46)
          ..quadraticBezierTo(184, 38, 194, 112)
          ..quadraticBezierTo(162, 90, 126, 84)
          ..quadraticBezierTo(94, 92, 66, 104),
        hairPaint,
      );
    }
  }

  void _drawFeatures(Canvas canvas) {
    final dark = Paint()..color = const Color(0xFF17202A);
    final blush = Paint()
      ..color = const Color(0xFFFF7FA1).withValues(alpha: 0.22);
    canvas.drawOval(const Rect.fromLTWH(78, 130, 24, 12), blush);
    canvas.drawOval(const Rect.fromLTWH(154, 130, 24, 12), blush);

    if (avatar.eyeStyle == 1) {
      canvas.drawArc(
          const Rect.fromLTWH(84, 112, 24, 18),
          3.3,
          2.5,
          false,
          dark
            ..strokeWidth = 4
            ..style = PaintingStyle.stroke);
      canvas.drawArc(
          const Rect.fromLTWH(148, 112, 24, 18), 3.3, 2.5, false, dark);
      dark.style = PaintingStyle.fill;
    } else if (avatar.eyeStyle == 2) {
      canvas.drawCircle(const Offset(94, 120), 9, dark);
      canvas.drawCircle(const Offset(162, 120), 9, dark);
      canvas.drawCircle(
          const Offset(98, 116), 3, Paint()..color = Colors.white);
      canvas.drawCircle(
          const Offset(166, 116), 3, Paint()..color = Colors.white);
    } else {
      canvas.drawCircle(const Offset(94, 120), 6, dark);
      canvas.drawCircle(const Offset(162, 120), 6, dark);
    }

    final brow = Paint()
      ..color = const Color(0xFF17202A)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    final browLift = avatar.eyebrowStyle == 1 ? -5.0 : 0.0;
    canvas.drawLine(Offset(82, 102 + browLift), const Offset(106, 100), brow);
    canvas.drawLine(const Offset(150, 100), Offset(174, 102 + browLift), brow);

    final mouth = Paint()
      ..color = const Color(0xFF9C3D47)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    if (avatar.mouthStyle == 0) {
      canvas.drawLine(const Offset(114, 154), const Offset(142, 154), mouth);
    } else if (avatar.mouthStyle == 2) {
      canvas.drawArc(
          const Rect.fromLTWH(108, 142, 40, 30), 0.1, 3.0, false, mouth);
    } else {
      canvas.drawArc(
          const Rect.fromLTWH(108, 142, 40, 24), 0.2, 2.75, false, mouth);
    }

    if (avatar.hasFreckles) {
      final freckle = Paint()
        ..color = const Color(0xFF9A5C3C).withValues(alpha: 0.42);
      for (final point in const [
        Offset(86, 138),
        Offset(98, 142),
        Offset(158, 142),
        Offset(170, 138),
      ]) {
        canvas.drawCircle(point, 2.4, freckle);
      }
    }
  }

  void _drawAccessories(Canvas canvas) {
    if (avatar.hasGlasses) {
      final glasses = Paint()
        ..color = const Color(0xFF17202A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(74, 108, 38, 28),
          const Radius.circular(12),
        ),
        glasses,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(144, 108, 38, 28),
          const Radius.circular(12),
        ),
        glasses,
      );
      canvas.drawLine(const Offset(112, 121), const Offset(144, 121), glasses);
    }
    if (avatar.headwearStyle == 1) {
      final hatPaint = Paint()..color = avatarOutfitColors[avatar.outfitColor];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(72, 42, 112, 32),
          const Radius.circular(16),
        ),
        hatPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(58, 68, 140, 14),
          const Radius.circular(8),
        ),
        hatPaint,
      );
    } else if (avatar.headwearStyle == 2) {
      final band = Paint()..color = avatarOutfitColors[avatar.outfitColor];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(70, 60, 116, 16),
          const Radius.circular(8),
        ),
        band,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AvatarPainter oldDelegate) {
    return oldDelegate.avatar != avatar;
  }
}
