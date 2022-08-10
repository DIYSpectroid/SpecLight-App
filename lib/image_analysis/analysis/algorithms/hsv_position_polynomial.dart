import 'package:spectroid/image_analysis/analysis/position_spectrable_hsv.dart';
import 'package:spectroid/image_analysis/data_extraction/image_data.dart';

import '../polynomial_position_spectrable_hsv.dart';

class HSVPositionPolynomial extends PolynomialPositionSpectrableHSV  {

  HSVPositionPolynomial(List<double> relativePosToWavelengthFunctionCoefficients,
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


}