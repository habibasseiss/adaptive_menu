import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:native_menu/adaptive_menu.dart';
import 'package:native_menu/view/material_menu.dart';

enum AdaptiveMenuType { material, native }

class AdaptiveMenu extends StatelessWidget {
  const AdaptiveMenu({
    required this.items,
    required this.size,
    required this.child,
    this.type,
    this.onPressed,
    super.key,
  });

  final List<AdaptiveMenuItem> items;
  final Size size;
  final VoidCallback? onPressed;
  final AdaptiveMenuType? type;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    assert(child is Icon, 'Currently, child must be an Icon widget');

    final nativeMenu = NativeMenuWidget(
      items: items,
      size: size,
      onPressed: onPressed,
      child: child,
    );

    final materialMenu = MaterialMenu(items: items, size: size, child: child);

    if (type == AdaptiveMenuType.native && defaultTargetPlatform != TargetPlatform.iOS) {
      return materialMenu;
    }
    return type == AdaptiveMenuType.material || type == null 
      ? materialMenu 
      : nativeMenu;
  }
}
