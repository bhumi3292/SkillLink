import 'package:flutter/material.dart';
import 'package:skill_link/features/favourite/domain/entity/cart/cart_item_entity.dart';
import 'package:skill_link/cores/utils/image_url_helper.dart';
import 'package:skill_link/features/explore/presentation/view/property_detail_page.dart';
import 'package:skill_link/features/explore/presentation/utils/property_converter.dart';

class CartItemWidget extends StatelessWidget {
  final CartItemEntity cartItem;
  final VoidCallback onRemove;

  const CartItemWidget({
    super.key,
    required this.cartItem,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final property = cartItem.property;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          final exploreProperty = PropertyConverter.fromPropertyEntity(
            property,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PropertyDetailPage(property: exploreProperty),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Property Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child:
                      property.images?.isNotEmpty == true
                          ? Image.network(
                            ImageUrlHelper.constructImageUrl(
                              property.images!.first,
                            ),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.home,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              );
                            },
                          )
                          : Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.home,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                ),
              ),
              const SizedBox(width: 12),

              // Property Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.title ?? 'No Title',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF002B5B),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            property.location ?? 'No Location',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (property.bedrooms != null) ...[
                          const Icon(Icons.bed, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${property.bedrooms}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (property.bathrooms != null) ...[
                          const Icon(
                            Icons.bathroom,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${property.bathrooms}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rs. ${property.price?.toStringAsFixed(0) ?? '0'} / month',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF002B5B),
                      ),
                    ),
                  ],
                ),
              ),

              // Remove Button
              IconButton(
                onPressed: onRemove,
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 24,
                ),
                tooltip: 'Remove from favourites',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
