import 'package:adaptive_menu/adaptive_menu.dart';
import 'package:adaptive_menu_example/common/trailing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoScreen extends StatelessWidget {
  const CupertinoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: const CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      child: Theme(
        data: ThemeData(scaffoldBackgroundColor: Colors.white),
        child: Scaffold(
          bottomNavigationBar: _BottomNavigationBar(),
          body: CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: const Text('Cupertino Example'),
              leading: CupertinoNavigationBarBackButton(
                previousPageTitle: 'Back',
              ),
              trailing: TrailingWidget(
                type: AdaptiveMenuType.native,
                builder: (openMenu) => CupertinoButton(
                  onPressed: openMenu,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(
                    CupertinoIcons.ellipsis_circle,
                    size: 26,
                    color: Colors.blue,
                  ),
                ),
              ),
              padding: EdgeInsetsDirectional.zero,
            ),
            child: ListView(
              children: [_WidgetMenu(), _TextMenu(), _ListItemButton()],
            ),
          ),
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
              builder: (openMenu) => CupertinoButton(
                onPressed: openMenu,
                child: Icon(
                  CupertinoIcons.square_on_square,
                  size: 24,
                  color: CupertinoTheme.of(context).primaryColor,
                ),
              ),
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AdaptiveMenu(
        type: AdaptiveMenuType.native,
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
        builder: (_) => Card(
          elevation: 0,
          color: Colors.blueGrey.shade200,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0),
            width: 100,
            height: 100,
            child: const Text(
              'This is a Card Menu',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _TextMenu extends StatelessWidget {
  const _TextMenu();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AdaptiveMenu(
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
        builder: (openMenu) => const Text('This is a Text Menu'),
      ),
    );
  }
}

class _ListItemButton extends StatelessWidget {
  const _ListItemButton();

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      children: [
        AdaptiveMenu(
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
          builder: (openMenu) => CupertinoListTile.notched(
            onTap: openMenu,
            leading: FlutterLogo(),
            title: Text('List Item Menu'),
            trailing: Icon(Icons.unfold_more),
          ),
        ),
      ],
    );
  }
}
