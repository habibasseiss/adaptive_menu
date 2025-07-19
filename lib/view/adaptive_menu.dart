import 'package:adaptive_menu/adaptive_menu.dart';
import 'package:adaptive_menu/view/material_menu.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum AdaptiveMenuType { material, native }

class AdaptiveMenu extends StatelessWidget {
  const AdaptiveMenu({
    required this.items,
    required this.child,
    this.size,
    this.type,
    this.onPressed,
    super.key,
  });

  final List<AdaptiveMenuItem> items;
  final Size? size;
  final VoidCallback? onPressed;
  final AdaptiveMenuType? type;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final nativeMenu = NativeMenuWidget(
      items: items,
      size: size,
      onPressed: onPressed,
      child: child,
    );

    final materialMenu = MaterialMenu(
      items: items,
      size: size,
      child: child,
    );

    // Native menu can only be used on iOS, but if type is null or
    // AdaptiveMenuType.native on iOS, we will use MaterialMenu
    // instead. On anything other than iOS, we will always use
    // MaterialMenu.
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return type == AdaptiveMenuType.native || type == null
          ? nativeMenu
          : materialMenu;
    } else {
      return materialMenu;
    }
  }
}
