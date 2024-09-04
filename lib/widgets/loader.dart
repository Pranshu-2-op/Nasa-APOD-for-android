import 'package:flutter/material.dart';

class NasaLoader extends StatelessWidget {
  const NasaLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/loader.gif', // Ensure this path matches your pubspec.yaml
        width: 100, // Adjust width as needed
        height: 100, // Adjust height as needed
      ),
    );
  }
}
