# Adaptive Menu

A Flutter package that provides an adaptive menu widget. It displays a native iOS pull-down menu on iOS and a Material Design popup menu on other platforms. This ensures your app feels native on every device, especially on iOS.

## Features

- **Platform-Adaptive:** Automatically uses `UIMenu` on iOS for a native feel
and falls back to `PopupMenuButton` on Android and other platforms.
- **Easy to Use:** A simple `AdaptiveMenu` widget that takes a list of actions
and a child to display.
- **Customizable:** Supports menu groups, dividers, icons, and destructive
actions.

## Getting Started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  adaptive_menu: ^1.0.0 # Replace with the latest version
```

Then run `flutter pub get`.

### Installation for iOS

This package expects the font file for the icons you want to use in the menu to
be available in the native iOS project. Any font file used in Flutter's
`IconData` issupported.

The following example adds the `CupertinoIcons` font file to the native iOS
project. We provide the font file in the `assets/fonts` directory.

1. In Xcode, drag and drop the `CupertinoIcons.ttf` font file to the `Runner`
directory. Use "Copy files to destination" action and make sure the Runner
target is checked. Click "Finish".

2. Edit the `Info.plist` file to add the font file to the `UIAppFonts` key.

```xml
<key>UIAppFonts</key>
<array>
  <string>CupertinoIcons.ttf</string>
</array>
```

## Usage

Here's a simple example of how to use the `AdaptiveMenu` widget.

```dart
import 'package:flutter/material.dart';
import 'package:adaptive_menu/adaptive_menu.dart';

class MenuDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adaptive Menu Demo'),
        actions: [
          AdaptiveMenu(
            // The widget that will trigger the menu.
            // Note: Currently, this must be an Icon.
            child: Icon(Icons.more_vert),
            // The items to display in the menu.
            items: [
              AdaptiveMenuAction(
                title: 'Share',
                icon: Icons.share,
                onPressed: () => print('Shared!'),
              ),
              AdaptiveMenuAction(
                title: 'Favorite',
                icon: Icons.favorite,
                onPressed: () => print('Favorited!'),
              ),
              // Use an inline group to create a section with a divider.
              AdaptiveMenuGroup.inline(
                actions: [
                  AdaptiveMenuAction.destructive(
                    title: 'Delete',
                    icon: Icons.delete,
                    onPressed: () => print('Deleted!'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Text('Press the menu button in the app bar!'),
      ),
    );
  }
}
```

### Forcing a Menu Type

By default, `AdaptiveMenu` chooses the menu type based on the platform. However,
you can force a specific type using the `type` parameter:

```dart
AdaptiveMenu(
  // Force a Material menu, even on iOS.
  type: AdaptiveMenuType.material,
  child: Icon(Icons.more_vert),
  items: [
    // ... your menu items
  ],
)
```

### Limitations

- The provided `MaterialMenu` uses Flutter's built-in `MenuAnchor` widget, which
currently doesn't support customizing animations. Refer to
[this issue](https://github.com/flutter/flutter/pull/167806) for more
information.

- Currently, this package only supports triggering a menu with an `Icon` widget.
Support for other widgets will be added in the future.

- Due to the way we call native Swift code, we must set the specific `Size` of
the icon.