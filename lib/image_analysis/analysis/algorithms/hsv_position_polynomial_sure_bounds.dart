import 'dart:developer';
import 'dart:ffi';
import 'dart:math';

import 'package:spectroid/image_analysis/analysis/position_spectrable_hsv.dart';
import 'package:spectroid/image_analysis/data_extraction/image_data.dart';

import '../polynomial_position_spectrable_hsv.dart';
import '../spectrable.dart';

class HSVPositionPolynomialSureBounds extends PolynomialPositionSpectrableHSV  {
  int pixelsOnEachSide = 4;

  HSVPositionPolynomialSureBounds(List<double> relativePosToWavelengthFunctionCoefficients,
      List<double> inverseRelativePosToWavelengthFunctionCoefficients,
      ImageData imageData)
      : super(relativePosToWavelengthFunctionCoefficients, inverseRelativePosToWavelengthFunctionCoefficients, imageData);

  void generateSpectrum(){
    SpectrumPositionBounds spectrumBounds = getSpectrumBounds();
    print("${spectrumBounds.firstLightX}, ${spectrumBounds.lastLightX}, ${spectrumBounds.firstLightWavelength}, ${spectrumBounds.lastLightWavelength}");

    SpectrumPositionBounds spectrumBoundsForPolynomial = getBoundsForPolynomial(spectrumBounds);
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
    normalizeAndSampleSpectrumValues();
  }

  @override
  SpectrumPositionBounds getSpectrumBounds() {
    int currentPositionX = 0;
    int currentPositionY = 0;
    int firstLightPositionX = imageData.width;
    HSVPixel? firstLightPixel;
    int lastLightPositionX = 0;
    HSVPixel? lastLightPixel;

    double firstLightWavelength = wavelengthMin.toDouble();
    double lastLightWavelength = wavelengthMax.toDouble();

    List<bool> valids = List.generate(imageData.width, (index) => false);

    for (HSVPixel pixel in imageData.hsvPixels) {
      valids[currentPositionX] = isHSVPixelValid(pixel) && isPixelXYZRatioUnique(linearHueToWavelength(pixel.hue));
      currentPositionX++;

      if(currentPositionX == imageData.width) {
        currentPositionX = 0;

        for(int i = pixelsOnEachSide; i < imageData.width - pixelsOnEachSide; i++) {
          if(valids.getRange(i-pixelsOnEachSide, 1+i+pixelsOnEachSide).reduce((value, element) => value && element)) {
            if(i < firstLightPositionX) {
              firstLightPositionX = i;
              firstLightPixel = imageData.hsvPixels.elementAt(currentPositionY * imageData.width + i);
              print("minX: ${firstLightPositionX}, minHue:${firstLightPixel.hue}, val:${firstLightPixel.value}");
              break;
            }
          }
        }
        for(int i = imageData.width - pixelsOnEachSide - 1; i > pixelsOnEachSide - 1; i--) {
          if(valids.getRange(i-pixelsOnEachSide, 1+i+pixelsOnEachSide).reduce((value, element) => value && element)) {
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

    if(firstLightPixel == null || lastLightPixel == null) {
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
}