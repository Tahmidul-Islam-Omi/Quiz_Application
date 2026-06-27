import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_exception.dart';

/// Handles Google authentication through Firebase Auth.
class AuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  bool _isGoogleSignInReady = false;

  AuthService({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  /// Web/server client id from google-services.json (oauth_client type 3).
  /// Required so Google returns an idToken that Firebase accepts.
  static const String _serverClientId =
      '225570904865-cd69brs9nq6hvhtsghrn4rvk4v5ehm6e.apps.googleusercontent.com';

  /// The currently signed-in user, or null if signed out.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Emits the user on sign-in and null on sign-out.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Signs in with Google and returns the Firebase user.
  /// Returns null if the user cancels the Google dialog.
  Future<User?> signInWithGoogle() async {
    try {
      await _ensureGoogleSignInReady();

      final GoogleSignInAccount googleUser =
          await _googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      return userCredential.user;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      throw const AuthException('Google sign in failed. Please try again.');
    } on FirebaseAuthException {
      throw const AuthException('Authentication failed. Please try again.');
    }
  }

  /// Signs the user out of both Google and Firebase.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  /// Initializes the Google Sign-In SDK once before first use.
  Future<void> _ensureGoogleSignInReady() async {
    if (_isGoogleSignInReady) {
      return;
    }
    await _googleSignIn.initialize(serverClientId: _serverClientId);
    _isGoogleSignInReady = true;
  }
}
