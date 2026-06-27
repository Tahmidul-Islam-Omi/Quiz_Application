/// Thrown when an API request fails.
/// Carries a user-friendly [message] for the UI to display.
class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}
