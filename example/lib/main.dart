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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // body: Center(child: Text("This is a test app.")),
        bottomNavigationBar: _BottomNavigationBar(),
      ),
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

class _BottomNavigationBar extends StatelessWidget {
  const _BottomNavigationBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CupertinoButton(
              onPressed: null,
              child: Icon(CupertinoIcons.chevron_left, size: 24),
            ),
            CupertinoButton(
              onPressed: null,
              child: Icon(CupertinoIcons.chevron_right, size: 24),
            ),
            CupertinoButton(
              child: Icon(CupertinoIcons.share, size: 24),
              onPressed: () {},
            ),
            CupertinoButton(
              child: Icon(CupertinoIcons.book, size: 24),
              onPressed: () {},
            ),
            NativeMenuWidget(
              onPressed: () {
                debugPrint('NativeMenuWidget was tapped!');
              },
              size: const Size(64, 32),
              items: [
                NativeMenuAction(
                  title: 'New Tab',
                  icon: CupertinoIcons.plus_square_on_square,
                  onPressed: () {
                    debugPrint('New Tab was tapped!');
                  },
                ),
                NativeMenuAction(
                  title: 'New Private Tab',
                  icon: CupertinoIcons.plus_square_fill_on_square_fill,
                  onPressed: () {
                    debugPrint('New Private Tab was tapped!');
                  },
                ),
                NativeMenuAction.destructive(
                  title: 'Close This Tab',
                  icon: CupertinoIcons.xmark,
                  onPressed: () {
                    debugPrint('Close This Tab was tapped!');
                  },
                ),
                NativeMenuAction.destructive(
                  title: 'Close All Tabs',
                  icon: CupertinoIcons.xmark,
                  onPressed: () {
                    debugPrint('Close All Tabs was tapped!');
                  },
                ),
              ],
              child: Icon(CupertinoIcons.square_on_square, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}
