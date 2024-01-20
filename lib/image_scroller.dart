import 'package:flutter/material.dart';
    
class ImageScroller extends StatelessWidget {
      ImageScroller(this.imageWidget, {Key? key}) : super(key: key);

      final ScrollController controller = ScrollController();
      final ScrollController controller2 = ScrollController();
      final Widget imageWidget;

      @override
      Widget build(BuildContext context) {
        return Scrollbar(
          controller: controller2,
         /* isAlwaysShown: true, */
          child: SingleChildScrollView(
            controller: controller2,
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              controller: controller,
              child: imageWidget,
              ),
          ),
        );
      }
    }