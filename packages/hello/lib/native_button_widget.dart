import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum NativeButtonActionStyle { normal, destructive }

enum NativeButtonGroupStyle { normal, inline }

abstract class NativeButtonMenuItem {}

class NativeButtonGroup extends NativeButtonMenuItem {
  final String? title;
  final List<NativeButtonMenuItem> actions;
  final NativeButtonGroupStyle style;

  NativeButtonGroup({
    required this.title,
    required this.actions,
    this.style = NativeButtonGroupStyle.normal,
  });

  NativeButtonGroup.inline({
    required this.actions,
    this.title,
    this.style = NativeButtonGroupStyle.inline,
  });
}

class NativeButtonAction extends NativeButtonMenuItem {
  final String id;
  final String title;
  final IconData? icon;
  final VoidCallback? onPressed;
  final NativeButtonActionStyle style;

  NativeButtonAction({required this.title, this.icon, this.onPressed})
    : id = UniqueKey().toString(),
      style = NativeButtonActionStyle.normal;

  NativeButtonAction.destructive({
    required this.title,
    this.icon,
    this.onPressed,
  }) : id = UniqueKey().toString(),
       style = NativeButtonActionStyle.destructive;
}

class NativeButtonWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final List<NativeButtonMenuItem> items;
  final Size? size;

  const NativeButtonWidget({
    super.key,
    required this.child,
    required this.onPressed,
    required this.items,
    this.backgroundColor,
    this.size,
  });

  @override
  State<NativeButtonWidget> createState() => _NativeButtonWidgetState();
}

class _NativeButtonWidgetState extends State<NativeButtonWidget> {
  // Define the method channel
  // IMPORTANT: This channel name must match the one used in the native iOS code (NativeButtonView.swift)
  // and the one that will be used in the plugin's registration (SwiftHelloPlugin.swift).
  static const _channelName = 'com.example/native_button_channel';
  static const MethodChannel _platformChannel = MethodChannel(_channelName);

  @override
  void initState() {
    super.initState();
    _platformChannel.setMethodCallHandler(_handleMethodCall);
  }

  @override
  void didUpdateWidget(NativeButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.child != oldWidget.child ||
        widget.backgroundColor != oldWidget.backgroundColor ||
        widget.size != oldWidget.size ||
        !listEquals(widget.items, oldWidget.items)) {
      _updateNativeView();
    }
  }

  Future<void> _updateNativeView() async {
    // Invoke a method on the channel to update the native view
    await _platformChannel.invokeMethod('update', _buildParams());
  }

  // Helper method to build the parameter map, used for both creation and updates.
  Map<String, dynamic> _buildParams() {
    final Map<String, dynamic> params = <String, dynamic>{};

    // Serialize the child widget into a map that can be sent to the native side.
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
      // Provide a fallback for unsupported widgets.
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

    if (widget.size != null) {
      params['size'] = {
        'width': widget.size!.width,
        'height': widget.size!.height,
      };
    }

    // Serialize menu items
    if (widget.items.isNotEmpty) {
      params['items'] = _serializeMenuItems(widget.items);
    }

    return params;
  }

  List<Map<String, dynamic>> _serializeMenuItems(
    List<NativeButtonMenuItem> items,
  ) {
    return items.map((item) {
      if (item is NativeButtonAction) {
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
      } else if (item is NativeButtonGroup) {
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

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'buttonTapped') {
      widget.onPressed();
    } else if (call.method == 'actionSelected') {
      final String? actionId = call.arguments['id'] as String?;
      if (actionId != null) {
        final action = _findActionById(actionId, widget.items);
        action?.onPressed?.call();
      }
    }
  }

  NativeButtonAction? _findActionById(
    String id,
    List<NativeButtonMenuItem> items,
  ) {
    for (final item in items) {
      if (item is NativeButtonAction && item.id == id) {
        return item;
      }
      if (item is NativeButtonGroup) {
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
    // This is the identifier used by iOS to identify the view type.
    // IMPORTANT: This viewType must match the one used in the plugin's registration (SwiftHelloPlugin.swift)
    // and the one used by the NativeButtonFactory.
    const String viewType = 'com.example/native_button';

    // Pass parameters to the platform view.
    final Map<String, dynamic> creationParams = _buildParams();

    // Only build UiKitView on iOS.
    // You might want to add a fallback for other platforms or throw an error.
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return SizedBox(
        width: widget.size?.width ?? 200, // Use provided width or default
        height: widget.size?.height ?? 50, // Use provided height or default
        child: UiKitView(
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
        ),
      );
    } else {
      // Fallback for other platforms (e.g., show a standard Flutter button or an error message)
      return Text('$viewType is not available on this platform.');
    }
  }

  @override
  void dispose() {
    _platformChannel.setMethodCallHandler(null);
    super.dispose();
  }
}
