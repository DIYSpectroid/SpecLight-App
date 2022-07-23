import 'package:spectroid/image_analysis/algorithms/spectrable.dart';
import 'package:spectroid/image_analysis/analysis/spectrable.dart';
import 'package:spectroid/image_analysis/data_extraction/image_data.dart';

class PositionSpectrable extends Spectrable {

  PositionSpectrable(ImageData imageData) : super(imageData)

  List getSpectrumBounds(int wavelengthMin, int wavelengthMax) {
    int currentPositionX = 0;
    int firstLightPositionX = imageData.width;
    int lastLightPositionX = 0;
    double firstLightWavelength = wavelengthMin.toDouble();
    double lastLightWavelength = wavelengthMax.toDouble();
    int minimalAllowedX = 0;
    int maximalAllowedX = imageData.width;

    for (HSVPixel pixel in imageData.hsvPixels) {
      if (/*currentPositionX >= minimalAllowedX && currentPositionX <= maximalAllowedX && */isPixelValid(pixel)) {
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
      currentPositionX = currentPositionX % imageWidth;
    }
    return [firstLightPositionX ,lastLightPositionX, firstLightWavelength, lastLightWavelength];
  }
}