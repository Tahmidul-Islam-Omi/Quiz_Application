import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/view_state.dart';
import '../../models/category.dart';
import '../../providers/category_provider.dart';
import '../../widgets/category_card.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../quiz/quiz_screen.dart';

/// Shows all quiz categories in a grid.
class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadIfNeeded());
  }

  void _loadIfNeeded() {
    final CategoryProvider provider = context.read<CategoryProvider>();
    if (provider.state != ViewState.success) {
      provider.loadCategories();
    }
  }

  void _openQuiz(Category category) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => QuizScreen(category: category)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose a Topic')),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, child) {
          switch (provider.state) {
            case ViewState.loading:
            case ViewState.idle:
              return const LoadingView(message: 'Loading topics...');
            case ViewState.error:
              return ErrorView(
                message: provider.errorMessage,
                onRetry: provider.loadCategories,
              );
            case ViewState.success:
              return _CategoryGrid(
                categories: provider.categories,
                onTap: _openQuiz,
              );
          }
        },
      ),
    );
  }
}

/// Two-column grid of category cards.
class _CategoryGrid extends StatelessWidget {
  final List<Category> categories;
  final void Function(Category) onTap;

  const _CategoryGrid({required this.categories, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Text(
            'Pick a category and test your knowledge',
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.92,
            ),
            itemBuilder: (context, index) {
              final Category category = categories[index];
              return CategoryCard(
                category: category,
                index: index,
                onTap: () => onTap(category),
              );
            },
          ),
        ),
      ],
    );
  }
}
