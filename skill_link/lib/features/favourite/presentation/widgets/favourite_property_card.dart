import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skill_link/features/add_property/data/model/property_model/property_api_model.dart';

import '../../../../app/constant/api_endpoints.dart';

class FavouritePropertyCard extends StatefulWidget {
  final PropertyApiModel property;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const FavouritePropertyCard({
    super.key,
    required this.property,
    this.onTap,
    this.onRemove,
  });

  @override
  State<FavouritePropertyCard> createState() => _FavouritePropertyCardState();
}

class _FavouritePropertyCardState extends State<FavouritePropertyCard> {
  int _currentImageIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getImageUrl(String imagePath) {
    // Use ApiEndpoints.localNetworkAddress for the base URL
    return '${ApiEndpoints.localNetworkAddress}/$imagePath';
  }

  Widget _buildImageCarousel() {
    if (widget.property.images.isEmpty) {
      return Container(
        width: 100,
        height: 100,
        color: Colors.grey[300],
        child: const Icon(Icons.home, size: 40, color: Colors.grey),
      );
    }
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.property.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final imageUrl = _getImageUrl(widget.property.images[index]);
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
                  memCacheWidth: 200,
                  memCacheHeight: 200,
                  placeholder: (context, url) {
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
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 20,
                      ),
                    );
                  },
                ),
              );
            },
          ),
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
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: widget.onRemove,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
