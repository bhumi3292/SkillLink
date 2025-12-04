import 'package:equatable/equatable.dart';
import 'package:skill_link/features/add_property/domain/entity/property/property_entity.dart';

class CartItemEntity extends Equatable {
  final String? id;
  final PropertyEntity property;

  const CartItemEntity({this.id, required this.property});

  @override
  List<Object?> get props => [id, property];

  @override
  bool get stringify => true;
}
