import 'dart:math';
import 'package:flutter/rendering.dart';
import 'package:spectroid/light_hue_conversion_extractor.dart';

import 'image_data_extraction.dart';

class Spectrum{
  Map<double, double> spectrum = {};
  List<HSVPixel> pixels;
  int imageWidth;
  int imageHeight;
  static const int wavelengthMin = 380;
  static const int wavelengthMax = 750;
  static const int upperHueBound = 270;
  static const int lowerHueBound = -12;
  static const int minSaturation = 2;
  static const int minValue = 15;
  static const int highMinValue = 15;

  List<double> getKeys(){
    return spectrum.keys.toList();
  }

  List<double> getValues(){
    return spectrum.values.toList();
  }

  Spectrum(this.pixels, this.imageWidth, this.imageHeight, Algorithm algorithm){
    switch(algorithm){
      case Algorithm.linear:
        linearHSVToSpectrum();
        break;
      case Algorithm.openstaxBased:
        openstaxBasedHSVToSpectrum();
        break;
      case Algorithm.positionBasedLinear:
        positionBasedLinearHSVToSpectrum();
        break;
      case Algorithm.positionBasedWithOpenstax:
        positionBasedWithOpenstaxHSVToSpectrum();
        break;
      case Algorithm.positionBasedWithHighValueControl:
        positionBasedWithHighValueControl();
        break;
      case Algorithm.positionBasedWithWiki:
        positionBasedWithWiki();
        break;
    }
  }

  void positionBasedWithWiki(){
    List spectrumBounds = getSpectrumBoundsWithWiki();
    double wavelengthIncreaseFactor = positionBasedWaveLengthIncreaseFactor(spectrumBounds);

    int currentPositionX = 0;
    for(HSVPixel pixel in pixels){
      if(isPixelValid(pixel)){
        double wavelength = spectrumBounds[2] + (currentPositionX - spectrumBounds[0])*wavelengthIncreaseFactor;
        updateSpectrumSumOfValueOverSaturation(wavelength, pixel);
      }
      currentPositionX++;
      currentPositionX = currentPositionX % imageWidth;
    }
    normalizeAndSampleSpectrumValues();
  }

  void positionBasedWithHighValueControl(){
    List spectrumBounds = getSpectrumBoundsWithHighValue();
    double wavelengthIncreaseFactor = positionBasedWaveLengthIncreaseFactor(spectrumBounds);

    int currentPositionX = 0;
    for(HSVPixel pixel in pixels){
      if(isPixelValid(pixel)){
        double wavelength = spectrumBounds[2] + (currentPositionX - spectrumBounds[0])*wavelengthIncreaseFactor;
        updateSpectrumSumOfValueOverSaturation(wavelength, pixel);
      }
      currentPositionX++;
      currentPositionX = currentPositionX % imageWidth;
    }
    normalizeAndSampleSpectrumValues();
  }

  void positionBasedWithOpenstaxHSVToSpectrum(){
    List spectrumBounds = getSpectrumBoundsWithOpenstax();
    double wavelengthIncreaseFactor = positionBasedWaveLengthIncreaseFactor(spectrumBounds);

    int currentPositionX = 0;
    for(HSVPixel pixel in pixels){
      if(isPixelValid(pixel)){
        double wavelength = spectrumBounds[2] + (currentPositionX - spectrumBounds[0])*wavelengthIncreaseFactor;
        updateSpectrumSumOfValueOverSaturation(wavelength, pixel);
      }
      currentPositionX++;
      currentPositionX = currentPositionX % imageWidth;
    }
    normalizeAndSampleSpectrumValues();
  }

  void openstaxBasedHSVToSpectrum(){
    for(HSVPixel pixel in pixels){
      if((pixel.hue >= HueConversionData.minFromOtherSide || pixel.hue <= HueConversionData.max) && pixel.value >= minValue && pixel.saturation >= minSaturation ){
        double wavelength = HueConversionData.getWavelength(pixel.hue, false);
        updateSpectrumSumOfValueOverSaturation(wavelength, pixel);
      }
    }
    normalizeAndSampleSpectrumValues();
  }

