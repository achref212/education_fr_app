import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/lesson.dart';

part 'lesson_model.g.dart';

@JsonSerializable()
class LessonModel {
  const LessonModel({
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

  factory LessonModel.fromJson(Map<String, dynamic> json) =>
      _$LessonModelFromJson(json);

  Map<String, dynamic> toJson() => _$LessonModelToJson(this);

  Lesson toDomain() => Lesson(
        id: id,
        title: title,
        content: content,
        category: category,
        level: level,
        sortOrder: sortOrder,
        createdAt: createdAt,
      );
}
