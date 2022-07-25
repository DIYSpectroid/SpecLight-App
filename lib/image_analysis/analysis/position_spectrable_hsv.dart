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
    int minimalAllowedX = 0;
    int maximalAllowedX = imageData.width;

    for (HSVPixel pixel in imageData.hsvPixels) {
      if (/*currentPositionX >= minimalAllowedX && currentPositionX <= maximalAllowedX && */isHSVPixelValid(pixel)) {
        firstLightPositionX = min(firstLightPositionX, currentPositionX);
        lastLightPositionX = max(lastLightPositionX, currentPositionX);
        if(firstLightPositionX == currentPositionX){
          double wavelength = linearHueToWavelength(pixel.hue);
          if(isPixelXYZRatioUnique(wavelength)){
            firstLightWavelength = wavelength;
          } else {
            minimalAllowedX = currentPositionX;
          }

        }
        if(lastLightPositionX == currentPositionX){
          double wavelength = linearHueToWavelength(pixel.hue);
          if(isPixelXYZRatioUnique(wavelength)){
            lastLightWavelength = wavelength;
          } else {
            maximalAllowedX = currentPositionX;
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