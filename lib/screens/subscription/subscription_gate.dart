import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../home/home_screen.dart';
import 'mobile_number_screen.dart';
import 'otp_screen.dart';

/// Keeps the app locked until the signed-in user has an active subscription.
///
/// Shows the mobile number and OTP steps when they are still needed, and only
/// then lets the user through to [HomeScreen].
class SubscriptionGate extends StatefulWidget {
  const SubscriptionGate({super.key});

  @override
  State<SubscriptionGate> createState() => _SubscriptionGateState();
}

class _SubscriptionGateState extends State<SubscriptionGate> {
  @override
  void initState() {
    super.initState();
    // Runs after the first frame so the provider is not updated during build.
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAccess());
  }

  Future<void> _checkAccess() async {
    if (!mounted) {
      return;
    }

    final String? uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) {
      return;
    }

    await context.read<SubscriptionProvider>().checkAccess(uid);
  }

  @override
  Widget build(BuildContext context) {
    final SubscriptionProvider subscription = context
        .watch<SubscriptionProvider>();

    switch (subscription.stage) {
      case SubscriptionStage.checking:
        return const Scaffold(
          body: LoadingView(message: 'Checking your subscription...'),
        );

      case SubscriptionStage.needsMobile:
        return const MobileNumberScreen();

      case SubscriptionStage.needsOtp:
        return const OtpScreen();

      case SubscriptionStage.subscribed:
        return const HomeScreen();

      case SubscriptionStage.error:
        return Scaffold(
          body: ErrorView(
            message: subscription.errorMessage,
            onRetry: _checkAccess,
          ),
        );
    }
  }
}
