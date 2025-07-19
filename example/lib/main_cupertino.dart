import 'package:adaptive_menu/adaptive_menu.dart';
import 'package:adaptive_menu_example/common/trailing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyCupertinoApp());
}

class MyCupertinoApp extends StatelessWidget {
  const MyCupertinoApp({super.key});

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
        middle: const Text('Adaptive Menu Example'),
        leading: _TextNativeButton(),
        trailing: TrailingWidget(
          type: AdaptiveMenuType.native,
          child: Icon(CupertinoIcons.ellipsis_circle, size: 26),
        ),
        padding: EdgeInsetsDirectional.only(start: 16, end: 0),
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SizedBox(
            width: double.infinity,
            child: Center(child: _WidgetMenu()),
          ),
          bottomNavigationBar: _BottomNavigationBar(),
        ),
      ),
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
            AdaptiveMenu(
              onPressed: () {
                debugPrint('NativeMenuWidget was tapped!');
              },
              size: const Size(64, 32),
              items: [
                AdaptiveMenuAction(
                  title: 'New Tab',
                  icon: CupertinoIcons.plus_square_on_square,
                  onPressed: () {
                    debugPrint('New Tab was tapped!');
                  },
                ),
                AdaptiveMenuAction(
                  title: 'New Private Tab',
                  icon: CupertinoIcons.plus_square_fill_on_square_fill,
                  onPressed: () {
                    debugPrint('New Private Tab was tapped!');
                  },
                ),
                AdaptiveMenuGroup(
                  title: 'Move to Tab Group',
                  icon: CupertinoIcons.square_arrow_right,
                  actions: [
                    AdaptiveMenuAction(
                      title: 'New Tab Group',
                      icon: CupertinoIcons.plus_square_on_square,
                      onPressed: () {
                        debugPrint('New Tab Group was tapped!');
                      },
                    ),
                    AdaptiveMenuGroup.inline(
                      actions: [
                        AdaptiveMenuAction(
                          title: '2 Tabs',
                          icon: CupertinoIcons.device_phone_portrait,
                          checked: true,
                          onPressed: () {
                            debugPrint('2 Tabs was tapped!');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                AdaptiveMenuAction.destructive(
                  title: 'Close This Tab',
                  icon: CupertinoIcons.xmark,
                  onPressed: () {
                    debugPrint('Close This Tab was tapped!');
                  },
                ),
                AdaptiveMenuAction.destructive(
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

class _WidgetMenu extends StatelessWidget {
  const _WidgetMenu();

  @override
  Widget build(BuildContext context) {
    return AdaptiveMenu(
      type: AdaptiveMenuType.native,
      size: const Size(100, 100),
      items: [
        AdaptiveMenuAction(
          title: 'Select',
          icon: CupertinoIcons.check_mark_circled,
          onPressed: () {
            debugPrint('Select was tapped!');
          },
        ),
        AdaptiveMenuAction(
          title: 'New Folder',
          icon: CupertinoIcons.folder_badge_plus,
          onPressed: () {
            debugPrint('New Folder was tapped!');
          },
        ),
      ],
      child: Card(
        color: Colors.red,
        child: SizedBox(
          width: 100,
          height: 100,
          child: Center(child: const Text('Card')),
        ),
      ),
    );
  }
}

class _TextNativeButton extends StatelessWidget {
  const _TextNativeButton();

  @override
  Widget build(BuildContext context) {
    return AdaptiveMenu(
      // type: AdaptiveMenuType.material,
      size: const Size(100, 30),
      items: [
        AdaptiveMenuAction(
          title: 'Select',
          icon: CupertinoIcons.check_mark_circled,
          onPressed: () {
            debugPrint('Select was tapped!');
          },
        ),
        AdaptiveMenuAction(
          title: 'New Folder',
          icon: CupertinoIcons.folder_badge_plus,
          onPressed: () {
            debugPrint('New Folder was tapped!');
          },
        ),
      ],
      child: const Text('Leading'),
    );
  }
}
