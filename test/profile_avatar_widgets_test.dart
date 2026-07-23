import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:education_fr_app/features/auth/domain/entities/user.dart';
import 'package:education_fr_app/features/profile/presentation/widgets/avatar_creator_dialog.dart';
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
