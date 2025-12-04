import 'package:flutter/material.dart';

class ExploreFilterDialog extends StatefulWidget {
  final double? initialMaxPrice;
  final String? initialCategory;
  final int? initialMinBedrooms;
  final int? initialMinBathrooms;

  const ExploreFilterDialog({
    super.key,
    this.initialMaxPrice,
    this.initialCategory,
    this.initialMinBedrooms,
    this.initialMinBathrooms,
  });

  @override
  State<ExploreFilterDialog> createState() => _ExploreFilterDialogState();
}

class _ExploreFilterDialogState extends State<ExploreFilterDialog> {
  late TextEditingController _maxPriceController;
  late TextEditingController _minPriceController;
  String? _selectedCategory;
  int? _selectedMinBedrooms;
  int? _selectedMinBathrooms;

  @override
  void initState() {
    super.initState();
    _maxPriceController = TextEditingController(
      text: widget.initialMaxPrice?.toString() ?? '',
    );
    _minPriceController = TextEditingController();
    _selectedCategory = widget.initialCategory;
    _selectedMinBedrooms = widget.initialMinBedrooms;
    _selectedMinBathrooms = widget.initialMinBathrooms;
  }

  @override
  void dispose() {
    _maxPriceController.dispose();
    _minPriceController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _maxPriceController.clear();
      _minPriceController.clear();
      _selectedCategory = null;
      _selectedMinBedrooms = null;
      _selectedMinBathrooms = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Filter Properties'),
          TextButton(
            onPressed: _resetFilters,
            child: const Text('Reset'),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85, // Increased width
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Price Range
              const Text(
                'Price Range',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Min Price',
                        hintText: '0',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _maxPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Max Price',
                        hintText: 'No limit',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Category Filter
              const Text(
                'Property Type',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All Types'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'apartment',
                    child: Text('Apartment'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'house',
                    child: Text('House'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'villa',
                    child: Text('Villa'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'condo',
                    child: Text('Condo'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'studio',
                    child: Text('Studio'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'penthouse',
                    child: Text('Penthouse'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              // Bedrooms Filter
              const Text(
                'Bedrooms',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _selectedMinBedrooms,
                decoration: const InputDecoration(
                  labelText: 'Minimum Bedrooms',
                  prefixIcon: Icon(Icons.bed),
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('Any'),
                  ),
                  const DropdownMenuItem<int>(
                    value: 1,
                    child: Text('1+ Bedroom'),
                  ),
                  const DropdownMenuItem<int>(
                    value: 2,
                    child: Text('2+ Bedrooms'),
                  ),
                  const DropdownMenuItem<int>(
                    value: 3,
                    child: Text('3+ Bedrooms'),
                  ),
                  const DropdownMenuItem<int>(
                    value: 4,
                    child: Text('4+ Bedrooms'),
                  ),
                  const DropdownMenuItem<int>(
                    value: 5,
                    child: Text('5+ Bedrooms'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedMinBedrooms = value;
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              // Bathrooms Filter
              const Text(
                'Bathrooms',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _selectedMinBathrooms,
                decoration: const InputDecoration(
                  labelText: 'Minimum Bathrooms',
                  prefixIcon: Icon(Icons.bathtub_outlined),
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('Any'),
                  ),
                  const DropdownMenuItem<int>(
                    value: 1,
                    child: Text('1+ Bathroom'),
                  ),
                  const DropdownMenuItem<int>(
                    value: 2,
                    child: Text('2+ Bathrooms'),
                  ),
                  const DropdownMenuItem<int>(
                    value: 3,
                    child: Text('3+ Bathrooms'),
                  ),
                  const DropdownMenuItem<int>(
                    value: 4,
                    child: Text('4+ Bathrooms'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedMinBathrooms = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final maxPrice = double.tryParse(_maxPriceController.text);
            final minPrice = double.tryParse(_minPriceController.text);
            Navigator.of(context).pop({
              'maxPrice': maxPrice,
              'minPrice': minPrice,
              'category': _selectedCategory,
              'minBedrooms': _selectedMinBedrooms,
              'minBathrooms': _selectedMinBathrooms,
            });
          },
          child: const Text('Apply Filters'),
        ),
      ],
    );
  }
} 