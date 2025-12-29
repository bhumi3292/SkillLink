import 'package:equatable/equatable.dart';

class BookingEntity extends Equatable {
  final String id;
  final String workerListingId;
  final String hirerId; // User who booked
  final String workerId; // Worker user
  final String date;
  final String timeSlot;
  final String status;
  final dynamic location; // {coordinates: [lng, lat], address: string}

  final dynamic hirer;
  final dynamic worker;
  final bool isRated;
  final List<dynamic>? timeline;
  final String? cancellationReason;
  final List<dynamic>? rescheduleRequests;

  const BookingEntity({
    required this.id,
    required this.workerListingId,
    required this.hirerId,
    required this.workerId,
    required this.date,
    required this.timeSlot,
    required this.status,
    this.location,
    this.hirer,
    this.worker,
    this.isRated = false,
    this.timeline,
    this.cancellationReason,
    this.rescheduleRequests,
  });

  @override
  List<Object?> get props => [
    id,
    workerListingId,
    hirerId,
    workerId,
    date,
    timeSlot,
    status,
    location,
    hirer,
    worker,
    isRated,
    timeline,
    cancellationReason,
    rescheduleRequests,
  ];
}
