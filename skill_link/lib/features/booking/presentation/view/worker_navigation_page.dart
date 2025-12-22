import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';
import 'package:skill_link/core/services/location_service.dart';
import '../bloc/navigation_bloc.dart';

class WorkerNavigationPage extends StatefulWidget {
  final LatLng workerInitialLocation;
  final LatLng hirerLocation;

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
  final MapController _mapController = MapController();

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
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigate to Hirer'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: BlocProvider.value(
        value: _navigationBloc,
        child: BlocConsumer<NavigationBloc, NavigationState>(
          listener: (context, state) {
            if (state is NavigationLoaded && state.shouldAnimateCamera) {
              _mapController.move(state.workerLocation, 15.0);
            }
          },
          builder: (context, state) {
            if (state is NavigationLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is NavigationError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error: ${state.message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            } else if (state is NavigationLoaded) {
              return Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: state.workerLocation,
                      initialZoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                        userAgentPackageName: 'com.example.skill_link',
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: state.routePoints,
                            strokeWidth: 4.0,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          // Worker Marker
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: state.workerLocation,
                            child: const Icon(
                              Icons.person_pin_circle,
                              color: Colors.blue,
                              size: 40.0,
                            ),
                          ),
                          // Hirer Marker
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: state.hirerLocation,
                            child: const Icon(
                              Icons.home,
                              color: Colors.red,
                              size: 40.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: FloatingActionButton(
                      onPressed: () {
                        _navigationBloc.add(RecenterMap());
                      },
                      backgroundColor: Theme.of(context).primaryColor,
                      child: const Icon(Icons.my_location),
                    ),
                  ),
                ],
              );
            }
            return const Center(child: Text("Starting Navigation..."));
          },
        ),
      ),
    );
  }
}
