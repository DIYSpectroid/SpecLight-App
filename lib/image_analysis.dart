import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;

enum Algorithm {
  linear,
  polynomial,
  position_based
}

class ImageAnalysis{

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

  static Future<List<int>> getBytes(String imageFilePath) async{
    List<int> values = await File(imageFilePath).readAsBytes();
    img.Image image = img.decodeImage(values)!;
    return image.data;
  }

  static Future<List<Pixel>> convertRGBtoHSV(List<int> bytes) async{
    List<Pixel> pixels = [];
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
      pixels.add(Pixel((h*360).round(), (s*100).round(), (v*100).round()));

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

class Spectrum{
  Map<double, double> spectrum = {};
  List<Pixel> pixels;
  static const int wavelengthMin = 380;
  static const int wavelengthMax = 750;
  static const int additionalHue = 12;
  static const int maxHue = 270;
  static const int minSaturation = 2;
  static const int minValue = 20;

  List<double> getKeys(){
    return spectrum.keys.toList();
  }

  List<double> getValues(){
    return spectrum.values.toList();
  }

  Spectrum(this.pixels, Algorithm algorithm){
    switch(algorithm){
      case Algorithm.linear:
        linearHSVToSpectrum();
        break;
      case Algorithm.polynomial:

        break;
      case Algorithm.position_based:

        break;
    }
  }

  void linearHSVToSpectrum(){
    for(Pixel pixel in pixels){
      int relativeHue = (pixel.hue + additionalHue) % 360;

      if(relativeHue <= maxHue + additionalHue && pixel.saturation > minSaturation && pixel.value > minValue){
        double wavelength = wavelengthMax - relativeHue*(wavelengthMax-wavelengthMin)/(maxHue + additionalHue);
        if(spectrum[wavelength] == null){
          spectrum[wavelength] = 0;
        }
        spectrum[wavelength] = spectrum[wavelength]! + pixel.value.toDouble()/pixel.saturation.toDouble();
      }
    }
    double maxValue = spectrum.values.reduce(max);
    for(double wavelength in spectrum.keys){
      spectrum[wavelength] = spectrum[wavelength]!*100/maxValue;
    }
  }
}




