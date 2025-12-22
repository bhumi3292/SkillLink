import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';
import 'package:skill_link/core/services/location_service.dart';
import 'package:skill_link/features/dashbaord/presentation/widgets/property_card_widget.dart';
import 'package:skill_link/features/explore/domain/entity/explore_worker_entity.dart';
import 'package:skill_link/features/explore/presentation/bloc/explore_bloc.dart';
import 'package:skill_link/features/explore/presentation/utils/worker_converter.dart';
import 'package:skill_link/features/explore/presentation/view/worker_detail_page.dart';
import 'package:skill_link/features/explore/presentation/view/osm_map_widget.dart';
import 'package:skill_link/features/explore/presentation/widgets/explore_filter_dialog.dart';
import 'package:skill_link/features/explore/presentation/widgets/explore_search_bar.dart';
import 'package:skill_link/features/favourite/presentation/bloc/cart_bloc.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  late CartBloc _cartBloc;
  String _searchText = '';
  String? _selectedCategory;
  double? _minPrice;
  double? _maxPrice;

  bool _isMapView = false;
  Position? _currentPosition;
  bool _nearMeOnly = false;
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _cartBloc = serviceLocator<CartBloc>();
    _cartBloc.add(GetCartEvent());
    context.read<ExploreBloc>().add(GetWorkersEvent());
    _subscribeToLocationUpdates();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _subscribeToLocationUpdates() async {
    final locationService = serviceLocator<LocationService>();
    final hasPermission = await locationService.requestPermission();
    if (hasPermission && mounted) {
      final position = await locationService.getCurrentPosition();
      if (position != null && mounted) {
        setState(() {
          _currentPosition = position;
        });
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          14.0,
        );
      }

      _positionStreamSubscription = locationService.getPositionStream().listen((
        position,
      ) {
        if (mounted) {
          setState(() {
            _currentPosition = position;
          });
        }
      });
    }
  }

  List<Marker> _buildMarkers(List<ExploreWorkerEntity> workers) {
    final markers = <Marker>[];

    // Add worker markers
    for (final worker in workers) {
      // Use coordinates (LatLng) when available; fallback to no marker
      if (worker.coordinates != null) {
        markers.add(
          Marker(
            width: 80.0,
            height: 80.0,
            point: worker.coordinates!,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WorkerDetailPage(worker: worker),
                  ),
                );
              },
              child: const Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 30,
              ),
            ),
          ),
        );
      }
    }

    // Add user's current location marker
    if (_currentPosition != null) {
      markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          child: const Icon(
            Icons.person_pin_circle,
            color: Colors.blue,
            size: 40,
          ),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            setState(() {
              _isMapView = !_isMapView;
            });
          },
          label: Text(_isMapView ? "List View" : "Map View"),
          icon: Icon(_isMapView ? Icons.list : Icons.map),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Column(
          children: [
            // Header with Search Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ExploreSearchBar(
                    onSearchChanged: (value) {
                      _searchText = value;
                      _filterWorkers();
                    },
                    onFilterPressed: () async {
                      await _showFilterDialog();
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Show only workers near me (10 km)',
                        onPressed: () {
                          setState(() {
                            _nearMeOnly = !_nearMeOnly;
                          });
                        },
                        icon: Icon(
                          Icons.near_me,
                          color:
                              _nearMeOnly
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _nearMeOnly
                            ? 'Showing workers near you'
                            : 'Showing all workers',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  if (_hasActiveFilters())
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.filter_list,
                                  size: 16,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Filters Active',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: _clearAllFilters,
                            child: Text(
                              'Clear All',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Content Body
            Expanded(
              child: BlocBuilder<ExploreBloc, ExploreState>(
                builder: (context, state) {
                  if (state is ExploreLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ExploreError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Something went wrong while loading workers.",
                            style: TextStyle(color: Colors.grey),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<ExploreBloc>().add(
                                GetWorkersEvent(),
                              );
                            },
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    );
                  } else if (state is ExploreLoaded) {
                    // locally apply 'near me' proximity filter when enabled
                    final locationService = serviceLocator<LocationService>();
                    List<ExploreWorkerEntity> displayedWorkers =
                        state.filteredWorkers;
                    if (_nearMeOnly && _currentPosition != null) {
                      displayedWorkers =
                          displayedWorkers.where((w) {
                            final coords = w.coordinates;
                            if (coords == null) return false;
                            final meters = locationService.calculateDistance(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                              coords.latitude,
                              coords.longitude,
                            );
                            return meters <= 10000; // within 10 km
                          }).toList();
                    }

                    if (_isMapView) {
                      final center =
                          _currentPosition != null
                              ? LatLng(
                                _currentPosition!.latitude,
                                _currentPosition!.longitude,
                              )
                              : const LatLng(27.7172, 85.3240);
                      return OsmMapWidget(
                        initialCenter: center,
                        initialZoom: 14.0,
                        mapController: _mapController,
                        markers: _buildMarkers(displayedWorkers),
                      );
                    }

                    if (displayedWorkers.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "No workers found matching your criteria",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        ...displayedWorkers.map((worker) {
                          final apiModel = WorkerConverter.toApiModel(worker);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: BlocProvider.value(
                              value: _cartBloc,
                              child: PropertyCardWidget(
                                property: apiModel,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) =>
                                              WorkerDetailPage(worker: worker),
                                    ),
                                  );
                                },
                                showFavoriteButton: true,
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  }

                  return const Center(child: Text('No data available'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _filterWorkers() {
    context.read<ExploreBloc>().add(
      FilterWorkersEvent(
        searchText: _searchText,
        categoryId: _selectedCategory,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
      ),
    );
  }

  Future<void> _showFilterDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (context) => ExploreFilterDialog(
            initialMaxPrice: _maxPrice,
            initialCategory: _selectedCategory,
          ),
    );

    if (result != null) {
      setState(() {
        _maxPrice = result['maxPrice'];
        _minPrice = result['minPrice'];
        _selectedCategory = result['category'];
      });
      _filterWorkers();
    }
  }

  bool _hasActiveFilters() {
    return _selectedCategory != null || _minPrice != null || _maxPrice != null;
  }

  void _clearAllFilters() {
    setState(() {
      _selectedCategory = null;
      _minPrice = null;
      _maxPrice = null;
    });
    _filterWorkers();
  }
}
