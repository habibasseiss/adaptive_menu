import 'package:adaptive_menu/adaptive_menu.dart';
import 'package:flutter/material.dart';

class MaterialMenu extends StatelessWidget {
  const MaterialMenu({
    required this.items,
    required this.child,
    this.size,
    this.onPressed,
    super.key,
  });

  final List<AdaptiveMenuItem> items;
  final Size? size;
  final VoidCallback? onPressed;
  final Widget child;

  List<Widget> _buildMenuItems(
    List<AdaptiveMenuItem> menuItems,
    BuildContext context, {
    bool forceIconPlaceholder = false,
  }) {
    List<Widget> widgets = [];
    for (var item in menuItems) {
      if (item is AdaptiveMenuAction) {
        Widget? leadingIcon;

        // Cupertino icons are smaller than Material icons, so we need to
        // adjust the size.
        final iconSize = item.icon?.fontPackage == 'cupertino_icons'
            ? 20.0
            : 24.0;

        if (item.icon != null) {
          leadingIcon = Icon(item.icon, size: iconSize);
        } else if (forceIconPlaceholder) {
          // Use an invisible widget to align items without an icon.
          leadingIcon = SizedBox(width: 24.0);
        }

        widgets.add(
          MenuItemButton(
            onPressed: item.onPressed,
            leadingIcon: item.icon?.fontPackage == 'cupertino_icons'
                ? Padding(padding: EdgeInsets.all(2), child: leadingIcon)
                : leadingIcon,
            trailingIcon: item.checked == true ? const Icon(Icons.check) : null,
            child: Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // Note: item.description is not directly rendered by MenuItemButton.
            // Consider Tooltip or a custom child widget for description.
          ),
        );
      } else if (item is AdaptiveMenuGroup) {
        // Determine if children of this group need icon alignment.
        final groupActions = item.actions
            .whereType<AdaptiveMenuAction>()
            .toList();
        final bool hasActionsWithIcons = groupActions.any(
          (a) => a.icon != null,
        );
        final bool hasActionsWithoutIcons = groupActions.any(
          (a) => a.icon == null,
        );
        final bool forceIconPlaceholderForChildren =
            hasActionsWithIcons && hasActionsWithoutIcons;

        if (item.style == AdaptiveMenuGroupStyle.inline) {
          // For inline groups, add separators around the group's actions.
          if (widgets.isNotEmpty && widgets.last is! PopupMenuDivider) {
            widgets.add(const PopupMenuDivider());
          }

          widgets.addAll(
            _buildMenuItems(
              item.actions,
              context,
              forceIconPlaceholder: forceIconPlaceholderForChildren,
            ),
          );

          widgets.add(const PopupMenuDivider());
        } else {
          assert(item.title != null, 'AdaptiveMenuGroup must have a title');

          widgets.add(
            SubmenuButton(
              menuChildren: _buildMenuItems(
                item.actions,
                context,
                forceIconPlaceholder: forceIconPlaceholderForChildren,
              ),
              leadingIcon: item.icon != null ? Icon(item.icon) : null,
              child: Text(item.title!),
            ),
          );
        }
      }
    }

    // Clean up separators to avoid leading, trailing, or consecutive dividers.
    if (widgets.isEmpty) {
      return [];
    }

    List<Widget> finalWidgets = [];
    for (final widget in widgets) {
      // Don't add a divider if it's the first item or if the previous one was also a divider.
      if (widget is PopupMenuDivider &&
          (finalWidgets.isEmpty || finalWidgets.last is PopupMenuDivider)) {
        continue;
      }
      finalWidgets.add(widget);
    }

    // Remove any trailing divider that might be left.
    if (finalWidgets.isNotEmpty && finalWidgets.last is PopupMenuDivider) {
      finalWidgets.removeLast();
    }

    return finalWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      style: MenuStyle(
        minimumSize: WidgetStatePropertyAll(const Size(224, 0)),
        maximumSize: WidgetStatePropertyAll(const Size.fromWidth(280)),
      ),
      crossAxisUnconstrained: false,
      menuChildren: _buildMenuItems(items, context),
      builder:
          (
            BuildContext context,
            MenuController controller,
            Widget? anchorChild,
          ) {
            final Widget effectiveChild = GestureDetector(
              onTap: () {
                // Call the user-provided onPressed callback for the menu trigger
                onPressed?.call();
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              child: child,
            );

            // If size is provided, use it; otherwise, let the child determine its own size
            if (size != null) {
              return SizedBox.fromSize(
                size: size,
                child: Center(child: effectiveChild),
              );
            } else {
              return effectiveChild;
            }
          },
    );
  }
}
