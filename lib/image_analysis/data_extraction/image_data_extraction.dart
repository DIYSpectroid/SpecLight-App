import 'dart:math';
import 'package:image/image.dart' as img;
import 'dart:io';

import 'image_data.dart';

class ImageDataExtraction{

  static Future<List<int>> getRGBABytesFromABGRInts(List<int> pixels) async{
    List<int> bytes = [];

    for (var element in pixels) {
      bytes.add(element % 256);
      bytes.add((element~/(256))%256);
      bytes.add((element~/(256*256))%256);
      bytes.add(element~/(256*256*256));
    }
    return bytes;
  }

  static Future<ImageData> getImageData(String imageFilePath) async{
    List<int> values = await File(imageFilePath).readAsBytes();
    img.Image image = img.decodeImage(values)!;
    return new ImageData(imageFilePath, image.data, image.height, image.width);
  }

  static Future<List<HSVPixel>> convertBytesToHSV(List<int> bytes) async{
    List<HSVPixel> pixels = [];
    for(int i=0;i<bytes.length-3;i+=4){
      double r = bytes[i]/255;
      double g = bytes[i+1]/255;
      double b = bytes[i+2]/255;

      double maxi = max(r, max(g,b));
      double mini = min(r, min(g,b));
      double dif = maxi - mini;
      double v = maxi;
      double s = maxi == 0.0 ? 0.0 : dif/maxi;
      double h = 0.0;

      if (dif.abs() > 1e-9){
        if(maxi == r){
          h = (g - b) / dif + (g < b ? 6.0 : 0.0);
        }
        else if(maxi == g){
          h = (b - r) / dif + 2.0;
        }
        else if(maxi == b){
          h = (r - g) / dif + 4.0;
        }
        h /= 6;
      }

      pixels.add(HSVPixel((h*360).round(), (s*100).round(), (v*100).round()));
    }
    return pixels;
  }

  static Future<List<RGBPixel>> convertBytesToRGB(List<int> bytes) async{
    List<RGBPixel> pixels = [];
    for(int i=0;i<bytes.length-3;i+=4) {
      pixels.add(RGBPixel(bytes[i], bytes[i+1], bytes[i+2]));
    }
    return pixels;
  }
}

