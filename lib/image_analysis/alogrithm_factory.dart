import 'package:spectroid/image_analysis/data_extraction/image_data.dart';

import 'analysis/algorithms/hsv_position_polynomial.dart';
import 'analysis/algorithms/hsv_position_polynomial_sure_bounds.dart';
import 'analysis/spectrable.dart';

class AlgorithmFactory {
  Algorithm algorithm = Algorithm.hsvPositionPolynomial;
  Grating grating = Grating.grating1000;
  ImageData? imageData = null;

  AlgorithmFactory();
  AlgorithmFactory setAlgorithm(Algorithm algorithm) {
    this.algorithm = algorithm;
    return this;
  }

  AlgorithmFactory setGrating(Grating grating) {
    this.grating = grating;
    return this;
  }

  AlgorithmFactory setImageData(ImageData imageData) {
    this.imageData = imageData;
    return this;
  }

  Spectrable? create()  {
    if(imageData == null) throw Exception("You must set imageData!");
    switch(algorithm){
      // case Algorithm.hsvPositionLinear:
      //   return positionBasedLinearHSVToSpectrum();
      case Algorithm.hsvPositionPolynomial:
        var functionsCoefficients = chooseCoefficients();
        return HSVPositionPolynomial(functionsCoefficients.first, functionsCoefficients.last, imageData!);
      case Algorithm.hsvPositionPolynomialSureBounds:
        var functionsCoefficients = chooseCoefficients();
        return HSVPositionPolynomialSureBounds(functionsCoefficients.first, functionsCoefficients.last, imageData!);
      // case Algorithm.hsvPositionPolynomialWithOpenstax:
      //   return hsvPositionBasedPolynomialWithOpenstax();
      // case Algorithm.hsvPositionWithHighValueControl:
      //   return positionBasedWithHighValueControl();
      // case Algorithm.rgbTest:
      //   return null;
      default:
        return null;
    }
  }

  Set<List<double>> chooseCoefficients(){
    var relativePosToWavelengthFunctionCoefficients, inverseRelativePosToWavelengthFunctionCoefficients;
    switch(grating){
      case Grating.grating0:
        relativePosToWavelengthFunctionCoefficients = [400.0, 300.0];
        inverseRelativePosToWavelengthFunctionCoefficients = [-1.3333333, 0.00333333];
        break;
      case Grating.grating625CD: //CD
        relativePosToWavelengthFunctionCoefficients = [400.0007013798323, 307.6643964487649, -1.3017481953669923, -6.678856865899427, 0.31480604595354617];
        inverseRelativePosToWavelengthFunctionCoefficients = [-1.3223417847100465, 0.003419361458820926, -3.7224990769414265e-07, 8.405812383743986e-11, 3.4300478303133106e-13];
        break;
      case Grating.grating1000:
        relativePosToWavelengthFunctionCoefficients = [400.0077618904527, 325.83535044857956, -2.0955972899592137, -27.404780808395127, 3.6495425294121504];
        inverseRelativePosToWavelengthFunctionCoefficients = [-1.114798557942878, 0.002056102438799916, 3.703763412027248e-06, -6.514584782138035e-09, 4.5609730129116094e-12];
        break;
      case Grating.grating1350DVD: //DVD
        relativePosToWavelengthFunctionCoefficients = [400.0754581192899, 395.9311755326786, 13.760839838400889, -159.5715283772228, 49.74137039957702];
        inverseRelativePosToWavelengthFunctionCoefficients = [3.669064165755059, -0.035276523108272964, 0.0001146491329724426, -1.5522708133172793e-07, 7.948135208231328e-11];
        break;
      default:
        throw Exception("Grating not supported");
    }
    return {relativePosToWavelengthFunctionCoefficients, inverseRelativePosToWavelengthFunctionCoefficients};
  }
}

enum Algorithm {
  // hsvPositionLinear,
  hsvPositionPolynomial,
  hsvPositionPolynomialSureBounds,
  // hsvPositionPolynomialWithOpenstax,
  // hsvPositionWithHighValueControl,
  // rgbTest
}

enum Grating {
  grating0,
  grating1000,
  grating625CD,
  grating1350DVD
}