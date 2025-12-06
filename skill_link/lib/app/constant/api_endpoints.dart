import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

class ApiEndpoints {
  ApiEndpoints._();

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Network addresses for different environments (keep as constants)
  static const String androidEmulatorAddress = "http://10.0.2.2:3001";
  static const String iosSimulatorAddress = "http://localhost:3001";

  // Default LAN address for real devices — update this if your PC IP changes
  static const String realDeviceAddress = "http://192.168.1.13:3001";

  // Runtime-resolved server address. Chooses the correct host for the
  // current platform (Android emulator, iOS simulator, web, or a real device).
  static String get serverAddress {
    if (kIsWeb) return iosSimulatorAddress;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return androidEmulatorAddress;
      case TargetPlatform.iOS:
        return iosSimulatorAddress;
      default:
        return realDeviceAddress;
    }
  }

  // Backwards-compatible alias used in parts of the codebase.
  static String get localNetworkAddress => serverAddress;

  static String get baseUrl => "$serverAddress/api/";
  static String get imageUrl => serverAddress;

  // ---------- Auth ----------
  static String get register => "${baseUrl}auth/register";
  static String get login => "${baseUrl}auth/login";
  static String get getCurrentUser => "${baseUrl}auth/me";

  // ---------- User ----------
  static String get updateUser => "${baseUrl}auth/update-profile";
  static String get deleteUser => "${baseUrl}user/delete/";

  // ---------- Profile ----------
  static String get uploadProfilePicture => "${baseUrl}auth/uploadImage";

  // ---------- Worker----------
  static String get createWorker => "${baseUrl}properties";
  // Backwards-compatible aliases for older code that still refers to "Property" endpoints
  static String get createProperty => createWorker;
  static String get getAllProperties => "${baseUrl}properties"; // GET
  static String get getPropertyById =>
      "${baseUrl}properties/"; // GET by ID (append ID)
  static String get deleteWorker =>
      "${baseUrl}properties/"; // DELETE by ID (append ID)
  static String get deleteProperty => deleteWorker;

  static String updateProperty(String id) {
    return "${baseUrl}properties/$id";
  }

  // ---------- Category ----------
  static String get createCategory => "${baseUrl}category"; // POST
  static String get getAllCategories => "${baseUrl}category"; // GET
  static String get getCategoryById => "${baseUrl}category/"; // GET by ID
  static String get updateCategory => "${baseUrl}category/"; // PUT by ID
  static String get deleteCategory => "${baseUrl}category/"; // DELETE by ID

  // ---------- Blog ----------
  static String get getAllBlogs => "${baseUrl}blogs"; // GET
  static String get getBlogById => "${baseUrl}blogs/"; // GET by ID (append ID)
  static String get createBlog => "${baseUrl}blogs"; // POST
  static String get updateBlog => "${baseUrl}blogs/"; // PUT by ID (append ID)
  static String get deleteBlog =>
      "${baseUrl}blogs/"; // DELETE by ID (append ID)
  static String get likeBlog =>
      "${baseUrl}blogs/"; // POST like (append ID + /like)
  static String get getFeaturedBlogs => "${baseUrl}blogs/featured"; // GET

  // ---------- Cart/Favorites ----------
  static String get getCart => "${baseUrl}cart"; // GET
  static String get addToCart => "${baseUrl}cart/add"; // POST
  static String get removeFromCart =>
      "${baseUrl}cart/remove/"; // DELETE (append propertyId)
  static String get clearCart => "${baseUrl}cart/clear"; // DELETE

  // ---------- Chatbot ----------
  static String get sendChatQuery => "${baseUrl}chatbot/query"; // POST

  // --- Calendar/Booking Endpoints ---
  static String getAvailableSlots(String propertyId) =>
      "${baseUrl}calendar/properties/$propertyId/available-slots";
  static String get bookVisit => "${baseUrl}calendar/book-visit";
  static String get manageAvailabilities =>
      "${baseUrl}calendar/availabilities"; // POST to create/update
  static String get getworkerAvailabilities =>
      "${baseUrl}calendar/worker/availabilities";
  static String deleteAvailabilityById(String availabilityId) =>
      "${baseUrl}calendar/availabilities/$availabilityId";

  static String get getHirerBookings => "${baseUrl}calendar/Hirer/bookings";
  static String get getworkerBookings => "${baseUrl}calendar/worker/bookings";
  static String updateBookingStatus(String bookingId) =>
      "${baseUrl}calendar/bookings/$bookingId/status";
  static String deleteBookingById(String bookingId) =>
      "${baseUrl}calendar/bookings/$bookingId";
}
