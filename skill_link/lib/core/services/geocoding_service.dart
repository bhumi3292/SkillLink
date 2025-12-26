import 'package:geocoding/geocoding.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart' as osm;

class GeocodingService {
  /// Convert Address string to GeoPoint
  Future<osm.GeoPoint?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return osm.GeoPoint(
          latitude: locations.first.latitude,
          longitude: locations.first.longitude,
        );
      }
    } catch (e) {
      print('GeocodingService Error: $e');
    }
    return null;
  }

  /// Convert GeoPoint to Address string
  Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return "${place.street}, ${place.locality}, ${place.country}";
      }
    } catch (e) {
      print('GeocodingService Error: $e');
    }
    return null;
  }
}
