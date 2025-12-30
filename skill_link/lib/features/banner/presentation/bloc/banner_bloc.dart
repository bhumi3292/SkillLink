import 'package:flutter_bloc/flutter_bloc.dart';
import 'banner_event.dart';
import 'banner_state.dart';
import 'package:skill_link/features/banner/data/repository/banner_repository_impl.dart';

class BannerBloc extends Bloc<BannerEvent, BannerState> {
  final IBannerRepository repository;

  BannerBloc({required this.repository}) : super(BannerLoading()) {
    on<FetchBanners>((event, emit) async {
      emit(BannerLoading());
      try {
        final banners = await repository.fetchActiveBanners();
        emit(BannerLoaded(banners));
      } catch (e) {
        emit(BannerError(e.toString()));
      }
    });
  }
}
