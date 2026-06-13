import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Cached dish image with a graceful loading shimmer and an offline-safe
/// fallback (gradient + icon) when the URL is missing or unreachable.
class DishImage extends StatelessWidget {
  const DishImage({super.key, required this.imageUrl, this.fit = BoxFit.cover});

  final String imageUrl;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) return const _Fallback();
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => Container(
        color: AppTheme.saffron.withValues(alpha: 0.08),
        alignment: Alignment.center,
        child: const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
      errorWidget: (context, url, error) => const _Fallback(),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.saffron.withValues(alpha: 0.75),
            AppTheme.saffron.withValues(alpha: 0.45),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.restaurant_rounded, size: 56, color: Colors.white),
    );
  }
}
