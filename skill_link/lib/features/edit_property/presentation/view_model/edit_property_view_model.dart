import 'package:flutter/material.dart';
import '../../data/repository/edit_property_repository.dart';
import '../../domain/entity/edit_property_item.dart';

class EditPropertyViewModel extends ChangeNotifier {
  final EditPropertyRepository repository;
  List<EditPropertyItem> items = [];
  bool isLoading = false;

  EditPropertyViewModel(this.repository);

  Future<void> fetchItems() async {
    isLoading = true;
    notifyListeners();
    final result = await repository.fetchEditProperties();
    items = result.map((e) => EditPropertyItem(e)).toList();
    isLoading = false;
    notifyListeners();
  }
} 