import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';
import 'package:skill_link/core/services/location_service.dart';
import 'package:latlong2/latlong.dart' as ll;
import '../bloc/navigation_bloc.dart';
import 'package:skill_link/features/explore/presentation/view/osm_map_widget.dart';

class WorkerNavigationPage extends StatefulWidget {
  final ll.LatLng workerInitialLocation;
  final ll.LatLng hirerLocation;

  const WorkerNavigationPage({
    super.key,
    required this.workerInitialLocation,
    required this.hirerLocation,
  });

  @override
  State<WorkerNavigationPage> createState() => _WorkerNavigationPageState();
}

class _WorkerNavigationPageState extends State<WorkerNavigationPage> {
  late final NavigationBloc _navigationBloc;

  @override
  void initState() {
    super.initState();
    _navigationBloc = NavigationBloc(serviceLocator<LocationService>());
    _navigationBloc.add(
      StartNavigation(
        workerInitialLocation: widget.workerInitialLocation,
        hirerLocation: widget.hirerLocation,
      ),
    );
  }

  @override
  void dispose() {
    _navigationBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation to Destination'),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
      ),
      body: BlocProvider.value(
        value: _navigationBloc,
        child: BlocBuilder<NavigationBloc, NavigationState>(
          builder: (context, state) {
            if (state is NavigationLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is NavigationError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 60),
                    const SizedBox(height: 16),
                    Text(state.message, textAlign: TextAlign.center),
                  ],
                ),
              );
            } else if (state is NavigationLoaded) {
              return OsmMapWidget(
                initialLocation: GeoPoint(
                  latitude: state.workerLocation.latitude,
                  longitude: state.workerLocation.longitude,
                ),
                destinationLocation: GeoPoint(
                  latitude: state.hirerLocation.latitude,
                  longitude: state.hirerLocation.longitude,
                ),
                showRoute: true,
              );
            }
            return const Center(child: Text("Initializing Map..."));
          },
        ),
      ),
    );
  }
}

