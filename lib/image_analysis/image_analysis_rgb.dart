import 'data_extraction/image_data.dart';

class RGBAnalyser{
  List<RGBPixel> rgbPixels;
  int imageWidth;
  int imageHeight;

  static const int wavelengthMin = 380;
  static const int wavelengthMax = 750;
  static const int upperHueBound = 270;
  static const int lowerHueBound = -12;
  static const int minSaturation = 2;
  static const int minValue = 15;
  static const int highMinValue = 80;

  RGBAnalyser(this.rgbPixels, this.imageWidth, this.imageHeight);
/*
  Map<double, double> rgbTest(){
    Map<double, double> spectrum = {};

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

    return spectrum;
  }

  List getSpectrumBoundsRGBTest() {
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
*/

}