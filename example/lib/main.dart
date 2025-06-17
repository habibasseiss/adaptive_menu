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
        trailing: _TrailingWidget(),
      ),
      child: Center(child: Text("This is a test app.")),
    );
  }
}

class _TrailingWidget extends StatefulWidget {
  const _TrailingWidget();

  @override
  State<_TrailingWidget> createState() => __TrailingWidgetState();
}

class __TrailingWidgetState extends State<_TrailingWidget> {
  bool _viewAsIcons = true;
  bool _sortAscending = true;
  String? _sortItem = 'Name';

  @override
  Widget build(BuildContext context) {
    return NativeMenuWidget(
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
              checked: _viewAsIcons,
              onPressed: () {
                setState(() {
                  _viewAsIcons = true;
                });
                debugPrint('Icons was tapped!');
              },
            ),
            NativeMenuAction(
              title: 'List',
              icon: CupertinoIcons.list_bullet,
              checked: !_viewAsIcons,
              onPressed: () {
                setState(() {
                  _viewAsIcons = false;
                });
                debugPrint('List was tapped!');
              },
            ),
          ],
        ),
        NativeMenuGroup.inline(
          actions: [
            NativeMenuAction(
              title: 'Name',
              icon: _sortItem == 'Name'
                  ? (_sortAscending
                        ? CupertinoIcons.chevron_up
                        : CupertinoIcons.chevron_down)
                  : null,
              onPressed: () {
                setState(() {
                  if (_sortItem == 'Name') {
                    _sortAscending = !_sortAscending;
                  } else {
                    _sortItem = 'Name';
                    _sortAscending = true;
                  }
                });
                debugPrint('Name was tapped!');
              },
            ),
            NativeMenuAction(
              title: 'Type',
              icon: _sortItem == 'Type'
                  ? (_sortAscending
                        ? CupertinoIcons.chevron_up
                        : CupertinoIcons.chevron_down)
                  : null,
              onPressed: () {
                setState(() {
                  if (_sortItem == 'Type') {
                    _sortAscending = !_sortAscending;
                  } else {
                    _sortItem = 'Type';
                    _sortAscending = true;
                  }
                });
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
    );
  }
}
