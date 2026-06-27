import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// A single tappable answer option.
/// After [revealed] is true, it shows correct/wrong feedback colors.
class OptionTile extends StatelessWidget {
  final String letter;
  final String text;
  final bool isCorrectAnswer;
  final bool isSelected;
  final bool revealed;
  final VoidCallback? onTap;

  const OptionTile({
    super.key,
    required this.letter,
    required this.text,
    required this.isCorrectAnswer,
    required this.isSelected,
    required this.revealed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final _OptionStyle style = _resolveStyle();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: style.border, width: 1.5),
        ),
        child: Row(
          children: [
            _LetterBadge(letter: letter, color: style.accent),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
              ),
            ),
            if (style.trailingIcon != null)
              Icon(style.trailingIcon, color: style.accent, size: 22),
          ],
        ),
      ),
    );
  }

  /// Picks colors and the trailing icon based on the answer state.
  _OptionStyle _resolveStyle() {
    if (!revealed) {
      return const _OptionStyle(
        background: AppColors.surface,
        border: Color(0xFFE3DEF7),
        accent: AppColors.primary,
        trailingIcon: null,
      );
    }

    if (isCorrectAnswer) {
      return const _OptionStyle(
        background: Color(0xFFE6F8EF),
        border: AppColors.correct,
        accent: AppColors.correct,
        trailingIcon: Icons.check_circle_rounded,
      );
    }

    if (isSelected) {
      return const _OptionStyle(
        background: Color(0xFFFDEAEC),
        border: AppColors.wrong,
        accent: AppColors.wrong,
        trailingIcon: Icons.cancel_rounded,
      );
    }

    return const _OptionStyle(
      background: AppColors.surface,
      border: Color(0xFFE3DEF7),
      accent: AppColors.textSecondary,
      trailingIcon: null,
    );
  }
}

/// Small rounded badge showing the option letter (A, B, C, D).
class _LetterBadge extends StatelessWidget {
  final String letter;
  final Color color;

  const _LetterBadge({required this.letter, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      width: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        letter,
        style: AppTextStyles.title.copyWith(color: color, fontSize: 16),
      ),
    );
  }
}

/// Bundle of colors and icon for one option state.
class _OptionStyle {
  final Color background;
  final Color border;
  final Color accent;
  final IconData? trailingIcon;

  const _OptionStyle({
    required this.background,
    required this.border,
    required this.accent,
    required this.trailingIcon,
  });
}
