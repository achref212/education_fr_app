import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// Base contract for every use case in the application.
///
/// [T] — the success return type.
/// [P] — the input parameters object.
abstract class UseCase<T, P> {
  Future<Either<Failure, T>> call(P params);
}

/// Placeholder for use cases that require no input parameters.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
