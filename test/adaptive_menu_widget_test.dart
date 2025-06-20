import 'package:adaptive_menu/adaptive_menu.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdaptiveMenu Widget Tests', () {
    final menuItems = [
      AdaptiveMenuAction(
        title: 'Action 1',
        onPressed: () {},
      ),
    ];

    testWidgets('Renders PopupMenuButton on non-iOS platforms',
        (WidgetTester tester) async {
      // Set platform to Android
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveMenu(
              items: menuItems,
              size: const Size(24, 24),
              child: const Icon(Icons.menu), // Changed child to Icon
            ),
          ),
        ),
      );

      expect(find.byType(MenuAnchor), findsOneWidget); // Changed to MenuAnchor
      expect(find.byType(UiKitView), findsNothing);

      // Clean up
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('Renders UiKitView on iOS', (WidgetTester tester) async {
      // Set platform to iOS
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      // Mock the platform views channel
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform_views,
        (MethodCall methodCall) async {
          if (methodCall.method == 'create') {
            // Return a dummy view ID
            return 1;
          }
          return null;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveMenu(
              type: AdaptiveMenuType.native,
              items: menuItems,
              size: const Size(24, 24),
              child: const Icon(Icons.menu), // Changed child to Icon
            ),
          ),
        ),
      );

      expect(find.byType(UiKitView), findsOneWidget);
      expect(find.byType(MenuAnchor), findsNothing); // Changed to MenuAnchor

      // Clean up
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('Material menu onPressed callback is triggered',
        (WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      bool wasPressed = false;
      final items = [
        AdaptiveMenuAction(
          title: 'Press me',
          onPressed: () {
            wasPressed = true;
          },
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveMenu(
              items: items,
              size: const Size(24, 24),
              child: const Icon(Icons.more_vert),
            ),
          ),
        ),
      );

      // Tap the IconButton to open the menu
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle(); // Wait for menu to appear

      // Tap the MenuItemButton
      await tester.tap(find.widgetWithText(MenuItemButton, 'Press me'));
      await tester.pumpAndSettle(); // Wait for menu to disappear

      expect(wasPressed, isTrue);

      debugDefaultTargetPlatformOverride = null;
    });
  });
}
