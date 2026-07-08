import 'package:equatable/equatable.dart';

class School extends Equatable {
  const School({
    required this.id,
    required this.name,
    this.city,
  });

  final String id;
  final String name;
  final String? city;

  @override
  List<Object?> get props => [id, name, city];
}
