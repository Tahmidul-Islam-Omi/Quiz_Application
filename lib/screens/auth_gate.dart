import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'home/home_screen.dart';
import 'login/login_screen.dart';

/// Routes to [HomeScreen] when signed in, otherwise [LoginScreen].
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isSignedIn = context.watch<AuthProvider>().isSignedIn;

    if (isSignedIn) {
      return const HomeScreen();
    }
    return const LoginScreen();
  }
}
