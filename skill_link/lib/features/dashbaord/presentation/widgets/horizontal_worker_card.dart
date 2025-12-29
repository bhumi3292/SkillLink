import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get_it/get_it.dart';
import 'package:skill_link/features/add_worker/data/model/worker_model/worker_api_model.dart';
import 'package:skill_link/features/add_worker/domain/use_case/cart/add_to_cart_usecase.dart';
import 'package:skill_link/features/add_worker/domain/use_case/cart/remove_from_cart_usecase.dart';
import 'package:skill_link/features/add_worker/domain/use_case/cart/get_cart_usecase.dart';
import 'package:skill_link/cores/utils/image_url_helper.dart'; // Ensure this import is correct

class HorizontalWorkerCard extends StatefulWidget {
  final WorkerApiModel worker;
  final VoidCallback? onTap;
  // Removed final String? baseUrl;
  // As ImageUrlHelper no longer needs it directly passed, it relies on ApiEndpoints.

  const HorizontalWorkerCard({
    super.key,
    required this.worker,
    this.onTap,
    // Removed this.baseUrl from constructor
  });

  @override
  State<HorizontalWorkerCard> createState() => _HorizontalWorkerCardState();
}

class _HorizontalWorkerCardState extends State<HorizontalWorkerCard> {
  bool _isLoading = false;
  bool _isFavorite = false;
  int _currentImageIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _checkFavoriteStatus();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      // Check if the Workeris in the cart (favorites)
      final getCartUsecase = GetIt.instance<GetCartUsecase>();
      final result = await getCartUsecase();

      result.fold(
        (failure) {
          // If we can't check, assume not favorite
          setState(() {
            _isFavorite = false;
          });
        },
        (cart) {
          final isInCart =
              cart.items?.any(
                (item) => item.worker?.id == widget.worker.id,
              ) ??
              false;
          setState(() {
            _isFavorite = isInCart;
          });
        },
      );
    } catch (e) {
      // If there's an error, assume not favorite
      setState(() {
        _isFavorite = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isLoading) return;

    print(
      'DEBUG: Horizontal heart icon tapped for worker: ${widget.worker.id} - ${widget.worker.title}',
    );
    print('DEBUG: Current favorite state: $_isFavorite');

    // Proceed with cart operation without authentication check
    print('DEBUG: Proceeding with cart operation (no login required)');

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isFavorite) {
        // Remove from favorites
        print('DEBUG: Attempting to remove from favorites (horizontal)');
        final removeUsecase = GetIt.instance<RemoveFromCartUsecase>();
        final result = await removeUsecase(
          RemoveFromCartParams(workerId: widget.worker.id ?? ''),
        );

        result.fold(
          (failure) {
            print(
              'DEBUG: Remove from favorites failed (horizontal): ${failure.message}',
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to remove from favorites: ${failure.message}',
                ),
                backgroundColor: Colors.red,
              ),
            );
          },
          (_) {
            print('DEBUG: Successfully removed from favorites (horizontal)');
            setState(() {
              _isFavorite = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Removed from favorites'),
                backgroundColor: Colors.green,
              ),
            );
          },
        );
      } else {
        // Add to favorites
        print('DEBUG: Attempting to add to favorites (horizontal)');
        final addUsecase = GetIt.instance<AddToCartUsecase>();
        final result = await addUsecase(
          AddToCartParams(workerId: widget.worker.id ?? ''),
        );

        result.fold(
          (failure) {
            print(
              'DEBUG: Add to favorites failed (horizontal): ${failure.message}',
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to add to favorites: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          },
          (_) {
            print('DEBUG: Successfully added to favorites (horizontal)');
            setState(() {
              _isFavorite = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Added to favorites'),
                backgroundColor: Colors.green,
              ),
            );
          },
        );
      }
    } catch (e) {
      print('DEBUG: Exception in _toggleFavorite (horizontal): $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Corrected _getImageUrl method - removed 'baseUrl' parameter
  String _getImageUrl(String imagePath) {
    print('DEBUG: Processing image path: $imagePath');
    // Calling ImageUrlHelper.constructImageUrl without the 'baseUrl' parameter
    final fullUrl = ImageUrlHelper.constructImageUrl(imagePath);
    print('DEBUG: Constructed full URL: $fullUrl');
    return fullUrl;
  }

  Widget _buildImageCarousel() {
    print(
      'DEBUG: Building horizontal image carousel for worker: ${widget.worker.title}',
    );
    print('DEBUG: Number of images: ${widget.worker.images.length}');
    print('DEBUG: Images: ${widget.worker.images}');

    if (widget.worker.images.isEmpty) {
      print('DEBUG: No images available, showing placeholder');
      return Container(
        width: 200,
        height: 120, // Consistent height
        color: Colors.grey[300],
        child: const Icon(Icons.home, size: 40, color: Colors.grey),
      );
    }

    return SizedBox(
      width: 200,
      height: 120, // Consistent height
      child: Stack(
        children: [
          // Image PageView
          PageView.builder(
            controller: _pageController,
            itemCount: widget.worker.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final imageUrl = _getImageUrl(widget.worker.images[index]);
              print('DEBUG: Loading horizontal image $index: $imageUrl');

              return ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 200,
                  height: 120, // Consistent height
                  fit: BoxFit.cover,
                  memCacheWidth: 400, // Optimize memory usage
                  memCacheHeight:
                      240, // Should be roughly 2x of actual height for better quality
                  placeholder: (context, url) {
                    print('DEBUG: Loading horizontal placeholder for: $url');
                    return Container(
                      width: 200,
                      height: 120, // Consistent height
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorWidget: (context, url, error) {
                    print(
                      'DEBUG: Error loading horizontal image: $url, Error: $error',
                    );
                    return Container(
                      width: 200,
                      height: 120, // Consistent height
                      color: Colors.grey[300],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 24),
                          const SizedBox(height: 4),
                          Text(
                            'Failed to load',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // Image indicators (only show if there are multiple images)
          if (widget.worker.images.length > 1)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.worker.images.length,
                  (index) => Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        width: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF003366).withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // WorkerImage Carousel
            SizedBox(
              height:
                  120, // Adjusted to match the image height in _buildImageCarousel
              child: _buildImageCarousel(),
            ),
            // WorkerDetails
            Padding(
              padding: const EdgeInsets.all(8.0), // Reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.worker.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF003366),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.worker.location,
                    style: const TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹ ${widget.worker.price.toStringAsFixed(0)}/hr', // Updated usage
                    style: const TextStyle(
                      color: Color(0xFFE65100), // Orange/Amber accent
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        (widget.worker.averageRating ?? 0.0).toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${widget.worker.numReviews ?? 0})',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
