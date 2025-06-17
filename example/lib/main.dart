import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:native_menu/native_menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter Demo Home Page'),
        actions: [
          NativeMenuWidget(
            size: const Size(48, 32),
            items: [
              NativeMenuAction(
                title: 'Select',
                icon: CupertinoIcons.check_mark_circled,
                onPressed: () {
                  debugPrint('Select was tapped!');
                },
              ),
              NativeMenuAction(
                title: 'New Folder',
                icon: CupertinoIcons.folder_badge_plus,
                onPressed: () {
                  debugPrint('New Folder was tapped!');
                },
              ),
              NativeMenuAction(
                title: 'Scan Documents',
                icon: CupertinoIcons.doc_text_viewfinder,
                onPressed: () {
                  debugPrint('Scan Documents was tapped!');
                },
              ),
              NativeMenuGroup.inline(
                actions: [
                  NativeMenuAction(
                    title: 'Icons',
                    icon: CupertinoIcons.rectangle_grid_2x2,
                    onPressed: () {
                      debugPrint('Icons was tapped!');
                    },
                  ),
                  NativeMenuAction(
                    title: 'List',
                    icon: CupertinoIcons.list_bullet,
                    onPressed: () {
                      debugPrint('List was tapped!');
                    },
                  ),
                ],
              ),
              NativeMenuGroup.inline(
                actions: [
                  NativeMenuAction(
                    title: 'Name',
                    icon: CupertinoIcons.chevron_up,
                    onPressed: () {
                      debugPrint('Name was tapped!');
                    },
                  ),
                  NativeMenuAction(
                    title: 'Type',
                    onPressed: () {
                      debugPrint('Type was tapped!');
                    },
                  ),
                ],
              ),
            ],
            // child: Text("Button", style: TextStyle(color: Colors.white)),
            child: Icon(
              CupertinoIcons.ellipsis_circle,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text("This is a test app.")],
        ),
      ),
    );
  }
}
