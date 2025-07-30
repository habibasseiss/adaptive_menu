import 'package:adaptive_menu/adaptive_menu.dart';
import 'package:adaptive_menu/view/material_menu.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum AdaptiveMenuType { material, native }

typedef AdaptiveMenuBuilder = Widget Function(void Function() openMenu);

class AdaptiveMenu extends StatelessWidget {
  const AdaptiveMenu({
    required this.items,
    required this.builder,
    this.type,
    super.key,
  });

  final List<AdaptiveMenuItem> items;
  final AdaptiveMenuBuilder builder;
  final AdaptiveMenuType? type;

  @override
  Widget build(BuildContext context) {
    final nativeMenu = NativeMenuWidget(
      items: items,
      builder: builder,
    );

    final materialMenu = MaterialMenu(
      items: items,
      builder: builder,
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
