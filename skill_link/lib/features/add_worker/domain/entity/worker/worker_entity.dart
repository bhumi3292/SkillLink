import 'package:equatable/equatable.dart';

class WorkerEntity extends Equatable {
  final String? id;
  final List<String>? images;
  final List<String>? videos;
  final String? name;
  String? get title => name;
  final String? primarySkill;
  final String? experience;
  final String? description;
  final String? location;
  final String? categoryId;
  final double? rate;
  final String? portfolioUrl;
  double? get price => rate;
  String? get workerId => id;
  final String? addedByAdminId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? coordinates;

  const WorkerEntity({
    this.id,
    this.images,
    this.videos,
    this.name,
    this.primarySkill,
    this.experience,
    this.description,
    this.location,
    this.categoryId,
    this.rate,
    this.portfolioUrl,
    this.addedByAdminId,
    this.createdAt,
    this.updatedAt,
    this.coordinates,
  });

  factory WorkerEntity.fromJson(Map<String, dynamic> json) {
    String? categoryId;
    if (json['categoryId'] != null) {
      if (json['categoryId'] is String) {
        categoryId = json['categoryId'] as String;
      } else if (json['categoryId'] is Map<String, dynamic>) {
        categoryId = json['categoryId']['_id'] as String?;
      }
    }

    String? adminId;
    if (json['addedByAdmin'] != null) {
      if (json['addedByAdmin'] is String) {
        adminId = json['addedByAdmin'] as String;
      } else if (json['addedByAdmin'] is Map<String, dynamic>) {
        adminId = json['addedByAdmin']['_id'] as String?;
      }
    }

    return WorkerEntity(
      id: json['_id'] as String?,
      images: (json['images'] as List?)?.map((e) => e.toString()).toList(),
      videos: (json['videos'] as List?)?.map((e) => e.toString()).toList(),
      name: json['name'] as String?,
      primarySkill: json['primarySkill'] as String?,
      experience: json['experience'] as String?,
      description: json['description'] as String?,
      location: (json['location'] is Map) 
          ? (json['location']['address'] ?? json['location']['formattedAddress'] ?? '') 
          : (json['location'] as String?),
      categoryId: categoryId,
      rate: (json['rate'] as num?)?.toDouble(),
      portfolioUrl: json['portfolioUrl'] as String?,
      addedByAdminId: adminId,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      coordinates: json['coordinates'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      '_id': id,
      'images': images,
      'videos': videos,
      'name': name,
      'primarySkill': primarySkill,
      'experience': experience,
      'description': description,
      'location': location,
      'categoryId': categoryId,
      'rate': rate,
      'portfolioUrl': portfolioUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'coordinates': coordinates,
    };

    if (addedByAdminId != null) {
      json['addedByAdmin'] = addedByAdminId;
    }

    return json;
  }

  WorkerEntity copyWith({
    String? id,
    List<String>? images,
    List<String>? videos,
    String? name,
    String? primarySkill,
    String? experience,
    String? description,
    String? location,
    String? categoryId,
    double? rate,
    String? portfolioUrl,
    String? addedByAdminId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? coordinates,
  }) {
    return WorkerEntity(
      id: id ?? this.id,
      images: images ?? this.images,
      videos: videos ?? this.videos,
      name: name ?? this.name,
      primarySkill: primarySkill ?? this.primarySkill,
      experience: experience ?? this.experience,
      description: description ?? this.description,
      location: location ?? this.location,
      categoryId: categoryId ?? this.categoryId,
      rate: rate ?? this.rate,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      addedByAdminId: addedByAdminId ?? this.addedByAdminId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      coordinates: coordinates ?? this.coordinates,
    );
  }

  @override
  List<Object?> get props => [
        id,
        images,
        videos,
        name,
        primarySkill,
        experience,
        description,
        location,
        categoryId,
        rate,
        portfolioUrl,
        addedByAdminId,
        createdAt,
        updatedAt,
        coordinates,
      ];
}
