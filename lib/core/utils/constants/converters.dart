import 'dart:math' as math;

import 'package:image/image.dart' as im;
import 'package:universal_io/io.dart';

class Converters {
  static double ftToCm(num feet) {
    return double.parse((feet * 30.48).toStringAsFixed(6));
  } // m ~ 0.3048;

  static double cmToFt(num cm) =>
      double.parse((cm * 0.0328084).toStringAsFixed(6)); // m ~ 3.28084;

  static double poundToKg(num pound) =>
      double.parse((pound * 0.453592).toStringAsFixed(6));
  static double kgToPound(num kg) =>
      double.parse((kg * 2.20462).toStringAsFixed(6));

  static Future<File> jpgToPng(path) async {
    File imagePath = File(path);
    //get temporary directory
    int rand = math.Random().nextInt(10000);
    //reading jpg image

    im.Image? image = im.decodeImage(imagePath.readAsBytesSync());

    //decreasing the size of image- optional
    // Im.Image smallerImage = Im.copyResize(image!); // width: 800

    //get converting and saving in file
    File image0 = File(path)..writeAsBytesSync(im.encodePng(image!));

    return image0;
  }
}
