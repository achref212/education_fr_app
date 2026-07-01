import 'package:flutter/material.dart';

import 'injection/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  runApp(const EducationFrApp());
}

class EducationFrApp extends StatelessWidget {
  const EducationFrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Education FR',
      home: Scaffold(
        body: Center(
          child: Text('Education FR — Service Layer Ready'),
        ),
      ),
    );
  }
}
