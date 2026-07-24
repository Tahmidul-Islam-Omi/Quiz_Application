import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/subscription_provider.dart';
import '../../widgets/gradient_button.dart';

/// Asks the user for the OTP that bdapps sent by SMS.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _otpLength = 6;

  final TextEditingController _controller = TextEditingController();
  String _validationError = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final String otp = _controller.text.trim();

    if (otp.length != _otpLength) {
      setState(() {
        _validationError = 'Enter the $_otpLength digit code.';
      });
      return;
    }

    setState(() => _validationError = '');

    await context.read<SubscriptionProvider>().verifyOtp(otp);
  }

  Future<void> _resend() async {
    setState(() => _validationError = '');
    _controller.clear();

    await context.read<SubscriptionProvider>().resendOtp();
  }

  @override
  Widget build(BuildContext context) {
    final SubscriptionProvider subscription = context
        .watch<SubscriptionProvider>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.heroGradient),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(mobileNumber: subscription.mobileNumber),
                  const SizedBox(height: 32),
                  _OtpForm(
                    controller: _controller,
                    otpLength: _otpLength,
                    errorText: _errorTextFor(subscription),
                    isSubmitting: subscription.isSubmitting,
                    onVerify: _verify,
                    onResend: _resend,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Local validation wins, otherwise show whatever the server reported.
  String _errorTextFor(SubscriptionProvider subscription) {
    if (_validationError.isNotEmpty) {
      return _validationError;
    }
    return subscription.errorMessage;
  }
}

/// Title block showing where the code was sent.
class _Header extends StatelessWidget {
  final String mobileNumber;

  const _Header({required this.mobileNumber});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 76,
          width: 76,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Verify your number',
          style: AppTextStyles.display.copyWith(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'We sent a code to +88 $mobileNumber',
          style: AppTextStyles.body.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// White card holding the code field, the verify button and the resend link.
class _OtpForm extends StatelessWidget {
  final TextEditingController controller;
  final int otpLength;
  final String errorText;
  final bool isSubmitting;
  final VoidCallback onVerify;
  final VoidCallback onResend;

  const _OtpForm({
    required this.controller,
    required this.otpLength,
    required this.errorText,
    required this.isSubmitting,
    required this.onVerify,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Enter the code', style: AppTextStyles.title),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            maxLength: otpLength,
            textAlign: TextAlign.center,
            autofocus: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: AppTextStyles.display.copyWith(letterSpacing: 12),
            decoration: InputDecoration(
              hintText: '------',
              counterText: '',
              filled: true,
              fillColor: AppColors.surfaceMuted,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (errorText.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              errorText,
              style: AppTextStyles.caption.copyWith(color: AppColors.wrong),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          GradientButton(
            label: 'Verify & Subscribe',
            icon: Icons.verified_rounded,
            isLoading: isSubmitting,
            onPressed: onVerify,
          ),
          const SizedBox(height: 12),
          _ResendRow(isSubmitting: isSubmitting, onResend: onResend),
        ],
      ),
    );
  }
}

/// Lets the user ask for another code when the first one never arrives.
class _ResendRow extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onResend;

  const _ResendRow({required this.isSubmitting, required this.onResend});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Didn't get the code?", style: AppTextStyles.caption),
        TextButton(
          onPressed: isSubmitting ? null : onResend,
          child: Text(
            'Resend',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
