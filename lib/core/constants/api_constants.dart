/// API endpoints for the quiz backend.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://sadiks-quiz-apihub.lovable.app';

  /// GET list of quiz categories.
  static const String categories = '$baseUrl/api/v1/categories';

  /// GET questions for a given category.
  static String questions(int categoryId) {
    return '$baseUrl/api/v1/categories/$categoryId/questions';
  }
}
