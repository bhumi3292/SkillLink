import 'package:skill_link/features/explore/presentation/view/worker_detail_page.dart';
import 'package:flutter/material.dart';
import '../../domain/entity/favourite_item.dart';
import 'package:skill_link/features/explore/domain/entity/explore_worker_entity.dart';

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
                (context) => WorkerDetailPage(
                  worker: ExploreWorkerEntity(
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
