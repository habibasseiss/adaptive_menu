import 'package:adaptive_menu/adaptive_menu.dart';
import 'package:adaptive_menu_example/common/trailing_widget.dart';
import 'package:flutter/material.dart';

class ExampleMaterialScreen extends StatelessWidget {
  const ExampleMaterialScreen({super.key});

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
