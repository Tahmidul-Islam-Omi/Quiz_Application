import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/view_state.dart';
import '../../models/category.dart';
import '../../models/question.dart';
import '../../providers/quiz_provider.dart';
import '../../widgets/error_view.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/option_tile.dart';

/// Plays through the questions of a single category.
class QuizScreen extends StatefulWidget {
  final Category category;

  const QuizScreen({super.key, required this.category});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final QuizProvider _quiz;

  @override
  void initState() {
    super.initState();
    _quiz = context.read<QuizProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _quiz.loadQuestions(widget.category.id);
    });
  }

  @override
  void dispose() {
    _quiz.stopTimer();
    super.dispose();
  }

  void _onNext(QuizProvider quiz) {
    if (quiz.isLastQuestion) {
      // TODO(step-23): navigate to the Result screen.
      Navigator.of(context).pop();
      return;
    }
    quiz.nextQuestion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category.name)),
      body: Consumer<QuizProvider>(
        builder: (context, quiz, child) {
          switch (quiz.state) {
            case ViewState.loading:
            case ViewState.idle:
              return const LoadingView(message: 'Loading questions...');
            case ViewState.error:
              return ErrorView(
                message: quiz.errorMessage,
                onRetry: () => quiz.loadQuestions(widget.category.id),
              );
            case ViewState.success:
              return _QuizBody(quiz: quiz, onNext: () => _onNext(quiz));
          }
        },
      ),
    );
  }
}

/// The active question view: progress, question card, options, next button.
class _QuizBody extends StatelessWidget {
  final QuizProvider quiz;
  final VoidCallback onNext;

  const _QuizBody({required this.quiz, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final Question question = quiz.currentQuestion;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProgressHeader(
            current: quiz.currentIndex + 1,
            total: quiz.totalQuestions,
            secondsLeft: quiz.secondsLeft,
          ),
          const SizedBox(height: 20),
          _QuestionCard(question: question),
          const SizedBox(height: 20),
          Expanded(child: _Options(quiz: quiz)),
          if (quiz.isLocked) ...[
            _AnswerFeedback(
              isCorrect: quiz.isCurrentAnswerCorrect,
              timedOut: !quiz.isAnswered,
              mark: quiz.currentQuestion.mark,
            ),
            const SizedBox(height: 12),
          ] else
            const SizedBox(height: 8),
          GradientButton(
            label: quiz.isLastQuestion ? 'Finish' : 'Next',
            icon: quiz.isLastQuestion
                ? Icons.flag_rounded
                : Icons.arrow_forward_rounded,
            onPressed: quiz.isLocked ? onNext : null,
          ),
        ],
      ),
    );
  }
}

/// Shows "Question x of N", a countdown pill, and a progress bar.
class _ProgressHeader extends StatelessWidget {
  final int current;
  final int total;
  final int secondsLeft;

  const _ProgressHeader({
    required this.current,
    required this.total,
    required this.secondsLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question $current of $total',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary),
            ),
            _TimerPill(secondsLeft: secondsLeft),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: current / total,
            minHeight: 8,
            backgroundColor: AppColors.surfaceMuted,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      ],
    );
  }
}

/// Countdown pill that turns red when time is running low.
class _TimerPill extends StatelessWidget {
  final int secondsLeft;

  const _TimerPill({required this.secondsLeft});

  @override
  Widget build(BuildContext context) {
    final bool isLow = secondsLeft <= 5;
    final Color color = isLow ? AppColors.wrong : AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_rounded, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            '${secondsLeft}s',
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// White card displaying the question text and its mark.
class _QuestionCard extends StatelessWidget {
  final Question question;

  const _QuestionCard({required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '+${question.mark} points',
              style: AppTextStyles.caption.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(height: 14),
          Text(question.question, style: AppTextStyles.heading.copyWith(
            fontSize: 20,
            height: 1.3,
          )),
        ],
      ),
    );
  }
}

/// The list of answer options for the current question.
class _Options extends StatelessWidget {
  final QuizProvider quiz;

  const _Options({required this.quiz});

  static const List<String> _letters = ['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context) {
    final Question question = quiz.currentQuestion;

    return ListView.separated(
      itemCount: question.options.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return OptionTile(
          letter: _letterFor(index),
          text: question.options[index],
          isCorrectAnswer: index == question.answerIndex,
          isSelected: index == quiz.selectedIndex,
          revealed: quiz.isLocked,
          onTap: quiz.isLocked ? null : () => quiz.selectAnswer(index),
        );
      },
    );
  }

  String _letterFor(int index) {
    if (index < _letters.length) {
      return _letters[index];
    }
    return '${index + 1}';
  }
}

/// Banner shown once a question is resolved, confirming the result.
class _AnswerFeedback extends StatelessWidget {
  final bool isCorrect;
  final bool timedOut;
  final int mark;

  const _AnswerFeedback({
    required this.isCorrect,
    required this.timedOut,
    required this.mark,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isCorrect ? AppColors.correct : AppColors.wrong;
    final IconData icon = isCorrect
        ? Icons.check_circle_rounded
        : (timedOut ? Icons.timer_off_rounded : Icons.cancel_rounded);
    final String message = isCorrect
        ? 'Correct! +$mark points'
        : (timedOut ? 'Time\'s up!' : 'Oops! That\'s not right.');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Text(
            message,
            style: AppTextStyles.body.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
