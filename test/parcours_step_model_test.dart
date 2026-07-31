import 'package:education_fr_app/features/parcours/data/models/parcours_step_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses saved parcours quiz answers for review', () {
    final step = ParcoursStepModel.fromJson(const {
      'id': 'step-1',
      'stepOrder': 2,
      'stepType': 'quiz',
      'title': 'Quiz grammaire',
      'xpReward': 20,
      'status': 'completed',
      'score': 50,
      'attempts': 1,
      'answers': [
        {'questionId': 'question-1', 'selectedIndex': 2},
      ],
    }).toDomain();

    expect(step.answers, hasLength(1));
    expect(step.answers.first.questionId, 'question-1');
    expect(step.answers.first.selectedIndex, 2);
  });
}
