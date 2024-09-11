# showimagepixel2
A flutter app to open local or remote image and click a point to show a pixel color value as hex color or int color.
A zip file is a web deploy. This zip file contains an index file, where base address (=local directory) is showpixel .
If you wil install this app, unzip this zip file into subdirectory: showpixel and by example to start in some browser,
write an address like: http://localhost:xxxx/showpixel/ . When you deployed this web app: flutter build command, remember to update index.html
base address / into example /showpixel address!

## Usage

1. Press either button 'Pick ... from gallery' to load local image file. 
2. Or Press either button 'Load network ... image' to load network image.
3. After loaded image, press mouse buton and click some pixel on below image.
4. Select copy selected color as integer or hex value string into clipboard.
5. Or press button 'Open picture dialog' to soo more bigger image, which can even zoomed and scrolled more precise.
6. In this dialog every click with mouse goes into clipboard as hex value. There is copy icon button for copy as integer value also.
   
## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
