/// Thrown when a bdapps subscription request fails.
/// Carries a user-friendly [message] for the UI to display.
class BdappsException implements Exception {
  final String message;

  const BdappsException(this.message);

  @override
  String toString() => message;
}
