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
  static const String _viewType = 'app.digizorg/native_menu';
  static const String _channelPrefix = 'app.digizorg/native_menu_channel_';

  MethodChannel? _instanceMethodChannel;
  Uint8List? _capturedImage;

  @override
  void initState() {
    super.initState();
    _schedulePostFrameCallback(_initializeMenuIfReady);
  }

  @override
  void didUpdateWidget(NativeMenuWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_hasWidgetChanged(oldWidget)) {
      _updateNativeView();
    }
  }

  @override
  void dispose() {
    _cleanupMethodChannel();
    super.dispose();
  }

  // Platform view creation and initialization
  void _onPlatformViewCreated(int id) {
    _setupMethodChannel(id);
    _schedulePostFrameCallback(_initializeViewIfImageReady);
  }

  void _setupMethodChannel(int id) {
    final String channelName = '$_channelPrefix$id';
    _instanceMethodChannel = MethodChannel(channelName);
    _instanceMethodChannel!.setMethodCallHandler(_handleMethodCall);
  }

  void _cleanupMethodChannel() {
    _instanceMethodChannel?.setMethodCallHandler(null);
    _instanceMethodChannel = null;
  }

  // Widget change detection
  bool _hasWidgetChanged(NativeMenuWidget oldWidget) {
    return widget.child != oldWidget.child ||
        !listEquals(widget.items, oldWidget.items) ||
        widget.onPressed != oldWidget.onPressed;
  }

  // Initialization helpers
  void _initializeMenuIfReady() {
    if (_instanceMethodChannel != null && _capturedImage != null) {
      _updateNativeView();
    }
  }

  void _initializeViewIfImageReady() {
    if (_capturedImage != null) {
      _updateNativeView();
    }
  }

  void _schedulePostFrameCallback(VoidCallback callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) => callback());
  }

  // Native view updates
  Future<void> _updateNativeView() async {
    if (_instanceMethodChannel == null) return;

    await _instanceMethodChannel!.invokeMethod('update', _buildParams());
    _scheduleSizeUpdate();
  }

  void _scheduleSizeUpdate() {
    final state = context.findAncestorStateOfType<_AutoSizeNativeMenuState>();
    if (state != null) {
      _schedulePostFrameCallback(state._updateChildSize);
    }
  }

  Future<void> _updateNativeImage() async {
    if (_capturedImage != null && _instanceMethodChannel != null) {
      await _instanceMethodChannel!.invokeMethod('updateImage', {
        'image': _capturedImage,
      });
    }
  }

  // Parameter building
  Map<String, dynamic> _buildParams() {
    return {
      'child': _buildChildParams(),
      if (widget.items.isNotEmpty) 'items': _serializeMenuItems(widget.items),
      'showsMenuAsPrimaryAction': widget.onPressed == null,
    };
  }

  Map<String, dynamic> _buildChildParams() {
    if (_capturedImage != null) {
      return {
        'type': 'image',
        'imageBytes': _capturedImage,
      };
    }
    return {'type': 'empty'};
  }

  // Size change handling
  void _onSizeChanged(Size size) {
    if (_instanceMethodChannel != null) {
      _instanceMethodChannel!.invokeMethod('updateSize', {
        'size': {'width': size.width, 'height': size.height},
      });
    }
  }

  // Menu item serialization
  List<Map<String, dynamic>> _serializeMenuItems(List<AdaptiveMenuItem> items) {
    return items.map(_serializeMenuItem).toList();
  }

  Map<String, dynamic> _serializeMenuItem(AdaptiveMenuItem item) {
    if (item is AdaptiveMenuAction) {
      return _serializeMenuAction(item);
    } else if (item is AdaptiveMenuGroup) {
      return _serializeMenuGroup(item);
    }
    return <String, dynamic>{};
  }

  Map<String, dynamic> _serializeMenuAction(AdaptiveMenuAction action) {
    return {
      'type': 'action',
      'id': action.id,
      'title': action.title,
      'style': _getStyleString(action.style),
      if (action.description != null) 'description': action.description,
      if (action.checked != null) 'checked': action.checked,
      if (action.icon != null) 'icon': _serializeIcon(action.icon!),
    };
  }

  Map<String, dynamic> _serializeMenuGroup(AdaptiveMenuGroup group) {
    return {
      'type': 'group',
      'title': group.title,
      'style': _getStyleString(group.style),
      'items': _serializeMenuItems(group.actions),
      if (group.icon != null) 'icon': _serializeIcon(group.icon!),
    };
  }

  Map<String, dynamic> _serializeIcon(IconData icon) {
    return {
      'codePoint': icon.codePoint,
      'fontFamily': icon.fontFamily,
      'fontPackage': icon.fontPackage,
    };
  }

  String _getStyleString(dynamic style) {
    return style.toString().split('.').last;
  }

  // Method call handling
  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'buttonTapped':
        _handleButtonTapped();
        break;
      case 'actionSelected':
        _handleActionSelected(call.arguments);
        break;
    }
  }

  void _handleButtonTapped() {
    widget.onPressed?.call();
  }

  void _handleActionSelected(dynamic arguments) {
    final String? actionId = arguments['id'] as String?;
    if (actionId != null) {
      final action = _findActionById(actionId, widget.items);
      action?.onPressed?.call();
    }
  }

  AdaptiveMenuAction? _findActionById(String id, List<AdaptiveMenuItem> items) {
    for (final item in items) {
      if (item is AdaptiveMenuAction && item.id == id) {
        return item;
      }
      if (item is AdaptiveMenuGroup) {
        final action = _findActionById(id, item.actions);
        if (action != null) return action;
      }
    }
    return null;
  }

  // Image capture handling
  void _onImageCaptured(Uint8List imageBytes) {
    setState(() {
      _capturedImage = imageBytes;
    });

    if (_instanceMethodChannel != null) {
      _updateNativeImage();
      _updateNativeView();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _AutoSizeNativeMenu(
        viewType: _viewType,
        creationParams: _buildParams(),
        onPlatformViewCreated: _onPlatformViewCreated,
        onSizeChanged: _onSizeChanged,
        onImageCaptured: _onImageCaptured,
        child: widget.child,
      );
    }
    return Text('$_viewType is not available on this platform.');
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
    _schedulePostFrameCallback(_updateChildSize);
  }

  @override
  void didChangeMetrics() {
    _schedulePostFrameCallback(_updateChildSize);
  }

  @override
  void didUpdateWidget(_AutoSizeNativeMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    _schedulePostFrameCallback(_updateChildSize);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _schedulePostFrameCallback(VoidCallback callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) => callback());
  }

  void _updateChildSize() {
    final renderBox = _getRenderBox();
    if (renderBox?.hasSize == true) {
      final size = renderBox!.size;
      if (_hasSizeChanged(size)) {
        _updateSize(size);
      }
    }
  }

  RenderBox? _getRenderBox() {
    return _childKey.currentContext?.findRenderObject() as RenderBox?;
  }

  bool _hasSizeChanged(Size newSize) {
    return _childSize == null ||
        _childSize!.width != newSize.width ||
        _childSize!.height != newSize.height;
  }

  void _updateSize(Size newSize) {
    setState(() {
      _childSize = newSize;
    });
    widget.onSizeChanged(newSize);
  }

  void _handleImageCaptured(Uint8List imageBytes) {
    widget.onImageCaptured(imageBytes);
    _ensureSizeUpdate();
    _scheduleRebuildIfMounted();
  }

  void _ensureSizeUpdate() {
    if (_childSize == null) {
      _updateChildSize();
    } else {
      widget.onSizeChanged(_childSize!);
    }
  }

  void _scheduleRebuildIfMounted() {
    _schedulePostFrameCallback(() {
      if (mounted) {
        setState(() {}); // Force rebuild to ensure proper rendering
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.passthrough,
      children: [
        _buildChildWithImage(),
        if (_childSize != null) _buildNativeView(),
      ],
    );
  }

  Widget _buildChildWithImage() {
    return Opacity(
      opacity: 0.3,
      child: WidgetAsImage(
        key: _childKey,
        onImageCaptured: _handleImageCaptured,
        child: widget.child,
      ),
    );
  }

  Widget _buildNativeView() {
    return Positioned(
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
    );
  }
}
