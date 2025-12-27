import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:skill_link/features/explore/presentation/view/osm_map_widget.dart';

class LocationPickerWidget extends StatefulWidget {
  final Function(ll.LatLng, String) onLocationPicked;

  const LocationPickerWidget({super.key, required this.onLocationPicked});

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400, // Fixed height or expanded as needed
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: OsmMapWidget(
          isPicker: true,
          onLocationSelected: (geoPoint, address) {
            widget.onLocationPicked(
              ll.LatLng(geoPoint.latitude, geoPoint.longitude),
              address,
            );
          },
        ),
      ),
    );
  }
}

