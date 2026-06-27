import 'package:flutter/material.dart';

import '../core/view_state.dart';
import '../models/question.dart';
import '../services/api_exception.dart';
import '../services/api_service.dart';

/// Manages a single quiz session: loading questions, tracking the
/// current question, recording answers, and computing the score.
class QuizProvider extends ChangeNotifier {
  final ApiService _apiService;

  QuizProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  ViewState _state = ViewState.idle;
  List<Question> _questions = [];
  String _errorMessage = '';

  int _currentIndex = 0;
  int _score = 0;
  int _correctCount = 0;
  int? _selectedIndex;

  ViewState get state => _state;
  String get errorMessage => _errorMessage;
  int get currentIndex => _currentIndex;
  int get score => _score;
  int get correctCount => _correctCount;
  int? get selectedIndex => _selectedIndex;

  int get totalQuestions => _questions.length;
  Question get currentQuestion => _questions[_currentIndex];
  bool get isAnswered => _selectedIndex != null;
  bool get isLastQuestion => _currentIndex == _questions.length - 1;

  /// True when the current question has been answered correctly.
  bool get isCurrentAnswerCorrect =>
      isAnswered && currentQuestion.isCorrect(_selectedIndex!);

  /// Total marks available across all questions.
  int get totalMarks {
    int total = 0;
    for (final Question question in _questions) {
      total += question.mark;
    }
    return total;
  }

  /// Loads questions for [categoryId] and starts a fresh session.
  Future<void> loadQuestions(int categoryId) async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      _questions = await _apiService.getQuestions(categoryId);
      _resetProgress();
      _state = ViewState.success;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      _state = ViewState.error;
    }

    notifyListeners();
  }

  /// Records the user's choice for the current question.
  /// Selection is locked once made, so the answer cannot be changed.
  void selectAnswer(int optionIndex) {
    if (isAnswered) {
      return;
    }

    _selectedIndex = optionIndex;
    if (currentQuestion.isCorrect(optionIndex)) {
      _score += currentQuestion.mark;
      _correctCount++;
    }
    notifyListeners();
  }

  /// Advances to the next question, if any.
  void nextQuestion() {
    if (isLastQuestion) {
      return;
    }
    _currentIndex++;
    _selectedIndex = null;
    notifyListeners();
  }

  /// Restarts the current set of questions from the beginning.
  void restart() {
    _resetProgress();
    notifyListeners();
  }

  void _resetProgress() {
    _currentIndex = 0;
    _score = 0;
    _correctCount = 0;
    _selectedIndex = null;
  }
}
