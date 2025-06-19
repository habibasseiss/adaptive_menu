import 'package:flutter/material.dart';

export 'view/adaptive_menu.dart';
export 'view/native_menu.dart';

enum AdaptiveMenuActionStyle { normal, destructive }

enum AdaptiveMenuGroupStyle { normal, inline }

/// Base class for adaptive menu items.
abstract class AdaptiveMenuItem {}

class AdaptiveMenuGroup extends AdaptiveMenuItem {
  final String? title;
  final IconData? icon;
  final List<AdaptiveMenuItem> actions;
  final AdaptiveMenuGroupStyle style;

  /// A regular group of adaptive menu items which displays a submenu with the
  /// group's actions.
  AdaptiveMenuGroup({
    required this.title,
    required this.actions,
    this.style = AdaptiveMenuGroupStyle.normal,
    this.icon,
  });

  /// An inline group of adaptive menu items which displays the group's actions
  /// separated by dividers directly in the parent menu.
  AdaptiveMenuGroup.inline({
    required this.actions,
    this.title,
    this.style = AdaptiveMenuGroupStyle.inline,
  }) : icon = null;
}

class AdaptiveMenuAction extends AdaptiveMenuItem {
  final String id;
  final String title;
  final IconData? icon;
  final VoidCallback? onPressed;
  final AdaptiveMenuActionStyle style;
  final bool? checked;
  final String? description;

  /// Creates a regular adaptive menu action.
  AdaptiveMenuAction({
    required this.title,
    this.icon,
    this.onPressed,
    this.checked,
    this.description,
    this.style = AdaptiveMenuActionStyle.normal,
  }) : id = UniqueKey().toString();

  /// Creates a destructive adaptive menu action. This will render with a red
  /// color on iOS, but regular color on Android due to Material specification.
  AdaptiveMenuAction.destructive({
    required this.title,
    this.icon,
    this.onPressed,
    this.description,
  }) : id = UniqueKey().toString(),
       style = AdaptiveMenuActionStyle.destructive,
       checked = false;
}
