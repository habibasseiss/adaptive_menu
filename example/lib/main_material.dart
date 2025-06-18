import 'package:flutter/material.dart';
import 'package:native_menu/adaptive_menu.dart';
import 'package:native_menu_example/common/trailing_widget.dart';

void main() {
  runApp(const MyMaterialApp());
}

class MyMaterialApp extends StatelessWidget {
  const MyMaterialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adaptive Menu Example'),
        actions: [TrailingWidget(type: AdaptiveMenuType.material)],
      ),
    );
  }
}
