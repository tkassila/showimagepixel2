// import 'dart:ffi';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart';
// import 'package:flutter/painting.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
//  import 'package:carousel_slider/carousel_slider.dart';

import 'package:image_picker/image_picker.dart';
import 'package:showimagepixel2/image_scroller.dart';
import 'package:showimagepixel2/PlaceSelectedImage.dart';

import 'image_popup.dart';


//import 'package:video_player/video_player.dart';

// import 'package:dart_ipify/dart_ipify.dart';

// import './clickPicturePixel.dart';

void main() async {
  const String ipv4 = ""; // await Ipify.ipv4();
 // print(ipv4);
  runApp(const MyApp(ipv4: ipv4));
}

class MyApp extends StatelessWidget {
  final String ipv4;
  // const MyApp({super.key});
  const MyApp({
   required this.ipv4,
      super.key,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Show picture pixel color',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Show clicked color pixel', ipv4: ipv4,),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String ipv4;
  const MyHomePage({super.key, required this.title, required this.ipv4});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => MyAppState();
// State<MyHomePage> createState() => _MyHomePageState();

}

class FileHandler {
  final String _filePath;
  FileHandler(this._filePath);
  Future<Uint8List> _readToBytes() async {
    var file = File.fromUri(Uri.parse(_filePath));
    return await file.readAsBytes();
  }

  Future<Map<String, dynamic>> get data async {
    var byte = await _readToBytes();
    var ext = _filePath.split('.').last;
    return {'byte': byte, 'extension': ext};
  }
}

class MyAppState extends State<MyHomePage> {
  String? imagePath;
  bool _isButtonDisabled = true;
  GlobalKey imageKey = GlobalKey();
  GlobalKey paintKey = GlobalKey();
  final ImagePicker _picker = ImagePicker();
  Color? selectedColor; // Colors.green;
// CHANGE THIS FLAG TO TEST BASIC IMAGE, AND SNAPSHOT.
  bool useSnapshot = true;
  String? _loadUrl;
  String? _loadFromNetwork;
// based on useSnapshot=true ? paintKey : imageKey ;
// this key is used in this example to keep the code shorter.
  late GlobalKey currentKey;
  double? _box_height;
  double? _box_width;
  final StreamController _stateController = StreamController();
  final TextEditingController _controller = TextEditingController();
  bool loading = false;

//late img.Image photo ;
  img.Image? photo;
  img.Image? unModifiedLoadPhoto;
  ByteData? snapShotBytes;
  int intHex = 0;
  late String strHex = "";
  double x = 0.0;
  double y = 0.0;
  ByteData? /* Uint8List? */ _imageBytes;
  Uint8List? _imageInt8List; 
  Uint8List? unModifiedLoadImageInt8List;

  dynamic _pickImageError;
  double? maxWidth;
  double? maxHeight;
  int? quality;
  File? pickedFile;
  final MethodChannel _channel = const MethodChannel('get_ip');
  double? _pageHeight = 0.0;
  double? _pageWidth = 0.0;
  final GlobalKey _globalKey = GlobalKey();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
        _controller.dispose();
        super.dispose();
  }

  @override
  void initState() {
    currentKey = useSnapshot ? paintKey : imageKey;   
    selectedColor = Colors.green;
    /*
    if (kIsWeb)
    {
      imagePath = "file://${imagePath!}"; // p.toUri(imagePath!).toString();
    }
     */
    super.initState();
  }

