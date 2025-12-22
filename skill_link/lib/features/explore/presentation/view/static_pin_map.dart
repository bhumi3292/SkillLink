import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

/// A Pathao/Uber-style static center pin map.
/// - Shows a fixed pin at the center of the screen.
/// - Debounces map movement and reverse-geocodes the center point using Nominatim.
/// - Provides a re-center button and an OK button to return the selected location.
class StaticPinMap extends StatefulWidget {
  /// Initial map center
  final LatLng initialCenter;

  /// Initial zoom level
  final double initialZoom;

  /// Called when user confirms location: returns { 'lat': ..., 'lng': ..., 'address': '...' }
  final void Function(LatLng coords, String address)? onConfirm;

  const StaticPinMap({
    super.key,
    this.initialCenter = const LatLng(27.7172, 85.3240),
    this.initialZoom = 16.0,
    this.onConfirm,
  });

  @override
  State<StaticPinMap> createState() => _StaticPinMapState();
}

class _StaticPinMapState extends State<StaticPinMap> {
  final MapController _mapController = MapController();
  LatLng _center = LatLng(27.7172, 85.3240);
  String _address = 'Searching address...';
  Timer? _debounce;
  bool _loadingAddress = false;

  @override
  void initState() {
    super.initState();
    _center = widget.initialCenter;
    _setInitialLocation();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _setInitialLocation() async {
    try {
      final hasPermission = await _ensureLocationPermission();
      if (!hasPermission) return;

      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _center = LatLng(pos.latitude, pos.longitude);
      });
      _mapController.move(_center, widget.initialZoom);
      _reverseGeocode(_center);
    } catch (e) {
      // ignore errors and keep default
    }
  }

  Future<bool> _ensureLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  void _onPositionChanged(MapPosition pos, bool hasGesture) {
    // pos.center may be null in some versions; guard
    final center = pos.center;
    if (center == null) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _center = LatLng(center.latitude, center.longitude);
      });
      _reverseGeocode(_center);
    });
  }

  Future<void> _reverseGeocode(LatLng coords) async {
    setState(() {
      _loadingAddress = true;
      _address = 'Searching address...';
    });

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${coords.latitude}&lon=${coords.longitude}&zoom=18&addressdetails=1',
      );
      final resp = await http
          .get(
            url,
            headers: {
              'User-Agent': 'SkillLinkApp/1.0 (contact: youremail@example.com)',
            },
          )
          .timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as Map<String, dynamic>;
        final name = data['display_name'] as String?;
        setState(() {
          _address = name ?? 'Unknown location';
        });
      } else {
        setState(() {
          _address = 'Unable to fetch address';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _address = 'Reverse geocode error';
        });
      }
    } finally {
      if (mounted) setState(() => _loadingAddress = false);
    }
  }

  Future<void> _recenter() async {
    try {
      final hasPermission = await _ensureLocationPermission();
      if (!hasPermission) return;
      final pos = await Geolocator.getCurrentPosition();
      final newCenter = LatLng(pos.latitude, pos.longitude);
      _mapController.move(newCenter, widget.initialZoom);
      setState(() => _center = newCenter);
      _reverseGeocode(newCenter);
    } catch (_) {}
  }

  void _confirm() {
    if (widget.onConfirm != null) widget.onConfirm!(_center, _address);
    Navigator.of(context).pop({
      'lat': _center.latitude,
      'lng': _center.longitude,
      'address': _address,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Pickup Location'),
        backgroundColor: const Color(0xFF003366),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: widget.initialZoom,
              onPositionChanged: _onPositionChanged,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.skill_link',
                tileProvider: NetworkTileProvider(
                  headers: {
                    'User-Agent':
                        'SkillLinkApp/1.0 (contact: youremail@example.com)',
                  },
                ),
              ),
            ],
          ),

          // Fixed center pin
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 30),
              child: Icon(Icons.location_on, color: Colors.red, size: 50),
            ),
          ),

          // Address card
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.place, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    if (_loadingAddress)
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Recenter button
          Positioned(
            bottom: 90,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'recenter',
              mini: true,
              onPressed: _recenter,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.black87),
            ),
          ),

          // Confirm button
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003366),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Confirm location',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
