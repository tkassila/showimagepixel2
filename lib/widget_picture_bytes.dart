import 'package:flutter/material.dart';

class WidgetRectangleBytes
{
  Future createImageFromWidget( Widget widget)
  {
      final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();
      final RenderView renderView = RenderView(
        child: RenderPositionedBox(alignment: Alignment.center, child: repaintBoundary),
        configuration: ViewConfiguration(size: const Size.square(300.0), devicePixelRatio: ui.window.devicePixelRatio),
        window: null,
      );

      final PipelineOwner pipelineOwner = PipelineOwner()..rootNode = renderView;
      renderView.prepareInitialFrame();

      final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());
      final RenderObjectToWidgetElement<RenderBox> rootElement = RenderObjectToWidgetAdapter<RenderBox>(
        container: repaintBoundary,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: IntrinsicHeight(child: IntrinsicWidth(child: widget)),
        ),
      ).attachToRenderTree(buildOwner);

      buildOwner..buildScope(rootElement)..finalizeTree();
      pipelineOwner..flushLayout()..flushCompositingBits()..flushPaint();

      return repaintBoundary.toImage(pixelRatio: ui.window.devicePixelRatio)
        .then((image) => image.toByteData(format: ui.ImageByteFormat.png))
        .then((byteData) => byteData.buffer.asUint8List());
    }
}