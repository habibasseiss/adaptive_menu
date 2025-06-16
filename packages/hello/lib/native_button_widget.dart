import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeButtonWidget extends StatefulWidget {
  final String title;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Size? size;

  const NativeButtonWidget({
    super.key,
    required this.title,
    required this.onPressed,
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
    if (widget.title != oldWidget.title ||
        widget.backgroundColor != oldWidget.backgroundColor ||
        widget.size != oldWidget.size) {
      _updateNativeView();
    }
  }

  Future<void> _updateNativeView() async {
    // This is the same map of parameters used for creation.
    final Map<String, dynamic> updateParams = <String, dynamic>{
      'title': widget.title,
    };

    if (widget.backgroundColor != null) {
      updateParams['backgroundColor'] = {
        'red': widget.backgroundColor!.red / 255.0,
        'green': widget.backgroundColor!.green / 255.0,
        'blue': widget.backgroundColor!.blue / 255.0,
        'alpha': widget.backgroundColor!.alpha / 255.0,
      };
    }

    if (widget.size != null) {
      updateParams['size'] = {
        'width': widget.size!.width,
        'height': widget.size!.height,
      };
    }

    // Invoke a method on the channel to update the native view
    await _platformChannel.invokeMethod('update', updateParams);
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'buttonTapped') {
      widget.onPressed();
    }
  }

  @override
  Widget build(BuildContext context) {
    // This is the identifier used by iOS to identify the view type.
    // IMPORTANT: This viewType must match the one used in the plugin's registration (SwiftHelloPlugin.swift)
    // and the one used by the NativeButtonFactory.
    const String viewType = 'com.example/native_button';

    // Pass parameters to the platform view.
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'title': widget.title,
    };

    if (widget.backgroundColor != null) {
      creationParams['backgroundColor'] = {
        'red': widget.backgroundColor!.red / 255.0,
        'green': widget.backgroundColor!.green / 255.0,
        'blue': widget.backgroundColor!.blue / 255.0,
        'alpha': widget.backgroundColor!.alpha / 255.0,
      };
    }

    if (widget.size != null) {
      creationParams['size'] = {
        'width': widget.size!.width,
        'height': widget.size!.height,
      };
    }

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
