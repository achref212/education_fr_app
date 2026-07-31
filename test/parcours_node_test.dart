import 'package:education_fr_app/features/parcours/domain/entities/parcours_step.dart';
import 'package:education_fr_app/features/parcours/presentation/widgets/parcours_node.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('completed step stays tappable for review', (tester) async {
    var opened = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ParcoursNode(
            step: const ParcoursStep(
              id: 'step-1',
              stepOrder: 1,
              stepType: 'quiz',
              title: 'Quiz grammaire',
              xpReward: 20,
              status: 'completed',
              score: 80,
            ),
            isLast: true,
            onTap: () => opened = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Terminé • 80% • +20 XP'), findsOneWidget);
    expect(find.byIcon(Icons.visibility_rounded), findsOneWidget);

    await tester.tap(find.text('Quiz grammaire'));
    await tester.pumpAndSettle();

    expect(opened, isTrue);
  });

  testWidgets('locked step stays blocked', (tester) async {
    var opened = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ParcoursNode(
            step: const ParcoursStep(
              id: 'step-2',
              stepOrder: 2,
              stepType: 'lesson',
              title: 'Leçon suivante',
              xpReward: 15,
              status: 'locked',
            ),
            isLast: true,
            onTap: () => opened = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Verrouillé'), findsOneWidget);

    await tester.tap(find.text('Leçon suivante'));
    await tester.pumpAndSettle();

    expect(opened, isFalse);
  });
}
