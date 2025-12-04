class ApiEndpoints {
  ApiEndpoints._();

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Network addresses for different environments
  static const String androidEmulatorAddress = "http://10.0.2.2:3001";
  static const String iosSimulatorAddress = "http://localhost:3001";

  static const String realDeviceAddress =
      "http://192.168.1.5:3001"; // Update this IP

  static const String localNetworkAddress = realDeviceAddress;

  static const String serverAddress = localNetworkAddress;

  static const String baseUrl = "$serverAddress/api/";
  static const String imageUrl = serverAddress;

  // ---------- Auth ----------
  static const String register = "${baseUrl}auth/register";
  static const String login = "${baseUrl}auth/login";
  static const String getCurrentUser = "${baseUrl}auth/me";

  // ---------- User ----------
  static const String updateUser = "${baseUrl}auth/update-profile";
  static const String deleteUser = "${baseUrl}user/delete/";

  // ---------- Profile ----------
  static const String uploadProfilePicture = "${baseUrl}auth/uploadImage";

  // ---------- Property ----------
  static const String createProperty = "${baseUrl}properties";
  static const String getAllProperties = "${baseUrl}properties"; // GET
  static const String getPropertyById =
      "${baseUrl}properties/"; // GET by ID (append ID)
  static const String deleteProperty =
      "${baseUrl}properties/"; // DELETE by ID (append ID)

  static String updateProperty(String id) {
    return "${baseUrl}properties/$id";
  }

  // ---------- Category ----------
  static const String createCategory = "${baseUrl}category"; // POST
  static const String getAllCategories = "${baseUrl}category"; // GET
  static const String getCategoryById = "${baseUrl}category/"; // GET by ID
  static const String updateCategory = "${baseUrl}category/"; // PUT by ID
  static const String deleteCategory = "${baseUrl}category/"; // DELETE by ID

  // ---------- Blog ----------
  static const String getAllBlogs = "${baseUrl}blogs"; // GET
  static const String getBlogById = "${baseUrl}blogs/"; // GET by ID (append ID)
  static const String createBlog = "${baseUrl}blogs"; // POST
  static const String updateBlog = "${baseUrl}blogs/"; // PUT by ID (append ID)
  static const String deleteBlog =
      "${baseUrl}blogs/"; // DELETE by ID (append ID)
  static const String likeBlog =
      "${baseUrl}blogs/"; // POST like (append ID + /like)
  static const String getFeaturedBlogs = "${baseUrl}blogs/featured"; // GET

  // ---------- Cart/Favorites ----------
  static const String getCart = "${baseUrl}cart"; // GET
  static const String addToCart = "${baseUrl}cart/add"; // POST
  static const String removeFromCart =
      "${baseUrl}cart/remove/"; // DELETE (append propertyId)
  static const String clearCart = "${baseUrl}cart/clear"; // DELETE

  // ---------- Chatbot ----------
  static const String sendChatQuery = "${baseUrl}chatbot/query"; // POST

  // --- Calendar/Booking Endpoints ---
  static String getAvailableSlots(String propertyId) =>
      "${baseUrl}calendar/properties/$propertyId/available-slots";
  static const String bookVisit = "${baseUrl}calendar/book-visit";
  static const String manageAvailabilities =
      "${baseUrl}calendar/availabilities"; // POST to create/update
  static const String getworkerAvailabilities =
      "${baseUrl}calendar/worker/availabilities";
  static String deleteAvailabilityById(String availabilityId) =>
      "${baseUrl}calendar/availabilities/$availabilityId";

  static const String getHirerBookings = "${baseUrl}calendar/Hirer/bookings";
  static const String getworkerBookings = "${baseUrl}calendar/worker/bookings";
  static String updateBookingStatus(String bookingId) =>
      "${baseUrl}calendar/bookings/$bookingId/status";
  static String deleteBookingById(String bookingId) =>
      "${baseUrl}calendar/bookings/$bookingId";
}
