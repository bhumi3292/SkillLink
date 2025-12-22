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
import 'package:skill_link/features/explore/presentation/widgets/explore_filter_dialog.dart';
import 'package:skill_link/features/explore/presentation/widgets/explore_search_bar.dart';
import 'package:skill_link/features/favourite/presentation/bloc/cart_bloc.dart';

enum WorkerFilter { all, nearby }

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
  WorkerFilter _currentFilter = WorkerFilter.all;

  bool _isMapView = false; // Default to List View
  Position? _currentPosition;
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStreamSubscription;
  final bool _followUser = true;

  @override
  void initState() {
    super.initState();
    _cartBloc = serviceLocator<CartBloc>();
    _cartBloc.add(GetCartEvent());
    context.read<ExploreBloc>().add(GetWorkersEvent());
    _initializeAndSubscribeToLocation();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initializeAndSubscribeToLocation() async {
    final locationService = serviceLocator<LocationService>();
    final hasPermission = await locationService.requestPermission();

    if (hasPermission && mounted) {
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        if (mounted) {
          setState(() {
            _currentPosition = position;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _mapController.move(
                LatLng(position.latitude, position.longitude),
                15.0,
              );
            }
          });
        }

        _positionStreamSubscription = locationService
            .getPositionStream()
            .listen((position) {
              if (mounted) {
                setState(() {
                  _currentPosition = position;
                });
                if (_followUser) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _mapController.move(
                        LatLng(position.latitude, position.longitude),
                        15.0,
                      );
                    }
                  });
                }
              }
            });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to get location: ${e.toString()}')),
          );
        }
      }
    }
  }

  List<Marker> _buildMarkers(List<ExploreWorkerEntity> workers) {
    final markers = <Marker>[];

    for (final worker in workers) {
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
                color: Colors.purple,
                size: 35,
              ),
            ),
          ),
        );
      }
    }

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
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ExploreSearchBar(
                          onSearchChanged: (value) {
                            _searchText = value;
                            _filterWorkers();
                          },
                          onFilterPressed: () async {
                            await _showFilterDialog();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Modern View Toggle Switch
                      _buildViewToggleSwitch(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Modern Segmented Control
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildFilterOption(
                          label: 'All Workers',
                          icon: Icons.people_outline,
                          isSelected: _currentFilter == WorkerFilter.all,
                          onTap: () {
                            setState(() {
                              _currentFilter = WorkerFilter.all;
                            });
                            _filterWorkers();
                          },
                        ),
                        const SizedBox(width: 4),
                        _buildFilterOption(
                          label: 'Nearby Only',
                          icon: Icons.location_on_outlined,
                          isSelected: _currentFilter == WorkerFilter.nearby,
                          onTap: () {
                            setState(() {
                              _currentFilter = WorkerFilter.nearby;
                            });
                            _filterWorkers();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<ExploreBloc, ExploreState>(
                builder: (context, state) {
                  if (state is ExploreLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ExploreError) {
                    return Center(
                      child: Text("Error loading workers: ${state.message}"),
                    );
                  } else if (state is ExploreLoaded) {
                    List<ExploreWorkerEntity> workersToDisplay =
                        state.filteredWorkers;
                    if (_currentFilter == WorkerFilter.nearby &&
                        _currentPosition != null) {
                      workersToDisplay =
                          workersToDisplay.where((worker) {
                            if (worker.coordinates == null) return false;
                            final distance = Geolocator.distanceBetween(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                              worker.coordinates!.latitude,
                              worker.coordinates!.longitude,
                            );
                            return distance <= 2000; // 2km
                          }).toList();
                      // Sort by distance
                      workersToDisplay.sort((a, b) {
                        final distanceA = Geolocator.distanceBetween(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                          a.coordinates!.latitude,
                          a.coordinates!.longitude,
                        );
                        final distanceB = Geolocator.distanceBetween(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                          b.coordinates!.latitude,
                          b.coordinates!.longitude,
                        );
                        return distanceA.compareTo(distanceB);
                      });
                    }

                    if (_isMapView) {
                      return FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter:
                              _currentPosition != null
                                  ? LatLng(
                                    _currentPosition!.latitude,
                                    _currentPosition!.longitude,
                                  )
                                  : const LatLng(27.7172, 85.3240), // Fallback
                          initialZoom: 15.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.skill_link',
                          ),
                          MarkerLayer(markers: _buildMarkers(workersToDisplay)),
                        ],
                      );
                    }

                    if (workersToDisplay.isEmpty) {
                      return const Center(
                        child: Text("No workers found matching your criteria"),
                      );
                    }

                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children:
                          workersToDisplay.map((worker) {
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
                                            (_) => WorkerDetailPage(
                                              worker: worker,
                                            ),
                                      ),
                                    );
                                  },
                                  showFavoriteButton: true,
                                ),
                              ),
                            );
                          }).toList(),
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
      _searchText = '';
      _currentFilter = WorkerFilter.all;
    });
    _filterWorkers();
  }

  Widget _buildFilterOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggleSwitch() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[100]!,
            Colors.grey[50]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Animated background indicator
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            left: _isMapView ? 48 : 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          // Toggle buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildToggleButton(
                icon: Icons.view_list_rounded,
                isActive: !_isMapView,
                onTap: () {
                  if (_isMapView) {
                    setState(() {
                      _isMapView = false;
                    });
                  }
                },
                tooltip: 'List View',
              ),
              _buildToggleButton(
                icon: Icons.map_rounded,
                isActive: _isMapView,
                onTap: () {
                  if (!_isMapView) {
                    setState(() {
                      _isMapView = true;
                    });
                  }
                },
                tooltip: 'Map View',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: AnimatedScale(
              scale: isActive ? 1.1 : 0.9,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              child: Icon(
                icon,
                size: 22,
                color: isActive ? Colors.white : Colors.grey[600],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

