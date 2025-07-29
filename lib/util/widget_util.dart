import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A widget that captures its child as an image and displays the image.
///
/// It uses a [RepaintBoundary] to capture the child widget. The original
/// widget is kept in the tree but is made invisible after being captured,
/// ensuring the layout size is maintained while displaying the generated image.
class WidgetAsImage extends StatefulWidget {
  /// The widget to be converted to an image.
  final Widget child;

  /// A callback that is executed when the image has been captured.
  /// It provides the image data as a Uint8List.
  final void Function(Uint8List imageBytes)? onImageCaptured;

  const WidgetAsImage({
    super.key,
    required this.child,
    this.onImageCaptured,
  });

  @override
  State<WidgetAsImage> createState() => _WidgetAsImageState();
}

class _WidgetAsImageState extends State<WidgetAsImage> {
  // A global key to access the RepaintBoundary
  final GlobalKey _globalKey = GlobalKey();

  // The captured image data in bytes. Null until the image is captured.
  Uint8List? _imageBytes;

  // A flag to control the visibility of the original child widget.
  // We keep it in the tree to preserve the size, but make it invisible
  // once the image is ready.
  bool _showOriginalChild = true;

  // Flag to prevent multiple captures running simultaneously
  bool _capturing = false;

  @override
  void initState() {
    super.initState();
    // We start the capture process after the first frame is rendered.
    // A small delay is added to give the framework time to finalize the painting
    // of the widget before we attempt to capture it. This helps to avoid the
    // '!debugNeedsPaint' error.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 50), _captureWidget);
    });
  }

  @override
  void didUpdateWidget(WidgetAsImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the child widget changes, we need to recapture
    if (widget.child != oldWidget.child) {
      setState(() {
        _imageBytes = null;
        _showOriginalChild = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 50), _captureWidget);
        }
      });
    }
  }

  /// Captures the widget identified by the global key as an image.
  Future<void> _captureWidget() async {
    // Ensure the widget is still mounted before proceeding.
    if (!mounted) return;

    // Prevent multiple captures running simultaneously
    if (_capturing) return;
    _capturing = true;

    try {
      // Find the render object associated with the RepaintBoundary.
      final boundary =
          _globalKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        debugPrint('Error: Could not find RenderRepaintBoundary.');
        _capturing = false;
        return;
      }

      // Make sure the boundary has been laid out and painted
      if (boundary.debugNeedsPaint) {
        _capturing = false;
        // Try again in the next frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Future.delayed(const Duration(milliseconds: 50), _captureWidget);
          }
        });
        return;
      }

      // Convert the boundary to an image. We use a pixel ratio for better quality.
      final image = await boundary.toImage(
        pixelRatio: MediaQuery.of(context).devicePixelRatio,
      );

      // Convert the image to byte data in PNG format.
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        debugPrint('Error: Could not get byte data from image.');
        _capturing = false;
        return;
      }

      // Convert the byte data to a Uint8List.
      final pngBytes = byteData.buffer.asUint8List();

      // Trigger the callback with the captured image bytes.
      widget.onImageCaptured?.call(pngBytes);

      // Update the state with the new image data and hide the original child.
      if (mounted) {
        setState(() {
          _imageBytes = pngBytes;
          _showOriginalChild = false;
        });
      }
    } catch (e) {
      debugPrint('Error capturing widget: $e');
    } finally {
      _capturing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // This RepaintBoundary wraps the original child.
        // It's used to capture the widget's rendering.
        // We control its visibility with the Opacity widget.
        Opacity(
          opacity: _showOriginalChild ? 1.0 : 0.0,
          child: RepaintBoundary(
            key: _globalKey,
            child: widget.child,
          ),
        ),

        // If the image has been captured, display it.
        // Otherwise, show a placeholder (or nothing).
        if (_imageBytes != null)
          Image.memory(
            _imageBytes!,
            scale: MediaQuery.of(context).devicePixelRatio,
          )
        else
          SizedBox.shrink(),
      ],
    );
  }
}
