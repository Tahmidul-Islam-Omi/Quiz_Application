import 'package:flutter/material.dart';

import '../services/bdapps_exception.dart';
import '../services/bdapps_service.dart';
import '../services/user_exception.dart';
import '../services/user_service.dart';

/// Where the user currently sits in the subscription flow.
enum SubscriptionStage {
  /// Looking up the saved mobile number and the subscription status.
  checking,

  /// No mobile number is saved yet, so we have to ask for one.
  needsMobile,

  /// An OTP has been sent and we are waiting for the user to confirm it.
  needsOtp,

  /// The user is subscribed and may use the app.
  subscribed,

  /// The check itself failed, so the user should be able to retry.
  error,
}

/// Decides whether a signed-in user is allowed into the app.
///
/// The saved mobile number comes from Firestore, while the subscription
/// status is always read live from bdapps.
class SubscriptionProvider extends ChangeNotifier {
  final BdappsService _bdappsService;
  final UserService _userService;

  SubscriptionProvider({BdappsService? bdappsService, UserService? userService})
    : _bdappsService = bdappsService ?? BdappsService(),
      _userService = userService ?? UserService();

  SubscriptionStage _stage = SubscriptionStage.checking;
  String _mobileNumber = '';
  String _referenceNo = '';
  String _errorMessage = '';
  bool _isSubmitting = false;

  SubscriptionStage get stage => _stage;
  String get mobileNumber => _mobileNumber;
  String get errorMessage => _errorMessage;
  bool get isSubmitting => _isSubmitting;

  /// Entry point after sign-in. Works out which screen the user belongs on.
  Future<void> checkAccess(String uid) async {
    _stage = SubscriptionStage.checking;
    _errorMessage = '';
    notifyListeners();

    try {
      final String? savedMobile = await _userService.getMobileNumber(uid);

      if (savedMobile == null) {
        _stage = SubscriptionStage.needsMobile;
      } else {
        _mobileNumber = savedMobile;

        final bool subscribed = await _bdappsService.isSubscribed(savedMobile);
        if (subscribed) {
          _stage = SubscriptionStage.subscribed;
        } else {
          await _sendOtpTo(savedMobile);
        }
      }
    } catch (error) {
      _errorMessage = _readableError(error);
      _stage = SubscriptionStage.error;
    }

    notifyListeners();
  }

  /// Saves the number the user typed, then sends them an OTP.
  Future<void> submitMobile({
    required String uid,
    required String mobile,
  }) async {
    _isSubmitting = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _userService.saveMobileNumber(uid: uid, mobile: mobile);
      _mobileNumber = mobile;
      await _sendOtpTo(mobile);
    } catch (error) {
      _errorMessage = _readableError(error);
    }

    _isSubmitting = false;
    notifyListeners();
  }

  /// Confirms the OTP the user typed and unlocks the app when it is correct.
  Future<void> verifyOtp(String otp) async {
    _isSubmitting = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _bdappsService.verifyOtp(otp: otp, referenceNo: _referenceNo);
      _stage = SubscriptionStage.subscribed;
    } catch (error) {
      _errorMessage = _readableError(error);
    }

    _isSubmitting = false;
    notifyListeners();
  }

  /// Sends a fresh OTP to the number we already have.
  Future<void> resendOtp() async {
    _isSubmitting = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _sendOtpTo(_mobileNumber);
    } catch (error) {
      _errorMessage = _readableError(error);
    }

    _isSubmitting = false;
    notifyListeners();
  }

  /// Cancels the subscription. Returns true when it succeeded.
  Future<bool> unsubscribe() async {
    _isSubmitting = true;
    _errorMessage = '';
    notifyListeners();

    bool succeeded = false;

    try {
      await _bdappsService.unsubscribe(_mobileNumber);
      succeeded = true;
    } catch (error) {
      _errorMessage = _readableError(error);
    }

    _isSubmitting = false;
    notifyListeners();
    return succeeded;
  }

  /// Clears everything, so the next signed-in user starts fresh.
  void reset() {
    _stage = SubscriptionStage.checking;
    _mobileNumber = '';
    _referenceNo = '';
    _errorMessage = '';
    _isSubmitting = false;
    notifyListeners();
  }

  /// Requests an OTP and moves the user to the OTP screen.
  Future<void> _sendOtpTo(String mobile) async {
    _referenceNo = await _bdappsService.sendOtp(mobile);
    _stage = SubscriptionStage.needsOtp;
  }

  /// Turns an error into a message that is safe to show the user.
  String _readableError(Object error) {
    if (error is BdappsException) {
      return error.message;
    }
    if (error is UserException) {
      return error.message;
    }
    return 'Something went wrong. Please try again.';
  }
}
