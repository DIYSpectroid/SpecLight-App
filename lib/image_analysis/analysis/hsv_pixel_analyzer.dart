import 'package:spectroid/image_analysis/data_extraction/image_data.dart';

class HSVPixelAnalyzer {
  int wavelengthMin = 400;
  int wavelengthMax = 700;
  int upperHueBound = 270;
  int lowerHueBound = -6;
  int minSaturation = 7;
  int minValue = 15;
  int highMinValue = 80;

  HSVPixelAnalyzer();

  bool isPixelValid(pixel){
    return getRelativeHue(pixel.hue) <= upperHueBound - lowerHueBound && pixel.saturation > minSaturation && pixel.value > minValue;
  }

  bool isPixelValidHighValue(pixel){
    return getRelativeHue(pixel.hue) <= upperHueBound - lowerHueBound && pixel.saturation > minSaturation && pixel.value > highMinValue;
  }

  int getRelativeHue(int hue){
    return (hue - lowerHueBound) % 360;
  }

  double linearHueToWavelength(int hue){
    return wavelengthMax - getRelativeHue(hue)*(wavelengthMax-wavelengthMin)/(upperHueBound - lowerHueBound);
  }

  void updateSpectrumSumOfValueOverSaturation(Map<double, double> spectrum, double wavelength, HSVPixel pixel){
    if(spectrum[wavelength] == null){
      spectrum[wavelength] = 0;
    }
    spectrum[wavelength] = spectrum[wavelength]! + pixel.value.toDouble()/pixel.saturation.toDouble();
  }

}