import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class UserEntity extends Equatable {
  final String? userId;
  final String fullName;
  final String email;
  final String? phoneNumber; // Made nullable
  final String? stakeholder; // Made nullable
  final String? password; // ⭐ Made nullable ⭐
  final String? confirmPassword; // ⭐ Made nullable ⭐
  final String? profilePicture;
  final LatLng? location;

  final double? averageRating;
  final int? numReviews;
  final String? workerStatus; // 'pending', 'approved', 'rejected'
  final String? rejectionReason;
  final int? viewCount;

  const UserEntity({
    this.userId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.stakeholder,
    this.password,
    this.confirmPassword,
    this.profilePicture,
    this.location,
    this.averageRating,
    this.numReviews,
    this.workerStatus,
    this.rejectionReason,
    this.viewCount,
  });

  UserEntity copyWith({
    String? userId,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? stakeholder,
    String? password,
    String? confirmPassword,
    String? profilePicture,
    double? averageRating,
    int? numReviews,
    int? viewCount,
  }) {
    return UserEntity(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      stakeholder: stakeholder ?? this.stakeholder,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      profilePicture: profilePicture ?? this.profilePicture,
      averageRating: averageRating ?? this.averageRating,
      numReviews: numReviews ?? this.numReviews,
      workerStatus: workerStatus ?? workerStatus,
      rejectionReason: rejectionReason ?? rejectionReason,
      viewCount: viewCount ?? this.viewCount,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    fullName,
    email,
    phoneNumber,
    stakeholder,
    password,
    confirmPassword,
    profilePicture,
    averageRating,
    numReviews,
    workerStatus,
    rejectionReason,
    viewCount,
  ];
}