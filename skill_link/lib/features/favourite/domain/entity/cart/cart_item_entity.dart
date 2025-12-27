import 'package:equatable/equatable.dart';
import 'package:skill_link/features/add_worker/domain/entity/worker/worker_entity.dart';

class CartItemEntity extends Equatable {
  final String? id;
  final WorkerEntity worker;

  const CartItemEntity({this.id, required this.worker});

  @override
  List<Object?> get props => [id, worker];

  @override
  bool get stringify => true;
}
