import 'package:flutter/material.dart';

import '../../models/category.dart';

/// Placeholder. Full quiz UI is built in Steps 20-22.
class QuizScreen extends StatelessWidget {
  final Category category;

  const QuizScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category.name)),
      body: Center(child: Text('Quiz: ${category.name}')),
    );
  }
}
