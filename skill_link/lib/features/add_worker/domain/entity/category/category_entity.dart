import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String? id; // Matches MongoDB's _id
  final String categoryName; // Matches category_name, non-nullable because 'required: true'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CategoryEntity({
    this.id,
    required this.categoryName, // Marked as required in constructor
    this.createdAt,
    this.updatedAt,
  });

  CategoryEntity copyWith({
    String? id,
    String? categoryName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    categoryName,
    createdAt,
    updatedAt,
  ];
}