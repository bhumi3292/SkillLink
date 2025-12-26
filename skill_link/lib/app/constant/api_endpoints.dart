
class ApiEndpoints {
  ApiEndpoints._();

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ---------------------------------------------------------
  // CHANGE THIS IP TO YOUR BACKEND SERVER ADDRESS
  // For Android Emulator, use: http://10.0.2.2:3001
  // For iOS Simulator / Web, use: http://localhost:3001
  // For Real Devices, use your PC's IP (e.g., http://192.168.x.y:3001)
  // ---------------------------------------------------------
  static const String activeServerAddress = "http://192.168.1.6:3001";

  static String get serverAddress => activeServerAddress;

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
  static String get createWorker => "${baseUrl}workers";
  static String get getAllWorkers => "${baseUrl}workers";
  static String get getWorkerById => "${baseUrl}workers/";
  static String get deleteWorker => "${baseUrl}workers/";

  // Aliases for compatibility
  static String get createProperty => createWorker;
  static String get getAllProperties => getAllWorkers;
  static String get getPropertyById => getWorkerById;
  static String get deleteProperty => deleteWorker;

  static String updateProperty(String id) {
    return "${baseUrl}workers/$id";
  }

  // ---------- Category ----------
  static String get createCategory => "${baseUrl}category"; // POST
  static String get getAllCategories => "${baseUrl}category"; // GET
  static String get getCategoryById => "${baseUrl}category/"; // GET by ID
  static String get updateCategory => "${baseUrl}category/"; // PUT by ID
  static String get deleteCategory => "${baseUrl}category/"; // DELETE by ID

  // ---------- Cart/Favorites ----------
  static String get getCart => "${baseUrl}cart"; // GET
  static String get addToCart => "${baseUrl}cart/add"; // POST
  static String get removeFromCart =>
      "${baseUrl}cart/remove/"; // DELETE (append propertyId)
  static String get clearCart => "${baseUrl}cart/clear"; // DELETE

  // ---------- Chatbot ----------
  static String get sendChatQuery => "${baseUrl}chatbot/query"; // POST

  // --- Calendar/Booking Endpoints ---
  static String getAvailableSlots(String workerId) =>
      "${baseUrl}calendar/workers/$workerId/available-slots";
  static String get bookVisit => "${baseUrl}calendar/book-visit";
  static String get manageAvailabilities =>
      "${baseUrl}calendar/availabilities"; // POST to create/update
  static String get getworkerAvailabilities =>
      "${baseUrl}calendar/worker/availabilities";
  static String deleteAvailabilityById(String availabilityId) =>
      "${baseUrl}calendar/availabilities/$availabilityId";

  static String get getHirerBookings => "${baseUrl}calendar/hirer/bookings";
  static String get getworkerBookings => "${baseUrl}calendar/worker/bookings";
  static String updateBookingStatus(String bookingId) =>
      "${baseUrl}calendar/bookings/$bookingId/status";
  static String deleteBookingById(String bookingId) =>
      "${baseUrl}calendar/bookings/$bookingId";

  // ---------- Notifications ----------
  static String get getNotifications => "${baseUrl}notifications";
  static String markNotificationRead(String notificationId) =>
      "${baseUrl}notifications/$notificationId/read";
  static String get markAllNotificationsRead =>
      "${baseUrl}notifications/read-all";
  static String deleteNotification(String notificationId) =>
      "${baseUrl}notifications/$notificationId";
}
