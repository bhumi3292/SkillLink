import 'package:flutter/material.dart';

void showMySnackbar({
  required BuildContext context,
  required String content,
  required bool isSuccess,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
