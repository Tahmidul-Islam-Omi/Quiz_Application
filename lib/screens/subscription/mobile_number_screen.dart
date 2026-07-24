import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../widgets/gradient_button.dart';

/// Asks the user for the mobile number that will hold the subscription.
class MobileNumberScreen extends StatefulWidget {
  const MobileNumberScreen({super.key});

  @override
  State<MobileNumberScreen> createState() => _MobileNumberScreenState();
}

class _MobileNumberScreenState extends State<MobileNumberScreen> {
  /// Bangladeshi mobile numbers: 11 digits starting with 013 to 019.
  static final RegExp _mobilePattern = RegExp(r'^01[3-9]\d{8}$');

  final TextEditingController _controller = TextEditingController();
  String _validationError = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String mobile = _controller.text.trim();

    if (!_mobilePattern.hasMatch(mobile)) {
      setState(() {
        _validationError = 'Enter a valid 11 digit number, like 01812345678.';
      });
      return;
    }

    setState(() => _validationError = '');

    final String? uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) {
      return;
    }

    await context.read<SubscriptionProvider>().submitMobile(
      uid: uid,
      mobile: mobile,
    );
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
                  const _Header(),
                  const SizedBox(height: 32),
                  _MobileForm(
                    controller: _controller,
                    errorText: _errorTextFor(subscription),
                    isSubmitting: subscription.isSubmitting,
                    onSubmit: _submit,
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

/// Title block explaining why the number is needed.
class _Header extends StatelessWidget {
  const _Header();

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
            Icons.smartphone_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'One last step',
          style: AppTextStyles.display.copyWith(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your Robi or Airtel number to unlock the quizzes.',
          style: AppTextStyles.body.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// White card holding the number field, the price note and the submit button.
class _MobileForm extends StatelessWidget {
  final TextEditingController controller;
  final String errorText;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const _MobileForm({
    required this.controller,
    required this.errorText,
    required this.isSubmitting,
    required this.onSubmit,
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
          Text('Mobile number', style: AppTextStyles.title),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            maxLength: 11,
            style: AppTextStyles.body,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: '01XXXXXXXXX',
              prefixText: '+88 ',
              prefixStyle: AppTextStyles.body,
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
            ),
          ],
          const SizedBox(height: 16),
          const _PriceNote(),
          const SizedBox(height: 24),
          GradientButton(
            label: 'Send OTP',
            icon: Icons.sms_rounded,
            isLoading: isSubmitting,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}

/// Tells the user what the subscription costs before they commit.
class _PriceNote extends StatelessWidget {
  const _PriceNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tk 2.00 + VAT is charged daily. You can cancel any time from '
              'your profile.',
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }
}
