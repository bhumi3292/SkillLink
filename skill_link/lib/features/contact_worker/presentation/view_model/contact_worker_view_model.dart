import 'package:flutter/material.dart';
import '../../data/repository/contact_worker_repository.dart';
import '../../domain/entity/contact_worker_item.dart';

class ContactworkerViewModel extends ChangeNotifier {
  final ContactworkerRepository repository;
  List<ContactworkerItem> items = [];
  bool isLoading = false;

  ContactworkerViewModel(this.repository);

  Future<void> fetchItems() async {
    isLoading = true;
    notifyListeners();
    final result = await repository.fetchContacts();
    items = result.map((e) => ContactworkerItem(e)).toList();
    isLoading = false;
    notifyListeners();
  }
}
