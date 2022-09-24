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
        relativePosToWavelengthFunctionCoefficients = [399.99971260114154,331.63465261047116, -27.547973040830968, -5.454094494323559, 1.3680989208162249];
        inverseRelativePosToWavelengthFunctionCoefficients = [-1.1047170070525247, 0.002506383433519993, 7.886494958025243e-07, -7.347700534902981e-10, 8.989102013574446e-13];
        break;
      case Grating.grating1000:
        relativePosToWavelengthFunctionCoefficients = [399.97981082771435, 419.2907842157629, -130.1861087421816, 3.9593131953818386, 6.980019941946402];
        inverseRelativePosToWavelengthFunctionCoefficients = [-0.11410202388799878, -0.003961148427120149, 1.8491581827859126e-05, -2.5817708839387402e-08, 1.5331748498266344e-11];
        break;
      case Grating.grating1350DVD: //DVD
        relativePosToWavelengthFunctionCoefficients = [400.35185888056503, 982.4786834945292,  -1494.966171082382, 1212.5356835609812, -401.72911625856375];
        inverseRelativePosToWavelengthFunctionCoefficients = [21.824958958855525, -0.17582705733311732, 0.0005251492827328874, -6.915366563216458e-07, 3.4190944043013816e-10];
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