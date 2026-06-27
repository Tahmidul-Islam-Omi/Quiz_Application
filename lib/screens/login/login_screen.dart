import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';

/// Sign-in screen with Google authentication.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final AuthProvider auth = context.read<AuthProvider>();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    await auth.signInWithGoogle();

    if (auth.errorMessage != null) {
      messenger.showSnackBar(SnackBar(content: Text(auth.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = context.watch<AuthProvider>().isLoading;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.heroGradient),
          child: Stack(
            children: [
              _FloatingMotifs(controller: _floatController),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),
                      const _HeroBadge(),
                      const SizedBox(height: 28),
                      Text(
                        'Quizzo',
                        style: AppTextStyles.display.copyWith(
                          color: Colors.white,
                          fontSize: 52,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Test your knowledge.\nBeat your best score.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const _FeaturePills(),
                      const Spacer(flex: 3),
                      _GoogleSignInButton(
                        isLoading: isLoading,
                        onPressed: _handleSignIn,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Sign in to start playing',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                      const Spacer(flex: 1),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tilted squircle badge with the app icon and a lime accent dot.
class _HeroBadge extends StatelessWidget {
  const _HeroBadge();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.06,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 116,
            width: 116,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.45),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.quiz_rounded,
              color: Colors.white,
              size: 58,
            ),
          ),
          Positioned(
            top: -8,
            right: -8,
            child: Container(
              height: 26,
              width: 26,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star_rounded,
                color: AppColors.textPrimary,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Row of small frosted pills highlighting app features.
class _FeaturePills extends StatelessWidget {
  const _FeaturePills();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        _Pill(icon: Icons.category_rounded, label: '6 Topics'),
        _Pill(icon: Icons.timer_rounded, label: 'Timed'),
        _Pill(icon: Icons.emoji_events_rounded, label: 'Score'),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Pill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// Decorative quiz shapes that gently float in the background.
class _FloatingMotifs extends StatelessWidget {
  final AnimationController controller;

  const _FloatingMotifs({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _motif(const Alignment(-0.85, -0.7), 0.0, const _LetterChip('A')),
        _motif(const Alignment(0.6, -0.82), 0.3, const _Sparkle()),
        _motif(const Alignment(0.9, -0.5), 0.5, const _QuestionDot()),
        _motif(const Alignment(-0.95, 0.0), 0.7, const _LetterChip('B')),
        _motif(const Alignment(0.95, 0.15), 0.2, const _LetterChip('C')),
        _motif(const Alignment(-0.55, 0.4), 0.9, const _Sparkle()),
        _motif(const Alignment(0.7, 0.5), 0.6, const _LetterChip('D')),
        _motif(const Alignment(-0.8, 0.7), 0.4, const _QuestionDot()),
      ],
    );
  }

  Widget _motif(Alignment alignment, double phase, Widget child) {
    return Align(
      alignment: alignment,
      child: AnimatedBuilder(
        animation: controller,
        child: child,
        builder: (context, child) {
          final double dy =
              math.sin((controller.value + phase) * 2 * math.pi) * 8;
          return Transform.translate(offset: Offset(0, dy), child: child);
        },
      ),
    );
  }
}

/// A small frosted chip showing an answer letter.
class _LetterChip extends StatelessWidget {
  final String letter;

  const _LetterChip(this.letter);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Text(
        letter,
        style: AppTextStyles.title.copyWith(
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}

class _QuestionDot extends StatelessWidget {
  const _QuestionDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      width: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Text(
        '?',
        style: AppTextStyles.title.copyWith(
          color: Colors.white.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.star_rounded,
      size: 26,
      color: Colors.white.withValues(alpha: 0.45),
    );
  }
}

/// White "Continue with Google" button with a loading state.
class _GoogleSignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _GoogleSignInButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          disabledBackgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _GoogleGlyph(),
                  const SizedBox(width: 12),
                  Text(
                    'Continue with Google',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Simple Google "G" mark.
class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      width: 26,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFF4285F4),
        shape: BoxShape.circle,
      ),
      child: const Text(
        'G',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}
