import 'package:equatable/equatable.dart';

class ReviewModel extends Equatable {
  final String id;
  final String hirerName;
  final String? hirerProfilePicture;
  final double rating;
  final String? comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.hirerName,
    this.hirerProfilePicture,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['_id'] as String,
      hirerName: (json['hirer'] is Map) ? (json['hirer']['fullName'] ?? 'Anonymous') : 'Anonymous',
      hirerProfilePicture: (json['hirer'] is Map) ? json['hirer']['profilePicture'] : null,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, hirerName, hirerProfilePicture, rating, comment, createdAt];
}
