import 'package:education_fr_app/features/parcours/domain/entities/step_complete_result.dart';
import 'package:education_fr_app/features/parcours/presentation/widgets/step_complete_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows next-step action when a next step is available',
      (tester) async {
    var openedNext = false;
    var returnedToParcours = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StepCompleteSheet(
            result: const StepCompleteResult(
              stepId: 'step-1',
              score: 100,
              xpEarned: 20,
              passed: true,
              nextStepId: 'step-2',
              parcoursPercent: 50,
            ),
            onNextStep: () => openedNext = true,
            onContinue: () => returnedToParcours = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ouvrir l’étape suivante'), findsOneWidget);
    expect(find.text('Revenir au parcours'), findsOneWidget);

    await tester.tap(find.text('Ouvrir l’étape suivante'));
    await tester.pumpAndSettle();
    expect(openedNext, isTrue);
    expect(returnedToParcours, isFalse);
  });

  testWidgets('uses parcours action when there is no next step',
      (tester) async {
    var returnedToParcours = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StepCompleteSheet(
            result: const StepCompleteResult(
              stepId: 'step-1',
              score: 100,
              xpEarned: 20,
              passed: true,
              parcoursPercent: 100,
            ),
            onNextStep: null,
            onContinue: () => returnedToParcours = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Terminer et voir mon parcours'), findsOneWidget);
    expect(find.text('Revenir au parcours'), findsNothing);

    await tester.tap(find.text('Terminer et voir mon parcours'));
    await tester.pumpAndSettle();
    expect(returnedToParcours, isTrue);
  });

  testWidgets('shows quiz result and answer review', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StepCompleteSheet(
            result: const StepCompleteResult(
              stepId: 'quiz-1',
              score: 50,
              xpEarned: 10,
              passed: true,
              nextStepId: 'lesson-2',
              parcoursPercent: 40,
            ),
            quizResult: const QuizResultSummary(
              correctCount: 1,
              totalCount: 2,
              answers: [
                QuizAnswerReview(
                  question: 'Comment dit-on hello ?',
                  selectedAnswer: 'Bonjour',
                  correctAnswer: 'Bonjour',
                  isCorrect: true,
                  explanation: 'Bonjour est la salutation correcte.',
                ),
                QuizAnswerReview(
                  question: 'Comment dit-on goodbye ?',
                  selectedAnswer: 'Merci',
                  correctAnswer: 'Au revoir',
                  isCorrect: false,
                  explanation: 'Au revoir sert à quitter quelqu’un.',
                ),
              ],
            ),
            onNextStep: () {},
            onContinue: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Résultat du quiz'), findsOneWidget);
    expect(find.text('1/2 réponses justes'), findsOneWidget);
    expect(find.text('Comment dit-on hello ?'), findsOneWidget);
    expect(find.text('Ta réponse : Bonjour'), findsOneWidget);
    expect(find.text('Bonne réponse : Au revoir'), findsOneWidget);
    expect(find.text('Au revoir sert à quitter quelqu’un.'), findsOneWidget);
  });
}
