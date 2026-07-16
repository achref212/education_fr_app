import 'package:equatable/equatable.dart';

class Lesson extends Equatable {
  const Lesson({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.level,
    required this.sortOrder,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String content;
  final String category;
  final String level;
  final int sortOrder;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        category,
        level,
        sortOrder,
        createdAt,
      ];
}
