
class ErrorMessageHelper {
  static String getFriendlyMessage(Object error) {
    String message = error.toString();
    
    // Check if it's a map or internal exception structure first
    // (This part depends on your specific Failure structure toString)

    // Remove common prefixes
    if (message.startsWith("Exception: ")) {
      message = message.substring(11);
    }
    if (message.startsWith("DioException [bad response]: ")) {
       // Often the response body is in the message or we need to parse it differently
       // But for simple string cleaning:
       message = message.replaceAll("DioException [bad response]: ", "");
    }
    if (message.contains("DioException")) {
       // Generic Network Error
       return "Network connection error. Please check your internet.";
    }

    // Remove "Error: " prefix
    if (message.startsWith("Error: ")) {
      message = message.substring(7);
    }

    // Clean up typical JSON-like errors if they leak through
    if (message.contains("message")) {
       // Attempt to extract if it looks like { success: false, message: "..." }
       // This is a naive regex or substring approach
       final regExp = RegExp(r'message:\s*"?([^"}]+)"?');
       final match = regExp.firstMatch(message);
       if (match != null) {
         return match.group(1) ?? message;
       }
    }

    return message;
  }
}
