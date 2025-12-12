import 'package:equatable/equatable.dart';
import 'package:skill_link/features/add_worker/domain/entity/worker/worker_entity.dart';

class CartItemEntity extends Equatable {
  final String? id;
  final WorkerEntity property;

  const CartItemEntity({this.id, required this.property});

  @override
  List<Object?> get props => [id, property];

  @override
  bool get stringify => true;
}
