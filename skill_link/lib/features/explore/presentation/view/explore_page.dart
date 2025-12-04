import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_link/features/explore/presentation/bloc/explore_bloc.dart';
import 'package:skill_link/features/explore/presentation/widgets/explore_property_card.dart';
import 'package:skill_link/features/explore/presentation/widgets/explore_search_bar.dart';
import 'package:skill_link/features/explore/presentation/widgets/explore_filter_dialog.dart';
import 'package:skill_link/features/favourite/presentation/bloc/cart_bloc.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';
import 'package:skill_link/features/explore/presentation/view/property_detail_page.dart';

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
  int? _minBedrooms;
  int? _minBathrooms;

  @override
  void initState() {
    super.initState();
    _cartBloc = serviceLocator<CartBloc>();
    _cartBloc.add(GetCartEvent());
    context.read<ExploreBloc>().add(GetPropertiesEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
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
                      _filterProperties();
                    },
                    onFilterPressed: () async {
                      await _showFilterDialog();
                    },
                  ),
                  // Filter Indicator
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

            // Properties List
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
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${state.message}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<ExploreBloc>().add(
                                GetPropertiesEvent(),
                              );
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  } else if (state is ExploreLoaded) {
                    if (state.filteredProperties.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No properties found',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search or filters',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.filteredProperties.length,
                      itemBuilder: (context, index) {
                        final property = state.filteredProperties[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: BlocProvider.value(
                            value: _cartBloc,
                            child: ExplorePropertyCard(
                              property: property,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => PropertyDetailPage(
                                          property: property,
                                        ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
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

  void _filterProperties() {
    context.read<ExploreBloc>().add(
      FilterPropertiesEvent(
        searchText: _searchText,
        categoryId: _selectedCategory,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        minBedrooms: _minBedrooms,
        minBathrooms: _minBathrooms,
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
            initialMinBedrooms: _minBedrooms,
            initialMinBathrooms: _minBathrooms,
          ),
    );

    if (result != null) {
      setState(() {
        _maxPrice = result['maxPrice'];
        _minPrice = result['minPrice'];
        _selectedCategory = result['category'];
        _minBedrooms = result['minBedrooms'];
        _minBathrooms = result['minBathrooms'];
      });
      _filterProperties();
    }
  }

  bool _hasActiveFilters() {
    return _selectedCategory != null ||
        _minPrice != null ||
        _maxPrice != null ||
        _minBedrooms != null ||
        _minBathrooms != null;
  }

  void _clearAllFilters() {
    setState(() {
      _selectedCategory = null;
      _minPrice = null;
      _maxPrice = null;
      _minBedrooms = null;
      _minBathrooms = null;
    });
    _filterProperties();
  }
}
