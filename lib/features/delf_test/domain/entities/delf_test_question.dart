import 'package:equatable/equatable.dart';

class DelfTestQuestion extends Equatable {
  const DelfTestQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.category,
    required this.level,
  });

  final String id;
  final String question;
  final List<String> options;
  final String category;
  final String level;

  @override
  List<Object?> get props => [id, question, options, category, level];
}
