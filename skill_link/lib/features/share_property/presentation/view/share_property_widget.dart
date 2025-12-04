import 'package:flutter/material.dart';

class SharePropertyWidget extends StatelessWidget {
  const SharePropertyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Property'),
      ),
      body: const Center(
        child: Text('Share Property Widget'),
      ),
    );
  }
} 