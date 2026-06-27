/// Thrown when authentication fails.
/// Carries a user-friendly [message] for the UI to display.
class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}
