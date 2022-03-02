import 'dart:math';
import 'package:flutter/rendering.dart';

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
      case Algorithm.polynomial:

        break;
      case Algorithm.position_based:
        positionBasedHSVToSpectrum();
        break;
    }
  }

  void positionBasedHSVToSpectrum(){
    List spectrumBounds = getSpectrumBounds();
    double wavelengthIncreaseFactor = positionBasedWaveLengthIncreaseFactor(spectrumBounds);
    print(wavelengthIncreaseFactor);
    print(spectrumBounds);
    int currentPositionX = 0;
    for(HSVPixel pixel in pixels){
      if(isPixelValid(pixel)){
        double wavelength = spectrumBounds[2] + (currentPositionX - spectrumBounds[0])*wavelengthIncreaseFactor;
        updateSpectrumSumOfValueOverSaturation(wavelength, pixel);
      }
      currentPositionX++;
      currentPositionX = currentPositionX % imageWidth;
    }
    normalizeSpectrumValues();
  }

  double positionBasedWaveLengthIncreaseFactor(List spectrumBounds){
    return (spectrumBounds[3] - spectrumBounds[2])/(spectrumBounds[1] - spectrumBounds[0]);
  }

  List getSpectrumBounds() {
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

  void linearHSVToSpectrum(){
    for(HSVPixel pixel in pixels){
      if(isPixelValid(pixel)){
        double wavelength = linearHueToWavelength(pixel.hue);
        updateSpectrumSumOfValueOverSaturation(wavelength, pixel);
      }
    }
    normalizeSpectrumValues();
  }

  bool isPixelValid(pixel){
    return getRelativeHue(pixel.hue) <= upperHueBound - lowerHueBound && pixel.saturation > minSaturation && pixel.value > minValue;
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

  void normalizeSpectrumValues(){
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
  polynomial,
  position_based
}




