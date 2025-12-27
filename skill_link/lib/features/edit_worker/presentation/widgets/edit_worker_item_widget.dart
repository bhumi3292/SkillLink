import 'package:flutter/material.dart';
import '../../domain/entity/edit_worker_item.dart';

class EditWorkerItemWidget extends StatelessWidget {
  final EditWorkerItem item;
  const EditWorkerItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(item.title),
    );
  }
} 