  void positionBasedLinearHSVToSpectrum(){
    List spectrumBounds = getSpectrumBoundsLinear();
    double wavelengthIncreaseFactor = positionBasedWaveLengthIncreaseFactor(spectrumBounds);

    int currentPositionX = 0;
    for(HSVPixel pixel in pixels){
      if(isPixelValid(pixel)){
        double wavelength = spectrumBounds[2] + (currentPositionX - spectrumBounds[0])*wavelengthIncreaseFactor;
        updateSpectrumSumOfValueOverSaturation(wavelength, pixel);
      }
      currentPositionX++;
      currentPositionX = currentPositionX % imageWidth;
    }
    normalizeAndSampleSpectrumValues();
  }

  double positionBasedWaveLengthIncreaseFactor(List spectrumBounds){
    return (spectrumBounds[3] - spectrumBounds[2])/(spectrumBounds[1] - spectrumBounds[0]);
  }

  List getSpectrumBoundsLinear() {
    int currentPositionX = 0;
    int firstLightPositionX = imageWidth;
    int lastLightPositionX = 0;
    double firstLightWavelength = wavelengthMin.toDouble();
    double lastLightWavelength = wavelengthMax.toDouble();

    for (HSVPixel pixel in pixels) {
      if (isPixelValid(pixel)) {
        firstLightPositionX = min(firstLightPositionX, currentPositionX);
        lastLightPositionX = max(lastLightPositionX, currentPositionX);
        if(firstLightPositionX == currentPositionX){
          firstLightWavelength = linearHueToWavelength(pixel.hue);
        }
        if(lastLightPositionX == currentPositionX){
          lastLightWavelength = linearHueToWavelength(pixel.hue);
        }
      }
      currentPositionX++;
      currentPositionX = currentPositionX % imageWidth;
    }
    return [firstLightPositionX ,lastLightPositionX, firstLightWavelength, lastLightWavelength];
  }

  List getSpectrumBoundsWithOpenstax() {
    int currentPositionX = 0;
    int firstLightPositionX = imageWidth;
    int lastLightPositionX = 0;
    double firstLightWavelength = wavelengthMin.toDouble();
    double lastLightWavelength = wavelengthMax.toDouble();

    for (HSVPixel pixel in pixels) {
      if (isPixelValid(pixel) && (pixel.hue < HueConversionData.max || pixel.hue > HueConversionData.minFromOtherSide)) {
        firstLightPositionX = min(firstLightPositionX, currentPositionX);
        lastLightPositionX = max(lastLightPositionX, currentPositionX);
        if(firstLightPositionX == currentPositionX){
          firstLightWavelength = HueConversionData.getWavelength(pixel.hue, false);

        }
        if(lastLightPositionX == currentPositionX){
          lastLightWavelength = HueConversionData.getWavelength(pixel.hue, false);

        }
      }
      currentPositionX++;
      currentPositionX = currentPositionX % imageWidth;
    }
    print("First hue: ${firstLightWavelength}, at: x: $firstLightPositionX y: ${currentPositionX / imageWidth}");
    print("Last hue: ${lastLightWavelength}, at: x: $lastLightPositionX y: ${currentPositionX / imageWidth}");
    return [firstLightPositionX ,lastLightPositionX, firstLightWavelength, lastLightWavelength];
  }

