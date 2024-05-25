import 'package:flutter/material.dart';
import 'screens/screen1.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //title: '',
      theme: ThemeData(),
      home: const Screen1(),
      debugShowCheckedModeBanner: false,
    );
  }
}
