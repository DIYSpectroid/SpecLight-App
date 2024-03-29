import 'dart:developer';
import 'dart:ffi';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:spectroid/image_analysis/analysis/position_spectrable_hsv.dart';
import 'package:spectroid/image_analysis/data_extraction/image_data.dart';

import '../polynomial_position_spectrable_hsv.dart';
import '../spectrable.dart';

class HSVPositionPolynomialSureBounds extends PolynomialPositionSpectrableHSV  {
  static const int PixelsOnEachSide = 4;

  HSVPositionPolynomialSureBounds(List<double> relativePosToWavelengthFunctionCoefficients,
      List<double> inverseRelativePosToWavelengthFunctionCoefficients,
      ImageData imageData)
      : super(relativePosToWavelengthFunctionCoefficients, inverseRelativePosToWavelengthFunctionCoefficients, imageData);

  Future<void> generateSpectrum() async{
    SpectrumPositionBounds spectrumBounds = await compute(getSpectrumBounds, 0);
    print("${spectrumBounds.firstLightX}, ${spectrumBounds.lastLightX}, ${spectrumBounds.firstLightWavelength}, ${spectrumBounds.lastLightWavelength}");

    SpectrumPositionBounds spectrumBoundsForPolynomial = await compute(getBoundsForPolynomial, spectrumBounds);
    print("${spectrumBoundsForPolynomial.firstLightX}, ${spectrumBoundsForPolynomial.lastLightX}, ${spectrumBoundsForPolynomial.firstLightWavelength}, ${spectrumBoundsForPolynomial.lastLightWavelength}");
    int currentPositionX = 0;
    for(HSVPixel pixel in imageData.hsvPixels){
      if(isHSVPixelValid(pixel)){
        double wavelength = getWavelengthForPolynomial(currentPositionX, spectrumBoundsForPolynomial);
        updateSpectrumSumOfValueOverSaturation(wavelength, pixel);
      }
      currentPositionX++;
      currentPositionX = currentPositionX % imageData.width;
    }
    normalizeAndSampleSpectrumValues(0);
  }

  @override
  Future<SpectrumPositionBounds> getSpectrumBounds(int _) async{

    int pixelBounds = PixelsOnEachSide;

    HSVPixel? firstLightPixel;
    HSVPixel? lastLightPixel;
    int firstLightPositionX = imageData.width;
    int lastLightPositionX = 0;

    List<bool> valids = List.generate(imageData.width, (index) => false);

    do{
      int currentPositionX = 0;
      int currentPositionY = 0;
      firstLightPositionX = imageData.width;
      lastLightPositionX = 0;
      for (HSVPixel pixel in imageData.hsvPixels) {
        valids[currentPositionX] = isHSVPixelValid(pixel) && isPixelXYZRatioUnique(linearHueToWavelength(pixel.hue));
        currentPositionX++;

        if(currentPositionX == imageData.width) {
          currentPositionX = 0;

          for(int i = pixelBounds; i < imageData.width - pixelBounds; i++) {
            if(valids.getRange(i-pixelBounds, 1+i+pixelBounds).reduce((value, element) => value && element)) {
              if(i < firstLightPositionX) {
                firstLightPositionX = i;
                firstLightPixel = imageData.hsvPixels.elementAt(currentPositionY * imageData.width + i);
                print("minX: ${firstLightPositionX}, minHue:${firstLightPixel.hue}, val:${firstLightPixel.value}");
                break;
              }
            }
          }
          for(int i = imageData.width - pixelBounds - 1; i > pixelBounds - 1; i--) {
            if(valids.getRange(i-pixelBounds, 1+i+pixelBounds).reduce((value, element) => value && element)) {
              if(i > lastLightPositionX) {
                lastLightPositionX = i;
                lastLightPixel = imageData.hsvPixels.elementAt(currentPositionY * imageData.width + i);
                print("maxX: ${lastLightPositionX}, maxHue:${lastLightPixel.hue}, val:${lastLightPixel.value}");
                break;
              }
            }
          }

          currentPositionY++;
        }
      }
      pixelBounds--;
    }
    while(!_areBoundsOk(firstLightPositionX, lastLightPositionX, imageData.width) && pixelBounds >= 0);

    double firstLightWavelength = wavelengthMin.toDouble();
    double lastLightWavelength = wavelengthMax.toDouble();

    if(firstLightPixel == null || lastLightPixel == null || !_areBoundsOk(firstLightPositionX, lastLightPositionX, imageData.width)) {
      return SpectrumPositionBounds(0 ,imageData.width, SpectrablesMetadata.WAVELENGTH_MIN, SpectrablesMetadata.WAVELENGTH_MAX);
    }

    firstLightWavelength = linearHueToWavelength(firstLightPixel.hue);
    lastLightWavelength = linearHueToWavelength(lastLightPixel.hue);

    if(firstLightWavelength > lastLightWavelength) {
      int tempI = firstLightPositionX;
      double tempD = firstLightWavelength;

      firstLightPositionX = lastLightPositionX;
      firstLightWavelength = lastLightWavelength;

      lastLightPositionX = tempI;
      lastLightWavelength = tempD;
    }

    return SpectrumPositionBounds(firstLightPositionX ,lastLightPositionX, firstLightWavelength, lastLightWavelength);
  }

  static const double Min_Relative_Bounds_Distance_On_Image = 0.4;
  bool _areBoundsOk(int firstLightPositionX, int lastLightPositionX, int imageWidth)
  {
    return (lastLightPositionX - firstLightPositionX)/imageWidth >= Min_Relative_Bounds_Distance_On_Image;
  }
}