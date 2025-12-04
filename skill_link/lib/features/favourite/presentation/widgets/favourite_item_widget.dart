import 'package:flutter/material.dart';
import '../../domain/entity/favourite_item.dart';
import 'package:skill_link/features/explore/domain/entity/explore_property_entity.dart';
import 'package:skill_link/features/explore/presentation/view/property_detail_page.dart';

class FavouriteItemWidget extends StatelessWidget {
  final FavouriteItem item;
  const FavouriteItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(item.title),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => PropertyDetailPage(
                  property: ExplorePropertyEntity(
                    id: item.id,
                    title: item.title,
                  ),
                ),
          ),
        );
      },
    );
  }
}