  /*
  String getImageUrl(String? url)
  {
    if (kIsWeb && url!.contains("localhost"))
    {

/*          MethodChannel _channel = const MethodChannel('get_ip'); */
      String ip = "file://"; widget.ipv4; //  _channel.invokeMethod('getIpAdress').toString();
      print(ip);
      url = url!.replaceFirst("localhost", ip);
      print(url!);
    }
    return url!;
  }
   */

  ByteData? _getBytes(String imageUrl) {
    final ByteData data =
    NetworkAssetBundle(Uri.parse(imageUrl)).load(imageUrl) as ByteData;
    return data;
/*    setState(() {
      _imageBytes = data.buffer.asByteData();
      // print(_imageBytes);
    });
 */
  }

  /*
  Future<Uint8List> _readFileByte(String filePath) async {
    Uri myUri = Uri.parse(filePath);
    File audioFile = File.fromUri(myUri);
    final Uint8List bytes;
    await audioFile.readAsBytes().then((value) {
      bytes = Uint8List.fromList(value);
      print('reading of bytes is completed');
    }).catchError((onError) {
      print('Exception Error while reading audio from path:$onError');
    });
    return bytes;
  }
   */

  Future<Uint8List> imageFromUrl(String url) async {
    final uri = Uri.parse(url);
    final Response response = await get(uri);
    return response.bodyBytes;
  }

  Future _openDialogButtonPressed({BuildContext? context}) async {
    if (photo == null) {
     // await (useSnapshot ? loadSnapshotBytes() : loadImageBundleBytes());
      return;
    }
    if (context == null) {
     // await (useSnapshot ? loadSnapshotBytes() : loadImageBundleBytes());
      return;
    }

    var result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImagePopUp(photo: unModifiedLoadPhoto, 
              imageInt8List: unModifiedLoadImageInt8List,
              loadFromNetwork: _loadFromNetwork, mainSelectedColor: selectedColor,
          )            
       ),
    );
   // print('after navigator: $result');

    if (result is int)
    {
     // if (result != intHex)
     // {
        setState(() {
          intHex = result;
          selectedColor = ui.Color(intHex);
          strHex = "0x${intHex.toRadixString(16)}";
        });
   //   }
    }
  }

  Future<void> _onLoadImageButtonPressed(BuildContext context) async
  {
    /*
    print("_onLoadImageButtonPressed");
    print("_loadUrl");
    print(_loadUrl);
    */

    if (_loadUrl == null || _loadUrl!.trim().isEmpty)
    {
      return;
    }

    _imageBytes = null;
    _imageInt8List = null;
    snapShotBytes = null;
  //  waitAnimation(context);

    setState(() {
        loading = true;
    });

    var loadedData = await imageFromUrl(_loadUrl!);
    setState(() {
        _loadFromNetwork = _loadUrl;
       // _imageInt8List = await FileHandler(_loadUrl!)._readToBytes();      
        _imageInt8List = loadedData;
        unModifiedLoadImageInt8List = _imageInt8List;
        setImageUint8List(/* _imageInt8List! */); 
        unModifiedLoadPhoto = photo;           
        loading = false;
    });

    return;
  } 

  Future<void> _onImageButtonPressed(ImageSource source,
      {BuildContext? context}) async {
    try {

      setState(() {
        loading = true;
      });

      final XFile? pickedF = await _picker.pickImage(
        source: source,
        requestFullMetadata: false,
        /*   maxWidth: maxWidth,
            maxHeight: maxHeight,
            imageQuality: quality,
          */
      );


      // final PickedFile? pickedF = await _picker.getImage(source: source);
      if (pickedF == null) {
        setState(() {
          loading = false;
        });
        return;
      }

      _imageBytes = null;
      _imageInt8List = null;
      snapShotBytes = null;

      String? imagePath2 = pickedF.path;
      if (kDebugMode) {
        print("imagePath2=$imagePath2");
      }

      // ignore: use_build_context_synchronously
      // waitAnimation(context!);

      // Uint8List bytes:
      Uint8List? uint8list2;
      await pickedF.readAsBytes().then((value) {
         uint8list2 = Uint8List.fromList(value);
         imagePath = imagePath2;

        setState(() {
          _imageInt8List = uint8list2;
          unModifiedLoadImageInt8List = _imageInt8List;
          _loadFromNetwork = null;
          // _imageBytes = pickedF?.readAsBytes() as Uint8List?;
          setImageUint8List(/* _imageInt8List! */);
          unModifiedLoadPhoto = photo;
          imagePath = imagePath2;
          loading = false;
          // _imageBytes = _readFileBytes(imagePath!);

          // Future<Uint8List>? uint8list = pickedF?.readAsBytes();
          /* Uint8List? uint8list = await pickedF?.readAsBytes();
           if (uint8list == null) {
             return;
           }
            */
          // Future<Uint8List>? uint8list = pickedF?.readAsBytes();
          // _imageBytes = FileHandler(pickedF.path).data.get('byte');
          // _imageBytes = _getBytes(pickedF.path);
          /*
           if (kIsWeb) {
             setImageUint8List(uint8list);
           }
           else {
            */
          // }

//    _uiImage = ;
        });

        if (kDebugMode) {
          print('reading of bytes is completed');
        }
      }).catchError((onError) {
        print('Exception Error in _onImageButtonPressed: while reading:$onError');
        setState(() {
          loading = false;
        });
        return;
      });

    } catch (e) {
      setState(() {
        _pickImageError = e;
      })        ;
    }
  }

  /*
  void textFieldChanged(String value){

  }
  */

  ImageProvider getImageProvider(){
    return _loadFromNetwork == null ? FileImage(File(imagePath!)) :
      NetworkImage(_loadFromNetwork!) as ImageProvider ;
  }

  Widget getImageView(){
   /* return PhotoView(
      imageProvider: getImageProvider(),
    );
    */
    return PlaceSelectedImage(getImageProvider());
  }

  Widget getImage(double? pageHeight, double? pageWidth){

    /*  print('- the new height is $pageHeight');
      print('- the new Width is $pageWidth');

    */

    Widget ret =  (kIsWeb
                            ?  (_loadFromNetwork == null ? Image.memory(_imageInt8List!,                            
                          //     height: 350,
                          //     width: 400,
                        //        fit: BoxFit.contain,
                          //      width: double.infinity, 
          fit: BoxFit.fitWidth,
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
                        ) : Image.network(_loadFromNetwork!,    
                              height: 350,
                               width: 400,
                               frameBuilder: (_, image, loadingBuilder, __) {
                            if (loadingBuilder == null) {
                              return const SizedBox(
                                height: 300,
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            return image;
                          },
                          loadingBuilder: (BuildContext context, Widget image, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return image;
                            return SizedBox(
                              height: 300,
                              child: Center(
                                child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (BuildContext context, Object error,
                              StackTrace? stackTrace) =>
                          const Center(
                              child: Text('This image type is not supported')),
                          key: imageKey,
                        ))
                            : (_loadFromNetwork == null ? Image.memory(_imageInt8List!,
                     //           height: 350,
                      //         width: 400,
                            //    fit: BoxFit.contain,
                       //         width: double.infinity, 
                               fit: BoxFit.fitWidth,
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
                        ) : Image.network(_loadFromNetwork!,
                              height: 350,
                               width: 400,
                               frameBuilder: (_, image, loadingBuilder, __) {
                            if (loadingBuilder == null) {
                              return const SizedBox(
                                height: 300,
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            return image;
                          },
                          loadingBuilder: (BuildContext context, Widget image, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return image;
                            return SizedBox(
                              height: 300,
                              child: Center(
                                child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                ),
                              ),
                            );
                          },
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
        child: IntrinsicHeight(
          child: 
          SizedBox(
         height: 350 ,
         width: 500,
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


  /* Future<void> */ waitAnimation(BuildContext context) /* async */
  {
     showDialog(
        context: context,
        builder: (context){
          return const Center(child: CircularProgressIndicator());
        },  
     );
  }

  @override
  Widget build(BuildContext context) {
    final String title = useSnapshot ? "snapshot" : "basic";
    _pageHeight = _globalKey.currentContext?.size?.height;
    _pageWidth = _globalKey.currentContext?.size?.width;

    Widget floatingButton = FloatingActionButton(
      heroTag: null,
      tooltip: 'Clicked color',
      onPressed: null,
      backgroundColor: selectedColor ?? Colors.green,
    );

    floatingButton = Center(child: SizedBox(height: 60, width: 60,
        child: Container(child: null,
        decoration: BoxDecoration(
          color: selectedColor == null ? Colors.green : selectedColor,
          border: Border.all(
              color: Colors.black,
              width: 2,
            ),
          ),

        ),
        ),
      );

      /*
      print('the new height is $_pageHeight');
      print('the new Width is $_pageWidth');
      */
    Widget loadingAnimation = TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 10),
                          duration: const Duration(seconds: 10),
                          builder: (context, value, _) => CircularProgressIndicator(value: value,
                           semanticsLabel: 'Loading...',                           
              semanticsValue: 'Loading...',              
              strokeWidth: 10.0,),
              );

    return SafeArea(
      minimum: const EdgeInsets.all(10.0),
      child: Scaffold(
        appBar: AppBar(title: Text("Color picker $title from file or url")),
        body: StreamBuilder(
            initialData: Colors.green[500],
            stream: _stateController.stream,
            builder: (buildContext, snapshot) {
              // Color selectedColor = snapshot.data as Color ?? Colors.green;
              if (loading) {
                return /* const */ const Center(
                heightFactor: 10,
                child: /* Text('Loading...',
                style: TextStyle(fontSize: 27,
                          backgroundColor: Colors.orange,
                          color: Colors.black, fontWeight: FontWeight.bold),
                )
                */
                CircularProgressWithText(text: 'Loading...'),
            );
              } else {
                return Container(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                children: [
                  Center(
                    // Center is a layout widget. It takes a single child and positions it
                    // in the middle of the parent.
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                          const Column(children: [
                            Text(
                                  "1. Select picture to show",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                  ),
                              ),
                              Text(
                                  "2. Zoom picture out or in with mouse scroll wheel",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black, fontWeight: FontWeight.bold
                                  )
                              ),
                             Text(
                                  "3. Click on image pixel to show selected color after pressing Open dialog button",
                                  style: TextStyle(
                                    fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold
                                  ),
                              ),
                               Padding(
                                 padding: EdgeInsets.all(5.0),
                                 child: Text(
                                  "(If selected color is not correct, move/click several times.)",
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                    color: Colors.black, fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                          ]
                          ),
                              Container(
                              margin: const EdgeInsets.all(0.0),
                              decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            width: 2,
                          ),
                       //   borderRadius: BorderRadius.circular(12),
                        ),
                        child:
                        Wrap(
             //             spacing: 8.0, // gap between adjacent chips
               //           runSpacing: 4.0, // gap between lines
                        // ignore: unnecessary_const
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                            Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: MaterialButton(
                              color: Colors.blue,
                              child: const Text(
                                  "Pick Image from Gallery",
                                  style: TextStyle(
                                      color: Colors.white70, fontWeight: FontWeight.bold
                                  )

                              ),
                              onPressed: () {
                                _onImageButtonPressed(ImageSource.gallery, context: context);
                              }
                          ),
                        ),
                         Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: MaterialButton(
                              color: Colors.blue,
                              child: const Text(
                                  "Load a picture from url text field",
                                  style: TextStyle(
                                      color: Colors.white70, fontWeight: FontWeight.bold
                                  )
                              ),
                              onPressed: () {
                                _onLoadImageButtonPressed(context);
                              }
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: MaterialButton(
                              color: Colors.blue,
                              child: const Text(
                                  "Open picture dialog",
                                  style: TextStyle(
                                      color: Colors.white70, fontWeight: FontWeight.bold
                                  )
                              ),
                              onPressed: () {
                                _openDialogButtonPressed(context: context);
                              }
                          ),
                        ),
                                    ]          ,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: TextFormField(
                          decoration: const InputDecoration(
                              hintStyle: TextStyle(fontSize: 17),
                              hintText: 'Enter a picture url to load',
                              suffixIcon: Icon(Icons.inbox),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(20),
                          ),
                          onChanged: (String val) {
                            _loadUrl = val;
                          },
                             ),
                          ),
                        ],
                        ),
                              ),
                        const SizedBox(height: 5),
                        SizedBox(height: 20,
                              width: double.infinity,
                          child: Container(child: null,
                            color: selectedColor == null ? Colors.green : selectedColor,
                          ),
                        ),
                        const SizedBox(height: 5),

                          Container(
                       //     margin: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            width: 2,
                          ),
                       //   borderRadius: BorderRadius.circular(12),
                        ),
                        child: Wrap(
                          spacing: 8.0, // gap between adjacent chips
                          runSpacing: 4.0, // gap between lines
                        // ignore: unnecessary_const
                        children: <Widget>[
                        Container(
                          margin: const EdgeInsets.all(0.0),
                                  color: Colors.white,
                                  height: 25,
                                  width: 50,
                                ),
                       const Center(child: Text(
                          'Pixel selection: (Flutter: copy/paste color code)',
                          style: TextStyle(fontSize: 18,
                                      color: Colors.black, fontWeight: FontWeight.bold
                                  )
           ),
                   ),
                  Center(child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Center(child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              verticalDirection: VerticalDirection.down,
                              children: <Widget>[
                                Text(
                                  '$intHex',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                Text(
                                  ' ',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                               /* FloatingActionButton(
                                  heroTag: null,
                                  tooltip: 'Clicked color',
                                  onPressed: (){},
                                  backgroundColor: selectedColor ?? Colors.green,
                                ) */
                                floatingButton,
                                Text(
                                  ' ',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                SelectableText(
                                  selectedColor == null ? '' : selectedColor.toString(),
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),// This trailing comma makes auto-formatting nicer for build methods.
                              ]
                          ),
                          ),
                        ),
                        ),
                           Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              verticalDirection: VerticalDirection.down,
                              children: <Widget>[
                              TextButton(
                                style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.blue,
                                ),
                                onPressed: () async {
                                    Clipboard.setData(ClipboardData(text: intHex.toString()));
                                },
                                child: const Text("Copy int color value into clipboard"),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.blue,
                                ),
                                onPressed: () async {
                                  if (!_isButtonDisabled)
                                  {
                                    Clipboard.setData(ClipboardData(text: strHex ));
                                  }
                                },
                                child: const Text("Copy hex color value into clipboard"),
                              ),
                              ]
                              ),
                                  Container(
                                  color: Colors.white,
                                  height: 25,
                                  width: 50,
                                ),
      ],
    ),
    ),
                        const Text(
                          'Pixel selection: ',
                          style: TextStyle(
                                      color: Colors.black, fontWeight: FontWeight.bold
                                  ),
                        ),


                      ],
                    ),
                  ),

      /*
      SingleChildScrollView(
            child: ?* ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),

              child:
              */

              LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
              _box_width = constraints.maxWidth -100;
              _box_height = constraints.maxHeight -200;
            return
                   RepaintBoundary(
                    key: paintKey,
                    child: GestureDetector(
                      onPanDown: (details) {
                        searchPixel(details.globalPosition);
                      },
                      onPanUpdate: (details) {
                        searchPixel(details.globalPosition);
                      },
                      child: /* Center(
                        child: */ (_pickImageError != null ? Text(
                          'Pick image error: $_pickImageError',
                          textAlign: TextAlign.center,
                        ) : (_imageInt8List == null ? const Text(
                          'Choose an image to show',
                          textAlign: TextAlign.center,
                        ) : /* SizedBox(
                              child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
            return getImage(constraints.maxHeight, constraints.maxWidth);
        }
    )
    )
    */
    getImage(_box_height, _box_width)
                        )/* ) , */
                      ),
                    ),
                  );
                  }
                ),

              //  ],
         //     ),
         //   ),
        //  ),


                  /*
                  Container(
                    margin: const EdgeInsets.all(70),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selectedColor!,
                        border: Border.all(width: 2.0, color: Colors.white),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2))
                        ]),
                  ),
                  Positioned(
                    left: 114,
                    top: 95,
                    child: Text('$selectedColor',
                        style: const TextStyle(
                            color: Colors.white,
                            backgroundColor: Colors.black54)),
                  ),
                  */
                ],

              ),
            );
              }
            }
        ),
      ),
    );
  }

  void searchPixel(Offset globalPosition) async {
    if (photo == null) {
     // await (useSnapshot ? loadSnapshotBytes() : loadImageBundleBytes());
      return;
    }
    if (useSnapshot && snapShotBytes == null) // use showen image widget as region can get its bytes as png:
    {
      unModifiedLoadImageInt8List = _imageInt8List;
      await loadSnapshotBytes();
    }
    _calculatePixel(globalPosition);
  }

  void _calculatePixel(Offset globalPosition) {
    RenderBox box = currentKey.currentContext!.findRenderObject() as RenderBox;
    Offset localPosition = box.globalToLocal(globalPosition);

    double px = localPosition.dx;
    double py = localPosition.dy;

    if (!useSnapshot) {
      double widgetScale = box.size.width / photo!.width;
    //  print(py);
      px = (px / widgetScale);
      py = (py / widgetScale);
    }

    img.Pixel pixel32 = photo!.getPixelSafe(px.toInt(), py.toInt());
   // int hex = hexOfRGB(pixel32.r.toInt(), pixel32.g.toInt(), pixel32.b.toInt()); // pixel32.toString();
    // int hex = abgrToArgb(pixel32);

    setState(() {
     // intHex = hex;
      x = px;
      y = px;
      selectedColor = /* ui.Color(intHex); */ Color.fromARGB(
          pixel32.a.toInt(), pixel32.r.toInt(), pixel32.r.toInt(),
          pixel32.b.toInt());
      intHex = selectedColor!.value;
      strHex = "0x${intHex.toRadixString(16)}";
    });
    Clipboard.setData(ClipboardData(text: strHex)); /*.then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Copied to your clipboard !')));
    });
    */
    _isButtonDisabled = false;
    _stateController.add(Color(intHex));
  }

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


  Future loadImageBundleBytes() async {
    ByteData imageBytes = await rootBundle.load(imagePath!);
    setImageBytes(imageBytes);
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

  void setImageBytes(ByteData? imageBytes) {
    if (imageBytes == null) {
      return;
    }
    // Uint8List values = imageBytes.buffer.asUint8List();
    _imageInt8List = imageBytes.buffer.asUint8List();
    setImageUint8List(/* values */);
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

// image lib uses uses KML color format, convert #AABBGGRR to regular #AARRGGBB
  int abgrToArgb(int argbColor) {
    int r = (argbColor >> 16) & 0xFF;
    int b = argbColor & 0xFF;
    return (argbColor & 0xFF00FF00) | (b << 16) | r;
  }
}


class CircularProgressWithText extends StatelessWidget {
  final String text;

  const CircularProgressWithText({super.key, required this.text,});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CircularProgressPainter(8),
      child: Container(
        width: 240,
        height: 240,
        alignment: Alignment.center,
        child: OutlinedText(text),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double percentage;

  _CircularProgressPainter(this.percentage);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 10
      ..color = Colors.blue
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);

    canvas.drawCircle(center, radius, paint);

    final progressPaint = Paint()
      ..strokeWidth = 10
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double arcAngle = 2 * pi * (percentage / 100);

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2,
        arcAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class OutlinedText extends StatelessWidget {
  final String text;

  const OutlinedText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
  //  final primaryColor = Colors.black.withOpacity(0.5);
    final primaryColor = Colors.blueAccent;
    final textStyle = TextStyle(
      shadows: [
        Shadow(
          color: primaryColor,
          blurRadius: 5,
          offset: const Offset(0, 0),
        )
      ],
      color: Colors.white,
      fontSize: 42,
      fontWeight: FontWeight.bold,
    );
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          text,
          style: textStyle.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..color = primaryColor
              ..strokeWidth = 2,
            color: null,
          ),
        ),
        Text(text, style: textStyle),
      ],
    );
  }
}