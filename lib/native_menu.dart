import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum NativeMenuActionStyle { normal, destructive }

enum NativeMenuGroupStyle { normal, inline }

abstract class NativeMenuItem {}

class NativeMenuGroup extends NativeMenuItem {
  final String? title;
  final List<NativeMenuItem> actions;
  final NativeMenuGroupStyle style;

  NativeMenuGroup({
    required this.title,
    required this.actions,
    this.style = NativeMenuGroupStyle.normal,
  });

  NativeMenuGroup.inline({
    required this.actions,
    this.title,
    this.style = NativeMenuGroupStyle.inline,
  });
}

class NativeMenuAction extends NativeMenuItem {
  final String id;
  final String title;
  final IconData? icon;
  final VoidCallback? onPressed;
  final NativeMenuActionStyle style;

  NativeMenuAction({required this.title, this.icon, this.onPressed})
    : id = UniqueKey().toString(),
      style = NativeMenuActionStyle.normal;

  NativeMenuAction.destructive({
    required this.title,
    this.icon,
    this.onPressed,
  }) : id = UniqueKey().toString(),
       style = NativeMenuActionStyle.destructive;
}

class NativeMenuWidget extends StatefulWidget {
  final Widget child;
  final Color? backgroundColor;
  final List<NativeMenuItem> items;
  final Size size;

  const NativeMenuWidget({
    super.key,
    required this.child,
    required this.items,
    required this.size,
    this.backgroundColor,
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
        !listEquals(widget.items, oldWidget.items)) {
      _updateNativeView();
    }
  }

  Future<void> _updateNativeView() async {
    await _instanceMethodChannel!.invokeMethod('update', _buildParams());
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
        iconParams['color'] = {
          'red': child.color!.red / 255.0,
          'green': child.color!.green / 255.0,
          'blue': child.color!.blue / 255.0,
          'alpha': child.color!.alpha / 255.0,
        };
      }
      params['child'] = iconParams;
    } else {
      params['child'] = {'type': 'text', 'text': ''};
    }

    if (widget.backgroundColor != null) {
      params['backgroundColor'] = {
        'red': widget.backgroundColor!.red / 255.0,
        'green': widget.backgroundColor!.green / 255.0,
        'blue': widget.backgroundColor!.blue / 255.0,
        'alpha': widget.backgroundColor!.alpha / 255.0,
      };
    }

    params['size'] = {
      'width': widget.size.width, 'height': widget.size.height};
  
    if (widget.items.isNotEmpty) {
      params['items'] = _serializeMenuItems(widget.items);
    }

    return params;
  }

  List<Map<String, dynamic>> _serializeMenuItems(
    List<NativeMenuItem> items,
  ) {
    return items.map((item) {
      if (item is NativeMenuAction) {
        return {
          'type': 'action',
          'id': item.id,
          'title': item.title,
          'style': item.style.toString().split('.').last,
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
        };
      }
      return <String, dynamic>{};
    }).toList();
  }

  Future<void> _instanceHandleMethodCall(MethodCall call) async {
    if (call.method == 'actionSelected') {
      final String? actionId = call.arguments['id'] as String?;
      if (actionId != null) {
        final action = _findActionById(actionId, widget.items);
        action?.onPressed?.call();
      }
    }
  }

  NativeMenuAction? _findActionById(
    String id,
    List<NativeMenuItem> items,
  ) {
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
          layoutDirection: TextDirection.ltr,
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
