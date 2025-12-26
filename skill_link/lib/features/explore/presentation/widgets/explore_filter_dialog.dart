import 'package:flutter/material.dart';

class ExploreFilterDialog extends StatefulWidget {
  final double? initialMaxPrice;
  final String? initialCategory;

  const ExploreFilterDialog({
    super.key,
    this.initialMaxPrice,
    this.initialCategory,
  });

  @override
  State<ExploreFilterDialog> createState() => _ExploreFilterDialogState();
}

class _ExploreFilterDialogState extends State<ExploreFilterDialog> {
  late TextEditingController _maxPriceController;
  late TextEditingController _minPriceController;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _maxPriceController = TextEditingController(
      text: widget.initialMaxPrice?.toString() ?? '',
    );
    _minPriceController = TextEditingController();
    _selectedCategory = widget.initialCategory;
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Filter Workers'),
          TextButton(onPressed: _resetFilters, child: const Text('Reset')),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Price Range
              const Text(
                'Hourly Rate Range',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Min Rate',
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
                        labelText: 'Max Rate',
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
                'Skill Category',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All Skills'),
                  ),
                  const DropdownMenuItem<String?>(
                    value: 'Plumbing',
                    child: Text('Plumbing'),
                  ),
                  const DropdownMenuItem<String?>(
                    value: 'Electrical',
                    child: Text('Electrical'),
                  ),
                  const DropdownMenuItem<String?>(
                    value: 'Cleaning',
                    child: Text('Cleaning'),
                  ),
                  const DropdownMenuItem<String?>(
                    value: 'Painting',
                    child: Text('Painting'),
                  ),
                  const DropdownMenuItem<String?>(
                    value: 'Carpentry',
                    child: Text('Carpentry'),
                  ),
                  const DropdownMenuItem<String?>(
                    value: 'Moving',
                    child: Text('Moving'),
                  ),
                  const DropdownMenuItem<String?>(
                    value: 'Other',
                    child: Text('Other'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
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
            });
          },
          child: const Text('Apply Filters'),
        ),
      ],
    );
  }
}
