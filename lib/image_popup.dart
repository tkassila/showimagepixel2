import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';

class ImagePopUp extends StatefulWidget {
 final img.Image? photo;
 final Uint8List? imageInt8List;
 final   String? loadFromNetwork;
 final Color? mainSelectedColor; // Colors.green;

 ImagePopUp(
     { super.key, required this.photo, 
     required this.imageInt8List, required this.loadFromNetwork, 
     required this.mainSelectedColor // Colors.green;
});

  @override
  State<ImagePopUp> createState() => ImagePopUpState();
}

class ImagePopUpState extends State<ImagePopUp> {

  GlobalKey imageKey = GlobalKey();
  GlobalKey paintKey = GlobalKey();
  late GlobalKey currentKey;
  int intHex = 0;
  String strHex = "";
  double x = 0.0;
  double y = 0.0;
//  String? _loadUrl;
  Color? selectedColor;
  double? _pageHeight = 0.0;
  double? _pageWidth = 0.0;
  BuildContext? myContext;
  bool useSnapshot = false;
  ByteData? snapShotBytes;
  ByteData? /* Uint8List? */ _imageBytes;
  Uint8List? _imageInt8List;
  img.Image? photo;
  String? imagePath;

  int hexOfRGB(int r,int g,int b)
  {
    r = (r<0)?-r:r;
    g = (g<0)?-g:g;
    b = (b<0)?-b:b;
    r = (r>255)?255:r;
    g = (g>255)?255:g;
    b = (b>255)?255:b;
    return int.parse('0xff${r.toRadixString(16)}${g.toRadixString(16)}${b.toRadixString(16)}');
  }

  void searchPixel(Offset globalPosition) async {
    if (useSnapshot && snapShotBytes == null) // use showen image widget as region can get its bytes as png:
    {
      await loadSnapshotBytes();
    }
    _calculatePixel(globalPosition);
  }

 Future loadSnapshotBytes() async {
    RenderRepaintBoundary boxPaint =
        paintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
//RenderObject? boxPaint = paintKey.currentContext.findRenderObject();
    ui.Image capture = await boxPaint.toImage();

    ByteData? imageBytes =
    await capture.toByteData(format: ui.ImageByteFormat.png);
    snapShotBytes = imageBytes;
    setImageBytes(imageBytes!);
    capture.dispose();
  }

  void setImageUint8List(/* Uint8List values */) {
    photo = img.decodeImage(_imageInt8List!)!;
    if (photo == null) {
      print("photo is null");
    }
  // _imageInt8List = img.encodePng(photo!); // img.encodeNamedImage(imagePath!, photo!);
    if (kDebugMode) {
      print("end of setImageUint8List");
      print("imagePath '$imagePath'");
    }
  }

  void _calculatePixel(Offset globalPosition) {
    if (widget.photo == null)
    {
      return;
    }

    RenderBox box = /* imageKey paintKey */ currentKey.currentContext!.findRenderObject() as RenderBox;
    Offset localPosition = box.globalToLocal(globalPosition);

    double px = localPosition.dx;
    double py = localPosition.dy;

    if (!useSnapshot) {
      double widgetScale = box.size.width / widget.photo!.width;
    //  print(py);
      px = (px / widgetScale);
      py = (py / widgetScale);
    }

    img.Pixel pixel32 = widget.photo!.getPixelSafe(px.toInt(), py.toInt());
    int hex = hexOfRGB(pixel32.r.toInt(), pixel32.g.toInt(), pixel32.b.toInt()); // pixel32.toString();
    // int hex = abgrToArgb(pixel32);

    setState(() {
      intHex = hex;
      x = px;
      y = px;
      selectedColor = Color(intHex);
      strHex = "0x${intHex.toRadixString(16)}";
    });
    Clipboard.setData(ClipboardData(text: strHex)); /*.then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Copied to your clipboard !')));
    });
    */
    // _isButtonDisabled = false;
  //  _stateController.add(Color(hex));
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
        super.dispose();
  }


  void setImageBytes(ByteData? imageBytes) {
    if (imageBytes == null) {
      return;
    }
    // Uint8List values = imageBytes.buffer.asUint8List();
    _imageInt8List = imageBytes.buffer.asUint8List();
    setImageUint8List(/* values */);
  }

  @override
  void initState() {
    super.initState();
    currentKey = useSnapshot ? paintKey : imageKey;   
    selectedColor = widget.mainSelectedColor;
    intHex = (selectedColor != null && selectedColor!.value != null ? selectedColor!.value : 0);
    strHex = "0x${intHex.toRadixString(16)}";
  }

