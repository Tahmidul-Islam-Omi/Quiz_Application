import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_page_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/category.dart';
import '../quiz/quiz_screen.dart';

/// Congratulations screen shown when a quiz is finished.
class ResultScreen extends StatelessWidget {
  final Category category;
  final int score;
  final int totalMarks;
  final int correctCount;
  final int totalQuestions;

  const ResultScreen({
    super.key,
    required this.category,
    required this.score,
    required this.totalMarks,
    required this.correctCount,
    required this.totalQuestions,
  });

  int get _percent {
    if (totalMarks == 0) {
      return 0;
    }
    return ((score / totalMarks) * 100).round();
  }

  void _playAgain(BuildContext context) {
    Navigator.of(
      context,
    ).pushReplacement(appPageRoute(QuizScreen(category: category)));
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final _Performance performance = _Performance.fromPercent(_percent);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.heroGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Text(performance.emoji, style: const TextStyle(fontSize: 56)),
                  const SizedBox(height: 12),
                  Text(
                    performance.title,
                    style: AppTextStyles.display.copyWith(
                      color: Colors.white,
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'on ${category.name}',
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _ScoreRing(
                    percent: _percent,
                    score: score,
                    total: totalMarks,
                  ),
                  const SizedBox(height: 32),
                  _StatsRow(
                    correctCount: correctCount,
                    totalQuestions: totalQuestions,
                    score: score,
                  ),
                  const Spacer(flex: 3),
                  _PrimaryButton(
                    label: 'Play Again',
                    icon: Icons.refresh_rounded,
                    onPressed: () => _playAgain(context),
                  ),
                  const SizedBox(height: 14),
                  _SecondaryButton(
                    label: 'Back to Home',
                    onPressed: () => _goHome(context),
                  ),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular ring showing the score percentage with the raw points inside.
class _ScoreRing extends StatelessWidget {
  final int percent;
  final int score;
  final int total;

  const _ScoreRing({
    required this.percent,
    required this.score,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      width: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 180,
            width: 180,
            child: CircularProgressIndicator(
              value: percent / 100,
              strokeWidth: 14,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percent%',
                style: AppTextStyles.display.copyWith(
                  color: Colors.white,
                  fontSize: 44,
                ),
              ),
              Text(
                '$score / $total pts',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Two frosted stat tiles: correct answers and points earned.
class _StatsRow extends StatelessWidget {
  final int correctCount;
  final int totalQuestions;
  final int score;

  const _StatsRow({
    required this.correctCount,
    required this.totalQuestions,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.check_circle_rounded,
            value: '$correctCount/$totalQuestions',
            label: 'Correct',
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _StatTile(
            icon: Icons.star_rounded,
            value: '$score',
            label: 'Points',
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.title.copyWith(color: Colors.white)),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

/// White primary action button.
class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.primary),
        label: Text(
          label,
          style: AppTextStyles.button.copyWith(color: AppColors.primary),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

/// Translucent secondary action button.
class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _SecondaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.button.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

/// Maps a score percentage to a celebratory message and emoji.
class _Performance {
  final String title;
  final String emoji;

  const _Performance({required this.title, required this.emoji});

  factory _Performance.fromPercent(int percent) {
    if (percent >= 80) {
      return const _Performance(title: 'Outstanding!', emoji: '🏆');
    }
    if (percent >= 60) {
      return const _Performance(title: 'Great job!', emoji: '🎉');
    }
    if (percent >= 40) {
      return const _Performance(title: 'Good effort!', emoji: '👍');
    }
    return const _Performance(title: 'Keep practicing!', emoji: '💪');
  }
}
