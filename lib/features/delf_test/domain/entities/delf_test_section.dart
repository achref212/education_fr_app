import 'package:equatable/equatable.dart';

import 'delf_test_question.dart';

class DelfTestSection extends Equatable {
  const DelfTestSection({
    required this.category,
    required this.questions,
    this.submitted = false,
    this.score,
  });

  final String category;
  final List<DelfTestQuestion> questions;
  final bool submitted;
  final int? score;

  @override
  List<Object?> get props => [category, questions, submitted, score];
}
