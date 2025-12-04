import 'package:skill_link/features/explore/domain/entity/explore_property_entity.dart';

class ExplorePropertyModel extends ExplorePropertyEntity {
  ExplorePropertyModel({
    super.id,
    super.images,
    super.videos,
    super.title,
    super.location,
    super.bedrooms,
    super.bathrooms,
    super.categoryId,
    super.categoryName,
    super.price,
    super.description,
    super.workerId,
    super.workerName,
    super.workerEmail,
    super.workerPhone,
  });

  factory ExplorePropertyModel.fromJson(Map<String, dynamic> json) {
    return ExplorePropertyModel(
      id: json['_id']?.toString(),
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      videos: json['videos'] != null ? List<String>.from(json['videos']) : [],
      title: json['title']?.toString(),
      location: json['location']?.toString(),
      bedrooms:
          json['bedrooms'] != null
              ? int.tryParse(json['bedrooms'].toString())
              : null,
      bathrooms:
          json['bathrooms'] != null
              ? int.tryParse(json['bathrooms'].toString())
              : null,
      categoryId:
          json['categoryId']?['_id']?.toString() ??
          json['categoryId']?.toString(),
      categoryName: json['categoryId']?['category_name']?.toString(),
      price:
          json['price'] != null
              ? double.tryParse(json['price'].toString())
              : null,
      description: json['description']?.toString(),
      workerId:
          json['worker']?['_id']?.toString() ?? json['worker']?.toString(),
      workerName: json['worker']?['fullName']?.toString(),
      workerEmail: json['worker']?['email']?.toString(),
      workerPhone: json['worker']?['phoneNumber']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'images': images,
      'videos': videos,
      'title': title,
      'location': location,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'categoryId': categoryId,
      'category_name': categoryName,
      'price': price,
      'description': description,
      'workerId': workerId,
      'workerName': workerName,
      'workerEmail': workerEmail,
      'workerPhone': workerPhone,
    };
  }
}
