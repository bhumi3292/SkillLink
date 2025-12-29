import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:skill_link/features/auth/domain/entity/user_entity.dart';

part 'user_api_model.g.dart';

@JsonSerializable()
class UserApiModel extends Equatable {
  @JsonKey(name: '_id')
  final String? userId;

  final String fullName;
  final String email;
  final String? phoneNumber;
  @JsonKey(name: 'role')
  final String? stakeholder;
  final String? password;
  final String? confirmPassword;
  final String? profilePicture;

  final double? averageRating;
  final int? numReviews;
  final String? workerStatus;
  final String? rejectionReason;
  final int? viewCount;

  const UserApiModel({
    this.userId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.stakeholder,
    this.password,
    this.confirmPassword,
    this.profilePicture,
    this.averageRating,
    this.numReviews,
    this.workerStatus,
    this.rejectionReason,
    this.viewCount,
  });

  factory UserApiModel.fromJson(Map<String, dynamic> json) => UserApiModel(
    userId: json['_id'] as String?,
    fullName: json['fullName'] as String,
    email: json['email'] as String,
    phoneNumber: json['phoneNumber'] as String?,
    stakeholder: json['role'] as String?,
    password: json['password'] as String?,
    confirmPassword: json['confirmPassword'] as String?,
    profilePicture: json['profilePicture'] as String?,
    averageRating: (json['averageRating'] as num?)?.toDouble(),
    numReviews: json['numReviews'] as int?,
    workerStatus: json['workerStatus'] as String?,
    rejectionReason: json['rejectionReason'] as String?,
    viewCount: json['viewCount'] as int?,
  );

  Map<String, dynamic> toJson() => _$UserApiModelToJson(this);

  // When converting FROM ApiModel TO UserEntity (e.g., after fetching profile)
  UserEntity toEntity() {
    return UserEntity(
      userId: userId,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      stakeholder: stakeholder,
      password: null,
      confirmPassword: null,
      profilePicture: profilePicture,
      averageRating: averageRating,
      numReviews: numReviews,
      workerStatus: workerStatus,
      rejectionReason: rejectionReason,
      viewCount: viewCount,
    );
  }

  factory UserApiModel.fromEntity(UserEntity entity) {
    return UserApiModel(
      userId: entity.userId,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      stakeholder: entity.stakeholder,
      password: entity.password,
      confirmPassword: entity.confirmPassword,
      profilePicture: entity.profilePicture,
      averageRating: entity.averageRating,
      numReviews: entity.numReviews,
      workerStatus: entity.workerStatus,
      rejectionReason: entity.rejectionReason,
      viewCount: entity.viewCount,
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
