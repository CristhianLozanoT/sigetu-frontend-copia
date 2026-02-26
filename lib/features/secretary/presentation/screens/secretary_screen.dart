import 'package:flutter/material.dart';

class SecretaryScreen extends StatelessWidget {
  const SecretaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Secretaría',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
