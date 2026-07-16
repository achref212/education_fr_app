import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(
      [super.message = 'Une erreur serveur est survenue.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure(
      [super.message = 'Vérifiez votre connexion réseau.']);
}

class AuthFailure extends Failure {
  const AuthFailure(
      [super.message = 'Session expirée. Reconnectez-vous.']);
}

class CacheFailure extends Failure {
  const CacheFailure(
      [super.message = 'Erreur lors de la lecture du cache.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Données invalides.']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Ressource introuvable.']);
}
