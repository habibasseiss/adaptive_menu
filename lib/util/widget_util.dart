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

  /// Captures the widget identified by the global key as an image.
  Future<void> _captureWidget() async {
    // Ensure the widget is still mounted before proceeding.
    if (!mounted) return;

    try {
      // Find the render object associated with the RepaintBoundary.
      final boundary =
          _globalKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        debugPrint('Error: Could not find RenderRepaintBoundary.');
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

// class WidgetAsImage extends StatefulWidget {
//   const WidgetAsImage({
//     super.key,
//     required this.child,
//     this.onImageCaptured,
//   });

//   final Widget child;
//   final void Function(Uint8List imageBytes)? onImageCaptured;

//   @override
//   State<WidgetAsImage> createState() => _WidgetAsImageState();
// }

// class _WidgetAsImageState extends State<WidgetAsImage> {
//   final GlobalKey _globalKey = GlobalKey();
//   Uint8List? _imageBytes;
//   bool _capturing = false;

//   @override
//   void initState() {
//     super.initState();
//     // We need to wait for the first frame to be rendered before attempting to capture
//     SchedulerBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         _captureWidget();
//       }
//     });
//   }

//   @override
//   void didUpdateWidget(WidgetAsImage oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     // If the child widget changes, we need to recapture
//     if (widget.child != oldWidget.child) {
//       setState(() {
//         _imageBytes = null;
//       });
//       SchedulerBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           _captureWidget();
//         }
//       });
//     }
//   }

//   Future<void> _captureWidget() async {
//     // Prevent multiple captures running simultaneously
//     if (_capturing) return;

//     _capturing = true;

//     try {
//       // Ensure the widget has been rendered
//       await Future.delayed(const Duration(milliseconds: 50));

//       if (!mounted || _globalKey.currentContext == null) {
//         _capturing = false;
//         return;
//       }

//       final RenderRepaintBoundary? boundary =
//           _globalKey.currentContext!.findRenderObject()
//               as RenderRepaintBoundary?;

//       if (boundary == null) {
//         _capturing = false;
//         return;
//       }

//       // Make sure the boundary has been laid out and painted
//       if (boundary.debugNeedsPaint) {
//         _capturing = false;
//         // Try again in the next frame
//         SchedulerBinding.instance.addPostFrameCallback((_) {
//           if (mounted) {
//             _captureWidget();
//           }
//         });
//         return;
//       }

//       try {
//         final ui.Image image = await boundary.toImage();
//         final ByteData? byteData = await image.toByteData(
//           format: ui.ImageByteFormat.png,
//         );

//         if (byteData != null && mounted) {
//           final imageBytes = byteData.buffer.asUint8List();
//           setState(() {
//             _imageBytes = imageBytes;
//           });
//           widget.onImageCaptured?.call(imageBytes);
//         }
//       } catch (e) {
//         // If we fail to capture (which can happen if the widget isn't fully rendered),
//         // try again after a delay
//         if (mounted) {
//           Future.delayed(const Duration(milliseconds: 20), () {
//             if (mounted) {
//               _captureWidget();
//             }
//           });
//         }
//       }
//     } finally {
//       _capturing = false;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         // We need to render the widget to capture it, but we hide it visually
//         // while still maintaining its layout
//         Opacity(
//           opacity: _imageBytes == null ? 1.0 : 0.0,
//           child: RepaintBoundary(
//             key: _globalKey,
//             child: widget.child,
//           ),
//         ),

//         // Once captured, show the image representation of the widget
//         if (_imageBytes != null)
//           Image.memory(
//             _imageBytes!,
//             // We let the image take its natural size or adapt to its parent constraints
//             fit: BoxFit.contain,
//           ),
//       ],
//     );
//   }
// }
