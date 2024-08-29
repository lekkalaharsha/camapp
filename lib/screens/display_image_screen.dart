import 'dart:io';
import 'package:flutter/material.dart';

class DisplayImageScreen extends StatelessWidget {
  final File imageFile;

  const DisplayImageScreen({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Captured Image'),
      ),
      body: Center(
        child: Image.file(imageFile),
      ),
    );
  }
}
