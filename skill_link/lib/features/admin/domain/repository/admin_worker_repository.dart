import 'package:skill_link/cores/network/api_service.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';
import 'package:skill_link/features/explore/data/model/explore_worker_model.dart';
import 'package:skill_link/features/explore/domain/entity/explore_worker_entity.dart';

class AdminWorkerRepository {
  final ApiService _api = serviceLocator<ApiService>();

  Future<List<ExploreWorkerEntity>> getPendingWorkers() async {
    final resp = await _api.dio.get('/admin/workers/pending');
    if (resp.statusCode == 200) {
      final List data = resp.data['data'];
      return data.map((e) => ExploreWorkerModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load pending workers');
    }
  }

  Future<void> verifyWorker(
    String workerId,
    String action, {
    String? reason,
  }) async {
    final resp = await _api.dio.post(
      '/admin/verify-worker',
      data: {'workerId': workerId, 'action': action, 'rejectionReason': reason},
    );
    if (resp.statusCode != 200) {
      throw Exception('Failed to verify worker');
    }
  }
}
