import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/constants/bdapps_constants.dart';
import 'bdapps_exception.dart';

/// Handles the bdapps subscription and OTP requests.
///
/// Every endpoint is a PHP script that expects form fields and replies with
/// JSON, so all requests here are form-encoded POSTs.
class BdappsService {
  final http.Client _client;

  BdappsService({http.Client? client}) : _client = client ?? http.Client();

  /// Returns true when [mobile] currently has an active subscription.
  Future<bool> isSubscribed(String mobile) async {
    final Map<String, dynamic> body = await _post(
      BdappsConstants.checkSubscription,
      {'user_mobile': mobile},
    );

    return body['isSubscribed'] == true;
  }

  /// Sends an OTP to [mobile] and returns the reference number.
  /// The reference number is needed later to verify the OTP.
  Future<String> sendOtp(String mobile) async {
    final Map<String, dynamic> body = await _post(
      BdappsConstants.sendOtp,
      {'user_mobile': mobile},
    );

    final String referenceNo = body['referenceNo']?.toString() ?? '';

    if (body['success'] != true || referenceNo.isEmpty) {
      throw BdappsException(
        _messageFrom(body, 'Could not send the OTP. Please try again.'),
      );
    }

    return referenceNo;
  }

  /// Confirms the [otp] for the given [referenceNo] and starts the subscription.
  Future<void> verifyOtp({
    required String otp,
    required String referenceNo,
  }) async {
    final Map<String, dynamic> body = await _post(
      BdappsConstants.verifyOtp,
      {'Otp': otp, 'referenceNo': referenceNo},
    );

    if (body['statusCode'] != BdappsConstants.successCode) {
      throw BdappsException(
        _messageFrom(body, 'The OTP is incorrect or has expired.'),
      );
    }
  }

  /// Cancels the subscription for [mobile].
  Future<void> unsubscribe(String mobile) async {
    final Map<String, dynamic> body = await _post(
      BdappsConstants.unsubscribe,
      {'user_mobile': mobile},
    );

    // The server reports success when the number ends up unregistered, even
    // if it was already unsubscribed before this call.
    if (body['success'] != true) {
      throw BdappsException(
        _messageFrom(body, 'Could not unsubscribe. Please try again.'),
      );
    }
  }

  /// Sends a form-encoded POST and returns the decoded JSON response.
  Future<Map<String, dynamic>> _post(
    String url,
    Map<String, String> fields,
  ) async {
    try {
      final http.Response response = await _client
          .post(Uri.parse(url), body: fields)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw const BdappsException('Something went wrong. Please try again.');
      }

      return jsonDecode(response.body) as Map<String, dynamic>;
    } on SocketException {
      throw const BdappsException('No internet connection.');
    } on BdappsException {
      rethrow;
    } catch (_) {
      throw const BdappsException('Something went wrong. Please try again.');
    }
  }

  /// Picks the most useful error text the server sent back.
  String _messageFrom(Map<String, dynamic> body, String fallback) {
    final Object? serverMessage =
        body['message'] ?? body['error'] ?? body['statusDetail'];

    if (serverMessage == null) {
      return fallback;
    }

    final String text = serverMessage.toString().trim();
    return text.isEmpty ? fallback : text;
  }
}