  Widget getImage(double? pageHeight, double? pageWidth){

    /*
      print('- the new height is $pageHeight');
      print('- the new Width is $pageWidth');
    */
    
    Widget ret =  (widget.imageInt8List != null ? Image.memory(widget.imageInt8List!,
                    scale: 0.7,
                          //     height: 350,
                          //     width: 400,
                        //        fit: BoxFit.contain,
                          //      width: double.infinity, 
         // fit: BoxFit.fitWidth,
                          errorBuilder: (BuildContext context, Object error,
                              StackTrace? stackTrace) =>
                          const Center(
                              child: Text('This image type is not supported')),
                          key: imageKey,
// color: Colors.red,
 // colorBlendMode: BlendMode.hue,
// alignment: Alignment.bottomRight,
                          //       fit: BoxFit.fill,
// scale: .8,
                        ) : widget.loadFromNetwork != null ? 
                             Image.network(widget.loadFromNetwork!,    
                              height: 350,
                               width: 400,
                          errorBuilder: (BuildContext context, Object error,
                              StackTrace? stackTrace) =>
                          const Center(
                              child: Text('This image type is not supported')),
                          key: imageKey,
                        )
                            : (widget.loadFromNetwork == null ? Image.memory(widget.imageInt8List!,
                                  scale: 0.7,
                     //           height: 350,
                      //         width: 400,
                            //    fit: BoxFit.contain,
                       //         width: double.infinity, 
           //                    fit: BoxFit.fitWidth,
//                            fit: BoxFit.cover,
  //                           cacheWidth: 360,
    //                         cacheHeight: 360,
                          errorBuilder: (BuildContext context, Object error,
                              StackTrace? stackTrace) =>
                          const Center(
                              child: Text('This image type is not supported')),
                          key: imageKey,
// color: Colors.red,
// colorBlendMode: BlendMode.hue,
// alignment: Alignment.bottomRight,
                          //       fit: BoxFit.fill,
//scale: .8,
                        ) : Image.network(widget.loadFromNetwork!,
                              height: 350,
                               width: 400,
                          errorBuilder: (BuildContext context, Object error,
                              StackTrace? stackTrace) =>
                          const Center(
                              child: Text('This image type is not supported')),
                          key: imageKey,
                        )));
     if (ret is Image)
     {        
        return /* ImageScroller( */ /* SizedBox( 
            height: 350, /* pageHeight == null ? 200 : pageHeight, */
            width: 400, /* pageWidth == null ? 200 : pageWidth, */
            child: ret,
            */            
          //  ),
          //  );
       // ret;
IntrinsicWidth(
        child:         IntrinsicHeight(
      child: 
      SizedBox(
      //      height: pageHeight == null ? 350 : pageHeight,
      //      width: pageWidth == null ? 400 : pageWidth,
            child: ret,
      ),      
      ),
        );
/*      ),
       );
*/
        /*
        return IntrinsicHeight(
      child: IntrinsicWidth(
      child: SizedBox(
            height: 300, /* pageHeight == null ? 200 : pageHeight, */
            width: 400, /* pageWidth == null ? 200 : pageWidth, */
            child: ret,
            ),
            )
        );
        */
        
        /*
         CarouselSlider( 
              items: [ 
                  
                //1st Image of Slider 
                Container( 
                  margin: EdgeInsets.all(6.0), 
                  decoration: BoxDecoration( 
                    borderRadius: BorderRadius.circular(8.0), 
                    image: DecorationImage( 
                      image: getImageProvider(), 
                      fit: BoxFit.cover, 
                    ), 
                  ), 
                ), 
                  
  
          ], 
              
            //Slider Container properties 
              options: CarouselOptions( 
                height: 180.0, 
                enlargeCenterPage: true, 
                autoPlay: true, 
                aspectRatio: 16 / 9, 
                autoPlayCurve: Curves.fastOutSlowIn, 
                enableInfiniteScroll: true, 
                autoPlayAnimationDuration: Duration(milliseconds: 800), 
                viewportFraction: 0.8, 
              ), 
          );
          */
     }                   
     return ret;                   
  }

  Future<bool> _onBackPressed() async {
    bool bValue = true;
    if (selectedColor != null && myContext != null)
    {
      Navigator.of(myContext!).pop(intHex);
    }
    return await bValue;
  }

  @override
  Widget build(BuildContext context) {
    myContext = context;
   // Color mySelectedColor = selectedColor ?? Colors.white;
    String strTitle = 'Select picture color on pixel: $intHex $strHex';
    return WillPopScope(
    onWillPop: _onBackPressed,
    child: 
    Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            color: Colors.black,          
          icon: const Icon(Icons.ads_click_sharp),
          tooltip: 'Copy selected color integer value into clibboard',
          onPressed: () {
            Clipboard.setData(ClipboardData(text: intHex.toString()));  
          },
        ),
        ],
        title: Text(strTitle,
        style: TextStyle(
          color: selectedColor!.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white, fontWeight: FontWeight.bold,                                  
          backgroundColor: selectedColor,          
          )
        ),
      ),
      body: /* Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: <Widget>[ 
            const Row(children: [ 
              Text("column 2"),
      ]
      ),
      */
    //  Row(children: [
        RepaintBoundary(
                    key: paintKey,
                    child: GestureDetector(
                      onPanDown: (details) {
                        searchPixel(details.globalPosition);
                      },
                      onPanUpdate: (details) {
                        searchPixel(details.globalPosition);
                      },
                      child: Padding(
        padding: const EdgeInsets.all(16),
        child: InteractiveViewer(constrained: true, maxScale: 20,
        scaleEnabled: true, child: getImage(_pageHeight, _pageWidth),
      ),
                    ),
        ),
    ),
      ),
    //  ]
    //  ),
  //    ]
    //  ),
    );
  }

}

