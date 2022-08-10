import 'dart:math';

import 'package:spectroid/image_analysis/analysis/spectrable_hsv.dart';
import 'package:spectroid/image_analysis/data_extraction/image_data.dart';

class PositionSpectrableHSV extends SpectrableHSV {

  PositionSpectrableHSV(ImageData imageData) : super(imageData) {}

  SpectrumPositionBounds getSpectrumBounds() {
    int currentPositionX = 0;
    int firstLightPositionX = imageData.width;
    int lastLightPositionX = 0;
    double firstLightWavelength = wavelengthMin.toDouble();
    double lastLightWavelength = wavelengthMax.toDouble();

    for (HSVPixel pixel in imageData.hsvPixels) {
      if (isHSVPixelValid(pixel)) {
        firstLightPositionX = min(firstLightPositionX, currentPositionX);
        lastLightPositionX = max(lastLightPositionX, currentPositionX);
        if(firstLightPositionX == currentPositionX){
          double wavelength = linearHueToWavelength(pixel.hue);
          if(isPixelXYZRatioUnique(wavelength)){
            firstLightWavelength = wavelength;
          }
        }
        if(lastLightPositionX == currentPositionX){
          double wavelength = linearHueToWavelength(pixel.hue);
          if(isPixelXYZRatioUnique(wavelength)){
            lastLightWavelength = wavelength;
          }
        }
      }
      currentPositionX++;
      currentPositionX = currentPositionX % imageData.width;
    }

    return SpectrumPositionBounds(firstLightPositionX ,lastLightPositionX, firstLightWavelength, lastLightWavelength);
  }
}

class SpectrumPositionBounds {
  int firstLightX;
  int lastLightX;
  double firstLightWavelength;
  double lastLightWavelength;

  SpectrumPositionBounds(this.firstLightX, this.lastLightX, this.firstLightWavelength, this.lastLightWavelength);
}