class ApiEndpoints {
  ApiEndpoints._();

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String serverIp = "192.168.1.7";

  static const String baseUrl = "http://$serverIp:3001/api/";
  static const String imageUrl = "http://$serverIp:3001";

  // ---------- Auth ----------
  static String get register => "${baseUrl}auth/register";
  static String get login => "${baseUrl}auth/login";
  static String get getCurrentUser => "${baseUrl}auth/me";

  // ---------- User ----------
  static String get updateUser => "${baseUrl}auth/update-profile";
  static String get updateNotificationPreferences =>
      "${baseUrl}auth/update-notification-preferences";
  static String deleteUser(String id) => "${baseUrl}user/delete/$id";

  // ---------- Profile ----------
  static String get uploadProfilePicture => "${baseUrl}auth/uploadImage";

  // ---------- Worker ----------
  static String get createWorker => "${baseUrl}workers";
  static String get getAllWorkers => "${baseUrl}workers";
  static String get getNearbyWorkers => "${baseUrl}workers/nearby";
  static String getWorkerById(String id) => "${baseUrl}workers/$id";
  static String deleteWorker(String id) => "${baseUrl}workers/$id";

  // Aliases for backward compatibility
  static String get getAllProperties => getAllWorkers;

  static String updateWorker(String id) => "${baseUrl}workers/$id";

  // ---------- Category ----------
  static String get createCategory => "${baseUrl}category";
  static String get getAllCategories => "${baseUrl}category";
  static String getCategoryById(String id) => "${baseUrl}category/$id";
  static String updateCategory(String id) => "${baseUrl}category/$id";
  static String deleteCategory(String id) => "${baseUrl}category/$id";

  // ---------- Cart/Favorites ----------
  static String get getCart => "${baseUrl}cart";
  static String get addToCart => "${baseUrl}cart/add";
  static String removeFromCart(String workerId) =>
      "${baseUrl}cart/remove/$workerId";
  static String get clearCart => "${baseUrl}cart/clear";

  // ---------- Chatbot ----------
  static String get sendChatQuery => "${baseUrl}chatbot/query";

  // --- Calendar/Booking Endpoints ---
  static String getAvailableSlots(String workerId) =>
      "${baseUrl}calendar/workers/$workerId/available-slots";
  static String get bookVisit => "${baseUrl}calendar/book-visit";
  static String get manageAvailabilities => "${baseUrl}calendar/availabilities";
  static String get getWorkerAvailabilities =>
      "${baseUrl}calendar/worker/availabilities";
  static String deleteAvailabilityById(String availabilityId) =>
      "${baseUrl}calendar/availabilities/$availabilityId";

  static String get bookings => "${baseUrl}bookings";
  static String get getHirerBookings => "${baseUrl}calendar/hirer/bookings";
  static String get getWorkerBookings => "${baseUrl}calendar/worker/bookings";
  static String getBookingById(String bookingId) =>
      "${baseUrl}bookings/$bookingId";
  static String updateBookingStatus(String bookingId) =>
      "${baseUrl}bookings/$bookingId/status";
  static String deleteBookingById(String bookingId) =>
      "${baseUrl}bookings/$bookingId";
  static String requestReschedule(String bookingId) =>
      "${baseUrl}calendar/bookings/$bookingId/reschedule";
  static String respondReschedule(String bookingId) =>
      "${baseUrl}calendar/bookings/$bookingId/reschedule/respond";

  // ---------- Notifications ----------
  static String get getNotifications => "${baseUrl}notifications";
  static String markNotificationRead(String notificationId) =>
      "${baseUrl}notifications/$notificationId/read";
  static String get markAllNotificationsRead =>
      "${baseUrl}notifications/read-all";
  static String deleteNotification(String notificationId) =>
      "${baseUrl}notifications/$notificationId";

  // ---------- Payments ----------
  static String get initiatePayment => "${baseUrl}payments/initiate";
  static String get verifyPayment => "${baseUrl}payments/verify";
  static String getPaymentHistory(String userId) =>
      "${baseUrl}payments/history/$userId";
  static String get adminPayments => "${baseUrl}payments/all";
  static String requestRefund(String paymentId) =>
      "${baseUrl}payments/$paymentId/refund-request";
  static String adminProcessRefund(String paymentId) =>
      "${baseUrl}payments/$paymentId/refund";
  static String adminRejectRefund(String paymentId) =>
      "${baseUrl}payments/$paymentId/refund-reject";

  // ---------- Reviews ----------
  static String get submitReview => "${baseUrl}reviews/submit";
  static String getWorkerReviews(String workerListingId) =>
      "${baseUrl}reviews/worker/$workerListingId";

  // ---------- Admin Panel ----------
  static String get adminDashboardStats => "${baseUrl}admin/dashboard-stats";
  static String get adminPendingWorkers => "${baseUrl}admin/workers/pending";
  static String get adminVerifyWorker => "${baseUrl}admin/verify-worker";
  static String get adminAllUsers => "${baseUrl}admin/users";
  static String toggleUserSuspension(String userId) =>
      "${baseUrl}admin/users/$userId/toggle-suspension";
  static String get adminCategories => "${baseUrl}admin/categories";
  static String toggleCategoryStatus(String id) =>
      "${baseUrl}admin/categories/$id/toggle-status";
  static String get adminReports => "${baseUrl}admin/reports";
  static String get adminResolveReport => "${baseUrl}admin/reports/resolve";
  static String get createReport => "${baseUrl}reports";
  static String get adminAllBookings => "${baseUrl}admin/bookings";
  // ---------- Banners ----------
  static String get publicActiveBanners => "${baseUrl}banners/active";
  static String get adminBanners => "${baseUrl}admin/banners";
}
