import 'package:skill_link/features/add_worker/data/model/worker_model/worker_api_model.dart';

abstract class DashboardRepository {
  Future<List<WorkerApiModel>> getDashboardProperties();
}
