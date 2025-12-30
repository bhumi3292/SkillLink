import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_link/features/banner/presentation/bloc/banner_bloc.dart';
import 'package:skill_link/features/banner/presentation/bloc/banner_event.dart';
import 'package:skill_link/features/banner/presentation/bloc/banner_state.dart';
import 'package:skill_link/app/constant/api_endpoints.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  PageController _controller = PageController(viewportFraction: 0.95);
  int _index = 0;

  @override
  void initState() {
    super.initState();
    context.read<BannerBloc>().add(FetchBanners());
    // Auto-scroll
    Future.delayed(const Duration(seconds: 4), _autoScroll);
  }

  void _autoScroll() async {
    if (!mounted) return;
    final state = context.read<BannerBloc>().state;
    if (state is BannerLoaded && state.banners.isNotEmpty) {
      final next = (_index + 1) % state.banners.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      setState(() => _index = next);
    }
    Future.delayed(const Duration(seconds: 4), _autoScroll);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: BlocBuilder<BannerBloc, BannerState>(
        builder: (context, state) {
          if (state is BannerLoading)
            return const Center(child: CircularProgressIndicator());
          if (state is BannerError)
            return Center(child: Text('Error loading banners'));
          if (state is BannerLoaded) {
            final banners = state.banners;
            if (banners.isEmpty) return const SizedBox.shrink();
            return PageView.builder(
              controller: _controller,
              itemCount: banners.length,
              itemBuilder: (context, index) {
                final b = banners[index];
                final fullUrl =
                    b.imageUrl.startsWith('http')
                        ? b.imageUrl
                        : '${ApiEndpoints.imageUrl}${b.imageUrl}';
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onTap: () => _onTapBanner(b.targetType, b.targetValue),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: fullUrl,
                        fit: BoxFit.cover,
                        placeholder:
                            (c, u) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        errorWidget:
                            (c, u, e) => const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _onTapBanner(String targetType, String? targetValue) {
    if (targetType == 'externalLink' && targetValue != null) {
      // open external link
      // Keeping minimal: use url_launcher if available; otherwise do nothing
    } else if (targetType == 'category' && targetValue != null) {
      // navigate to category page
    } else if (targetType == 'workerList' && targetValue != null) {
      // navigate to worker list filtered by targetValue
    }
  }
}
