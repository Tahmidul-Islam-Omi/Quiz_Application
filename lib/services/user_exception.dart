/// Thrown when reading or writing the stored user profile fails.
/// Carries a user-friendly [message] for the UI to display.
class UserException implements Exception {
  final String message;

  const UserException(this.message);

  @override
  String toString() => message;
}
