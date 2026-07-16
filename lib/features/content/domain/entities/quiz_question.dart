import 'package:equatable/equatable.dart';

class QuizQuestion extends Equatable {
  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.category,
    required this.level,
    this.explanation,
  });

  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;
  final String category;
  final String level;

  @override
  List<Object?> get props => [
        id,
        question,
        options,
        correctIndex,
        explanation,
        category,
        level,
      ];
}
