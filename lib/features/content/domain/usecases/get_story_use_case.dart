import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/story.dart';
import '../repositories/content_repository.dart';

class GetStoryParams extends Equatable {
  const GetStoryParams({required this.storyId});

  final String storyId;

  @override
  List<Object?> get props => [storyId];
}

class GetStoryUseCase implements UseCase<Story, GetStoryParams> {
  GetStoryUseCase(this._repository);

  final ContentRepository _repository;

  @override
  Future<Either<Failure, Story>> call(GetStoryParams params) =>
      _repository.getStory(params.storyId);
}
