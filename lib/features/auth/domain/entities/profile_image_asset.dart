import 'package:equatable/equatable.dart';

class ProfileImageAsset extends Equatable {
  const ProfileImageAsset({
    required this.id,
    required this.url,
    this.title,
    this.mimeType,
    this.createdAt,
  });

  final String id;
  final String url;
  final String? title;
  final String? mimeType;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, url, title, mimeType, createdAt];
}
