import 'package:spectroid/image_analysis/analysis/position_spectrable_hsv.dart';
import 'package:spectroid/image_analysis/data_extraction/image_data.dart';

class PolynomialPositionSpectrableHSV extends PositionSpectrableHSV {
  List<double> relativePosToWavelengthFunctionCoefficients;
  List<double> inverseRelativePosToWavelengthFunctionCoefficients;

  PolynomialPositionSpectrableHSV(this.relativePosToWavelengthFunctionCoefficients,
      this.inverseRelativePosToWavelengthFunctionCoefficients,
      ImageData imageData) : super(imageData) {}

  SpectrumPositionBounds getBoundsForPolynomial(SpectrumPositionBounds spectrumPositionBounds) {
    double relativeStartPosition = 0;
    double relativeEndPosition = 0;
    for (double coefficient in inverseRelativePosToWavelengthFunctionCoefficients
        .reversed) {
      relativeStartPosition *= spectrumPositionBounds.firstLightWavelength;
      relativeEndPosition *= spectrumPositionBounds.lastLightWavelength;
      relativeStartPosition += coefficient;
      relativeEndPosition += coefficient;
    }
    print("Relative bounds ${[relativeStartPosition, relativeEndPosition]}");
    spectrumPositionBounds.firstLightWavelength = relativeStartPosition;
    spectrumPositionBounds.lastLightWavelength = relativeEndPosition;
    return spectrumPositionBounds;
  }

  double getWavelengthForPolynomial(int posX, SpectrumPositionBounds spectrumPositionBounds){
    double relativeRelativePosition = (posX - spectrumPositionBounds.firstLightX)/(spectrumPositionBounds.lastLightX - spectrumPositionBounds.firstLightX);
    double relativePosition = spectrumPositionBounds.firstLightWavelength + relativeRelativePosition * (spectrumPositionBounds.lastLightWavelength - spectrumPositionBounds.firstLightWavelength);
    double wavelength = 0;
    for(double coefficient in relativePosToWavelengthFunctionCoefficients.reversed){
      wavelength *= relativePosition;
      wavelength += coefficient;
    }
    // print("posX: ${posX} Wavelength: ${wavelength}");
    return wavelength;
  }
}