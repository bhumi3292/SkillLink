// lib/features/add_property/presentation/bloc/add_property_event.dart

import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart'; // For XFile
import 'package:flutter/material.dart'; // For BuildContext

import 'package:skill_link/features/add_property/domain/entity/category/category_entity.dart';

abstract class AddPropertyEvent extends Equatable {
  const AddPropertyEvent();

  @override
  List<Object?> get props => [];
}

class InitializeAddPropertyForm extends AddPropertyEvent {
  const InitializeAddPropertyForm();

  @override
  List<Object?> get props => [];
}

class SelectCategoryEvent extends AddPropertyEvent {
  final String? categoryId;

  const SelectCategoryEvent({required this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

class AddImageEvent extends AddPropertyEvent {
  final XFile image;

  const AddImageEvent({required this.image});

  @override
  List<Object?> get props => [image];
}

class RemoveImageEvent extends AddPropertyEvent {
  final int index;

  const RemoveImageEvent({required this.index});

  @override
  List<Object?> get props => [index];
}

class AddVideoEvent extends AddPropertyEvent {
  final XFile video;

  const AddVideoEvent({required this.video});

  @override
  List<Object?> get props => [video];
}

class RemoveVideoEvent extends AddPropertyEvent {
  final int index;

  const RemoveVideoEvent({required this.index});

  @override
  List<Object?> get props => [index];
}

class NewCategoryAddedEvent extends AddPropertyEvent {
  final CategoryEntity newCategory;

  const NewCategoryAddedEvent({required this.newCategory});

  @override
  List<Object?> get props => [newCategory];
}

class SubmitPropertyEvent extends AddPropertyEvent {
  final String title;
  final String location;
  final String price;
  final String description;
  final String bedrooms;
  final String bathrooms;
  final String? categoryId; // Nullable if the dropdown starts with a 'select' option
  final BuildContext? context; // For Snackbar

  const SubmitPropertyEvent({
    required this.title,
    required this.location,
    required this.price,
    required this.description,
    required this.bedrooms,
    required this.bathrooms,
    this.categoryId,
    this.context,
  });

  @override
  List<Object?> get props => [
    title,
    location,
    price,
    description,
    bedrooms,
    bathrooms,
    categoryId,
    context,
  ];
}

class ClearAddPropertyMessageEvent extends AddPropertyEvent {
  const ClearAddPropertyMessageEvent();

  @override
  List<Object?> get props => [];
}

class SubmitUpdatePropertyEvent extends AddPropertyEvent {
  final String propertyId;
  final String title;
  final String location;
  final String price;
  final String description;
  final String bedrooms;
  final String bathrooms;
  final String? categoryId;
  final List<String> newImagePaths;
  final List<String> newVideoPaths;
  final List<String> existingImages;
  final List<String> existingVideos;
  final BuildContext? context;

  const SubmitUpdatePropertyEvent({
    required this.propertyId,
    required this.title,
    required this.location,
    required this.price,
    required this.description,
    required this.bedrooms,
    required this.bathrooms,
    this.categoryId,
    required this.newImagePaths,
    required this.newVideoPaths,
    required this.existingImages,
    required this.existingVideos,
    this.context,
  });

  @override
  List<Object?> get props => [
    propertyId,
    title,
    location,
    price,
    description,
    bedrooms,
    bathrooms,
    categoryId,
    newImagePaths,
    newVideoPaths,
    existingImages,
    existingVideos,
    context,
  ];
}