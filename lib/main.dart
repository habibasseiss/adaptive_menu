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
                title: 'Menu Item 1',
                icon: CupertinoIcons.archivebox,
                onPressed: () {
                  print('Action 1 was tapped!');
                },
              ),
              NativeButtonAction(
                title: 'Menu Item 2',
                icon: CupertinoIcons.ellipses_bubble,
                onPressed: () {
                  print('Action 2 was tapped!');
                },
              ),
              NativeButtonGroup.inline(
                // title: 'Group',
                actions: [
                  NativeButtonAction.destructive(
                    title: 'Menu Item 3',
                    icon: CupertinoIcons.share_up,
                    onPressed: () {
                      print('Action 3 was tapped!');
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
          children: <Widget>[
            const Text("This is a test app."),
          
            NativeButtonWidget(
              onPressed: _handleNativeButtonTap,
              size: const Size(48, 32),
              items: [
                NativeButtonAction(
                  title: 'Menu Item 1',
                  icon: CupertinoIcons.archivebox,
                  onPressed: () {
                    print('Action 1 was tapped!');
                  },
                ),
                NativeButtonAction(
                  title: 'Menu Item 2',
                  icon: CupertinoIcons.ellipses_bubble,
                  onPressed: () {
                    print('Action 2 was tapped!');
                  },
                ),
                NativeButtonGroup(
                  title: 'Group',
                  actions: [
                    NativeButtonGroup(
                      title: 'Sub Group',
                      actions: [
                        NativeButtonAction(
                          title: 'Menu Item 4',
                          icon: CupertinoIcons.doc_text,
                          onPressed: () {
                            print('Action 4 was tapped!');
                          },
                        ),
                        NativeButtonAction.destructive(
                          title: 'Menu Item 3',
                          icon: CupertinoIcons.share_up,
                          onPressed: () {
                            print('Action 3 was tapped!');
                          },
                        ),
                      ],
                    ),
                    NativeButtonAction(
                      title: 'Menu Item 4',
                      icon: CupertinoIcons.doc_text,
                      onPressed: () {
                        print('Action 4 was tapped!');
                      },
                    ),
                    NativeButtonAction.destructive(
                      title: 'Menu Item 3',
                      icon: CupertinoIcons.share_up,
                      onPressed: () {
                        print('Action 3 was tapped!');
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
      ),
    );
  }
}
