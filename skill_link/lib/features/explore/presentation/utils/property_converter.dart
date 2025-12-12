import 'package:skill_link/features/explore/domain/entity/explore_property_entity.dart';
import 'package:skill_link/features/add_worker/data/model/worker_model/worker_api_model.dart';
import 'package:skill_link/features/add_worker/domain/entity/worker/worker_entity.dart';

class PropertyConverter {
  /// Convert WorkerApiModel to ExplorePropertyEntity
  static ExplorePropertyEntity fromApiModel(WorkerApiModel apiModel) {
    return ExplorePropertyEntity(
      id: apiModel.id,
      images: apiModel.images,
      videos: apiModel.videos,
      title: apiModel.title,
      location: apiModel.location,
      categoryId: apiModel.categoryId,
      categoryName: null, // API model doesn't have category name
      price: apiModel.price,
      description: apiModel.description,
      workerId: apiModel.workerId,
      workerName:
          'worker ID: ${apiModel.workerId}', // Show worker ID as reference
      workerPhone: null,
      workerEmail: null,
    );
  }

  /// Convert PropertyEntity to ExplorePropertyEntity
  static ExplorePropertyEntity fromPropertyEntity(WorkerEntity propertyEntity) {
    return ExplorePropertyEntity(
      id: propertyEntity.id,
      images: propertyEntity.images,
      videos: propertyEntity.videos,
      title: propertyEntity.name,
      location: propertyEntity.location,
      bedrooms: null,
      bathrooms: null,
      categoryId: propertyEntity.categoryId,
      // Use primarySkill as categoryName for display in explore
      categoryName: propertyEntity.primarySkill,
      price: propertyEntity.price,
      description: propertyEntity.description,
      workerId: propertyEntity.workerId,
      workerName:
          propertyEntity.name ?? 'worker ID: ${propertyEntity.workerId}',
      workerPhone: null,
      workerEmail: null,
    );
  }
}
