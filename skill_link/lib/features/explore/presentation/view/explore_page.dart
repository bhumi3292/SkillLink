import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';
import 'package:skill_link/core/services/location_service.dart';
import 'package:skill_link/features/explore/domain/entity/explore_worker_entity.dart';
import 'package:skill_link/features/explore/presentation/bloc/explore_bloc.dart';
import 'package:skill_link/features/explore/presentation/view/osm_map_widget.dart';
import 'package:skill_link/features/explore/presentation/view/worker_detail_page.dart';
import 'package:skill_link/features/explore/presentation/widgets/explore_worker_card.dart';
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

  Position? _currentPosition;
  bool _hasLocationPermission = false;
  
  // Draggable Scrollable Sheet Controller
  final DraggableScrollableController _scrollSheetController = DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _cartBloc = serviceLocator<CartBloc>();
    _cartBloc.add(GetCartEvent());
    
    // Initial fetch (will get all workers or default location ones)
    context.read<ExploreBloc>().add(const GetWorkersEvent());
    
    _initializeAndSubscribeToLocation();
  }

  Future<void> _initializeAndSubscribeToLocation() async {
    final locationService = serviceLocator<LocationService>();
    final hasPermission = await locationService.requestPermission();
    setState(() => _hasLocationPermission = hasPermission);

    if (hasPermission && mounted) {
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        if (mounted) {
          setState(() {
            _currentPosition = position;
          });
          
          // Refresh workers with location context if needed (Nearby)
          if (_currentFilter == WorkerFilter.nearby) {
             _filterWorkers();
          }
        }
      } catch (e) {
        if (mounted) {
          // debugPrint("Location Error: $e");
          // Fail silently or show snackbar
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Map Layer (Full Screen Background)
          // If permission denied, we won't show the map effectively (or just show default lat/long)
          Positioned.fill(
            child: BlocBuilder<ExploreBloc, ExploreState>(
              builder: (context, state) {
                List<ExploreWorkerEntity> markers = [];
                if (state is ExploreLoaded) {
                   markers = state.filteredWorkers;
                }
                
                return OsmMapWidget(
                   isPicker: false,
                   initialLocation: _currentPosition != null 
                     ? GeoPoint(latitude: _currentPosition!.latitude, longitude: _currentPosition!.longitude) 
                     : null, // Will default to user loc in widget
                   workerMarkers: markers,
                   onMarkerTap: _showWorkerPreview,
                 );
              }
            ),
          ),

          // 2. Filter & Search Header (Floating Top)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
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
                _buildFilterChips(),
              ],
            ),
          ),
          
          // 3. Draggable List Sheet (Bottom)
          DraggableScrollableSheet(
            controller: _scrollSheetController,
            initialChildSize: 0.4, // Map covers 60% initially
            minChildSize: 0.15, // Just the handle visible
            maxChildSize: 0.9, // Almost full screen
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                   borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                   boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)]
                ),
                child: Column(
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    
                    if (!_hasLocationPermission && _currentFilter == WorkerFilter.nearby)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Enable location to see nearby workers", 
                          style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold)
                        ),
                      ),
                      
                    // List
                    Expanded(
                      child: BlocBuilder<ExploreBloc, ExploreState>(
                        builder: (context, state) {
                          if (state is ExploreLoading) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (state is ExploreError) {
                            return Center(child: Text("${'error_loading_workers'.tr} ${state.message}"));
                          } else if (state is ExploreLoaded) {
                             if (state.filteredWorkers.isEmpty) {
                               return Center(child: Text("no_workers_found".tr));
                             }
                             return ListView.builder(
                               controller: scrollController,
                               padding: const EdgeInsets.symmetric(horizontal: 16),
                               itemCount: state.filteredWorkers.length,
                               itemBuilder: (context, index) {
                                  final worker = state.filteredWorkers[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: BlocProvider.value(
                                      value: _cartBloc,
                                      child: ExploreWorkerCard(
                                        worker: worker,
                                        onTap: () {
                                           Navigator.push(context, MaterialPageRoute(builder: (_) => WorkerDetailPage(worker: worker)));
                                        },
                                      ),
                                    ),
                                  );
                               },
                             );
                          }
                          return const Center(child: SizedBox());
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
       height: 40,
       child: ListView(
         scrollDirection: Axis.horizontal,
         children: [
            _buildChip(
              "All", 
              _currentFilter == WorkerFilter.all, 
              () {
                setState(() => _currentFilter = WorkerFilter.all);
                context.read<ExploreBloc>().add(const GetWorkersEvent()); // Fetch All
              }
            ),
            const SizedBox(width: 8),
            _buildChip(
              "Nearby", 
              _currentFilter == WorkerFilter.nearby, 
              () {
                 setState(() => _currentFilter = WorkerFilter.nearby);
                 // Trigger geo-query
                 if (_currentPosition != null) {
                   context.read<ExploreBloc>().add(GetWorkersEvent(lat: _currentPosition!.latitude, long: _currentPosition!.longitude));
                 } else {
                   // Request permission again or show toast
                   _initializeAndSubscribeToLocation();
                 }
              }
            ),
         ],
       ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
       child: Container(
         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
         decoration: BoxDecoration(
           color: isSelected ? Theme.of(context).primaryColor : Colors.white,
           borderRadius: BorderRadius.circular(20),
           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
         ),
         child: Text(
           label, 
           style: TextStyle(
             color: isSelected ? Colors.white : Colors.black87, 
             fontWeight: FontWeight.bold
           )
         ),
       ),
    );
  }

  void _showWorkerPreview(ExploreWorkerEntity worker) {
     showModalBottomSheet(
       context: context,
       isScrollControlled: true,
       backgroundColor: Colors.transparent,
       builder: (context) {
         return Container(
           margin: const EdgeInsets.all(16),
           decoration: BoxDecoration(
             color: Colors.white,
             borderRadius: BorderRadius.circular(16),
             boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)]
           ),
           child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               // Use existing card structure for consistency but wrapped slightly differently
               BlocProvider.value(
                  value: _cartBloc,
                  child: ExploreWorkerCard(
                    worker: worker,
                    onTap: () {
                       Navigator.pop(context); // Close sheet
                       Navigator.push(context, MaterialPageRoute(builder: (_) => WorkerDetailPage(worker: worker)));
                    },
                  ),
               ),
             ],
           ),
         );
       }
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
}
