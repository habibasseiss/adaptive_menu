import 'package:adaptive_menu/adaptive_menu.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeMenuWidget extends StatefulWidget {
  final Widget child;
  final Color? backgroundColor;
  final List<AdaptiveMenuItem> items;
  final Size? size;
  final VoidCallback? onPressed;

  const NativeMenuWidget({
    super.key,
    required this.child,
    required this.items,
    this.size,
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

    // Use default size if not provided
    final Size effectiveSize = widget.size ?? const Size(184, 184);
    params['size'] = {
      'width': effectiveSize.width,
      'height': effectiveSize.height,
    };

    if (widget.items.isNotEmpty) {
      params['items'] = _serializeMenuItems(widget.items);
    }

    params['showsMenuAsPrimaryAction'] = widget.onPressed == null;

    return params;
  }

  // Called when the child widget's size changes
  void _onSizeChanged(Size size) {
    if (_instanceMethodChannel != null) {
      final Map<String, dynamic> params = <String, dynamic>{
        'size': {'width': size.width, 'height': size.height},
      };
      _instanceMethodChannel!.invokeMethod('updateSize', params);
    }
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
      if (widget.size != null) {
        return SizedBox(
          width: widget.size!.width,
          height: widget.size!.height,
          child: UiKitView(
            viewType: viewType,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onPlatformViewCreated,
          ),
        );
      } else {
        // Use automatic sizing based on child's layout
        return _AutoSizeNativeMenu(
          viewType: viewType,
          creationParams: creationParams,
          onPlatformViewCreated: _onPlatformViewCreated,
          onSizeChanged: _onSizeChanged,
          child: widget.child,
        );
      }
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

/// A widget that automatically sizes the native menu based on the child widget's layout.
class _AutoSizeNativeMenu extends StatefulWidget {
  final Widget child;
  final String viewType;
  final Map<String, dynamic> creationParams;
  final Function(int) onPlatformViewCreated;
  final Function(Size) onSizeChanged;

  const _AutoSizeNativeMenu({
    required this.child,
    required this.viewType,
    required this.creationParams,
    required this.onPlatformViewCreated,
    required this.onSizeChanged,
  });

  @override
  State<_AutoSizeNativeMenu> createState() => _AutoSizeNativeMenuState();
}

class _AutoSizeNativeMenuState extends State<_AutoSizeNativeMenu>
    with WidgetsBindingObserver {
  final GlobalKey _childKey = GlobalKey();
  Size? _childSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Schedule a post-frame callback to measure the child's size
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateChildSize());
  }

  @override
  void didChangeMetrics() {
    // Re-measure when the metrics change (e.g., orientation changes)
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateChildSize());
  }

  @override
  void didUpdateWidget(_AutoSizeNativeMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-measure when the widget updates
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateChildSize());
  }

  void _updateChildSize() {
    final RenderBox? renderBox =
        _childKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      // Get the size in the global coordinate system
      final Size size = renderBox.size;

      // Always update size even if it appears the same - this ensures proper synchronization
      setState(() {
        _childSize = size;
      });
      // Pass size to Swift
      widget.onSizeChanged(size);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // This widget is used to measure the child's size.
        SizedBox(
          key: _childKey,
          child: widget.child,
        ),
        // The native view is only built after the child's size is known.
        if (_childSize != null)
          SizedBox(
            width: _childSize!.width,
            height: _childSize!.height,
            child: UiKitView(
              viewType: widget.viewType,
              creationParams: widget.creationParams,
              creationParamsCodec: const StandardMessageCodec(),
              onPlatformViewCreated: widget.onPlatformViewCreated,
            ),
          ),
      ],
    );
  }
}
