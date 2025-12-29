import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:skill_link/features/add_worker/domain/entity/category/category_entity.dart';

part 'category_api_model.g.dart';

@JsonSerializable()
class CategoryApiModel extends Equatable {
  @JsonKey(name: '_id')
  final String? id;

  @JsonKey(name: 'category_name', required: true)
  final String categoryName;

  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;

  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;

  const CategoryApiModel({
    this.id,
    required this.categoryName,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryApiModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryApiModelFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryApiModelToJson(this);

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      categoryName: categoryName,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory CategoryApiModel.fromEntity(CategoryEntity entity) {
    return CategoryApiModel(
      id: entity.id,
      categoryName: entity.categoryName,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, categoryName, createdAt, updatedAt];

  @override
  bool get stringify => true;

  CategoryApiModel copyWith({
    String? id,
    String? categoryName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryApiModel(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
