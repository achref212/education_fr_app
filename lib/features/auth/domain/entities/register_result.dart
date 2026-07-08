import 'package:equatable/equatable.dart';

class RegisterResult extends Equatable {
  const RegisterResult({
    required this.email,
    required this.registrationStateToken,
    required this.message,
  });

  final String email;
  final String registrationStateToken;
  final String message;

  @override
  List<Object?> get props => [email, registrationStateToken, message];
}
