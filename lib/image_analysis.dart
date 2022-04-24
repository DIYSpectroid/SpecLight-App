import 'dart:math';
import 'package:flutter/rendering.dart';
import 'package:spectroid/image_analysis_rgb.dart';
import 'package:spectroid/light_hue_conversion_extractor.dart';

import 'image_data_extraction.dart';

class Spectrum{
  Map<double, double> spectrum = {};
  List<HSVPixel> hsvPixels;

  int imageWidth;
  int imageHeight;
  late List<double> relativePosToWavelengthFunctionCoefficients;
  late List<double> inverseRelativePosToWavelengthFunctionCoefficients;
  static const int wavelengthMin = 400;
  static const int wavelengthMax = 700;
  static const int upperHueBound = 270;
  static const int lowerHueBound = -6;
  static const int minSaturation = 7;
  static const int minValue = 15;
  static const int highMinValue = 80;

  List<double> getKeys(){
    return spectrum.keys.toList();
  }

  List<double> getValues(){
    return spectrum.values.toList();
  }

  Spectrum(this.hsvPixels, this.imageWidth, this.imageHeight, List<RGBPixel> rgbPixels, Algorithm algorithm){
    chooseCoefficients(1000);
    switch(algorithm){
      case Algorithm.hsvLinear:
        linearHSVToSpectrum();
        break;
      case Algorithm.hsvOpenstaxBased:
        openstaxBasedHSVToSpectrum();
        break;
      case Algorithm.hsvPositionBasedLinear:
        positionBasedLinearHSVToSpectrum();
        break;
      case Algorithm.hsvPositionBasedPolynomial:
        positionBasedPolynomialHSVToSpectrum();
        break;
      case Algorithm.hsvPositionBasedPolynomialWithOpenstax:
        hsvPositionBasedPolynomialWithOpenstax();
        break;
      case Algorithm.hsvPositionBasedWithOpenstax:
        positionBasedWithOpenstaxHSVToSpectrum();
        break;
      case Algorithm.hsvPositionBasedWithHighValueControl:
        positionBasedWithHighValueControl();
        break;
      case Algorithm.hsvPositionBasedWithWiki:
        positionBasedWithWiki();
        break;
      case Algorithm.rgbTest:
        RGBAnalyser rgbAnalyser = RGBAnalyser(rgbPixels, this.imageWidth, this.imageHeight);
        //spectrum = rgbAnalyser.rgbTest();

    }
    normalizeAndSampleSpectrumValues();
  }

  void positionBasedWithWiki(){
    List spectrumBounds = getSpectrumBoundsWithWiki();
    double wavelengthIncreaseFactor = positionBasedWaveLengthIncreaseFactor(spectrumBounds);

    int currentPositionX = 0;
    for(HSVPixel pixel in hsvPixels){
      if(isPixelValid(pixel)){
        double wavelength = spectrumBounds[2] + (currentPositionX - spectrumBounds[0])*wavelengthIncreaseFactor;
        updateSpectrumSumOfValueOverSaturation(wavelength, pixel);
      }
      currentPositionX++;
      currentPositionX = currentPositionX % imageWidth;
    }
  }

  void positionBasedWithHighValueControl(){
    List spectrumBounds = getSpectrumBoundsWithHighValue();
    double wavelengthIncreaseFactor = positionBasedWaveLengthIncreaseFactor(spectrumBounds);

    int currentPositionX = 0;
    for(HSVPixel pixel in hsvPixels){
      if(isPixelValid(pixel)){
        double wavelength = spectrumBounds[2] + (currentPositionX - spectrumBounds[0])*wavelengthIncreaseFactor;
        updateSpectrumSumOfValueOverSaturation(wavelength, pixel);
      }
      currentPositionX++;
      currentPositionX = currentPositionX % imageWidth;
    }
  }

  void positionBasedWithOpenstaxHSVToSpectrum(){
    List spectrumBounds = getSpectrumBoundsWithOpenstax();
    double wavelengthIncreaseFactor = positionBasedWaveLengthIncreaseFactor(spectrumBounds);

    int currentPositionX = 0;
    for(HSVPixel pixel in hsvPixels){
      if(isPixelValid(pixel)){
        double wavelength = spectrumBounds[2] + (currentPositionX - spectrumBounds[0])*wavelengthIncreaseFactor;
        updateSpectrumSumOfValueOverSaturation(wavelength, pixel);
      }
      currentPositionX++;
      currentPositionX = currentPositionX % imageWidth;
    }
  }

  void openstaxBasedHSVToSpectrum(){
    for(HSVPixel pixel in hsvPixels){
      if((pixel.hue >= HueConversionData.minFromOtherSide || pixel.hue <= HueConversionData.max) && pixel.value >= minValue && pixel.saturation >= minSaturation ){
        double wavelength = HueConversionData.getWavelength(pixel.hue, false);
        updateSpectrumSumOfValueOverSaturation(wavelength, pixel);
      }
    }
  }

