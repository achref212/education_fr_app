import 'package:equatable/equatable.dart';

class Story extends Equatable {
  const Story({
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

  @override
  List<Object?> get props => [id, title, content, level, audioUrl, createdAt];
}
