// Base Failure class
abstract class Failure {
  final String message;

  Failure({required this.message});
}

class ServerFailure extends Failure {
  ServerFailure({String? message})
      : super(message: message ?? 'Server error occurred');
}

class NetworkFailure extends Failure {
  NetworkFailure({String? message})
      : super(message: message ?? 'No internet connection');
}

class WeakPasswordFailure extends Failure {
  WeakPasswordFailure({String? message})
      : super(message: message ?? 'Password is too weak');
}

class UserNotFoundFailure extends Failure {
  UserNotFoundFailure({String? message})
      : super(message: message ?? 'User not found');
}

class EmailAlreadyInUseFailure extends Failure {
  EmailAlreadyInUseFailure({String? message})
      : super(message: message ?? 'Email already in use');
}

class InvalidCredentialsFailure extends Failure {
  InvalidCredentialsFailure({String? message})
      : super(message: message ?? 'Invalid email or password');
}

class OrderFailure extends Failure {
  OrderFailure({required super.message});
}

class UniqueNameAlreadyInUseFailure extends Failure {
  UniqueNameAlreadyInUseFailure({String? message})
      : super(message: message ?? 'This unique name is already taken');
}

class EmailNotFoundFailure extends Failure {
  EmailNotFoundFailure({String? message})
      : super(message: message ?? 'User not found');
}

class WrongPasswordFailure extends Failure {
  WrongPasswordFailure({String? message})
      : super(message: message ?? 'Password is incorrect');
}

class NoInternetFailure extends Failure {
  NoInternetFailure() : super(message: 'No internet connection');
}
