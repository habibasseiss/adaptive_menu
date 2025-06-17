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
  MethodChannel? _instanceMethodChannel; // Instance-specific channel

  @override
  void initState() {
    super.initState();
  }

  void _onPlatformViewCreated(int id) {
    final String channelName = 'com.example/native_button_channel_$id';
    _instanceMethodChannel = MethodChannel(channelName);
    _instanceMethodChannel!.setMethodCallHandler(_instanceHandleMethodCall);
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

    if (widget.size != null) {
      params['size'] = {
        'width': widget.size!.width,
        'height': widget.size!.height,
      };
    }

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

  Future<void> _instanceHandleMethodCall(MethodCall call) async {
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
    const String viewType = 'com.example/native_button';
    final Map<String, dynamic> creationParams = _buildParams();

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return SizedBox(
        width: widget.size?.width ?? 200,
        height: widget.size?.height ?? 50,
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
