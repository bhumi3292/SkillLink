// lib/features/add_worker/presentation/bloc/add_worker_event.dart

import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart'; // For XFile
import 'package:flutter/material.dart'; // For BuildContext
import 'package:skill_link/features/add_worker/domain/entity/category/category_entity.dart';

abstract class AddWorkerEvent extends Equatable {
  const AddWorkerEvent();

  @override
  List<Object?> get props => [];
}

class InitializeAddWorkerForm extends AddWorkerEvent {
  const InitializeAddWorkerForm();

  @override
  List<Object?> get props => [];
}

class SelectCategoryEvent extends AddWorkerEvent {
  final String? categoryId;

  const SelectCategoryEvent({required this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

class AddImageEvent extends AddWorkerEvent {
  final XFile image;

  const AddImageEvent({required this.image});

  @override
  List<Object?> get props => [image];
}

class RemoveImageEvent extends AddWorkerEvent {
  final int index;

  const RemoveImageEvent({required this.index});

  @override
  List<Object?> get props => [index];
}

class AddVideoEvent extends AddWorkerEvent {
  final XFile video;

  const AddVideoEvent({required this.video});

  @override
  List<Object?> get props => [video];
}

class RemoveVideoEvent extends AddWorkerEvent {
  final int index;

  const RemoveVideoEvent({required this.index});

  @override
  List<Object?> get props => [index];
}

class NewCategoryAddedEvent extends AddWorkerEvent {
  final CategoryEntity newCategory;

  const NewCategoryAddedEvent({required this.newCategory});

  @override
  List<Object?> get props => [newCategory];
}

class SubmitWorkerEvent extends AddWorkerEvent {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String experience;
  final String skills;
  final String? categoryId;
  final BuildContext? context;

  const SubmitWorkerEvent({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.experience,
    required this.skills,
    this.categoryId,
    this.context,
  });

  @override
  List<Object?> get props => [
    fullName,
    email,
    phoneNumber,
    experience,
    skills,
    categoryId,
    context,
  ];
}

class ClearAddWorkerMessageEvent extends AddWorkerEvent {
  const ClearAddWorkerMessageEvent();

  @override
  List<Object?> get props => [];
}

class SubmitUpdateWorkerEvent extends AddWorkerEvent {
  final String workerId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String experience;
  final String skills;
  final String? categoryId;
  final List<String> newImagePaths;
  final List<String> newVideoPaths;
  final List<String> existingImages;
  final List<String> existingVideos;
  final BuildContext? context;

  const SubmitUpdateWorkerEvent({
    required this.workerId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.experience,
    required this.skills,
    this.categoryId,
    required this.newImagePaths,
    required this.newVideoPaths,
    required this.existingImages,
    required this.existingVideos,
    this.context,
  });

  @override
  List<Object?> get props => [
    workerId,
    fullName,
    email,
    phoneNumber,
    experience,
    skills,
    categoryId,
    newImagePaths,
    newVideoPaths,
    existingImages,
    existingVideos,
    context,
  ];
}
