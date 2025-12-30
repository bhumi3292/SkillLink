import 'package:skill_link/features/banner/data/data_source/banner_remote_datasource.dart';
import 'package:skill_link/features/banner/data/models/banner_model.dart';

abstract class IBannerRepository {
  Future<List<BannerModel>> fetchActiveBanners();
  // Admin operations
  Future<List<BannerModel>> fetchAdminBanners();
  Future<BannerModel> createBanner({
    required Map<String, dynamic> body,
    dynamic image,
  });
  Future<BannerModel> updateBanner({
    required String id,
    required Map<String, dynamic> body,
    dynamic image,
  });
  Future<void> deleteBanner(String id);
}

class BannerRepositoryImpl implements IBannerRepository {
  final BannerRemoteDatasource remoteDatasource;

  BannerRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<BannerModel>> fetchActiveBanners() =>
      remoteDatasource.fetchActiveBanners();

  @override
  Future<List<BannerModel>> fetchAdminBanners() =>
      remoteDatasource.fetchAdminBanners();

  @override
  Future<BannerModel> createBanner({
    required Map<String, dynamic> body,
    image,
  }) => remoteDatasource.createBanner(body: body, image: image);

  @override
  Future<BannerModel> updateBanner({
    required String id,
    required Map<String, dynamic> body,
    image,
  }) => remoteDatasource.updateBanner(id: id, body: body, image: image);

  @override
  Future<void> deleteBanner(String id) => remoteDatasource.deleteBanner(id);
}
