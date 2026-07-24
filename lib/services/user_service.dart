import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_exception.dart';

/// Stores the profile data we keep for a signed-in user in Firestore.
///
/// Only the mobile number is saved here. Whether the user is subscribed is
/// always read live from bdapps, so that answer can never go stale.
class UserService {
  static const String _usersCollection = 'users';
  static const String _mobileField = 'mobileNumber';
  static const String _updatedAtField = 'updatedAt';

  final FirebaseFirestore _firestore;

  UserService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Returns the saved mobile number for [uid], or null when none is stored.
  Future<String?> getMobileNumber(String uid) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .get();

      final String mobile = snapshot.data()?[_mobileField]?.toString() ?? '';
      return mobile.isEmpty ? null : mobile;
    } catch (_) {
      throw const UserException('Could not load your saved details.');
    }
  }

  /// Saves [mobile] against [uid], creating the document when it does not exist.
  Future<void> saveMobileNumber({
    required String uid,
    required String mobile,
  }) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).set({
        _mobileField: mobile,
        _updatedAtField: FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      throw const UserException('Could not save your mobile number.');
    }
  }
}
