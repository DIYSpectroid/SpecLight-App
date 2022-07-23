

import 'package:spectroid/image_analysis/analysis/hsv_pixel_analyzer.dart';

import '../polynomial_position_spectrable.dart';

class HSVPositionPolynomial extends PolynomialPositionSpectrable  {
  HSVPixelAnalyzer hsvPixelAnalyzer;

  HSVPositionPolynomial(this.hsvPixelAnalyzer, List<double> relativePosToWavelengthFunctionCoefficients, List<double> inverseRelativePosToWavelengthFunctionCoefficients) : super(relativePosToWavelengthFunctionCoefficients, inverseRelativePosToWavelengthFunctionCoefficients);


  void GenerateSpectrum(){
    List spectrumBounds = getSpectrumBoundsLinear();
    List relativeBounds = getBoundsForPolynomial(spectrumBounds[2], spectrumBounds[3]);
    print(spectrumBounds);
    int currentPositionX = 0;
    for(HSVPixel pixel in hsvPixels){
      if(isPixelValid(pixel)){
        double wavelength = getWavelengthForPolynomial(currentPositionX, spectrumBounds, relativeBounds);
        updateSpectrumSumOfValueOverSaturation(wavelength, pixel);
      }
      currentPositionX++;
      currentPositionX = currentPositionX % imageWidth;
    }
  }

}