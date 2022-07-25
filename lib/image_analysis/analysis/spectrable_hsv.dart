import 'dart:math';

import 'package:spectroid/image_analysis/analysis/spectrable.dart';
import 'package:spectroid/image_analysis/data_extraction/image_data.dart';

class SpectrableHSV extends Spectrable {

  int upperHueBound = 270;
  int lowerHueBound = -6;

  SpectrableHSV(ImageData imageData): super(imageData);

  bool isHSVPixelValid(pixel){
    return getRelativeHue(pixel.hue) <= upperHueBound - lowerHueBound && pixel.saturation > minSaturation && pixel.value > minValue;
  }

  bool isHSVPixelValidHighValue(pixel){
    return getRelativeHue(pixel.hue) <= upperHueBound - lowerHueBound && pixel.saturation > minSaturation && pixel.value > highMinValue;
  }

  int getRelativeHue(int hue){
    return (hue - lowerHueBound) % 360;
  }

  double linearHueToWavelength(int hue){
    return wavelengthMax - getRelativeHue(hue)*(wavelengthMax-wavelengthMin)/(upperHueBound - lowerHueBound);
  }

  void updateSpectrumSumOfValueOverSaturation(double wavelength, HSVPixel pixel){
    if(spectrum[wavelength] == null){
      spectrum[wavelength] = 0;
    }
    spectrum[wavelength] = spectrum[wavelength]! + pixel.value.toDouble()/pixel.saturation.toDouble();
  }

}