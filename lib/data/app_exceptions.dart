// lib/data/app_exceptions.dart

class AppExceptions implements Exception {
  final String? _message;
  final String? _prefix;

  AppExceptions([this._message, this._prefix]);

  // Clean message - HTML tags aur prefix remove karke
  String get cleanMessage {
    final raw = (_message ?? 'Something went wrong')
        .replaceAll(RegExp(r"<[^>]*>"), "")
        .trim();
    return raw;
  }

  @override
  String toString() => "$_prefix$_message";
}

class InternetExceptions extends AppExceptions {
  InternetExceptions([String? message])
      : super(message ?? 'Please check your internet connection', 'No Internet: ');
}

class RequestTimeOut extends AppExceptions {
  RequestTimeOut([String? message])
      : super(message ?? 'Request timed out. Try again.', 'Timeout: ');
}

class FetchDataException extends AppExceptions {
  FetchDataException([String? message])
      : super(message ?? 'Failed to fetch data', 'Fetch Error: ');
}

class BadRequestException extends AppExceptions {
  BadRequestException([String? message])
      : super(message ?? 'Invalid request', 'Bad Request: ');
}

class UnauthorizedException extends AppExceptions {
  UnauthorizedException([String? message])
      : super(message ?? 'Session expired. Please login again.', 'Unauthorized: ');
}

class ServerException extends AppExceptions {
  ServerException([String? message])
      : super(message ?? 'Server error. Try again later.', 'Server Error: ');
}