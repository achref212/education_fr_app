import '../../domain/entities/profile_image_asset.dart';

class ProfileImageAssetModel {
  const ProfileImageAssetModel({
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

  factory ProfileImageAssetModel.fromJson(Map<String, dynamic> json) {
    return ProfileImageAssetModel(
      id: json['id'] as String,
      url: json['url'] as String,
      title: json['title'] as String?,
      mimeType: json['mimeType'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    );
  }

  ProfileImageAsset toDomain() {
    return ProfileImageAsset(
      id: id,
      url: url,
      title: title,
      mimeType: mimeType,
      createdAt: createdAt,
    );
  }
}
