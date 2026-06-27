import 'package:flutter/material.dart';

import '../core/view_state.dart';
import '../models/category.dart';
import '../services/api_exception.dart';
import '../services/api_service.dart';

/// Loads and exposes the list of quiz categories.
class CategoryProvider extends ChangeNotifier {
  final ApiService _apiService;

  CategoryProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  ViewState _state = ViewState.idle;
  List<Category> _categories = [];
  String _errorMessage = '';

  ViewState get state => _state;
  List<Category> get categories => _categories;
  String get errorMessage => _errorMessage;

  /// Fetches categories from the API and updates [state].
  Future<void> loadCategories() async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      _categories = await _apiService.getCategories();
      _state = ViewState.success;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      _state = ViewState.error;
    }

    notifyListeners();
  }
}
