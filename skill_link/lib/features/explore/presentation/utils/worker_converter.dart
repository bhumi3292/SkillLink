import 'package:skill_link/features/explore/domain/entity/explore_worker_entity.dart';
import 'package:skill_link/features/add_worker/data/model/worker_model/worker_api_model.dart';
import 'package:skill_link/features/add_worker/domain/entity/worker/worker_entity.dart';

class WorkerConverter {
  /// Convert WorkerApiModel to ExploreWorkerEntity
  static ExploreWorkerEntity fromApiModel(WorkerApiModel apiModel) {
    return ExploreWorkerEntity(
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

  /// Convert WorkerEntity to ExploreWorkerEntity
  static ExploreWorkerEntity fromWorkerEntity(WorkerEntity workerEntity) {
    return ExploreWorkerEntity(
      id: workerEntity.id,
      images: workerEntity.images,
      videos: workerEntity.videos,
      title: workerEntity.name,
      location: workerEntity.location,
      categoryId: workerEntity.categoryId,
      // Use primarySkill as categoryName for display in explore
      categoryName: workerEntity.primarySkill,
      price: workerEntity.price,
      description: workerEntity.description,
      workerId: workerEntity.workerId,
      workerName: workerEntity.name ?? 'worker ID: ${workerEntity.workerId}',
      workerPhone: null,
      workerEmail: null,
    );
  }

  /// Convert ExploreWorkerEntity back to WorkerApiModel for UI widgets that expect the API model
  static WorkerApiModel toApiModel(ExploreWorkerEntity explore) {
    return WorkerApiModel(
      id: explore.id,
      images: explore.images ?? [],
      videos: explore.videos,
      title: explore.title ?? '',
      location: explore.location ?? '',
      categoryId: explore.categoryId ?? '',
      price: explore.price ?? 0.0,
      description: explore.description,
      workerId: explore.workerId ?? '',
      createdAt: null,
      updatedAt: null,
    );
  }
}
