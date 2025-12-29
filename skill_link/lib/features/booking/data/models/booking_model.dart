import '../../domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.workerListingId,
    required super.hirerId,
    required super.workerId,
    required super.date,
    required super.timeSlot,
    required super.status,
    super.location,
    super.hirer,
    super.worker,
    super.isRated = false,
    super.timeline,
    super.cancellationReason,
    super.rescheduleRequests,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    String extractId(dynamic value) {
      if (value == null) return '';
      if (value is Map) return value['_id']?.toString() ?? '';
      return value.toString();
    }

    return BookingModel(
      id: json['_id'] ?? '',
      workerListingId:
          json['workerListing'] != null
              ? extractId(json['workerListing'])
              : extractId(json['property']),
      hirerId: extractId(json['Hirer']),
      workerId: extractId(json['worker']),
      date: json['date'] ?? '',
      timeSlot: json['timeSlot'] ?? '',
      status: json['status'] ?? 'Pending',
      location: json['location'],
      hirer: json['Hirer'] is Map ? json['Hirer'] : null,
      worker: json['worker'] is Map ? json['worker'] : null,
      isRated: json['isRated'] ?? false,
      // optional timeline and reschedule data
      timeline: json['timeline'] is List ? json['timeline'] : null,
      cancellationReason:
          json['cancellationReason'] ?? json['cancellation_reason'],
      rescheduleRequests:
          json['rescheduleRequests'] is List
              ? json['rescheduleRequests']
              : json['reschedule_requests'] is List
              ? json['reschedule_requests']
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'workerListing': workerListingId,
      'Hirer': hirerId,
      'worker': workerId,
      'date': date,
      'timeSlot': timeSlot,
      'status': status,
      'location': location,
      'isRated': isRated,
      'timeline': timeline,
      'cancellationReason': cancellationReason,
      'rescheduleRequests': rescheduleRequests,
    };
  }

  @override
  BookingEntity toEntity() => BookingEntity(
    id: id,
    workerListingId: workerListingId,
    hirerId: hirerId,
    workerId: workerId,
    date: date,
    timeSlot: timeSlot,
    status: status,
    location: location,
    hirer: hirer,
    worker: worker,
    isRated: isRated,
    timeline: timeline,
    cancellationReason: cancellationReason,
    rescheduleRequests: rescheduleRequests,
  );
}
