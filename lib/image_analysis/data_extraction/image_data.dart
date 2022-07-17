import 'package:flutter/foundation.dart';
import 'image_data_extraction.dart';

class ImageData{
  String filepath;
  List<int> bytes;
  int height;
  int width;
  List<HSVPixel> hsvPixels = [];
  List<RGBPixel> rgbPixels = [];


  ImageData(this.filepath, this.bytes, this.height, this.width);

  Future<void> ExtractData() async {
    List<int> rgba = await compute(ImageDataExtraction.getRGBABytesFromABGRInts, bytes);
    hsvPixels = await compute(ImageDataExtraction.convertBytesToHSV, rgba);
    rgbPixels = await compute(ImageDataExtraction.convertBytesToRGB, rgba);
  }
}

abstract class Pixel {
}

class HSVPixel extends Pixel{
  int hue;
  int saturation;
  int value;

  HSVPixel(this.hue, this.saturation, this.value);
}

class RGBPixel extends Pixel{
  int red;
  int green;
  int blue;
  late int intensity;

  RGBPixel(this.red, this.green, this.blue){
    intensity = red + green + blue;
  }
}
