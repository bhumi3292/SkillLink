import 'package:flutter/material.dart';
import 'dart:async';

class ExploreSearchBar extends StatefulWidget {
  final Function(String) onSearchChanged;
  final VoidCallback onFilterPressed;

  const ExploreSearchBar({
    super.key,
    required this.onSearchChanged,
    required this.onFilterPressed,
  });

  @override
  State<ExploreSearchBar> createState() => _ExploreSearchBarState();
}

class _ExploreSearchBarState extends State<ExploreSearchBar> {
  Timer? _debounceTimer;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    // Cancel the previous timer
    _debounceTimer?.cancel();
    
    // Start a new timer
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      widget.onSearchChanged(value);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    widget.onSearchChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: theme.primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search properties by title, location, or description...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.grey[600],
              ),
              onPressed: _clearSearch,
            ),
          IconButton(
            icon: Icon(
              Icons.tune,
              color: theme.primaryColor,
            ),
            onPressed: widget.onFilterPressed,
          ),
        ],
      ),
    );
  }
} 