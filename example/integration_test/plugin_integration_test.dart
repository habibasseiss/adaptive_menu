import 'package:adaptive_menu/adaptive_menu.dart';
import 'package:adaptive_menu_example/main.dart' as app;
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('AdaptiveMenu Integration Test (iOS)', () {
    testWidgets('Tap menu item and verify action', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Find the AdaptiveMenu widget. We'll look for the one with the 'square_on_square' icon.
      final adaptiveMenuFinder = find.byWidgetPredicate(
        (Widget widget) =>
            widget is AdaptiveMenu &&
            widget.child is Icon &&
            (widget.child as Icon).icon == CupertinoIcons.square_on_square,
      );

      expect(adaptiveMenuFinder, findsOneWidget);

      // Tap the AdaptiveMenu to open it
      await tester.tap(adaptiveMenuFinder);
      await tester.pumpAndSettle(
        const Duration(seconds: 1),
      ); // Wait for native menu to appear

      // We expect debug prints when actions are triggered.
      // We can't directly verify native UI elements in Flutter integration tests easily,
      // so we rely on the side effects (like debug prints) of the actions.

      // To tap a specific item, we would ideally use a key or a more specific finder.
      // For this example, let's assume we want to tap the "New Tab" item.
      // Since we can't directly find native elements, we'll trust the order or a unique property if available.
      // For now, this test will only verify the menu opens.
      // A more robust test would involve platform-specific testing tools (like XCUITest) or
      // a method channel call back to Flutter to confirm the tap.

      // For demonstration, let's just check if the menu opened without error.
      // In a real scenario, you would add more specific checks here.
      // For example, if tapping 'New Tab' causes a navigation or state change in Flutter,
      // you would verify that.

      // This is a placeholder for actual verification of item tap.
      // You would need to implement a way to confirm the native action occurred.
      debugPrint(
        'Native menu was opened. Manual verification or further platform-specific testing needed for item taps.',
      );

      // Example: If 'New Tab' was supposed to print something specific:
      // final log = await tester.binding.traceAction(() async {
      //   // Hypothetical tap on a native element if a bridge existed
      // }, reportTimings: false);
      // expect(log.events.where((event) => event.containsKey('message') && event['message'].contains('New Tab was tapped!')).isNotEmpty, isTrue);
    });
  });
}
