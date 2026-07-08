import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entities/school.dart';
import '../../../auth/domain/usecases/get_current_user_use_case.dart';
import '../../../auth/domain/usecases/get_schools_use_case.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required GetSchoolsUseCase getSchoolsUseCase,
  })  : _getCurrentUserUseCase = getCurrentUserUseCase,
        _getSchoolsUseCase = getSchoolsUseCase,
        super(const ProfileState.initial());

  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final GetSchoolsUseCase _getSchoolsUseCase;

  Future<void> loadProfile() async {
    emit(const ProfileState.loading());
    final userResult = await _getCurrentUserUseCase(const NoParams());
    await userResult.fold(
      (failure) async => emit(ProfileState.error(failure.message)),
      (user) async {
        String? schoolName;
        if (user.schoolId != null) {
          final schoolsResult = await _getSchoolsUseCase(const NoParams());
          schoolName = schoolsResult.fold(
            (_) => null,
            (schools) => _resolveSchoolName(schools, user.schoolId!),
          );
        }
        emit(ProfileState.loaded(user: user, schoolName: schoolName));
      },
    );
  }

  String? _resolveSchoolName(List<School> schools, String schoolId) {
    for (final school in schools) {
      if (school.id == schoolId) return school.name;
    }
    return null;
  }
}
