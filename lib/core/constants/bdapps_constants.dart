/// Endpoints for the bdapps subscription backend.
///
/// These point at our own PHP scripts, which forward the requests to bdapps
/// using the application credentials stored on the server.
class BdappsConstants {
  BdappsConstants._();

  static const String baseUrl = 'https://bdappsdigitalapps.com/NADB26126';

  /// POST `user_mobile` — returns whether the number is currently subscribed.
  static const String checkSubscription = '$baseUrl/check_subscription.php';

  /// POST `user_mobile` — sends an OTP by SMS and returns a reference number.
  static const String sendOtp = '$baseUrl/send_otp.php';

  /// POST `Otp` and `referenceNo` — confirms the OTP and starts the subscription.
  static const String verifyOtp = '$baseUrl/verify_otp.php';

  /// POST `user_mobile` — cancels the subscription for that number.
  static const String unsubscribe = '$baseUrl/unsubscribe.php';

  /// bdapps returns this code when a request succeeds.
  static const String successCode = 'S1000';
}
