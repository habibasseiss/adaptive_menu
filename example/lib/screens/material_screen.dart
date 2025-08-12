import 'package:adaptive_menu/adaptive_menu.dart';
import 'package:adaptive_menu_example/common/trailing_widget.dart';
import 'package:flutter/material.dart';

class MaterialScreen extends StatelessWidget {
  const MaterialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Material Example'),
        actions: [
          TrailingWidget(
            type: AdaptiveMenuType.material,
            builder: (openMenu) => IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: openMenu,
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          AdaptiveMenu(
            type: AdaptiveMenuType.material,
            items: [
              AdaptiveMenuAction(
                title: 'Select',
                icon: Icons.check,
                onPressed: () {
                  debugPrint('Select was tapped!');
                },
              ),
              AdaptiveMenuAction(
                title: 'New Folder',
                icon: Icons.folder,
                onPressed: () {
                  debugPrint('New Folder was tapped!');
                },
              ),
            ],
            builder: (openMenu) => ListTile(
              title: const Text('List Tile Menu'),
              trailing: Icon(Icons.more_vert),
              onTap: openMenu,
            ),
          ),
        ],
      ),
    );
  }
}
