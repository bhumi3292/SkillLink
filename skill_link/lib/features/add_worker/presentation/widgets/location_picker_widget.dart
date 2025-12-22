import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class LocationPickerWidget extends StatefulWidget {
  final Function(LatLng, String) onLocationPicked;

  const LocationPickerWidget({super.key, required this.onLocationPicked});

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  final MapController _mapController = MapController();
  final TextEditingController _addressController = TextEditingController();
  LatLng _center = const LatLng(27.7172, 85.3240); // Default: Kathmandu
  Timer? _debounce;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _addressController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// 1. Get current user location
  Future<void> _determinePosition() async {
    setState(() => _isLoading = true);
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoading = false);
      return;
    }

    // Check permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLoading = false);
      return;
    }

    // Get position
    try {
      Position position = await Geolocator.getCurrentPosition();
      LatLng newCenter = LatLng(position.latitude, position.longitude);

      setState(() {
        _center = newCenter;
      });
      _mapController.move(newCenter, 16.0);
      _getAddress(newCenter);
    } catch (e) {
      debugPrint("Error getting location: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 2. Reverse Geocoding: LatLng -> Address String using Nominatim (Free)
  Future<void> _getAddress(LatLng coords) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${coords.latitude}&lon=${coords.longitude}',
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'com.example.skill_link'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['display_name'] ?? "Unknown Location";

        if (mounted) {
          setState(() {
            _addressController.text = address;
          });
          widget.onLocationPicked(coords, address);
        }
      }
    } catch (e) {
      debugPrint("Geocoding error: $e");
    }
  }

  /// 3. Search Address -> LatLng (Forward Geocoding)
  Future<void> _onSearch() async {
    if (_addressController.text.isEmpty) return;

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${_addressController.text}&format=json&limit=1',
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'com.example.skill_link'},
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          final latLng = LatLng(lat, lon);
          final displayName = data[0]['display_name'];

          setState(() {
            _center = latLng;
            _addressController.text = displayName; // Update to full name
          });
          _mapController.move(latLng, 16.0);
          widget.onLocationPicked(latLng, displayName);
        }
      }
    } catch (e) {
      debugPrint("Search error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Address Search Bar
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Search or Move Map',
              prefixIcon: const Icon(Icons.location_on, color: Colors.blue),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: _onSearch,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onSubmitted: (_) => _onSearch(),
          ),
        ),

        Expanded(
          child: Stack(
            children: [
              // 1. The Map
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _center,
                  initialZoom: 16.0,
                  onPositionChanged: (position, hasGesture) {
                    if (hasGesture) {
                      // Debounce to prevent hitting API too many times while dragging
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 800), () {
                        if (position.center != null) {
                          _getAddress(position.center!);
                        }
                      });
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.skill_link',
                  ),
                ],
              ),

              // 2. The Static Center Pin
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: 35,
                  ), // Adjust icon tip to center
                  child: Icon(Icons.location_on, color: Colors.red, size: 50),
                ),
              ),

              // 3. Current Location Button
              Positioned(
                bottom: 20,
                right: 20,
                child: FloatingActionButton(
                  onPressed: _determinePosition,
                  backgroundColor: const Color(0xFF003366),
                  child: _isLoading
                      ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                      : const Icon(Icons.my_location, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
