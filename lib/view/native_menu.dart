import 'package:adaptive_menu/adaptive_menu.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeMenuWidget extends StatefulWidget {
  final Widget child;
  final List<AdaptiveMenuItem> items;
  final Size size;
  final VoidCallback? onPressed;

  const NativeMenuWidget({
    super.key,
    required this.child,
    required this.items,
    this.onPressed,
    this.size = const Size(44, 44),
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
    if (widget.size != oldWidget.size ||
        !listEquals(widget.items, oldWidget.items) ||
        widget.onPressed != oldWidget.onPressed) {
      _updateNativeView();
    }
  }

  Future<void> _updateNativeView() async {
    await _instanceMethodChannel!.invokeMethod('update', _buildParams());
  }

  Map<String, dynamic> _buildParams() {
    final Map<String, dynamic> params = <String, dynamic>{};

    params['size'] = {'width': widget.size.width, 'height': widget.size.height};

    if (widget.items.isNotEmpty) {
      params['items'] = _serializeMenuItems(widget.items);
    }

    params['showsMenuAsPrimaryAction'] = widget.onPressed == null;

    return params;
  }

  List<Map<String, dynamic>> _serializeMenuItems(List<AdaptiveMenuItem> items) {
    return items.map((item) {
      if (item is AdaptiveMenuAction) {
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
      } else if (item is AdaptiveMenuGroup) {
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

  AdaptiveMenuAction? _findActionById(String id, List<AdaptiveMenuItem> items) {
    for (final item in items) {
      if (item is AdaptiveMenuAction && item.id == id) {
        return item;
      }
      if (item is AdaptiveMenuGroup) {
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
      return Stack(
        children: [
          widget.child,
          SizedBox(
            width: widget.size.width,
            height: widget.size.height,
            child: UiKitView(
              viewType: viewType,
              creationParams: creationParams,
              creationParamsCodec: const StandardMessageCodec(),
              onPlatformViewCreated: _onPlatformViewCreated,
            ),
          ),
        ],
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
