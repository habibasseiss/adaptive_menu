import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum NativeMenuActionStyle { normal, destructive }

enum NativeMenuGroupStyle { normal, inline }

abstract class NativeMenuItem {}

class NativeMenuGroup extends NativeMenuItem {
  final String? title;
  final IconData? icon;
  final List<NativeMenuItem> actions;
  final NativeMenuGroupStyle style;

  NativeMenuGroup({
    required this.title,
    required this.actions,
    this.style = NativeMenuGroupStyle.normal,
    this.icon,
  });

  NativeMenuGroup.inline({
    required this.actions,
    this.title,
    this.style = NativeMenuGroupStyle.inline,
  }) : icon = null;
}

class NativeMenuAction extends NativeMenuItem {
  final String id;
  final String title;
  final IconData? icon;
  final VoidCallback? onPressed;
  final NativeMenuActionStyle style;
  final bool? checked;
  final String? description;

  NativeMenuAction({
    required this.title,
    this.icon,
    this.onPressed,
    this.checked,
    this.description,
  })
    : id = UniqueKey().toString(),
      style = NativeMenuActionStyle.normal;

  NativeMenuAction.destructive({required this.title, this.icon, this.onPressed, this.description})
    : id = UniqueKey().toString(),
      style = NativeMenuActionStyle.destructive,
      checked = false;
}

class NativeMenuWidget extends StatefulWidget {
  final Widget child;
  final Color? backgroundColor;
  final List<NativeMenuItem> items;
  final Size size;
  final VoidCallback? onPressed;

  const NativeMenuWidget({
    super.key,
    required this.child,
    required this.items,
    required this.size,
    this.backgroundColor,
    this.onPressed,
  });

  @override
  State<NativeMenuWidget> createState() => _NativeMenuWidgetState();
}

class _NativeMenuWidgetState extends State<NativeMenuWidget> {
  MethodChannel? _instanceMethodChannel; // Instance-specific channel

  @override
  void initState() {
    super.initState();
  }

  void _onPlatformViewCreated(int id) {
    final String channelName = 'app.digizorg/native_menu_channel_$id';
    _instanceMethodChannel = MethodChannel(channelName);
    _instanceMethodChannel!.setMethodCallHandler(_instanceHandleMethodCall);
  }

  @override
  void didUpdateWidget(NativeMenuWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.child != oldWidget.child ||
        widget.backgroundColor != oldWidget.backgroundColor ||
        widget.size != oldWidget.size ||
        !listEquals(widget.items, oldWidget.items) ||
        widget.onPressed != oldWidget.onPressed) {
      _updateNativeView();
    }
  }

  Future<void> _updateNativeView() async {
    await _instanceMethodChannel!.invokeMethod('update', _buildParams());
  }

  Map<String, double> _serializeColor(Color color) {
    return {
      'red': ((color.r * 255.0).round() & 0xff) / 255.0,
      'green': ((color.g * 255.0).round() & 0xff) / 255.0,
      'blue': ((color.b * 255.0).round() & 0xff) / 255.0,
      'alpha': ((color.a * 255.0).round() & 0xff) / 255.0,
    };
  }

  Map<String, dynamic> _buildParams() {
    final Map<String, dynamic> params = <String, dynamic>{};

    final child = widget.child;
    if (child is Text && child.data != null) {
      params['child'] = {'type': 'text', 'text': child.data!};
    } else if (child is Icon && child.icon is IconData) {
      final icon = child.icon as IconData;
      final Map<String, dynamic> iconParams = {
        'type': 'icon',
        'icon': {
          'codePoint': icon.codePoint,
          'fontFamily': icon.fontFamily,
          'fontPackage': icon.fontPackage,
        },
        'size': child.size,
      };
      if (child.color != null) {
        iconParams['color'] = _serializeColor(child.color!);
      }
      params['child'] = iconParams;
    } else {
      params['child'] = {'type': 'text', 'text': ''};
    }

    if (widget.backgroundColor != null) {
      params['backgroundColor'] = _serializeColor(widget.backgroundColor!);
    }

    params['size'] = {'width': widget.size.width, 'height': widget.size.height};

    if (widget.items.isNotEmpty) {
      params['items'] = _serializeMenuItems(widget.items);
    }

    params['showsMenuAsPrimaryAction'] = widget.onPressed == null;

    return params;
  }

  List<Map<String, dynamic>> _serializeMenuItems(List<NativeMenuItem> items) {
    return items.map((item) {
      if (item is NativeMenuAction) {
        return {
          'type': 'action',
          'id': item.id,
          'title': item.title,
          'style': item.style.toString().split('.').last,
          if (item.description != null) 'description': item.description,
          if (item.checked != null) 'checked': item.checked,
          if (item.icon != null)
            'icon': {
              'codePoint': item.icon!.codePoint,
              'fontFamily': item.icon!.fontFamily,
              'fontPackage': item.icon!.fontPackage,
            },
        };
      } else if (item is NativeMenuGroup) {
        return {
          'type': 'group',
          'title': item.title,
          'style': item.style.toString().split('.').last,
          'items': _serializeMenuItems(item.actions),
          if (item.icon != null)
            'icon': {
              'codePoint': item.icon!.codePoint,
              'fontFamily': item.icon!.fontFamily,
              'fontPackage': item.icon!.fontPackage,
            },
        };
      }
      return <String, dynamic>{};
    }).toList();
  }

  Future<void> _instanceHandleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'buttonTapped':
        widget.onPressed?.call();
        break;
      case 'actionSelected':
        final String? actionId = call.arguments['id'] as String?;
        if (actionId != null) {
          final action = _findActionById(actionId, widget.items);
          action?.onPressed?.call();
        }
        break;
    }
  }

  NativeMenuAction? _findActionById(String id, List<NativeMenuItem> items) {
    for (final item in items) {
      if (item is NativeMenuAction && item.id == id) {
        return item;
      }
      if (item is NativeMenuGroup) {
        final action = _findActionById(id, item.actions);
        if (action != null) {
          return action;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // This should match exactly with the registered id in NativeMenuPlugin.swift
    const String viewType = 'app.digizorg/native_menu';
    final Map<String, dynamic> creationParams = _buildParams();

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return SizedBox(
        width: widget.size.width,
        height: widget.size.height,
        child: UiKitView(
          viewType: viewType,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: _onPlatformViewCreated,
        ),
      );
    } else {
      return Text('$viewType is not available on this platform.');
    }
  }

  @override
  void dispose() {
    _instanceMethodChannel?.setMethodCallHandler(null);
    _instanceMethodChannel = null;
    super.dispose();
  }
}
