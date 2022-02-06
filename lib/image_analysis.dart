import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;


class ImageAnalysis{

  static List<int> getRGBABytesFromABGRInts(List<int> pixels){
    List<int> bytes = [];

    for (var element in pixels) {
      bytes.add(element % 256);
      bytes.add((element~/(256))%256);
      bytes.add((element~/(256*256))%256);
      bytes.add(element~/(256*256*256));
    }
    return bytes;
  }

  static Future<List<int>> getBytes(String imageFilePath) async{
    List<int> values = await File(imageFilePath).readAsBytes();
    img.Image image = img.decodeImage(values)!;
    return image.data;
  }

  static List<Pixel> convertRGBtoHSV(List<int> bytes){
    List<Pixel> pixels = [];
    for(int i=0;i<bytes.length-3;i+=4){
      double r = bytes[i]/255;
      double g = bytes[i+1]/255;
      double b = bytes[i+2]/255;
      double maxi = max(r, max(g,b));
      double mini = min(r, min(g,b));
      double dif = maxi - mini;
      double v = maxi;
      double s = maxi == 0 ? 0 : dif/maxi;
      double h = 0;
      if (max != min){
        if(maxi == r){
          h = (g - b) / dif + (g < b ? 6 : 0);
        }
        else if(maxi == g){
          h = (b - r) / dif + 2;
        }
        else if(maxi == b){
          h = (r - g) / dif + 4;
        }

        h /= 6;
      }
      pixels.add(Pixel(h*360 as int, s*100 as int, v*100 as int))
    }
    return pixels;
  }
}

class Pixel{
  late int hue;
  late int saturation;
  late int value;

  Pixel(this.hue, this.saturation, this.value);
}




