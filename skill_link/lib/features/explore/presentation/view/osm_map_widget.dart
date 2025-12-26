import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Reusable OSM map widget with proper User-Agent and optional markers.
class OsmMapWidget extends StatefulWidget {
  final LatLng initialCenter;
  final double initialZoom;
  final List<Marker> markers;
  final MapController? mapController;

  const OsmMapWidget({
    super.key,
    this.initialCenter = const LatLng(27.7172, 85.3240),
    this.initialZoom = 13.0,
    this.markers = const [],
    this.mapController,
  });

  @override
  State<OsmMapWidget> createState() => _OsmMapWidgetState();
}

class _OsmMapWidgetState extends State<OsmMapWidget> {
  late final MapController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.mapController ?? MapController();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 420,
      child: FlutterMap(
        mapController: _controller,
        options: MapOptions(
          initialCenter: widget.initialCenter,
          initialZoom: widget.initialZoom,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.skill_link',
          ),
          if (widget.markers.isNotEmpty) MarkerLayer(markers: widget.markers),
        ],
      ),
    );
  }
}
