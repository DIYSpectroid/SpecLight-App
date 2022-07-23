import 'dart:math';

import 'package:spectroid/image_analysis/data_extraction/image_data.dart';

class Spectrable {
  Map<double, double> spectrum = {};
  ImageData imageData;

  Spectrable(this.imageData);
  void GenerateSpectrum() {}


  void normalizeAndSampleSpectrumValues(int wavelengthMin, int wavelengthMax){
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