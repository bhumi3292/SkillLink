import 'package:flutter/material.dart';
import '../../data/repository/edit_worker_repository.dart';
import '../../domain/entity/edit_worker_item.dart';

class EditWorkerViewModel extends ChangeNotifier {
  final EditWorkerRepository repository;
  List<EditWorkerItem> items = [];
  bool isLoading = false;

  EditWorkerViewModel(this.repository);

  Future<void> fetchItems() async {
    isLoading = true;
    notifyListeners();
    final result = await repository.fetchEditProperties();
    items = result.map((e) => EditWorkerItem(e)).toList();
    isLoading = false;
    notifyListeners();
  }
} 