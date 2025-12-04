// lib/features/add_property/presentation/bloc/add_property_event.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart'; // For BuildContext in events if needed

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class FetchCategories extends CategoryEvent {
  const FetchCategories();
}

class AddNewCategory extends CategoryEvent {
  final String categoryName;
  final BuildContext? context; // Optional context for showing snackbars

  const AddNewCategory({required this.categoryName, this.context});

  @override
  List<Object?> get props => [categoryName, context];
}

class ClearCategoryMessageEvent extends CategoryEvent {
  const ClearCategoryMessageEvent();
}