import 'package:equatable/equatable.dart';
import 'package:skill_link/features/explore/domain/entity/explore_worker_entity.dart';
import 'dart:io';

abstract class WorkerProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchWorkerProfileEvent extends WorkerProfileEvent {
  final String workerId;
  FetchWorkerProfileEvent(this.workerId);
  @override
  List<Object?> get props => [workerId];
}

class UpdateWorkerEvent extends WorkerProfileEvent {
  final String workerId;
  final Map<String, dynamic> data;
  final List<File>? newImages;
  UpdateWorkerEvent({required this.workerId, required this.data, this.newImages});
  @override
  List<Object?> get props => [workerId, data, newImages];
}

class DeactivateWorkerEvent extends WorkerProfileEvent {
  final String workerId;
  DeactivateWorkerEvent(this.workerId);
  @override
  List<Object?> get props => [workerId];
}
