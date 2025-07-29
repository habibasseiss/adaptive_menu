import 'package:adaptive_menu/adaptive_menu.dart';
import 'package:adaptive_menu/util/widget_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeMenuWidget extends StatefulWidget {
  final Widget child;
  final List<AdaptiveMenuItem> items;
  final VoidCallback? onPressed;

  const NativeMenuWidget({
    super.key,
    required this.child,
    required this.items,
    this.onPressed,
  });

  @override
  State<NativeMenuWidget> createState() => _NativeMenuWidgetState();
}

class _NativeMenuWidgetState extends State<NativeMenuWidget> {
  MethodChannel? _instanceMethodChannel; // Instance-specific channel
  Uint8List? _capturedImage;

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
        !listEquals(widget.items, oldWidget.items) ||
        widget.onPressed != oldWidget.onPressed) {
      _updateNativeView();
    }
  }

  Future<void> _updateNativeView() async {
    // First update the parameters
    await _instanceMethodChannel!.invokeMethod('update', _buildParams());

    // Force a size update to ensure proper alignment
    final _AutoSizeNativeMenuState? state = context
        .findAncestorStateOfType<_AutoSizeNativeMenuState>();
    if (state != null) {
      // Schedule this for the next frame to ensure all layout is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        state._updateChildSize();
      });
    }
  }

  Map<String, dynamic> _buildParams() {
    final Map<String, dynamic> params = <String, dynamic>{};

    // Pass image data if available
    if (_capturedImage != null) {
      params['child'] = {
        'type': 'image',
        'imageBytes': _capturedImage,
      };
    } else {
      // Fallback when image isn't captured yet
      params['child'] = {'type': 'empty'};
    }

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

  void _onImageCaptured(Uint8List imageBytes) {
    setState(() {
      _capturedImage = imageBytes;
    });
    // If the channel is already initialized, update the view with the new image
    if (_instanceMethodChannel != null) {
      _updateNativeView();
    }
  }

  @override
  Widget build(BuildContext context) {
    // This should match exactly with the registered id in NativeMenuPlugin.swift
    const String viewType = 'app.digizorg/native_menu';
    final Map<String, dynamic> creationParams = _buildParams();

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // Use automatic sizing based on child's layout
      return _AutoSizeNativeMenu(
        viewType: viewType,
        creationParams: creationParams,
        onPlatformViewCreated: _onPlatformViewCreated,
        onSizeChanged: _onSizeChanged,
        onImageCaptured: _onImageCaptured,
        child: widget.child,
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

/// A widget that automatically sizes the native menu based on the child widget's layout.
class _AutoSizeNativeMenu extends StatefulWidget {
  final Widget child;
  final String viewType;
  final Map<String, dynamic> creationParams;
  final Function(int) onPlatformViewCreated;
  final Function(Size) onSizeChanged;
  final Function(Uint8List) onImageCaptured;

  const _AutoSizeNativeMenu({
    required this.child,
    required this.viewType,
    required this.creationParams,
    required this.onPlatformViewCreated,
    required this.onSizeChanged,
    required this.onImageCaptured,
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

      // Check if size actually changed to avoid unnecessary updates
      final bool sizeChanged =
          _childSize == null ||
          _childSize!.width != size.width ||
          _childSize!.height != size.height;

      if (sizeChanged) {
        // Update size in state
        setState(() {
          _childSize = size;
        });
        // Pass size to Swift
        widget.onSizeChanged(size);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Called when the WidgetAsImage widget captures the image
  void _handleImageCaptured(Uint8List imageBytes) {
    // We don't need to store the image locally, just forward it to the parent
    widget.onImageCaptured(imageBytes);

    // Force a size update if it hasn't happened yet
    if (_childSize == null) {
      _updateChildSize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.passthrough,
      children: [
        // Use WidgetAsImage to capture the child widget as an image
        Opacity(
          opacity: 0.3,
          child: WidgetAsImage(
            key: _childKey,
            onImageCaptured: _handleImageCaptured,
            child: widget.child,
          ),
        ),

        // The native view is only built after the child's size is known
        if (_childSize != null)
          Positioned(
            left: 0,
            top: 0,
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
