import 'package:flutter/material.dart';
import '../../data/repository/explore_repository.dart';
import '../../domain/entity/explore_item.dart';

class ExploreViewModel extends ChangeNotifier {
  final ExploreRepository repository;
  List<ExploreItem> items = [];
  bool isLoading = false;

  ExploreViewModel(this.repository);

  Future<void> fetchItems() async {
    isLoading = true;
    notifyListeners();
    final result = await repository.fetchExploreItems();
    items = result.asMap().entries.map((entry) => ExploreItem(id: entry.key.toString(), title: entry.value)).toList();
    isLoading = false;
    notifyListeners();
  }
} 