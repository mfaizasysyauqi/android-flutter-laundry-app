class ServerException implements Exception {
  final String? message;

  ServerException({this.message});

  @override
  String toString() => message ?? 'Server error occurred';
}

class CacheException implements Exception {}

class NetworkException implements Exception {}

class WeakPasswordException implements Exception {}

class EmailAlreadyInUseException implements Exception {}

class InvalidCredentialsException implements Exception {}

class EmailNotFoundException implements Exception {}

class WrongPasswordException implements Exception {}

class UserNotFoundException implements Exception {}

class UniqueNameAlreadyInUseException implements Exception {}

class NoInternetException implements Exception {
  final String message;

  NoInternetException({this.message = 'No internet connection'});
}
