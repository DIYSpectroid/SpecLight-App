import 'dart:math';

import 'package:spectroid/image_analysis/data_extraction/image_data.dart';

class SpectrablesMetadata{
  static const double WAVELENGTH_MIN = 400;
  static const double WAVELENGTH_MAX = 700;
}

class Spectrable {
  Map<double, double> spectrum = {};
  ImageData imageData;

  double wavelengthMin = SpectrablesMetadata.WAVELENGTH_MIN;
  double wavelengthMax = SpectrablesMetadata.WAVELENGTH_MAX;
  int minSaturation = 7;
  int minValue = 15;
  int highMinValue = 80;

  Spectrable(this.imageData){}
  void generateSpectrum() {}

  bool isPixelXYZRatioUnique(double wavelength){
    int uniquenessStart = 410;
    int uniquenessEnd = 620;
    return wavelength >= uniquenessStart && wavelength <= uniquenessEnd;
  }

  void normalizeAndSampleSpectrumValues(){
    print(spectrum.keys.first);
    print(spectrum.keys.last);
    Map<double, double> newSpectrum = {};
    for(double i = wavelengthMin; i <= wavelengthMax; i += 1) {
      newSpectrum[i] = 0;
    }

    for(double wavelength in spectrum.keys){
      double roundedWavelength = wavelength.round().toDouble();
      if(newSpectrum[roundedWavelength] == null) {
        newSpectrum[roundedWavelength] = spectrum[wavelength]!;
      } else {
        newSpectrum[roundedWavelength] = max(newSpectrum[roundedWavelength]!, spectrum[wavelength]!);
      }
    }

    // for(double wavelength = wavelengthMin; wavelength <= wavelengthMax; wavelength += 5){
    //   if(spectrum[wavelength] == null){
    //     spectrum[wavelength] = 0;
    //   }
    // }
    // double wavelengthLeft = -1, wavelengthCenter = -1, wavelengthRight = -1;
    // for(double wavelength in spectrum.keys){
    //   wavelengthLeft = wavelengthCenter;
    //   wavelengthCenter = wavelengthRight;
    //   wavelengthRight = wavelength;
    //   if(wavelengthLeft != -1){
    //     spectrum[wavelengthCenter] = (spectrum[wavelengthLeft]! + 2*spectrum[wavelengthCenter]! + spectrum[wavelengthRight]!)/4;
    //   }
    // }

    spectrum = newSpectrum;
    double maxValue = spectrum.values.reduce(max);
    for(double wavelength in spectrum.keys){
      spectrum[wavelength] = spectrum[wavelength]!*100/maxValue;
    }
  }
}