// lib/cores/utils/mongo_id_converter.dart
import 'package:json_annotation/json_annotation.dart';

/// A custom [JsonConverter] to handle MongoDB's '_id' field,
/// which often comes as an object like `{"$oid": "some_id_string"}`.
class MongoIdConverter implements JsonConverter<String?, Object?> {
  const MongoIdConverter();

  @override
  String? fromJson(Object? json) {
    if (json == null) {
      return null;
    }
    // If the _id is directly a String (e.g., in some test environments or if backend normalizes)
    if (json is String) {
      return json;
    }
    // If _id is an object like {"$oid": "value"}
    if (json is Map<String, dynamic> && json.containsKey('\$oid')) {
      return json['\$oid'] as String?;
    }
    // Handle other unexpected types or throw an error
    throw FormatException('Unexpected type for _id field: ${json.runtimeType}');
  }

  @override
  Object? toJson(String? object) {
    if (object == null) return null;
    // When sending back to the backend, you might need to convert it back to {"$oid": "value"}
    // if the backend expects it this way for updates or other operations.
    // For simple cases, sending just the string is often acceptable for updates.
    // For now, let's assume the backend expects the $oid object for consistency.
    return {'\$oid': object};
  }
}