  void hsvPositionBasedPolynomialWithOpenstax(){
    List spectrumBounds = getSpectrumBoundsWithOpenstax();

    int currentPositionX = 0;
    for(HSVPixel pixel in hsvPixels){
      if(isPixelValid(pixel)){
        double wavelength = getWavelengthForPolynomial(currentPositionX, spectrumBounds);
        updateSpectrumSumOfValueOverSaturation(wavelength, pixel);
      }
      currentPositionX++;
      currentPositionX = currentPositionX % imageWidth;
    }
  }

  void positionBasedPolynomialHSVToSpectrum(){
    List spectrumBounds = getSpectrumBoundsLinear();

    int currentPositionX = 0;
    for(HSVPixel pixel in hsvPixels){
      if(isPixelValid(pixel)){
        double wavelength = getWavelengthForPolynomial(currentPositionX, spectrumBounds);
        updateSpectrumSumOfValueOverSaturation(wavelength, pixel);
      }
      currentPositionX++;
      currentPositionX = currentPositionX % imageWidth;
    }
  }

  double getWavelengthForPolynomial(int posX, List spectrumBounds){
    List relativeBounds = getBoundsForPolynomial(spectrumBounds[2], spectrumBounds[3]);
    double relativeRelativePosition = (posX - spectrumBounds[0])/(spectrumBounds[1] - spectrumBounds[0]);
    double relativePosition = relativeBounds[0] + relativeRelativePosition * (relativeBounds[1] - relativeBounds[0]);
    double wavelength = 0;
    for(double coefficient in relativePosToWavelengthFunctionCoefficients.reversed){
      wavelength *= relativePosition;
      wavelength += coefficient;
    }
    return wavelength;
  }

  List<double> getBoundsForPolynomial(double startSpectrumWavelength, double endSpectrumWavelength){
    double relativeStartPosition = 0;
    double relativeEndPosition = 0;
    for(double coefficient in inverseRelativePosToWavelengthFunctionCoefficients.reversed){
      relativeStartPosition *= startSpectrumWavelength;
      relativeEndPosition *= endSpectrumWavelength;
      relativeStartPosition += coefficient;
      relativeEndPosition += coefficient;
    }
    return [relativeStartPosition, relativeEndPosition];
  }

  chooseCoefficients(int grating){
    switch(grating){
      case 625: //CD
        relativePosToWavelengthFunctionCoefficients = [399.99971260114154,331.63465261047116, -27.547973040830968, -5.454094494323559, 1.3680989208162249];
        inverseRelativePosToWavelengthFunctionCoefficients = [-1.1047170070525247, 0.002506383433519993, 7.886494958025243e-07, -7.347700534902981e-10, 8.989102013574446e-13];
        break;
      case 1000:
        relativePosToWavelengthFunctionCoefficients = [399.97981082771435, 419.2907842157629, -130.1861087421816, 3.9593131953818386, 6.980019941946402];
        inverseRelativePosToWavelengthFunctionCoefficients = [-0.11410202388799878, -0.003961148427120149, 1.8491581827859126e-05, -2.5817708839387402e-08, 1.5331748498266344e-11];
        break;
      case 1350: //DVD
        relativePosToWavelengthFunctionCoefficients = [400.35185888056503, 982.4786834945292,  -1494.966171082382, 1212.5356835609812, -401.72911625856375];
        inverseRelativePosToWavelengthFunctionCoefficients = [21.824958958855525, -0.17582705733311732, 0.0005251492827328874, -6.915366563216458e-07, 3.4190944043013816e-10];
        break;
      default:
        throw Exception("Grating not supported");
        break;
    }
  }

  void positionBasedLinearHSVToSpectrum(){
    List spectrumBounds = getSpectrumBoundsLinear();
    double wavelengthIncreaseFactor = positionBasedWaveLengthIncreaseFactor(spectrumBounds);

    int currentPositionX = 0;
    for(HSVPixel pixel in hsvPixels){
      if(isPixelValid(pixel)){
        double wavelength = spectrumBounds[2] + (currentPositionX - spectrumBounds[0])*wavelengthIncreaseFactor;
        updateSpectrumSumOfValueOverSaturation(wavelength, pixel);
      }
      currentPositionX++;
      currentPositionX = currentPositionX % imageWidth;
    }
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

    for (HSVPixel pixel in hsvPixels) {
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

    for (HSVPixel pixel in hsvPixels) {
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

    for (HSVPixel pixel in hsvPixels) {
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

    for (HSVPixel pixel in hsvPixels) {
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
    for(HSVPixel pixel in hsvPixels){
      if(isPixelValid(pixel)){
        double wavelength = linearHueToWavelength(pixel.hue);
        updateSpectrumSumOfValueOverSaturation(wavelength, pixel);
      }
    }
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
  hsvLinear,
  hsvOpenstaxBased,
  hsvPositionBasedLinear,
  hsvPositionBasedPolynomial,
  hsvPositionBasedPolynomialWithOpenstax,
  hsvPositionBasedWithOpenstax,
  hsvPositionBasedWithHighValueControl,
  hsvPositionBasedWithWiki,
  rgbTest
}