  List getSpectrumBoundsWithHighValue() {
    int currentPositionX = 0;
    int firstLightPositionX = imageWidth;
    int lastLightPositionX = 0;
    double firstLightWavelength = wavelengthMin.toDouble();
    double lastLightWavelength = wavelengthMax.toDouble();

    for (HSVPixel pixel in pixels) {
      if (isPixelValidHighValue(pixel) && (pixel.hue < HueConversionData.max || pixel.hue > HueConversionData.minFromOtherSide)) {
        firstLightPositionX = min(firstLightPositionX, currentPositionX);
        lastLightPositionX = max(lastLightPositionX, currentPositionX);
        if(firstLightPositionX == currentPositionX){
          firstLightWavelength = HueConversionData.getWavelength(pixel.hue, false);

        }
        if(lastLightPositionX == currentPositionX){
          lastLightWavelength = HueConversionData.getWavelength(pixel.hue, false);

        }
      }
      currentPositionX++;
      currentPositionX = currentPositionX % imageWidth;
    }
    print("First hue: ${firstLightWavelength}, at: x: $firstLightPositionX y: ${currentPositionX / imageWidth}");
    print("Last hue: ${lastLightWavelength}, at: x: $lastLightPositionX y: ${currentPositionX / imageWidth}");
    return [firstLightPositionX ,lastLightPositionX, firstLightWavelength, lastLightWavelength];
  }

  List getSpectrumBoundsWithWiki() {
    int currentPositionX = 0;
    int firstLightPositionX = imageWidth;
    int lastLightPositionX = 0;
    double firstLightWavelength = wavelengthMin.toDouble();
    double lastLightWavelength = wavelengthMax.toDouble();

    for (HSVPixel pixel in pixels) {
      if (isPixelValidHighValue(pixel) && (pixel.hue < HueConversionData.max || pixel.hue > HueConversionData.minFromOtherSide)) {
        firstLightPositionX = min(firstLightPositionX, currentPositionX);
        lastLightPositionX = max(lastLightPositionX, currentPositionX);
        if(firstLightPositionX == currentPositionX){
          firstLightWavelength = HueConversionData.getWavelength(pixel.hue, true);

        }
        if(lastLightPositionX == currentPositionX){
          lastLightWavelength = HueConversionData.getWavelength(pixel.hue, true);

        }
      }
      currentPositionX++;
      currentPositionX = currentPositionX % imageWidth;
    }
    print("First hue: ${firstLightWavelength}, at: x: $firstLightPositionX y: ${currentPositionX / imageWidth}");
    print("Last hue: ${lastLightWavelength}, at: x: $lastLightPositionX y: ${currentPositionX / imageWidth}");
    return [firstLightPositionX ,lastLightPositionX, firstLightWavelength, lastLightWavelength];
  }

  void linearHSVToSpectrum(){
    for(HSVPixel pixel in pixels){
      if(isPixelValid(pixel)){
        double wavelength = linearHueToWavelength(pixel.hue);
        updateSpectrumSumOfValueOverSaturation(wavelength, pixel);
      }
    }
    normalizeAndSampleSpectrumValues();
  }

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

  void updateSpectrumSumOfValueOverSaturation(double wavelength, HSVPixel pixel){
    if(spectrum[wavelength] == null){
      spectrum[wavelength] = 0;
    }
    spectrum[wavelength] = spectrum[wavelength]! + pixel.value.toDouble()/pixel.saturation.toDouble();
  }

  void normalizeAndSampleSpectrumValues(){
    double maxValue = spectrum.values.reduce(max);
    for(double wavelength in spectrum.keys){
      spectrum[wavelength] = spectrum[wavelength]!*100/maxValue;
    }
    for(double wavelength = wavelengthMin.toDouble(); wavelength <= wavelengthMax.toDouble(); wavelength += 5){
      if(spectrum[wavelength] == null){
        spectrum[wavelength] = 0;
      }
    }
    double wavelengthLeft = -1, wavelengthCenter = -1, wavelengthRight = -1;
    for(double wavelength in spectrum.keys){
      wavelengthLeft = wavelengthCenter;
      wavelengthCenter = wavelengthRight;
      wavelengthRight = wavelength;
      if(wavelengthLeft != -1){
        spectrum[wavelengthCenter] = (spectrum[wavelengthLeft]! + 2*spectrum[wavelengthCenter]! + spectrum[wavelengthRight]!)/4;
      }
    }
  }
}

enum Algorithm {
  linear,
  openstaxBased,
  positionBasedLinear,
  positionBasedWithOpenstax,
  positionBasedWithHighValueControl,
  positionBasedWithWiki
}




