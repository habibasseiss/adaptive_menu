import 'package:flutter/material.dart';
import 'package:adaptive_menu/adaptive_menu.dart';
import 'package:adaptive_menu_example/common/trailing_widget.dart';

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
        actions: [
          TrailingWidget(
            type: AdaptiveMenuType.material,
            child: Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SizedBox(
        width: double.infinity,
        child: Image.asset(
          'assets/image.png',
          fit: BoxFit.fitWidth,
          alignment: Alignment.topCenter,
        ),
      ),
    );
  }
}
