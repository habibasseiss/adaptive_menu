import 'package:flutter/material.dart';
import 'package:native_menu/adaptive_menu.dart';

class MaterialMenu extends StatelessWidget {
  const MaterialMenu({
    required this.items,
    required this.size,
    required this.child,
    this.onPressed,
    super.key,
  });

  final List<AdaptiveMenuItem> items;
  final Size size;
  final VoidCallback? onPressed;
  final Widget child;

  List<Widget> _buildMenuItems(
    List<AdaptiveMenuItem> menuItems,
    BuildContext context,
  ) {
    List<Widget> widgets = [];
    for (var item in menuItems) {
      if (item is AdaptiveMenuAction) {
        widgets.add(
          MenuItemButton(
            onPressed: item.onPressed,
            leadingIcon: item.icon != null ? Icon(item.icon) : null,
            style: item.style == AdaptiveMenuActionStyle.destructive
                ? ButtonStyle(
                    foregroundColor: WidgetStateProperty.all(
                      Colors.red.shade700,
                    ),
                  )
                : null,
            trailingIcon: item.checked == true ? const Icon(Icons.check) : null,
            child: Text(item.title),
            // Note: item.description is not directly rendered by MenuItemButton.
            // Consider Tooltip or a custom child widget for description.
          ),
        );
      } else if (item is AdaptiveMenuGroup) {
        if (item.style == AdaptiveMenuGroupStyle.inline) {
          // For inline groups, actions are rendered directly.
          // The title of the inline group is currently not rendered to maintain a flat list of actions.
          // If a title separator is needed, it could be added here as a non-interactive widget.
          widgets.addAll(_buildMenuItems(item.actions, context));
        } else {
          // AdaptiveMenuGroupStyle.normal
          widgets.add(
            SubmenuButton(
              menuChildren: _buildMenuItems(item.actions, context),
              leadingIcon: item.icon != null ? Icon(item.icon) : null,
              child: Text(item.title ?? 'Submenu'), // Default title if null
            ),
          );
        }
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: _buildMenuItems(items, context), // Use the helper method
      builder:
          (
            BuildContext context,
            MenuController controller,
            Widget? anchorChild,
          ) {
            Widget? effectiveChild;

            if (child is Icon) {
              final childIcon = (child as Icon);

              effectiveChild = IconButton(
                icon: Icon(childIcon.icon, size: childIcon.size),
                onPressed: () {
                  onPressed
                      ?.call(); // Call the user-provided onPressed callback for the menu trigger
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
              );
            } else {
              throw Exception('Unsupported child type: ${child.runtimeType}');
            }

            return SizedBox.fromSize(
              size: size,
              child: Center(child: effectiveChild),
            );
          },
    );
  }
}
