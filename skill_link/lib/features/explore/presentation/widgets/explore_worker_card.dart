import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skill_link/features/explore/domain/entity/explore_worker_entity.dart';
import 'package:skill_link/cores/utils/image_url_helper.dart';
import 'package:skill_link/features/favourite/presentation/bloc/cart_bloc.dart';

class ExploreWorkerCard extends StatefulWidget {
  final ExploreWorkerEntity worker;
  final VoidCallback onTap;

  const ExploreWorkerCard({
    super.key,
    required this.worker,
    required this.onTap,
  });

  @override
  State<ExploreWorkerCard> createState() => _ExploreWorkerCardState();
}

class _ExploreWorkerCardState extends State<ExploreWorkerCard> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImages =
        widget.worker.images != null && widget.worker.images!.isNotEmpty;
    final hasVideos =
        widget.worker.videos != null && widget.worker.videos!.isNotEmpty;
    final allMedia = <String>[];

    if (hasImages) allMedia.addAll(widget.worker.images!);
    if (hasVideos) allMedia.addAll(widget.worker.videos!);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // WorkerImages/Videos Carousel
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child:
                    allMedia.isNotEmpty
                        ? Stack(
                          children: [
                            // Image/Video Carousel
                            PageView.builder(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentImageIndex = index;
                                });
                              },
                              itemCount: allMedia.length,
                              itemBuilder: (context, index) {
                                final mediaUrl = allMedia[index];
                                final isVideo =
                                    hasVideos &&
                                    widget.worker.videos!.contains(mediaUrl);

                                return Stack(
                                  children: [
                                    // Image or Video Thumbnail
                                    SizedBox(
                                      width: double.infinity,
                                      height: double.infinity,
                                      child:
                                          isVideo
                                              ? _buildVideoThumbnail(mediaUrl)
                                              : CachedNetworkImage(
                                                imageUrl: ImageUrlHelper.constructImageUrl(
                                                  mediaUrl,
                                                ),
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) => Container(
                                                  color: Colors.grey[200],
                                                  child: const Center(
                                                    child: CircularProgressIndicator(strokeWidth: 2),
                                                  ),
                                                ),
                                                errorWidget: (context, url, error) {
                                                  return Container(
                                                    color: Colors.grey[300],
                                                    child: const Icon(
                                                      Icons.broken_image,
                                                      size: 48,
                                                      color: Colors.grey,
                                                    ),
                                                  );
                                                },
                                              ),
                                    ),
                                    // Video Play Icon
                                    if (isVideo)
                                      Center(
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(
                                              0.5,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.play_arrow,
                                            color: Colors.white,
                                            size: 32,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                            // Image Counter
                            if (allMedia.length > 1)
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_currentImageIndex + 1}/${allMedia.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            // Image Indicators
                            if (allMedia.length > 1)
                              Positioned(
                                bottom: 12,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    allMedia.length,
                                    (index) => Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            _currentImageIndex == index
                                                ? Colors.white
                                                : Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        )
                        : Container(
                          color: Colors.grey[300],
                          child: Icon(
                            widget.worker.workerName != null
                                ? Icons.person
                                : Icons.home,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
              ),
            ),

            // WorkerDetails
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.worker.title ?? 'Unknown Service',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Subtitle: show worker name or short description
                  if (widget.worker.workerName != null &&
                      widget.worker.workerName!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Text(
                        widget.worker.workerName!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.worker.location ?? 'Unknown Location',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  const SizedBox(height: 12),

                  // Price and actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rs ${widget.worker.price?.toStringAsFixed(0) ?? '0'}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '/ per visit',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Call button
                          if (widget.worker.workerPhone != null &&
                              widget.worker.workerPhone!.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.call, color: Colors.green),
                              onPressed: () {
                                // Launch phone intent handled by caller
                              },
                            ),
                          // Message button
                          if (widget.worker.workerEmail != null &&
                              widget.worker.workerEmail!.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.email, color: Colors.blue),
                              onPressed: () {
                                // Launch email intent handled by caller
                              },
                            ),
                          BlocBuilder<CartBloc, CartState>(
                            builder: (context, cartState) {
                              bool isFavorite = false;
                              if (cartState is CartLoaded &&
                                  widget.worker.id != null) {
                                isFavorite =
                                    cartState.cart.items?.any(
                                      (item) =>
                                          item.worker.id ==
                                          widget.worker.id,
                                    ) ??
                                    false;
                              }
                              return IconButton(
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      isFavorite
                                          ? Colors.red
                                          : Colors.grey[600],
                                ),
                                onPressed: () {
                                  if (widget.worker.id != null) {
                                    if (isFavorite) {
                                      context.read<CartBloc>().add(
                                        RemoveFromCartEvent(widget.worker.id!),
                                      );
                                    } else {
                                      context.read<CartBloc>().add(
                                        AddToCartEvent(widget.worker.id!),
                                      );
                                    }
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Skill chip
                  if (widget.worker.categoryName != null &&
                      widget.worker.categoryName!.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.work,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.worker.categoryName!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoThumbnail(String videoUrl) {
    // For now, we'll show a placeholder for videos
    // In a real implementation, you might want to generate thumbnails
    return Container(
      color: Colors.grey[400],
      child: const Icon(Icons.video_library, size: 48, color: Colors.white),
    );
  }

  Widget _buildFeatureChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
