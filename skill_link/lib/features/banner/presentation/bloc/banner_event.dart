abstract class BannerEvent {}

class FetchBanners extends BannerEvent {}

class CreateBanner extends BannerEvent {
  // For admin use; left minimal
}

class UpdateBanner extends BannerEvent {}

class DeleteBanner extends BannerEvent {}
