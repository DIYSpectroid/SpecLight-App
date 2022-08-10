// import 'dart:math';
// import 'package:spectroid/image_analysis/data_extraction/light_hue_conversion_extractor.dart';
//
// import 'data_extraction/image_data.dart';
// import 'data_extraction/image_data_extraction.dart';
//
// class Spectrum{
//   Map<double, double> spectrum = {};
//
//   late List<HSVPixel> hsvPixels;
//   late int imageWidth;
//   late int imageHeight;
//
//   late List<double> relativePosToWavelengthFunctionCoefficients;
//   late List<double> inverseRelativePosToWavelengthFunctionCoefficients;
//   static const int wavelengthMin = 400;
//   static const int wavelengthMax = 700;
//   static const int upperHueBound = 270;
//   static const int lowerHueBound = -6;
//   static const int minSaturation = 7;
//   static const int minValue = 15;
//   static const int highMinValue = 80;
//
//   List<double> getKeys(){
//     return spectrum.keys.toList();
//   }
//
//   List<double> getValues(){
//     return spectrum.values.toList();
//   }
//
//   Spectrum(ImageData imageData, Algorithm algorithm, Grating grating){
//     hsvPixels = imageData.hsvPixels;
//     imageWidth = imageData.width;
//     imageHeight = imageData.height;
//     chooseCoefficients(grating);
//     switch(algorithm){
//       case Algorithm.hsvLinear:
//         linearHSVToSpectrum();
//         break;
//       case Algorithm.hsvOpenstaxBased:
//         openstaxBasedHSVToSpectrum();
//         break;
//       case Algorithm.hsvPositionBasedLinear:
//         positionBasedLinearHSVToSpectrum();
//         break;
//       case Algorithm.hsvPositionBasedPolynomial:
//         positionBasedPolynomialHSVToSpectrum();
//         break;
//       case Algorithm.hsvPositionBasedPolynomialWithOpenstax:
//         hsvPositionBasedPolynomialWithOpenstax();
//         break;
//       case Algorithm.hsvPositionBasedWithOpenstax:
//         positionBasedWithOpenstaxHSVToSpectrum();
//         break;
//       case Algorithm.hsvPositionBasedWithHighValueControl:
//         positionBasedWithHighValueControl();
//         break;
//       case Algorithm.hsvPositionBasedWithWiki:
//         positionBasedWithWiki();
//         break;
//       case Algorithm.rgbTest:
//         //RGBAnalyser rgbAnalyser = RGBAnalyser(rgbPixels, this.imageWidth, this.imageHeight);
//         //spectrum = rgbAnalyser.rgbTest();
//
//     }
//     normalizeAndSampleSpectrumValues();
//   }
//
//   void positionBasedWithWiki(){
//     List spectrumBounds = getSpectrumBoundsWithWiki();
//     double wavelengthIncreaseFactor = positionBasedWaveLengthIncreaseFactor(spectrumBounds);
//
//     int currentPositionX = 0;
//     for(HSVPixel pixel in hsvPixels){
//       if(isPixelValid(pixel)){
//         double wavelength = spectrumBounds[2] + (currentPositionX - spectrumBounds[0])*wavelengthIncreaseFactor;
//         updateSpectrumSumOfValueOverSaturation(wavelength, pixel);
//       }
//       currentPositionX++;
//       currentPositionX = currentPositionX % imageWidth;
//     }
//   }
//
//   void positionBasedWithHighValueControl(){
//     List spectrumBounds = getSpectrumBoundsWithHighValue();
//     double wavelengthIncreaseFactor = positionBasedWaveLengthIncreaseFactor(spectrumBounds);
//
//     int currentPositionX = 0;
//     for(HSVPixel pixel in hsvPixels){
//       if(isPixelValid(pixel)){
//         double wavelength = spectrumBounds[2] + (currentPositionX - spectrumBounds[0])*wavelengthIncreaseFactor;
//         updateSpectrumSumOfValueOverSaturation(wavelength, pixel);
//       }
//       currentPositionX++;
//       currentPositionX = currentPositionX % imageWidth;
//     }
//   }
//
//   void positionBasedWithOpenstaxHSVToSpectrum(){
//     List spectrumBounds = getSpectrumBoundsWithOpenstax();
//     double wavelengthIncreaseFactor = positionBasedWaveLengthIncreaseFactor(spectrumBounds);
//
//     int currentPositionX = 0;
//     for(HSVPixel pixel in hsvPixels){
//       if(isPixelValid(pixel)){
//         double wavelength = spectrumBounds[2] + (currentPositionX - spectrumBounds[0])*wavelengthIncreaseFactor;
//         updateSpectrumSumOfValueOverSaturation(wavelength, pixel);
//       }
//       currentPositionX++;
//       currentPositionX = currentPositionX % imageWidth;
//     }
//   }
//
//   void openstaxBasedHSVToSpectrum(){
//     for(HSVPixel pixel in hsvPixels){
//       if((pixel.hue >= HueConversionData.minFromOtherSide || pixel.hue <= HueConversionData.max) && pixel.value >= minValue && pixel.saturation >= minSaturation ){
//         double wavelength = HueConversionData.getWavelength(pixel.hue, false);
//         updateSpectrumSumOfValueOverSaturation(wavelength, pixel);
//       }
//     }
//   }
//
//   void hsvPositionBasedPolynomialWithOpenstax(){
//     List spectrumBounds = getSpectrumBoundsWithOpenstax();
//     List relativeBounds = getBoundsForPolynomial(spectrumBounds[2], spectrumBounds[3]);
//
//     int currentPositionX = 0;
//     for(HSVPixel pixel in hsvPixels){
//       if(isPixelValid(pixel)){
//         double wavelength = getWavelengthForPolynomial(currentPositionX, spectrumBounds, relativeBounds);
//         updateSpectrumSumOfValueOverSaturation(wavelength, pixel);
//       }
//       currentPositionX++;
//       currentPositionX = currentPositionX % imageWidth;
//     }
//   }
//
//
//
//   double getWavelengthForPolynomial(int posX, List spectrumBounds, List relativeBounds){
//     double relativeRelativePosition = (posX - spectrumBounds[0])/(spectrumBounds[1] - spectrumBounds[0]);
//     double relativePosition = relativeBounds[0] + relativeRelativePosition * (relativeBounds[1] - relativeBounds[0]);
//     double wavelength = 0;
//     for(double coefficient in relativePosToWavelengthFunctionCoefficients.reversed){
//       wavelength *= relativePosition;
//       wavelength += coefficient;
//     }
//     // print("posX: ${posX} Wavelength: ${wavelength}");
//     return wavelength;
//   }
//
//   List<double> getBoundsForPolynomial(double startSpectrumWavelength, double endSpectrumWavelength){
//     double relativeStartPosition = 0;
//     double relativeEndPosition = 0;
//     for(double coefficient in inverseRelativePosToWavelengthFunctionCoefficients.reversed){
//       relativeStartPosition *= startSpectrumWavelength;
//       relativeEndPosition *= endSpectrumWavelength;
//       relativeStartPosition += coefficient;
//       relativeEndPosition += coefficient;
//     }
//     print("Relative bounds ${[relativeStartPosition, relativeEndPosition]}");
//     return [relativeStartPosition, relativeEndPosition];
//   }
//
//
//
//   void positionBasedLinearHSVToSpectrum(){
//     List spectrumBounds = getSpectrumBoundsLinear();
//     double wavelengthIncreaseFactor = positionBasedWaveLengthIncreaseFactor(spectrumBounds);
//
//     int currentPositionX = 0;
//     for(HSVPixel pixel in hsvPixels){
//       if(isPixelValid(pixel)){
//         double wavelength = spectrumBounds[2] + (currentPositionX - spectrumBounds[0])*wavelengthIncreaseFactor;
//         updateSpectrumSumOfValueOverSaturation(wavelength, pixel);
//       }
//       currentPositionX++;
//       currentPositionX = currentPositionX % imageWidth;
//     }
//   }
//
//   double positionBasedWaveLengthIncreaseFactor(List spectrumBounds){
//     return (spectrumBounds[3] - spectrumBounds[2])/(spectrumBounds[1] - spectrumBounds[0]);
//   }
//
//   List getSpectrumBoundsLinear() {
//     int currentPositionX = 0;
//     int firstLightPositionX = imageWidth;
//     int lastLightPositionX = 0;
//     double firstLightWavelength = wavelengthMin.toDouble();
//     double lastLightWavelength = wavelengthMax.toDouble();
//     int minimalAllowedX = 0;
//     int maximalAllowedX = imageWidth;
//
//     for (HSVPixel pixel in hsvPixels) {
//       if (/*currentPositionX >= minimalAllowedX && currentPositionX <= maximalAllowedX && */isPixelValid(pixel)) {
//         firstLightPositionX = min(firstLightPositionX, currentPositionX);
//         lastLightPositionX = max(lastLightPositionX, currentPositionX);
//         if(firstLightPositionX == currentPositionX){
//           double wavelength = linearHueToWavelength(pixel.hue);
//           if(isPixelXYZRatioUnique(wavelength)){
//             firstLightWavelength = wavelength;
//           } else {
//             minimalAllowedX = currentPositionX;
//           }
//
//         }
//         if(lastLightPositionX == currentPositionX){
//           double wavelength = linearHueToWavelength(pixel.hue);
//           if(isPixelXYZRatioUnique(wavelength)){
//             lastLightWavelength = wavelength;
//           } else {
//             maximalAllowedX = currentPositionX;
//           }
//         }
//       }
//       currentPositionX++;
//       currentPositionX = currentPositionX % imageWidth;
//     }
//     return [firstLightPositionX ,lastLightPositionX, firstLightWavelength, lastLightWavelength];
//   }
//
//   bool isPixelXYZRatioUnique(double wavelength){
//     int uniquenessStart = 410;
//     int uniquenessEnd = 620;
//     return wavelength >= uniquenessStart && wavelength <= uniquenessEnd;
//   }
//
//   List getSpectrumBoundsWithOpenstax() {
//     int currentPositionX = 0;
//     int firstLightPositionX = imageWidth;
//     int lastLightPositionX = 0;
//     double firstLightWavelength = wavelengthMin.toDouble();
//     double lastLightWavelength = wavelengthMax.toDouble();
//
//     for (HSVPixel pixel in hsvPixels) {
//       if (isPixelValid(pixel) && (pixel.hue < HueConversionData.max || pixel.hue > HueConversionData.minFromOtherSide)) {
//         firstLightPositionX = min(firstLightPositionX, currentPositionX);
//         lastLightPositionX = max(lastLightPositionX, currentPositionX);
//         if(firstLightPositionX == currentPositionX){
//           firstLightWavelength = HueConversionData.getWavelength(pixel.hue, false);
//
//         }
//         if(lastLightPositionX == currentPositionX){
//           lastLightWavelength = HueConversionData.getWavelength(pixel.hue, false);
//
//         }
//       }
//       currentPositionX++;
//       currentPositionX = currentPositionX % imageWidth;
//     }
//     print("First hue: ${firstLightWavelength}, at: x: $firstLightPositionX y: ${currentPositionX / imageWidth}");
//     print("Last hue: ${lastLightWavelength}, at: x: $lastLightPositionX y: ${currentPositionX / imageWidth}");
//     return [firstLightPositionX ,lastLightPositionX, firstLightWavelength, lastLightWavelength];
//   }
//
//   List getSpectrumBoundsWithHighValue() {
//     int currentPositionX = 0;
//     int firstLightPositionX = imageWidth;
//     int lastLightPositionX = 0;
//     double firstLightWavelength = wavelengthMin.toDouble();
//     double lastLightWavelength = wavelengthMax.toDouble();
//
//     for (HSVPixel pixel in hsvPixels) {
//       if (isPixelValidHighValue(pixel) && (pixel.hue < HueConversionData.max || pixel.hue > HueConversionData.minFromOtherSide)) {
//         firstLightPositionX = min(firstLightPositionX, currentPositionX);
//         lastLightPositionX = max(lastLightPositionX, currentPositionX);
//         if(firstLightPositionX == currentPositionX){
//           firstLightWavelength = HueConversionData.getWavelength(pixel.hue, false);
//
//         }
//         if(lastLightPositionX == currentPositionX){
//           lastLightWavelength = HueConversionData.getWavelength(pixel.hue, false);
//
//         }
//       }
//       currentPositionX++;
//       currentPositionX = currentPositionX % imageWidth;
//     }
//     print("First hue: ${firstLightWavelength}, at: x: $firstLightPositionX y: ${currentPositionX / imageWidth}");
//     print("Last hue: ${lastLightWavelength}, at: x: $lastLightPositionX y: ${currentPositionX / imageWidth}");
//     return [firstLightPositionX ,lastLightPositionX, firstLightWavelength, lastLightWavelength];
//   }
//
//   List getSpectrumBoundsWithWiki() {
//     int currentPositionX = 0;
//     int firstLightPositionX = imageWidth;
//     int lastLightPositionX = 0;
//     double firstLightWavelength = wavelengthMin.toDouble();
//     double lastLightWavelength = wavelengthMax.toDouble();
//
//     for (HSVPixel pixel in hsvPixels) {
//       if (isPixelValidHighValue(pixel) && (pixel.hue < HueConversionData.max || pixel.hue > HueConversionData.minFromOtherSide)) {
//         firstLightPositionX = min(firstLightPositionX, currentPositionX);
//         lastLightPositionX = max(lastLightPositionX, currentPositionX);
//         if(firstLightPositionX == currentPositionX){
//           firstLightWavelength = HueConversionData.getWavelength(pixel.hue, true);
//
//         }
//         if(lastLightPositionX == currentPositionX){
//           lastLightWavelength = HueConversionData.getWavelength(pixel.hue, true);
//
//         }
//       }
//       currentPositionX++;
//       currentPositionX = currentPositionX % imageWidth;
//     }
//     print("First hue: ${firstLightWavelength}, at: x: $firstLightPositionX y: ${currentPositionX / imageWidth}");
//     print("Last hue: ${lastLightWavelength}, at: x: $lastLightPositionX y: ${currentPositionX / imageWidth}");
//     return [firstLightPositionX ,lastLightPositionX, firstLightWavelength, lastLightWavelength];
//   }
//
//   void linearHSVToSpectrum(){
//     for(HSVPixel pixel in hsvPixels){
//       if(isPixelValid(pixel)){
//         double wavelength = linearHueToWavelength(pixel.hue);
//         updateSpectrumSumOfValueOverSaturation(wavelength, pixel);
//       }
//     }
//   }
//
//   bool isPixelValid(pixel){
//     return getRelativeHue(pixel.hue) <= upperHueBound - lowerHueBound && pixel.saturation > minSaturation && pixel.value > minValue;
//   }
//
//   bool isPixelValidHighValue(pixel){
//     return getRelativeHue(pixel.hue) <= upperHueBound - lowerHueBound && pixel.saturation > minSaturation && pixel.value > highMinValue;
//   }
//
//   int getRelativeHue(int hue){
//     return (hue - lowerHueBound) % 360;
//   }
//
//   double linearHueToWavelength(int hue){
//     return wavelengthMax - getRelativeHue(hue)*(wavelengthMax-wavelengthMin)/(upperHueBound - lowerHueBound);
//   }
//
//   void updateSpectrumSumOfValueOverSaturation(double wavelength, HSVPixel pixel){
//     if(spectrum[wavelength] == null){
//       spectrum[wavelength] = 0;
//     }
//     spectrum[wavelength] = spectrum[wavelength]! + pixel.value.toDouble()/pixel.saturation.toDouble();
//   }
//
//   void normalizeAndSampleSpectrumValues(){
//     double maxValue = spectrum.values.reduce(max);
//     for(double wavelength in spectrum.keys){
//       spectrum[wavelength] = spectrum[wavelength]!*100/maxValue;
//     }
//     for(double wavelength = wavelengthMin.toDouble(); wavelength <= wavelengthMax.toDouble(); wavelength += 5){
//       if(spectrum[wavelength] == null){
//         spectrum[wavelength] = 0;
//       }
//     }
//     double wavelengthLeft = -1, wavelengthCenter = -1, wavelengthRight = -1;
//     for(double wavelength in spectrum.keys){
//       wavelengthLeft = wavelengthCenter;
//       wavelengthCenter = wavelengthRight;
//       wavelengthRight = wavelength;
//       if(wavelengthLeft != -1){
//         spectrum[wavelengthCenter] = (spectrum[wavelengthLeft]! + 2*spectrum[wavelengthCenter]! + spectrum[wavelengthRight]!)/4;
//       }
//     }
//   }
// }
//
//
//
