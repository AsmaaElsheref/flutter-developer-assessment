import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'loading_shimmer.dart';

class AppCachedImage extends StatelessWidget {
  final String? imageUrl;

  const AppCachedImage({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return imageUrl==null||imageUrl!.trim().isEmpty?
    Container(
      color: AppColors.shimmerBase,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: Colors.grey),
    ):
    CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: BoxFit.cover,
      placeholder: (context, url) => const LoadingShimmer(),
      errorWidget: (context, url, error) {
        return Container(
          color: AppColors.shimmerBase,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
        );
      },
    );

  }
}