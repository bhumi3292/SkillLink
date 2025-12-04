import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_link/features/add_property/data/model/property_model/property_api_model.dart';
import 'package:skill_link/features/favourite/presentation/bloc/cart_bloc.dart';
import 'package:skill_link/cores/utils/image_url_helper.dart'; // Make sure this path is correct

class PropertyCardWidget extends StatefulWidget {
  final PropertyApiModel property;
  final VoidCallback? onTap;
  final bool showFavoriteButton;
  final bool showRemoveButton;
  final bool isFavorite;
  // Removed final String? baseUrl; // <--- REMOVED THIS LINE

  const PropertyCardWidget({
    super.key,
    required this.property,
    this.onTap,
    this.showFavoriteButton = true,
    this.showRemoveButton = false,
    this.isFavorite = false,
    // Removed this.baseUrl, // <--- REMOVED THIS LINE from constructor
  });

  @override
  State<PropertyCardWidget> createState() => _PropertyCardWidgetState();
}

class _PropertyCardWidgetState extends State<PropertyCardWidget> {
  bool _isLoading = false;
  bool _isFavorite = false;
  int _currentImageIndex = 0;
  late PageController _pageController;
  late CartBloc _cartBloc;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
    _pageController = PageController();
    _cartBloc = context.read<CartBloc>();
    _checkFavoriteStatus();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _checkFavoriteStatus() async {
    // The cart status will be updated through the bloc listener
    _cartBloc.add(GetCartEvent());
  }

  void _toggleFavorite() {
    if (_isLoading) return;

    print(
      'DEBUG: Heart icon tapped for property: ${widget.property.id} - ${widget.property.title}',
    );
    print('DEBUG: Current favorite state: $_isFavorite');

    setState(() {
      _isLoading = true;
    });

    if (_isFavorite) {
      // Remove from favorites
      print('DEBUG: Attempting to remove from favorites');
      _cartBloc.add(RemoveFromCartEvent(widget.property.id!));
    } else {
      // Add to favorites
      print('DEBUG: Attempting to add to favorites');
      _cartBloc.add(AddToCartEvent(widget.property.id!));
    }
  }

  String _getImageUrl(String imagePath) {
    print('DEBUG: Processing image path: $imagePath');
    // CORRECTED LINE 83: Removed 'baseUrl: widget.baseUrl'
    final fullUrl = ImageUrlHelper.constructImageUrl(imagePath);
    print('DEBUG: Constructed full URL: $fullUrl');
    return fullUrl;
  }

  Widget _buildImageCarousel() {
    print(
      'DEBUG: Building image carousel for property: ${widget.property.title}',
    );
    print('DEBUG: Number of images: ${widget.property.images.length}');
    print('DEBUG: Images: ${widget.property.images}');

    if (widget.property.images.isEmpty) {
      print('DEBUG: No images available, showing placeholder');
      return Container(
        width: 100,
        height: 100,
        color: Colors.grey[300],
        child: const Icon(Icons.home, size: 40, color: Colors.grey),
      );
    }

    // For debugging: Show all images in a grid to verify they load
    if (widget.property.images.length > 1) {
      print('DEBUG: Multiple images detected, showing carousel');
    }

    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        children: [
          // Image PageView
          PageView.builder(
            controller: _pageController,
            itemCount: widget.property.images.length,
            onPageChanged: (index) {
              print('DEBUG: Page changed to index: $index');
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final imageUrl = _getImageUrl(widget.property.images[index]);
              print('DEBUG: Loading image $index: $imageUrl');

              return ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  memCacheWidth: 200, // Optimize memory usage
                  memCacheHeight: 200,
                  placeholder: (context, url) {
                    print('DEBUG: Loading placeholder for: $url');
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorWidget: (context, url, error) {
                    print('DEBUG: Error loading image: $url, Error: $error');

                    // These alternative URLs will still use a hardcoded IP.
                    // If your ImageUrlHelper is set up correctly with ApiEndpoints,
                    // these hardcoded attempts should ideally not be needed.
                    // They are here as a fallback/debug measure.
                    final originalPath = widget.property.images[index];
                    final alternativeUrls = [
                      'http://10.0.2.2:3001/uploads/$originalPath',
                      'http://10.0.2.2:3001/images/$originalPath',
                      'http://10.0.2.2:3001/static/$originalPath',
                    ];

                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[300],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 20),
                          const SizedBox(height: 4),
                          Text(
                            'Failed',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.red[700],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'URL: ${originalPath.length > 10 ? '${originalPath.substring(0, 10)}...' : originalPath}',
                            style: const TextStyle(fontSize: 6),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Status: 404',
                            style: const TextStyle(
                              fontSize: 6,
                              color: Colors.red,
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
          if (widget.property.images.length > 1)
            Positioned(
              bottom: 4,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.property.images.length,
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
    return BlocListener<CartBloc, CartState>(
      listener: (context, state) {
        if (state is CartLoaded) {
          // Check if the current property is in the cart
          final isInCart =
              state.cart.items?.any(
                (item) => item.property.id == widget.property.id,
              ) ??
              false;

          // Only update if the favorite status actually changed to avoid unnecessary rebuilds and snackbars
          if (_isFavorite != isInCart) {
            setState(() {
              _isFavorite = isInCart;
              _isLoading =
                  false; // Stop loading indicator after state is updated
            });

            // Show success message only if status changed due to an action
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isInCart ? 'Added to favorites' : 'Removed from favorites',
                ),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            // If status didn't change but loading was true, just set loading to false
            setState(() {
              _isLoading = false;
            });
          }
        } else if (state is CartError) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is CartLoading) {
          // You might want to show a loading indicator on the favorite button
          // This is already handled by the _isLoading variable
        }
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          child: Stack(
            children: [
              Row(
                children: [
                  _buildImageCarousel(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.property.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.property.location,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Price: ${widget.property.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (widget.property.bedrooms != null)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.bed,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${widget.property.bedrooms}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                ),
                              if (widget.property.bathrooms != null)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.bathtub,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${widget.property.bathrooms}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Vertical Heart Icon positioned on the right
              if (widget.showFavoriteButton)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _toggleFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.red,
                                ),
                              )
                              : Icon(
                                _isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _isFavorite ? Colors.red : Colors.grey,
                                size: 24,
                              ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
