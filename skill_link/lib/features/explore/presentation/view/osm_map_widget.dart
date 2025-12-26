import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:skill_link/core/services/location_service.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';
import 'package:skill_link/core/services/geocoding_service.dart';
import 'package:geolocator/geolocator.dart';

/// A production-ready Map Widget using flutter_osm_plugin.
/// Supports: Picking (Center Pin), Search, Route Drawing, and Live Tracking.
class OsmMapWidget extends StatefulWidget {
  final bool isPicker;
  final GeoPoint? initialLocation;
  final GeoPoint? destinationLocation;
  final Function(GeoPoint, String address)? onLocationSelected;
  final bool showRoute;
  final String? pickerTitle;

  const OsmMapWidget({
    super.key,
    this.isPicker = false,
    this.initialLocation,
    this.destinationLocation,
    this.onLocationSelected,
    this.showRoute = false,
    this.pickerTitle,
  });

  @override
  State<OsmMapWidget> createState() => _OsmMapWidgetState();
}

class _OsmMapWidgetState extends State<OsmMapWidget> {
  late MapController controller;
  final TextEditingController _searchController = TextEditingController();
  final GeocodingService _geocodingService = GeocodingService();
  
  bool _isMapReady = false;
  bool _isLocating = false;
  bool _isConfirming = false;
  bool _isLoading = true; // For full-screen loading
  RoadInfo? _roadInfo; // For turn-by-turn directions
  StreamSubscription<Position>? _positionSubscription;

