import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:native_menu/adaptive_menu.dart';
import 'package:native_menu_example/common/trailing_widget.dart';

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
            child: Image.asset(
              'assets/image.png',
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
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
