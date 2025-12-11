import 'package:skill_link/features/add_worker/data/model/property_model/property_api_model.dart';

abstract class DashboardRepository {
  Future<List<PropertyApiModel>> getDashboardProperties();
}
