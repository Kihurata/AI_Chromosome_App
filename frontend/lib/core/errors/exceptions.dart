abstract class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() {
    return message;
  }
}

class ServerException extends AppException {
  const ServerException({String message = 'AN error occured on the server.'})
    : super(message);
}

class NetworkException extends AppException {
  const NetworkException({String message = 'No internet connection.'})
    : super(message);
}

class CacheException extends AppException {
  const CacheException({String message = 'Failed to load local data.'})
    : super(message);
}
