// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserApiModel _$UserApiModelFromJson(Map<String, dynamic> json) => UserApiModel(
      userId: json['_id'] as String?,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      stakeholder: json['role'] as String?,
      password: json['password'] as String?,
      confirmPassword: json['confirmPassword'] as String?,
      profilePicture: json['profilePicture'] as String?,
    );

Map<String, dynamic> _$UserApiModelToJson(UserApiModel instance) =>
    <String, dynamic>{
      '_id': instance.userId,
      'fullName': instance.fullName,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'role': instance.stakeholder,
      'password': instance.password,
      'confirmPassword': instance.confirmPassword,
      'profilePicture': instance.profilePicture,
    };