  @override
  void initState() {
    super.initState();
    
    // Initialize controller with either initialLocation or user position
    controller = MapController(
      initPosition: widget.initialLocation,
      initMapWithUserPosition: widget.initialLocation == null
          ? const UserTrackingOption(
              enableTracking: true,
              unFollowUser: false,
            )
          : null,
    );
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Request permissions and start high-frequency location updates
  Future<void> _setupLocationTracking() async {
    final granted = await serviceLocator<LocationService>().requestPermission();
    if (granted && mounted) {
      // Use Geolocator stream to fix the "Single Fetch Timeout" issue
      _positionSubscription = serviceLocator<LocationService>().getPositionStream().listen(
        (position) async {
          if (_isMapReady && !widget.isPicker) {
            // Only follow user if not in picker mode
            // await controller.goToLocation(GeoPoint(latitude: position.latitude, longitude: position.longitude));
          }
        },
        onError: (e) => debugPrint("Location Stream Error: $e"),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission denied. Feature limited.")),
      );
    }
  }

  /// Forward Geocoding: Address -> Coordinates
  Future<void> _handleSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isLocating = true);
    try {
      final coords = await _geocodingService.getCoordinatesFromAddress(query);
      if (coords != null && mounted) {
        await controller.goToLocation(coords);
        // Explicitly update the search box to the formatted address if possible
        _autofillAddressFromCoords(coords);
      } else if (mounted) {
        throw "Location not found";
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  /// Reverse Geocoding: Coordinates -> Address
  Future<void> _autofillAddressFromCoords(GeoPoint point) async {
    try {
      final address = await _geocodingService.getAddressFromCoordinates(
        point.latitude,
        point.longitude,
      );
      if (address != null && mounted) {
        setState(() {
          _searchController.text = address;
        });
      }
    } catch (e) {
      debugPrint("Reverse Geocoding Error: $e");
    }
  }

  /// Initial autofill when map loads
  Future<void> _initialAutofill() async {
    try {
      GeoPoint? point;
      if (widget.initialLocation != null) {
        point = widget.initialLocation;
      } else {
        point = await controller.myLocation();
      }
      if (point != null) _autofillAddressFromCoords(point);
    } catch (_) {
      // Fallback to single fetch if tracking not yet warmed up
      final pos = await serviceLocator<LocationService>().getCurrentPosition();
      if (pos != null && mounted) {
        final gp = GeoPoint(latitude: pos.latitude, longitude: pos.longitude);
        _autofillAddressFromCoords(gp);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        OSMFlutter(
          controller: controller,
          osmOption: OSMOption(
            userTrackingOption: const UserTrackingOption(
              enableTracking: true,
              unFollowUser: false,
            ),
            userLocationMarker: UserLocationMaker(
              personMarker: const MarkerIcon(
                icon: Icon(Icons.person_pin_circle, color: Colors.blue, size: 48),
              ),
              directionArrowMarker: const MarkerIcon(
                icon: Icon(Icons.navigation, color: Colors.blue, size: 24),
              ),
            ),
            staticPoints: [
              if (widget.destinationLocation != null)
                StaticPositionGeoPoint(
                  "destination",
                  const MarkerIcon(
                    icon: Icon(Icons.location_on, color: Colors.red, size: 56),
                  ),
                  [widget.destinationLocation!],
                ),
            ],
            roadConfiguration: const RoadOption(
              roadColor: Colors.blueAccent,
              roadWidth: 12,
            ),
            enableRotationByGesture: true,
            zoomOption: const ZoomOption(
              initZoom: 15,
              minZoomLevel: 3,
              maxZoomLevel: 19,
              stepZoom: 1.0,
            ),
          ),
          onMapIsReady: (isReady) async {
            if (isReady && mounted) {
              setState(() => _isMapReady = true);
              await _setupLocationTracking();
              
              // Small delay to ensure engine stability before heavy calls
              Future.delayed(const Duration(seconds: 1), () async {
                if (mounted) {
                  await _initialAutofill();
                  if (widget.showRoute) {
                    await _drawNavigationRoute();
                  }
                  setState(() => _isLoading = false);
                }
              });
            }
          },
          onGeoPointClicked: (geoPoint) async {
            if (widget.isPicker) {
              await controller.goToLocation(geoPoint);
              _autofillAddressFromCoords(geoPoint);
            }
          },
        ),

        // Directions Instruction Card (Pathao-style)
        if (widget.showRoute && _roadInfo != null && _roadInfo!.instructions.isNotEmpty)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF003366),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  const Icon(Icons.navigation, color: Colors.white, size: 30),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _roadInfo!.instructions.first.instruction,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          "Next turn in ${(_roadInfo!.distance ?? 0.0).toStringAsFixed(1)} km",
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

        // SEARCH BAR UI
        if (widget.isPicker)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 15,
            right: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Search for a location...",
                  border: InputBorder.none,
                  prefixIcon: _isLocating 
                      ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)) 
                      : const Icon(Icons.search, color: Color(0xFF003366)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _searchController.clear(),
                  ),
                ),
                onSubmitted: (_) => _handleSearch(),
              ),
            ),
          ),

        // CENTER PIN (Wow Factor)
        if (widget.isPicker)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 48), // Offset for pin point
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - value) * -20),
                      child: child,
                    ),
                  );
                },
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 50,
                  shadows: [Shadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 4)],
                ),
              ),
            ),
          ),

        // CONFIRM BUTTON
        if (widget.isPicker)
          Positioned(
            bottom: 30,
            left: 30,
            right: 30,
            child: Column(
              children: [
                if (widget.pickerTitle != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.pickerTitle!,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ElevatedButton(
                  onPressed: _isConfirming ? null : _confirmSelection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003366),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                  ),
                  child: _isConfirming 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("Confirm Location", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
          ),

        // RECENTER BUTTON
        Positioned(
          bottom: widget.isPicker ? 110 : 30,
          right: 20,
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            mini: true,
            onPressed: () async {
              await controller.currentLocation();
              await controller.enableTracking(enableStopFollow: false);
            },
            child: const Icon(Icons.my_location, color: Color(0xFF003366)),
          ),
        ),

        // Full-screen Loading Overlay (Must be last to cover all)
        if (_isLoading)
          Container(
            color: Colors.white.withOpacity(0.9),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   const CircularProgressIndicator(color: Color(0xFF003366)),
                  const SizedBox(height: 20),
                  Text(
                    widget.showRoute ? "Finding Best Path..." : "Locating You...",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF003366), fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _confirmSelection() async {
    if (!mounted) return;
    setState(() => _isConfirming = true);
    try {
      final center = await controller.centerMap;
      final address = await _geocodingService.getAddressFromCoordinates(
        center.latitude,
        center.longitude,
      );
      widget.onLocationSelected?.call(center, address ?? "Selected Location");
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Confirmation Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  Future<void> _drawNavigationRoute() async {
    if (widget.showRoute && widget.initialLocation != null && widget.destinationLocation != null) {
      // Prevent crash when start and end are identical
      if (widget.initialLocation!.latitude == widget.destinationLocation!.latitude &&
          widget.initialLocation!.longitude == widget.destinationLocation!.longitude) {
        debugPrint("Skipping road drawing: Start and End are same.");
        return;
      }

      try {
        // Clear previous roads before drawing new ones to give that "live" feel
        await controller.removeLastRoad();
        
        final roadInfo = await controller.drawRoad(
          widget.initialLocation!,
          widget.destinationLocation!,
          roadType: RoadType.car,
          roadOption: const RoadOption(
            roadColor: Colors.blueAccent,
            roadWidth: 12,
          ),
        );
        
        if (mounted) {
          setState(() {
            _roadInfo = roadInfo;
          });
        }
      } catch (e) {
        debugPrint("Road Drawing failed: $e");
      }
    }
  }

  @override
  void didUpdateWidget(covariant OsmMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the initial location (worker location) changes, redraw the road
    if (widget.showRoute && 
        oldWidget.initialLocation != widget.initialLocation && 
        widget.initialLocation != null) {
      _drawNavigationRoute();
    }
  }
}
