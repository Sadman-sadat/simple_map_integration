import 'package:flutter/material.dart';
import 'package:simple_map_integration/map_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Map & Location Tracker',
      theme: ThemeData(),
      debugShowCheckedModeBanner: false,
      home: const MapScreen(),
    );
  }
}
