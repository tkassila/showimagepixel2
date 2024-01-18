// import 'dart:ffi';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
      Key? key,
  }) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
  bool useSnapshot = false;
  String? _loadUrl;
  String? _loadFromNetwork;
// based on useSnapshot=true ? paintKey : imageKey ;
// this key is used in this example to keep the code shorter.
  late GlobalKey currentKey;

  final StreamController _stateController = StreamController();
  final TextEditingController _controller = TextEditingController();

//late img.Image photo ;
  img.Image? photo;
  int intHex = 0;
  String strHex = "";
  double x = 0.0;
  double y = 0.0;
  ByteData? /* Uint8List? */ _imageBytes;
  Uint8List? _imageInt8List;
  dynamic _pickImageError;
  double? maxWidth;
  double? maxHeight;
  int? quality;
  File? pickedFile;
  final MethodChannel _channel = const MethodChannel('get_ip');

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
        _controller.dispose();
        super.dispose();
  }

  @override
  void initState() {
    currentKey = useSnapshot ? paintKey : imageKey;
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

  Future _onLoadImageButtonPressed() async
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
    var loaded = await imageFromUrl(_loadUrl!);
    setState(() {
        _loadFromNetwork = _loadUrl;
       // _imageInt8List = await FileHandler(_loadUrl!)._readToBytes();      
        _imageInt8List = loaded;
        setImageUint8List(/* _imageInt8List! */);            
    });

    return;
  } 

  Future<void> _onImageButtonPressed(ImageSource source,
      {BuildContext? context}) async {
    try {
      final XFile? pickedF = await _picker.pickImage(
        source: source,
        requestFullMetadata: false,
        /*   maxWidth: maxWidth,
            maxHeight: maxHeight,
            imageQuality: quality,
          */
      );

      // final PickedFile? pickedF = await _picker.getImage(source: source);
      _imageBytes = null;
      _imageInt8List = null;
      if (pickedF == null) {
        return;
      }

      String? imagePath2 = pickedF.path;
      if (kDebugMode) {
        print("imagePath2=$imagePath2");
      }

      // Uint8List bytes:
      Uint8List? uint8list2;
      await pickedF.readAsBytes().then((value) {
         uint8list2 = Uint8List.fromList(value);
         imagePath = imagePath2;

        setState(() {
          _imageInt8List = uint8list2;
          _loadFromNetwork = null;
          // _imageBytes = pickedF?.readAsBytes() as Uint8List?;
          setImageUint8List(/* _imageInt8List! */);
          imagePath = imagePath2;
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
        return;
      });

    } catch (e) {
      setState(() {
        _pickImageError = e;
      })        ;
    }
  }

  void textFieldChanged(String value){

  }

  @override
  Widget build(BuildContext context) {
    final String title = useSnapshot ? "snapshot" : "basic";

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("Color picker $title from file or url")),
        body: StreamBuilder(
            initialData: Colors.green[500],
            stream: _stateController.stream,
            builder: (buildContext, snapshot) {
              // Color selectedColor = snapshot.data as Color ?? Colors.green;
              return Column(
                children: [
                  Center(
                    // Center is a layout widget. It takes a single child and positions it
                    // in the middle of the parent.
                    child: Column(
                      // Column is also a layout widget. It takes a list of children and
                      // arranges them vertically. By default, it sizes itself to fit its
                      // children horizontally, and tries to be as tall as its parent.
                      //
                      // Invoke "debug painting" (press "p" in the console, choose the
                      // "Toggle Debug Paint" action from the Flutter Inspector in Android
                      // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
                      // to see the wireframe for each widget.
                      //
                      // Column has various properties to control how it sizes itself and
                      // how it positions its children. Here we use mainAxisAlignment to
                      // center the children vertically; the main axis here is the vertical
                      // axis because Columns are vertical (the cross axis would be
                      // horizontal).
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(10.0),
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
                          padding: const EdgeInsets.all(10.0),
                          child: MaterialButton(
                              color: Colors.blue,
                              child: const Text(
                                  "Load a picture from url text field",
                                  style: TextStyle(
                                      color: Colors.white70, fontWeight: FontWeight.bold
                                  )
                              ),
                              onPressed: () {
                                _onLoadImageButtonPressed();
                              }
                          ),
                        ),
                        TextFormField(                      
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
                        const Text(
                          'Pixel selection: ',
                        ),
                        Center(child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Center(child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              verticalDirection: VerticalDirection.down,
                              children: <Widget>[
                                Text(
                                  '$intHex ',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                Text(
                                  ' ',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                FloatingActionButton(
                                  tooltip: 'Clicked color',
                                  onPressed: null,
                                  backgroundColor: selectedColor ?? Colors.green,
                                ),
                                Text(
                                  ' ',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                Text(
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
                                  if (!_isButtonDisabled)
                                  {
                                    Clipboard.setData(ClipboardData(text: intHex.toString()));
                                  }
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
                                    Clipboard.setData(ClipboardData(text: strHex));
                                  }
                                },                                          
                                child: const Text("Copy hex color value into clipboard"),
                              ),
                              ]
                              ),
                             Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              verticalDirection: VerticalDirection.down,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                  color: Colors.white,
                                  height: 50,
                                  width: 50,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

      SingleChildScrollView(
            child: /* ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              
              child: 
              */
                   RepaintBoundary(
                    key: paintKey,
                    child: GestureDetector(
                      onPanDown: (details) {
                        searchPixel(details.globalPosition);
                      },
                      onPanUpdate: (details) {
                        searchPixel(details.globalPosition);
                      },
                      child: Center(
                        child: (_pickImageError != null ? Text(
                          'Pick image error: $_pickImageError',
                          textAlign: TextAlign.center,
                        ) : (_imageInt8List == null ? const Text(
                          'Choose an image to show',
                          textAlign: TextAlign.center,
                        ) : (kIsWeb
                            ? (_loadFromNetwork == null ? Image.memory(_imageInt8List!,
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
                          errorBuilder: (BuildContext context, Object error,
                              StackTrace? stackTrace) =>
                          const Center(
                              child: Text('This image type is not supported')),
                          key: imageKey,
                        ))
                            : (_loadFromNetwork == null ? Image.memory(_imageInt8List!,
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
                          errorBuilder: (BuildContext context, Object error,
                              StackTrace? stackTrace) =>
                          const Center(
                              child: Text('This image type is not supported')),
                          key: imageKey,
                        )))
                        )),
                      ),
                    ),
                  ),

              //  ],
              ),
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

              );
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
    _isButtonDisabled = false;
    _stateController.add(Color(hex));
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
