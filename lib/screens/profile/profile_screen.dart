import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../widgets/user_avatar.dart';

/// Shows the signed-in user's details, the subscription and a logout action.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final NavigatorState navigator = Navigator.of(context);
    final AuthProvider auth = context.read<AuthProvider>();

    final bool confirmed = await _confirmLogout(context);
    if (!confirmed) {
      return;
    }

    await auth.signOut();
    navigator.popUntil((route) => route.isFirst);
  }

  Future<bool> _confirmLogout(BuildContext context) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Log out?', style: AppTextStyles.title),
          content: Text(
            'You will need to sign in again to play.',
            style: AppTextStyles.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Log Out',
                style: AppTextStyles.button.copyWith(color: AppColors.wrong),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  /// Cancels the subscription, then signs the user out because access ends.
  Future<void> _unsubscribe(BuildContext context) async {
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AuthProvider auth = context.read<AuthProvider>();
    final SubscriptionProvider subscription = context
        .read<SubscriptionProvider>();

    final bool confirmed = await _confirmUnsubscribe(context);
    if (!confirmed) {
      return;
    }

    final bool succeeded = await subscription.unsubscribe();
    if (!succeeded) {
      messenger.showSnackBar(
        SnackBar(content: Text(subscription.errorMessage)),
      );
      return;
    }

    subscription.reset();
    await auth.signOut();
    navigator.popUntil((route) => route.isFirst);
  }

  Future<bool> _confirmUnsubscribe(BuildContext context) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Cancel subscription?', style: AppTextStyles.title),
          content: Text(
            'Daily charging will stop and you will lose access to the '
            'quizzes. You can subscribe again any time.',
            style: AppTextStyles.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Keep It'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Unsubscribe',
                style: AppTextStyles.button.copyWith(color: AppColors.wrong),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final User? user = context.watch<AuthProvider>().user;
    final SubscriptionProvider subscription = context
        .watch<SubscriptionProvider>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Column(
          children: [
            _ProfileHeader(
              name: user?.displayName,
              email: user?.email,
              photoUrl: user?.photoURL,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _InfoTile(
                    icon: Icons.person_rounded,
                    label: 'Name',
                    value: user?.displayName ?? 'Quizzo Player',
                  ),
                  const SizedBox(height: 14),
                  _InfoTile(
                    icon: Icons.email_rounded,
                    label: 'Email',
                    value: user?.email ?? 'Not available',
                  ),
                  const SizedBox(height: 14),
                  _InfoTile(
                    icon: Icons.verified_rounded,
                    label: 'Subscription',
                    value: '+88 ${subscription.mobileNumber} · Active',
                  ),
                  const SizedBox(height: 28),
                  _ActionButton(
                    label: 'Unsubscribe',
                    icon: Icons.cancel_rounded,
                    color: AppColors.textSecondary,
                    isLoading: subscription.isSubmitting,
                    onPressed: () => _unsubscribe(context),
                  ),
                  const SizedBox(height: 14),
                  _ActionButton(
                    label: 'Log Out',
                    icon: Icons.logout_rounded,
                    color: AppColors.wrong,
                    onPressed: () => _logout(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gradient header with the avatar, name and email.
class _ProfileHeader extends StatelessWidget {
  final String? name;
  final String? email;
  final String? photoUrl;

  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 28),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: UserAvatar(photoUrl: photoUrl, name: name, size: 96),
              ),
              const SizedBox(height: 16),
              Text(
                (name != null && name!.isNotEmpty) ? name! : 'Quizzo Player',
                style: AppTextStyles.heading.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                email ?? '',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A labelled detail row inside a card.
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceMuted),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-width coloured button used for the unsubscribe and logout actions.
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Icon(icon, color: Colors.white),
        label: Text(label, style: AppTextStyles.button),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: color.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
