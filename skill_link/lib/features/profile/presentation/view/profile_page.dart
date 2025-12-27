import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';
import 'package:skill_link/cores/utils/image_url_helper.dart';
import 'package:skill_link/features/auth/presentation/view/login.dart';
import 'package:skill_link/features/profile/presentation/view_model/profile_event.dart';
import 'package:skill_link/features/profile/presentation/view_model/profile_state.dart';
import 'package:skill_link/features/profile/presentation/view_model/profile_view_model.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<ProfileViewModel>()..add(FetchUserProfileEvent(context: context)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F8FB),
        body: BlocConsumer<ProfileViewModel, ProfileState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
            if (state.isLogoutSuccess) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const Login()),
                (route) => false,
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            final user = state.user;
            if (user == null) {
               return const Center(child: Text("User not found"));
            }

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200.0,
                  pinned: true,
                  backgroundColor: const Color(0xFF003366),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF003366), Color(0xFF0055A4)],
                        ),
                      ),
                      child: Center(
                         child: Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             const SizedBox(height: 30),
                             CircleAvatar(
                               radius: 50,
                               backgroundColor: Colors.white,
                               child: CircleAvatar(
                                 radius: 46,
                                 backgroundImage: user.profilePicture != null
                                     ? NetworkImage(ImageUrlHelper.constructImageUrl(user.profilePicture!))
                                     : null,
                                 child: user.profilePicture == null
                                     ? const Icon(Icons.person, size: 50, color: Colors.grey)
                                     : null,
                               ),
                             ),
                             const SizedBox(height: 10),
                             Text(
                               user.fullName,
                               style: const TextStyle(
                                 fontSize: 22,
                                 fontWeight: FontWeight.bold,
                                 color: Colors.white,
                               ),
                             ),
                           ],
                         ),
                      ),
                    ),
                  ),
                  actions: [
                     IconButton(
                       icon: const Icon(Icons.logout, color: Colors.white),
                       onPressed: () {
                         context.read<ProfileViewModel>().add(LogoutEvent(context: context));
                       },
                     ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Rating Card - Only display if user has rating data
                        if (user.averageRating != null || user.numReviews != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    const Text(
                                      "Average Rating",
                                      style: TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Text(
                                          (user.averageRating ?? 0.0).toStringAsFixed(1),
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF003366),
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        const Icon(Icons.star, color: Colors.amber, size: 24),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(width: 1, height: 40, color: Colors.grey[300]),
                                Column(
                                  children: [
                                    const Text(
                                      "Total Reviews",
                                      style: TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      (user.numReviews ?? 0).toString(),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF003366),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                        // Contact Info
                         _buildInfoTile(Icons.email, "Email", user.email),
                         if (user.phoneNumber != null)
                            _buildInfoTile(Icons.phone, "Phone", user.phoneNumber!),
                         if (user.location != null)
                             _buildInfoTile(Icons.location_on, "Location", "Lat: ${user.location!.latitude.toStringAsFixed(2)}, Lng: ${user.location!.longitude.toStringAsFixed(2)}"),
                         
                         const SizedBox(height: 20),
                         
                         ElevatedButton(
                           onPressed: () {
                             // Navigate to edit profile or similar
                           },
                           style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF003366),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                           ),
                           child: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
                         ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
         boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF003366).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF003366), size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}