import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:education_fr_app/features/auth/domain/entities/user.dart';
import 'package:education_fr_app/features/profile/presentation/widgets/avatar_creator_dialog.dart';
import 'package:education_fr_app/features/profile/presentation/widgets/profile_image_adjust_dialog.dart';
import 'package:education_fr_app/features/profile/presentation/widgets/profile_picture_actions.dart';

void main() {
  testWidgets('profile picture action sheet shows all sources', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showProfilePictureActions(
              context: context,
              user: _user(),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Importer une image'), findsOneWidget);
    expect(find.text('Prendre une photo'), findsOneWidget);
    expect(find.text('Photos déjà utilisées'), findsOneWidget);
    expect(find.text('Créer un avatar'), findsOneWidget);
  });

  testWidgets('avatar creator shows style examples and updates controls',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showAvatarCreatorDialog(context),
            child: const Text('avatar'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('avatar'));
    await tester.pumpAndSettle();

    expect(find.text('École'), findsOneWidget);
    expect(find.text('Portrait'), findsOneWidget);
    expect(find.text('Cartoon'), findsOneWidget);
    expect(find.text('Neutre'), findsOneWidget);
    expect(find.text('Fille'), findsOneWidget);
    expect(find.text('Garçon'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Coiffure 2/4'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Coiffure 2/4'), findsOneWidget);
    await tester.tap(find.text('Coiffure 2/4'));
    await tester.pumpAndSettle();
    expect(find.text('Coiffure 3/4'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Enregistrer cet avatar'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Enregistrer cet avatar'), findsOneWidget);
    expect(find.text('Générer une version IA'), findsOneWidget);
    expect(find.text('Selfie IA'), findsOneWidget);
  });

  testWidgets('profile image adjust dialog exposes framing controls',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showProfileImageAdjustDialog(
              context: context,
              bytes: Uint8List.fromList(_pngBytes),
            ),
            child: const Text('adjust'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('adjust'));
    await tester.pumpAndSettle();

    expect(find.text('Ajuster l\'image'), findsOneWidget);
    expect(find.byIcon(Icons.restart_alt_rounded), findsOneWidget);
    expect(find.byIcon(Icons.rotate_90_degrees_cw_rounded), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.text('Annuler'), findsOneWidget);
    expect(find.text('Enregistrer'), findsOneWidget);
  });
}

User _user() {
  return User(
    id: 'student-1',
    email: 'student@example.com',
    firstName: 'Sana',
    lastName: 'Student',
    level: 'A1',
    createdAt: DateTime(2026),
    role: 'user',
  );
}

const _pngBytes = <int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
];
