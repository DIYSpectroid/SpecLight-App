import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as Img;
import 'package:path_provider/path_provider.dart';
import 'package:spectroid/image_analysis/analysis/spectrable.dart';
import 'package:spectroid/image_analysis/data_extraction/image_data.dart';

import '../alogrithm_factory.dart';
import 'image_data_extraction.dart';


class HueConversionData{
  static Map<int, double> wavelengthByHue = {};
  static Map<int, double> wavelengthByHueWiki = {};
  static bool _completed = false;
  static int max = 270;
  static int minFromOtherSide = 360;

  static void initialize(bool wiki) async {
    var atomsNames = await rootBundle.loadString("assets/lines_images/atomsNames.txt");
    Iterable<String> atomNames = atomsNames.split("\n")
        .map((e) => e.trim())
        .where((element) => element.length > 0);
    for(String atomName in atomNames) {
      print(atomName);
      await _createImageAnalysisFile("${atomName}");
    }

    final String jsonData;
    if(!wiki) {
      jsonData = await _loadAsset();
    }
    else{
      jsonData = await _loadAssetWiki();
    }
    final parsedJson = jsonDecode(jsonData);

    Map<dynamic, dynamic> jsonDict = parsedJson['wavelength'];

    for (String str in jsonDict.keys) {
      int a = int.parse(str);
      if (a < 300 && a > max) {
        max = a;
      }
      if (a > 300 && a < minFromOtherSide) {
        minFromOtherSide = a;
      }
    }

    _complementHue(jsonDict, wiki);
    _completed = true;
  }

  static void _complementHue(Map<dynamic, dynamic> jsonDict, bool wiki){
    List<int> notExisting = [];
    int left = minFromOtherSide, right = minFromOtherSide;


    for (int i = max + 360 - minFromOtherSide; i >= 0; i--) {
      int targetHue = (i - 360 + minFromOtherSide) % 360;

      if (jsonDict[targetHue.toString()] != null) {
        left = right;
        right = targetHue;
        if(!wiki) {
          wavelengthByHue[targetHue] = jsonDict[targetHue.toString()];
        }
        else{
          wavelengthByHueWiki[targetHue] = jsonDict[targetHue.toString()];
        }

        for (int j = 0; j < notExisting.length; j++) {

          if(!wiki) {
            wavelengthByHue[notExisting[j]] =
                ((notExisting.length - j) * wavelengthByHue[left]! +
                    (j + 1) * wavelengthByHue[right]!) /
                    (notExisting.length + 1);
          }
          else{
            wavelengthByHueWiki[notExisting[j]] =
                ((notExisting.length - j) * wavelengthByHueWiki[left]! +
                    (j + 1) * wavelengthByHueWiki[right]!) /
                    (notExisting.length + 1);
          }
        }
        notExisting.clear();
      }
      else {
        notExisting.add(targetHue);
      }
    }
    if(!wiki) {
      wavelengthByHue[360] = wavelengthByHue[0]!;
    }
    else{
      for(int i = 360; i>350; i--) {
        wavelengthByHueWiki[i] = wavelengthByHueWiki[0]!;
      }
    }
  }

  static double getWavelength(int hue, bool wiki){
    if(!_completed){
      throw Exception("Not completed");
    }
    if(!wiki) {
      return wavelengthByHue[hue]!;
    }
    else{
      print("len of wiki ${wavelengthByHueWiki.length}");
      print(hue);
      return wavelengthByHueWiki[hue]!;
    }
  }

  static Future<String> _loadAsset() async {
    return await rootBundle.loadString('assets/spectrum.json');
  }

  static Future<String> _loadAssetWiki() async {
    return await rootBundle.loadString('assets/spectrumWiki.json');
  }

  static Future<void> _createImageAnalysisFile(String imageName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String dirPath = "${directory.path}";

    var spectrum = (await _getLineImageSpectrum("${imageName}.png"))?.spectrum;
    StringBuffer stringToSave = new StringBuffer();
    spectrum?.forEach((key, value) {stringToSave.write("$key: $value\n");});

    File fileToSave = new File("$dirPath/${imageName}_data.txt");
    fileToSave.writeAsString(stringToSave.toString());
    fileToSave.create();
  }

  static Future<Spectrable?> _getLineImageSpectrum(String imageName) async {
      ByteData byteData = await rootBundle.load("assets/lines_images/$imageName");

      Uint8List audioUint8List = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
      List<int> values = audioUint8List.map((eachUint8) => eachUint8.toInt()).toList();
      Img.Image image = Img.decodeImage(values)!;

      ImageData imageData = ImageData("", image.data, image.height, image.width);
      await imageData.extractData();

      Spectrable? spectrumGenerator = AlgorithmFactory()
          .setAlgorithm(Algorithm.hsvPositionPolynomialSureBounds)
          .setGrating(Grating.grating0)
          .setImageData(imageData)
          .create();

      if(spectrumGenerator == null) {
        throw new Exception("Something went wrong");
      }
      spectrumGenerator.generateSpectrum();
      return spectrumGenerator;
  }
}