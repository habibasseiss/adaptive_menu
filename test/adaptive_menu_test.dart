import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_menu/adaptive_menu.dart';
import 'package:flutter/widgets.dart';

void main() {
  // Ensure that Flutter is initialized for tests that use things like UniqueKey
  setUpAll(() => WidgetsFlutterBinding.ensureInitialized());

  group('AdaptiveMenuItem', () {
    group('AdaptiveMenuAction', () {
      test('can be instantiated', () {
        final action = AdaptiveMenuAction(title: 'Test Action');
        expect(action.title, 'Test Action');
        expect(action.style, AdaptiveMenuActionStyle.normal);
        expect(action.id, isA<String>());
      });

      test('destructive constructor works', () {
        final action = AdaptiveMenuAction.destructive(title: 'Delete');
        expect(action.title, 'Delete');
        expect(action.style, AdaptiveMenuActionStyle.destructive);
        expect(action.checked, false);
      });

      test('onPressed callback can be set', () {
        bool pressed = false;
        final action = AdaptiveMenuAction(
          title: 'Press me',
          onPressed: () {
            pressed = true;
          },
        );
        action.onPressed?.call();
        expect(pressed, isTrue);
      });
    });

    group('AdaptiveMenuGroup', () {
      test('can be instantiated', () {
        final group = AdaptiveMenuGroup(
          title: 'Test Group',
          actions: [
            AdaptiveMenuAction(title: 'Action 1'),
          ],
        );
        expect(group.title, 'Test Group');
        expect(group.actions, hasLength(1));
        expect(group.style, AdaptiveMenuGroupStyle.normal);
      });

      test('inline constructor works', () {
        final group = AdaptiveMenuGroup.inline(
          actions: [
            AdaptiveMenuAction(title: 'Inline Action'),
          ],
        );
        expect(group.title, isNull);
        expect(group.style, AdaptiveMenuGroupStyle.inline);
        expect(group.icon, isNull);
      });

      test('can contain other groups', () {
        final nestedGroup = AdaptiveMenuGroup(
          title: 'Nested Group',
          actions: [
            AdaptiveMenuAction(title: 'Nested Action'),
          ],
        );
        final mainGroup = AdaptiveMenuGroup(
          title: 'Main Group',
          actions: [
            nestedGroup,
            AdaptiveMenuAction(title: 'Main Action'),
          ],
        );
        expect(mainGroup.actions, hasLength(2));
        expect(mainGroup.actions[0], isA<AdaptiveMenuGroup>());
      });
    });
  });
}
