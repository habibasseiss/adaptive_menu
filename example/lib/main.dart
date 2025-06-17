import 'package:flutter/cupertino.dart';
import 'package:native_menu/native_menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Native Menu Example'),
        trailing: NativeMenuWidget(
          size: const Size(24, 24),
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
            NativeMenuGroup.inline(
              actions: [
                NativeMenuAction.destructive(
                  title: 'Delete',
                  icon: CupertinoIcons.trash,
                  onPressed: () {
                    debugPrint('Delete was tapped!');
                  },
                ),
              ],
            ),
          ],
          // child: Text("Button", style: TextStyle(color: Colors.white)),
          child: Icon(CupertinoIcons.ellipsis_circle),
        ),
      ),
      child: Center(child: Text("This is a test app.")),
    );
  }
}
