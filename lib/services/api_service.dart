import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import '../models/category.dart';
import '../models/question.dart';
import 'api_exception.dart';

/// Handles all network requests to the quiz API.
class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches the list of quiz categories.
  Future<List<Category>> getCategories() async {
    final Uri url = Uri.parse(ApiConstants.categories);
    final List<dynamic> data = await _getData(url);
    return data
        .map((item) => Category.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Fetches the questions for the given [categoryId].
  Future<List<Question>> getQuestions(int categoryId) async {
    final Uri url = Uri.parse(ApiConstants.questions(categoryId));
    final List<dynamic> data = await _getData(url);
    return data
        .map((item) => Question.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Sends a GET request and returns the `data` array from the response.
  Future<List<dynamic>> _getData(Uri url) async {
    try {
      final http.Response response = await _client
          .get(url)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw const ApiException('Something went wrong. Please try again.');
      }

      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      return body['data'] as List<dynamic>? ?? [];
    } on SocketException {
      throw const ApiException('No internet connection.');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Failed to load data. Please try again.');
    }
  }
}
