import 'package:skill_link/app/constant/api_endpoints.dart';

class ImageUrlHelper {
  /// Constructs a full URL for an image, using ApiEndpoints.imageUrl as the base.
  ///
  /// - [imagePath]: The relative or absolute path of the image.
  ///                Examples: 'uploads/profile/my_pic.jpg', '/uploads/property/house1.jpg',
  ///                'http://example.com/some_image.png'
  ///
  /// If [imagePath] is null, empty, or cannot form a valid URL,
  /// it returns a generic placeholder URL.
  static String constructImageUrl(String? imagePath) {
    // For debugging, useful to see what paths are being processed
    print('DEBUG: ImageUrlHelper - Original path received: $imagePath');

    // 1. Handle null or empty image paths gracefully
    if (imagePath == null || imagePath.isEmpty) {
      print('DEBUG: ImageUrlHelper - Path is null or empty. Returning placeholder.');
      // You might want to return a local asset placeholder here instead
      // e.g., 'assets/images/placeholder_profile.png' or 'assets/images/placeholder_property.png'
      return 'https://via.placeholder.com/150';
    }

    // 2. If the path is already a full absolute URL, return it directly.
    // This is important for external images or if your backend sometimes provides full URLs.
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      print('DEBUG: ImageUrlHelper - Path is already a full URL. Returning as is: $imagePath');
      return imagePath;
    }

    // 3. Use the base URL defined in ApiEndpoints.
    // ApiEndpoints.imageUrl is designed to be the base for all your backend-served images.
    final String baseServerUrl = ApiEndpoints.imageUrl;
    print('DEBUG: ImageUrlHelper - Base Server URL from ApiEndpoints: $baseServerUrl');

    // 4. Normalize the relative image path:
    //    a. Replace any backslashes with forward slashes (common issue with Windows-based servers).
    //    b. Remove any leading slashes from the imagePath to avoid double slashes when joining.
    //       Example: 'uploads/image.jpg' or '/uploads/image.jpg' both become 'uploads/image.jpg'
    String normalizedPath = imagePath.replaceAll('\\', '/');
    if (normalizedPath.startsWith('/')) {
      normalizedPath = normalizedPath.substring(1);
    }
    print('DEBUG: ImageUrlHelper - Normalized relative path: $normalizedPath');

    // 5. Construct the final URL using Uri.parse for robustness.
    // This handles proper joining of base URL and path segment, including trailing/leading slashes.
    try {
      final Uri baseUri = Uri.parse(baseServerUrl);
      final Uri fullUri = baseUri.resolve(normalizedPath); // Use resolve to intelligently combine paths

      print('DEBUG: ImageUrlHelper - Final constructed URL: ${fullUri.toString()}');
      return fullUri.toString();
    } catch (e) {
      print('ERROR: ImageUrlHelper - Failed to construct URL for path "$imagePath". Error: $e');
      return 'https://via.placeholder.com/150'; // Return placeholder on error
    }
  }
}