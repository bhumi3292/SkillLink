import 'package:skill_link/features/dashbaord/data/data_source/remote_datasource/dashboard_remote_datasource.dart';
import 'package:skill_link/features/dashbaord/domain/repository/dashboard_repository.dart';
import 'package:skill_link/features/add_property/data/model/property_model/property_api_model.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDatasource _remoteDatasource;

  DashboardRepositoryImpl({required DashboardRemoteDatasource remoteDatasource})
    : _remoteDatasource = remoteDatasource;

  @override
  Future<List<PropertyApiModel>> getDashboardProperties() async {
    return await _remoteDatasource.getDashboardProperties();
  }
}
