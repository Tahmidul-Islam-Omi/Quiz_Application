import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/category.dart';

/// A tappable gradient card representing one quiz category.
class CategoryCard extends StatelessWidget {
  final Category category;
  final int index;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<Color> gradientColors = AppColors.gradientForIndex(index);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IconBadge(icon: _iconFor(category.name)),
            const Spacer(),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.title.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              category.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Picks a fitting icon for a category by name.
  IconData _iconFor(String name) {
    switch (name.toLowerCase()) {
      case 'math':
        return Icons.calculate_rounded;
      case 'general knowledge':
        return Icons.public_rounded;
      case 'physics':
        return Icons.bolt_rounded;
      case 'biology':
        return Icons.eco_rounded;
      case 'chemistry':
        return Icons.science_rounded;
      case 'computer':
        return Icons.computer_rounded;
      default:
        return Icons.quiz_rounded;
    }
  }
}

/// Frosted square badge holding the category icon.
class _IconBadge extends StatelessWidget {
  final IconData icon;

  const _IconBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: Colors.white, size: 26),
    );
  }
}
