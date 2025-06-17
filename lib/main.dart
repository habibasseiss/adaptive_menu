import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello/hello.dart';

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

  Future<void> _handleNativeButtonTap() async {
    print('NativeButtonWidget (from hello package) was tapped!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter Demo Home Page'),
        actions: [
          IconButton(
            onPressed: _handleNativeButtonTap,
            icon: Icon(CupertinoIcons.ellipsis_circle),
          ),
          NativeButtonWidget(
            onPressed: _handleNativeButtonTap,
            size: const Size(48, 32),
            items: [
              NativeButtonAction(
                title: 'Select',
                icon: CupertinoIcons.check_mark_circled,
                onPressed: () {
                  debugPrint('Select was tapped!');
                },
              ),
              NativeButtonAction(
                title: 'New Folder',
                icon: CupertinoIcons.folder_badge_plus,
                onPressed: () {
                  debugPrint('New Folder was tapped!');
                },
              ),
              NativeButtonAction(
                title: 'Scan Documents',
                icon: CupertinoIcons.doc_text_viewfinder,
                onPressed: () {
                  debugPrint('Scan Documents was tapped!');
                },
              ),
              NativeButtonGroup.inline(
                actions: [
                  NativeButtonAction(
                    title: 'Icons',
                    icon: CupertinoIcons.rectangle_grid_2x2,
                    onPressed: () {
                      debugPrint('Icons was tapped!');
                    },
                  ),
                  NativeButtonAction(
                    title: 'List',
                    icon: CupertinoIcons.list_bullet,
                    onPressed: () {
                      debugPrint('List was tapped!');
                    },
                  ),
                ],
              ),
              NativeButtonGroup.inline(
                actions: [
                  NativeButtonAction(
                    title: 'Name',
                    icon: CupertinoIcons.chevron_up,
                    onPressed: () {
                      debugPrint('Name was tapped!');
                    },
                  ),
                  NativeButtonAction(
                    title: 'Type',
                    onPressed: () {
                      debugPrint('Type was tapped!');
                    },
                  ),
                ],
              ),
            ],
            // child: Text("Button", style: TextStyle(color: Colors.white)),
            child: Icon(CupertinoIcons.ellipsis_circle),
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
