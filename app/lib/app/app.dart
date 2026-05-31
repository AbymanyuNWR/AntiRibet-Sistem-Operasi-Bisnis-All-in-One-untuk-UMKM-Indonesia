import 'package:flutter/material.dart';

class AntiribetApp extends StatelessWidget {
  const AntiribetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Antiribet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Antiribet Flutter MVP'),
        ),
      ),
    );
  }
}
