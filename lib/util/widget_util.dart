import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

class WidgetAsImage extends StatefulWidget {
  const WidgetAsImage({super.key, required this.child});

  final Widget child;

  @override
  State<WidgetAsImage> createState() => _WidgetAsImageState();
}

class _WidgetAsImageState extends State<WidgetAsImage> {
  final GlobalKey _globalKey = GlobalKey();
  Uint8List? _imageBytes;
  bool _capturing = false;

  @override
  void initState() {
    super.initState();
    // We need to wait for the first frame to be rendered before attempting to capture
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _captureWidget();
      }
    });
  }

  @override
  void didUpdateWidget(WidgetAsImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the child widget changes, we need to recapture
    if (widget.child != oldWidget.child) {
      setState(() {
        _imageBytes = null;
      });
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _captureWidget();
        }
      });
    }
  }

  Future<void> _captureWidget() async {
    // Prevent multiple captures running simultaneously
    if (_capturing) return;

    _capturing = true;

    try {
      // Ensure the widget has been rendered
      await Future.delayed(const Duration(milliseconds: 50));

      if (!mounted || _globalKey.currentContext == null) {
        _capturing = false;
        return;
      }

      final RenderRepaintBoundary? boundary =
          _globalKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        _capturing = false;
        return;
      }

      // Make sure the boundary has been laid out and painted
      if (boundary.debugNeedsPaint) {
        _capturing = false;
        // Try again in the next frame
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _captureWidget();
          }
        });
        return;
      }

      try {
        final ui.Image image = await boundary.toImage(
          pixelRatio: MediaQuery.of(context).devicePixelRatio,
        );
        final ByteData? byteData = await image.toByteData(
          format: ui.ImageByteFormat.png,
        );

        if (byteData != null && mounted) {
          setState(() {
            _imageBytes = byteData.buffer.asUint8List();
          });
        }
      } catch (e) {
        // If we fail to capture (which can happen if the widget isn't fully rendered),
        // try again after a delay
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) {
              _captureWidget();
            }
          });
        }
      }
    } finally {
      _capturing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // We need to render the widget to capture it, but we hide it visually
        // while still maintaining its layout
        Opacity(
          opacity: _imageBytes == null ? 1.0 : 0.0,
          child: RepaintBoundary(
            key: _globalKey,
            child: widget.child,
          ),
        ),

        // Once captured, show the image representation of the widget
        if (_imageBytes != null)
          Image.memory(
            _imageBytes!,
            // We let the image take its natural size or adapt to its parent constraints
            fit: BoxFit.contain,
          ),
      ],
    );
  }
}
