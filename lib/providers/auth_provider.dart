import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_exception.dart';
import '../services/auth_service.dart';

/// Exposes authentication state and actions to the UI.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  late final StreamSubscription<User?> _authSubscription;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _user = _authService.currentUser;
    _authSubscription =
        _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSignedIn => _user != null;

  /// Signs in with Google. Errors are stored in [errorMessage].
  Future<void> signInWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.signInWithGoogle();
    } on AuthException catch (error) {
      _errorMessage = error.message;
    } finally {
      _setLoading(false);
    }
  }

  /// Signs the user out.
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
    } finally {
      _setLoading(false);
    }
  }

  /// Keeps [user] in sync with Firebase auth state changes.
  void _onAuthStateChanged(User? user) {
    _user = user;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
