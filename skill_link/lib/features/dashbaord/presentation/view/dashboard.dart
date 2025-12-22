import 'package:cached_network_image/cached_network_image.dart';
import 'package:skill_link/features/favourite/presentation/bloc/cart_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_link/features/profile/presentation/view_model/profile_view_model.dart';
import 'package:skill_link/features/auth/domain/entity/user_entity.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';
import 'package:skill_link/features/dashbaord/presentation/view_model/dashboard_view_model.dart';
import 'package:skill_link/features/add_worker/data/model/worker_model/worker_api_model.dart';
import 'package:skill_link/features/dashbaord/presentation/widgets/property_card_widget.dart';
import 'package:skill_link/features/dashbaord/presentation/widgets/horizontal_property_card.dart';
import 'package:skill_link/features/explore/presentation/view/worker_detail_page.dart';
import 'package:skill_link/features/explore/presentation/utils/worker_converter.dart';
import 'package:skill_link/cores/utils/image_url_helper.dart'; // Import ImageUrlHelper here

class DashboardPage extends StatelessWidget {
  final VoidCallback? onSeeAllTap;

  const DashboardPage({super.key, this.onSeeAllTap});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileViewModel>.value(
          value: BlocProvider.of<ProfileViewModel>(context),
        ),
        BlocProvider<DashboardViewModel>(
          create:
              (context) =>
                  serviceLocator<DashboardViewModel>()..loadProperties(),
        ),
        BlocProvider<CartBloc>(create: (context) => serviceLocator<CartBloc>()),
      ],
      child: DashboardView(onSeeAllTap: onSeeAllTap),
    );
  }
}

class DashboardView extends StatelessWidget {
  final VoidCallback? onSeeAllTap;

  const DashboardView({super.key, this.onSeeAllTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FA),
        body: BlocBuilder<DashboardViewModel, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DashboardError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<DashboardViewModel>().loadProperties();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (state is DashboardLoaded) {
              return _buildDashboardContent(context, state.properties);
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    List<WorkerApiModel> properties,
  ) {
    final user = context.select<ProfileViewModel, UserEntity?>(
      (vm) => vm.state.user,
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Modern Header ---
          Container(
            padding: const EdgeInsets.only(
              top: 24,
              bottom: 32,
              left: 16,
              right: 16,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF003366),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 26,
                        backgroundImage:
                            user?.profilePicture != null &&
                                    user!.profilePicture!.isNotEmpty
                                ? CachedNetworkImageProvider(
                                  ImageUrlHelper.constructImageUrl(
                                    user.profilePicture!,
                                  ),
                                )
                                : const AssetImage('assets/images/fb.png')
                                    as ImageProvider,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome,',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                        Text(
                          user?.fullName ?? 'Guest',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Search Bar Placeholder
                GestureDetector(
                  onTap: onSeeAllTap, // Navigate to Explore
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 12),
                        const Text(
                          'Find Electrician, Plumber...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --- Horizontal Scroll: Featured/Recommended Properties ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recommended Workers",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003366),
                  ),
                ),
                TextButton(
                  onPressed: onSeeAllTap,
                  child: Text(
                    "See All",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (properties.isNotEmpty)
            SizedBox(
              height: 210,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: properties.length > 5 ? 5 : properties.length,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemBuilder: (context, index) {
                  final property = properties[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: HorizontalPropertyCard(
                      property: property,
                      onTap: () {
                        // If you have a corresponding ExploreWorkerEntity available,
                        // prefer passing that. Otherwise fallback to converting.
                        final exploreWorker =
                        // property may be a WorkerApiModel; try to avoid losing
                        // phone by checking for an existing ExploreWorkerEntity
                        // in scope — fallback to conversion.
                        WorkerConverter.fromApiModel(property);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => WorkerDetailPage(worker: exploreWorker),
                          ),
                        );
                      },
                      // REMOVED baseUrl: ApiEndpoints.imageUrl
                      // HorizontalPropertyCard no longer needs baseUrl in its constructor
                      // and ImageUrlHelper already uses ApiEndpoints internally.
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 20),

          // --- Promotional Banner ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              // It's generally better to use ImageUrlHelper for this too if it's from your backend
              // For now, keeping it as is since it's a direct external URL.
              child: CachedNetworkImage(
                // Changed to CachedNetworkImage for consistency
                imageUrl:
                    "https://thumbs.dreamstime.com/z/commercial-real-estate-banner-blue-colors-hands-smartphone-buildings-skyscrapers-cityscape-worker-searching-app-concept-186877789.jpg",
                fit: BoxFit.cover,
                width: double.infinity,
                height: 140,
                placeholder:
                    (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                errorWidget:
                    (context, error, stackTrace) => const Icon(Icons.error),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // --- Vertical List: All Properties ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: const Text(
              "All Workers",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF003366),
              ),
            ),
          ),
          Column(
            children:
                properties
                    .map(
                      (property) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: PropertyCardWidget(
                          property: property,
                          onTap: () {
                            final exploreWorker = WorkerConverter.fromApiModel(
                              property,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        WorkerDetailPage(worker: exploreWorker),
                              ),
                            );
                          },
                          showFavoriteButton: true,
                          // REMOVED baseUrl: ApiEndpoints.imageUrl
                          // PropertyCardWidget no longer needs baseUrl in its constructor
                          // and ImageUrlHelper already uses ApiEndpoints internally.
                        ),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
