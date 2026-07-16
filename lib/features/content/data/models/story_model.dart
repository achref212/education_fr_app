import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/story.dart';

part 'story_model.g.dart';

@JsonSerializable()
class StoryModel {
  const StoryModel({
    required this.id,
    required this.title,
    required this.content,
    required this.level,
    required this.createdAt,
    this.audioUrl,
  });

  final String id;
  final String title;
  final String content;
  final String level;
  final String? audioUrl;
  final DateTime createdAt;

  factory StoryModel.fromJson(Map<String, dynamic> json) =>
      _$StoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$StoryModelToJson(this);

  Story toDomain() => Story(
        id: id,
        title: title,
        content: content,
        level: level,
        audioUrl: audioUrl,
        createdAt: createdAt,
      );
}
