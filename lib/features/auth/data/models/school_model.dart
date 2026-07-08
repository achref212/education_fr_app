import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/school.dart';

part 'school_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SchoolModel {
  const SchoolModel({
    required this.id,
    required this.name,
    this.city,
  });

  final String id;
  final String name;
  final String? city;

  factory SchoolModel.fromJson(Map<String, dynamic> json) =>
      _$SchoolModelFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolModelToJson(this);

  School toDomain() => School(id: id, name: name, city: city);
}
