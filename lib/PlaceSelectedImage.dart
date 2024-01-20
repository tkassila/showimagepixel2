import 'package:photo_view/photo_view.dart';
import 'package:flutter/material.dart';

class PlaceSelectedImage extends StatefulWidget{
final ImageProvider image;
const PlaceSelectedImage(
    this.image,
     { Key? key,
  }) : super(key: key);
@override
PlaceSelectedImageState createState() => PlaceSelectedImageState();
}

class PlaceSelectedImageState extends State<PlaceSelectedImage>{

@override
 Widget build(BuildContext context) {
  return Center(
  child: PhotoView(
      imageProvider: widget.image
  ),
);
}
}