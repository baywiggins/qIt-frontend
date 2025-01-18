class TokenExpiredException implements Exception {
  final String message;

  TokenExpiredException(
      [this.message = "User token has expired and refresh token is invalid"]);

  @override
  String toString() => message;
}
