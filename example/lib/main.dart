import 'package:adaptive_menu_example/screens/cupertino_screen.dart';
import 'package:adaptive_menu_example/screens/home_screen.dart';
import 'package:adaptive_menu_example/screens/material_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const HomeScreen(),
        '/cupertino': (context) => const CupertinoScreen(),
        '/material': (context) => const MaterialScreen(),
      },
    );
  }
}
