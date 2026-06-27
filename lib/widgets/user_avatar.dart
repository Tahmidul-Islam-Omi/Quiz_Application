import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Circular user avatar from a network photo, with an initial fallback.
class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final String? name;
  final double size;

  const UserAvatar({
    super.key,
    required this.photoUrl,
    required this.name,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    if (photoUrl == null || photoUrl!.isEmpty) {
      return _buildInitial();
    }

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: photoUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildInitial(),
        errorWidget: (context, url, error) => _buildInitial(),
      ),
    );
  }

  Widget _buildInitial() {
    final String letter =
        (name != null && name!.isNotEmpty) ? name![0].toUpperCase() : '?';

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
      ),
      child: Text(
        letter,
        style: AppTextStyles.title.copyWith(
          color: Colors.white,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}
