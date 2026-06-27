import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/app_page_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/view_state.dart';
import '../../models/category.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../widgets/category_card.dart';
import '../../widgets/user_avatar.dart';
import '../category/category_screen.dart';
import '../profile/profile_screen.dart';
import '../quiz/quiz_screen.dart';

/// Landing dashboard shown after sign-in.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
    });
  }

  void _openCategories() {
    Navigator.of(context).push(appPageRoute(const CategoryScreen()));
  }

  void _openProfile() {
    Navigator.of(context).push(appPageRoute(const ProfileScreen()));
  }

  void _openQuiz(Category category) {
    Navigator.of(context).push(appPageRoute(QuizScreen(category: category)));
  }

  @override
  Widget build(BuildContext context) {
    final User? user = context.watch<AuthProvider>().user;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              _HomeHeader(
                name: user?.displayName,
                photoUrl: user?.photoURL,
                onProfileTap: _openProfile,
              ),
              const SizedBox(height: 24),
              _HeroCard(onBrowse: _openCategories),
              const SizedBox(height: 28),
              _SectionHeader(
                title: 'Popular Topics',
                onSeeAll: _openCategories,
              ),
              const SizedBox(height: 14),
              _PopularTopics(onTap: _openQuiz),
            ],
          ),
        ),
      ),
    );
  }
}

/// Greeting row with the user's name and a tappable avatar.
class _HomeHeader extends StatelessWidget {
  final String? name;
  final String? photoUrl;
  final VoidCallback onProfileTap;

  const _HomeHeader({
    required this.name,
    required this.photoUrl,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final String firstName = (name != null && name!.isNotEmpty)
        ? name!.split(' ').first
        : 'there';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hi, $firstName 👋', style: AppTextStyles.heading),
              const SizedBox(height: 4),
              Text(
                'Ready for a challenge?',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onProfileTap,
          child: UserAvatar(photoUrl: photoUrl, name: name, size: 52),
        ),
      ],
    );
  }
}

/// Gradient hero card prompting the user to browse topics.
class _HeroCard extends StatelessWidget {
  final VoidCallback onBrowse;

  const _HeroCard({required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pick a topic\n& start playing',
                  style: AppTextStyles.title.copyWith(
                    color: Colors.white,
                    fontSize: 22,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 16),
                _BrowseButton(onPressed: onBrowse),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.rocket_launch_rounded,
            color: Colors.white,
            size: 64,
          ),
        ],
      ),
    );
  }
}

class _BrowseButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _BrowseButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(
        'Browse Topics',
        style: AppTextStyles.button.copyWith(color: AppColors.primary),
      ),
    );
  }
}

/// Section title with a "See all" action.
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.title),
        GestureDetector(
          onTap: onSeeAll,
          child: Text(
            'See all',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Horizontal preview of the first few categories.
class _PopularTopics extends StatelessWidget {
  final void Function(Category) onTap;

  const _PopularTopics({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        if (provider.state == ViewState.loading ||
            provider.state == ViewState.idle) {
          return const SizedBox(
            height: 180,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (provider.state == ViewState.error) {
          return SizedBox(
            height: 180,
            child: Center(
              child: TextButton(
                onPressed: provider.loadCategories,
                child: const Text('Couldn\'t load topics. Tap to retry.'),
              ),
            ),
          );
        }

        final List<Category> preview = provider.categories.take(4).toList();
        return SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: preview.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final Category category = preview[index];
              return SizedBox(
                width: 150,
                child: CategoryCard(
                  category: category,
                  index: index,
                  onTap: () => onTap(category),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
