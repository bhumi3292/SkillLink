import 'package:flutter/material.dart';
import '../../domain/entity/contact_worker_item.dart';

class ContactworkerItemWidget extends StatelessWidget {
  final ContactworkerItem item;
  const ContactworkerItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(item.title));
  }
}
