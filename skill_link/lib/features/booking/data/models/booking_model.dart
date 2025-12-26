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
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['_id'] ?? '',
      workerListingId: (json['workerListing'] is Map) ? json['workerListing']['_id'] : (json['workerListing'] ?? json['property'] ?? ''),
      hirerId: (json['Hirer'] is Map) ? json['Hirer']['_id'] : (json['Hirer'] ?? ''),
      workerId: (json['worker'] is Map) ? json['worker']['_id'] : (json['worker'] ?? ''),
      date: json['date'] ?? '',
      timeSlot: json['timeSlot'] ?? '',
      status: json['status'] ?? 'Pending',
      location: json['location'],
      hirer: json['Hirer'] is Map ? json['Hirer'] : null,
      worker: json['worker'] is Map ? json['worker'] : null,
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
  );
}
