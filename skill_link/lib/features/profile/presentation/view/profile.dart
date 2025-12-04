import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_link/features/auth/domain/entity/user_entity.dart';
import 'package:skill_link/cores/common/snackbar/snackbar.dart';
import 'package:image_picker/image_picker.dart'; // For image picking
import 'dart:io'; // For File
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image/image.dart' as img; // For image processing
import 'package:path_provider/path_provider.dart'; // For getTemporaryDirectory
import 'package:sensors_plus/sensors_plus.dart'; // For accelerometer
import 'dart:async'; // For Timer
import 'package:flutter/foundation.dart';

// Imports for your Profile BLoC
import 'package:skill_link/features/profile/presentation/view_model/profile_event.dart';
import 'package:skill_link/features/profile/presentation/view_model/profile_state.dart';
import 'package:skill_link/features/profile/presentation/view_model/profile_view_model.dart';

// Import CartBloc for favourites count
import 'package:skill_link/features/favourite/presentation/bloc/cart_bloc.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';
import '../../../../app/constant/api_endpoints.dart';
import 'edit_profile_page.dart';
// Add import for HelpSupportPage
import 'package:skill_link/features/profile/presentation/view/help_support_page.dart';
// Add import for SettingPage
import 'package:skill_link/features/profile/presentation/view/setting_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker(); // Initialize ImagePicker
  late CartBloc _cartBloc;

  // Accelerometer variables for global logout
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  bool _hasTurnedLeft = false;
  bool _hasTurnedRight = false;
  Timer? _resetTimer;
  static const double _threshold = 7.0; // Sensitivity
  static const int _resetSeconds = 3;

  @override
  void initState() {
    super.initState();
    _cartBloc = serviceLocator<CartBloc>();
    _cartBloc.add(GetCartEvent());
    
    // Fetch user profile on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().add(FetchUserProfileEvent(context: context));
    });

    // Start listening to accelerometer for global logout
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      _detectTilt(event.x);
    });
  }

  void _detectTilt(double x) {
    if (!_hasTurnedLeft && x < -_threshold) {
      _hasTurnedLeft = true;
      _showGestureFeedback('Left tilt detected!');
      _resetTimer?.cancel();
      _resetTimer = Timer(const Duration(seconds: _resetSeconds), _resetGesture);
      return;
    }
    if (_hasTurnedLeft && !_hasTurnedRight && x > _threshold) {
      _hasTurnedRight = true;
      _showGestureFeedback('Right tilt detected! Logging out...');
      _performLogout();
    }
  }

  void _showGestureFeedback(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
      );
    }
  }

  void _resetGesture() {
    _hasTurnedLeft = false;
    _hasTurnedRight = false;
  }

  void _performLogout() {
    _resetGesture();
    _resetTimer?.cancel();
    context.read<ProfileViewModel>().add(LogoutEvent(context: context));
  }

  // --- Image Picker Functionality ---
  Future<void> _showImagePickerDialog(BuildContext context) async {
    if (!mounted) return;

    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Choose Photo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Supported formats: JPEG, PNG, GIF, HEIC, WebP',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildImageOption(
                        icon: Icons.photo_library,
                        title: 'Gallery',
                        subtitle: 'Choose from gallery',
                        onTap: () {
                          Navigator.of(bc).pop();
                          _pickImage(ImageSource.gallery, context);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildImageOption(
                        icon: Icons.camera_alt,
                        title: 'Camera',
                        subtitle: 'Take a photo',
                        onTap: () {
                          Navigator.of(bc).pop();
                          _pickImage(ImageSource.camera, context);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // Method to pick image from chosen source (gallery or camera)
  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85, // Reduce quality to reduce file size
        maxWidth: 800, // Limit width
        maxHeight: 800, // Limit height
      );
      
      if (!mounted) return; // Check mounted after async operation

      if (pickedFile != null) {
        try {
          // Validate and convert image if needed
          final File processedImage = await _processImage(File(pickedFile.path));
          
          // Clear the current profile image cache before uploading new one
          await _clearProfileImageCache();
          
          context.read<ProfileViewModel>().add(
            UploadProfilePictureEvent(imageFile: processedImage, context: context),
          );
        } catch (e) {
          if (!mounted) return;
          showMySnackbar(
            context: context,
            content: e.toString(),
            isSuccess: false,
          );
        }
      } else {
        showMySnackbar(
          context: context,
          content: 'Image picking cancelled.',
          isSuccess: false,
        );
      }
    } catch (e) {
      if (!mounted) return; // Check mounted after async operation

      showMySnackbar(
        context: context,
        content: 'Failed to pick image: ${e.toString()}',
        isSuccess: false,
      );
    }
  }

  // Method to process and validate image
  Future<File> _processImage(File imageFile) async {
    try {
      // Check file extension
      final String extension = imageFile.path.split('.').last.toLowerCase();
      final List<String> supportedFormats = ['jpg', 'jpeg', 'png', 'gif', 'heic', 'webp'];
      
      if (!supportedFormats.contains(extension)) {
        throw Exception('Unsupported image format. Please select JPEG, PNG, GIF, HEIC, or WebP image.');
      }
      
      // Read the image
      final List<int> imageBytes = await imageFile.readAsBytes();
      
      // Convert to Uint8List for image processing
      final Uint8List imageData = Uint8List.fromList(imageBytes);
      
      // Decode the image
      final img.Image? originalImage = img.decodeImage(imageData);
      
      if (originalImage == null) {
        throw Exception('Failed to decode image. Please try another image.');
      }
      
      // Resize image if it's too large
      img.Image resizedImage = originalImage;
      if (originalImage.width > 800 || originalImage.height > 800) {
        resizedImage = img.copyResize(originalImage, width: 800, height: 800);
      }
      
      // Convert to JPEG format for consistency
      final List<int> jpegBytes = img.encodeJpg(resizedImage, quality: 85);
      
      // Create a temporary file with proper JPEG extension
      final String tempDir = (await getTemporaryDirectory()).path;
      final String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String tempPath = '$tempDir/$fileName';
      final File processedFile = File(tempPath);
      
      // Write the processed image
      await processedFile.writeAsBytes(jpegBytes);
      
      // Verify the file was created and has the correct extension
      if (!await processedFile.exists()) {
        throw Exception('Failed to create processed image file.');
      }
      
      print('DEBUG: Processed image path: ${processedFile.path}');
      print('DEBUG: Processed image extension: ${processedFile.path.split('.').last}');
      print('DEBUG: Processed image size: ${await processedFile.length()} bytes');
      
      return processedFile;
    } catch (e) {
      print('Error processing image: $e');
      // If processing fails, return the original file
      return imageFile;
    }
  }

  // Method to clear profile image cache
  Future<void> _clearProfileImageCache() async {
    try {
      final user = context.read<ProfileViewModel>().state.user;
      if (user?.profilePicture != null && user!.profilePicture!.isNotEmpty) {
        // Corrected line for imageUrl
        final imageUrl = '${ApiEndpoints.localNetworkAddress}${user.profilePicture}';

        await DefaultCacheManager().removeFile(imageUrl);
        print('Cleared cache for image: $imageUrl'); // Added for debugging
      } else {
        print('No profile picture found for user or path is empty. Cache not cleared.');
      }
    } catch (e) {
      print('Error clearing image cache: $e');
    }
  }
  // --- End Image Picker Functionality ---

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cartBloc,
      child: BlocListener<ProfileViewModel, ProfileState>(
        listenWhen: (previous, current) => previous.isLogoutSuccess != current.isLogoutSuccess,
        listener: (context, state) {
          if (state.isLogoutSuccess) {
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text('Profile'),
            centerTitle: true,
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [

            ],
          ),
          body: BlocConsumer<ProfileViewModel, ProfileState>(
            listener: (context, state) {
              if (state.errorMessage != null && !state.isLoading) {
                if (mounted) {
                  showMySnackbar(context: context, content: state.errorMessage!, isSuccess: false);
                }
              }
              if (!state.isUploadingImage && state.successMessage != null && state.successMessage!.contains('Profile picture updated')) {
                if (mounted) {
                  showMySnackbar(
                    context: context,
                    content: 'Profile picture updated successfully!',
                    isSuccess: true,
                  );
                  // The view model will automatically refresh the user data
                }
              }
            },
            builder: (context, state) {
              print("Profile page - Building with state. User: ${state.user?.fullName}, isLoading: ${state.isLoading}"); // Debug print
              if (state.isLoading && state.user == null) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.errorMessage != null && state.user == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 50),
                        const SizedBox(height: 10),
                        Text(
                          state.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            context.read<ProfileViewModel>().add(FetchUserProfileEvent(context: context));
                          },
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final UserEntity? user = state.user;
              print("Profile page - Current user: ${user?.fullName}, email: ${user?.email}"); // Debug print

              if (user == null) {
                return const Center(
                  child: Text("No profile data available. Please log in."),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Profile Header Section
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            // Profile Picture
                            GestureDetector(
                              onTap: () => _showImagePickerDialog(context),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 4),
                                    ),
                                    child: user.profilePicture != null && user.profilePicture!.isNotEmpty
                                        ? ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl: '${ApiEndpoints.localNetworkAddress}${user.profilePicture}',
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => Container(
                                                width: 100,
                                                height: 100,
                                                color: Colors.grey[300],
                                                child: const Icon(Icons.person, size: 50, color: Colors.white),
                                              ),
                                              errorWidget: (context, url, error) => Container(
                                                width: 100,
                                                height: 100,
                                                color: Colors.grey[300],
                                                child: const Icon(Icons.person, size: 50, color: Colors.white),
                                              ),
                                            ),
                                          )
                                        : CircleAvatar(
                                            radius: 50,
                                            backgroundColor: Colors.grey[300],
                                            child: const Icon(Icons.person, size: 50, color: Colors.white),
                                          ),
                                  ),
                                  if (state.isUploadingImage)
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                      child: const CircularProgressIndicator(color: Colors.white),
                                    ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: Theme.of(context).primaryColor,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // User Info
                            Text(
                              user.fullName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            if (user.stakeholder != null && user.stakeholder!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  user.stakeholder!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),

                    // Profile Stats Section
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: BlocBuilder<CartBloc, CartState>(
                              builder: (context, cartState) {
                                int favouritesCount = 0;
                                if (cartState is CartLoaded) {
                                  favouritesCount = cartState.cart.items?.length ?? 0;
                                }
                                return _buildStatCard(
                                  icon: Icons.favorite,
                                  title: 'Favourites',
                                  value: favouritesCount.toString(),
                                  color: Colors.red,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.visibility,
                              title: 'Profile Views',
                              value: '156',
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.star,
                              title: 'Rating',
                              value: '4.8',
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Menu Options Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Account Settings',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildMenuItem(
                                  icon: Icons.person_outline,
                                  title: 'Edit Profile',
                                  subtitle: 'Update your personal information',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditProfilePage(user: user),
                                      ),
                                    ).then((updated) {
                                      print("Profile page - Navigation returned with updated: $updated"); // Debug print
                                      // Refresh user data if profile was updated
                                      if (updated == true) {
                                        print("Profile page - Triggering FetchUserProfileEvent"); // Debug print
                                        context.read<ProfileViewModel>().add(
                                          FetchUserProfileEvent(context: context),
                                        );
                                      }
                                    });
                                  },
                                ),
                                _buildDivider(),
                                _buildMenuItem(
                                  icon: Icons.settings,
                                  title: 'Settings',
                                  subtitle: 'App preferences and notifications',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const SettingPage(),
                                      ),
                                    );
                                  },
                                ),
                                _buildDivider(),
                                _buildMenuItem(
                                  icon: Icons.payment,
                                  title: 'Payments',
                                  subtitle: 'Manage payment methods',
                                  onTap: () {
                                    showMySnackbar(context: context, content: "Payments tapped!", isSuccess: true);
                                  },
                                ),
                                _buildDivider(),
                                _buildMenuItem(
                                  icon: Icons.receipt_long,
                                  title: 'Billing Details',
                                  subtitle: 'View billing history',
                                  onTap: () {
                                    showMySnackbar(context: context, content: "Billing Details tapped!", isSuccess: true);
                                  },
                                ),
                                _buildDivider(),
                                _buildMenuItem(
                                  icon: Icons.help_outline,
                                  title: 'Help & Support',
                                  subtitle: 'Get help and contact support',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const HelpSupportPage(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // REMOVE AccelerometerLogoutWidget and replace with a standard logout ListTile
                          ListTile(
                            leading: Icon(Icons.logout, color: Colors.red),
                            title: Text('Logout', style: TextStyle(color: Colors.red)),
                            subtitle: Text('Logout from your account'),
                            onTap: () async {
                              final shouldLogout = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirm Logout'),
                                  content: const Text('Are you sure you want to logout?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text('Logout'),
                                    ),
                                  ],
                                ),
                              );
                              if (shouldLogout == true) {
                                // Dispatch logout event
                                context.read<ProfileViewModel>().add(LogoutEvent(context: context));
                              }
                            },
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isLogout = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isLogout ? Colors.red.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isLogout ? Colors.red : Colors.grey[700],
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isLogout ? Colors.red : Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: isLogout ? Colors.red : Colors.grey[400],
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 56, right: 16),
      child: Divider(color: Colors.grey[200], height: 1),
    );
  }



  @override
  void dispose() {
    _cartBloc.close();
    _accelerometerSubscription?.cancel();
    _resetTimer?.cancel();
    super.dispose();
  }
}