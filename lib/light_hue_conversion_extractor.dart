import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;


class HueConversionData{
  static Map<int, double> wavelengthByHue = {};
  static bool _completed = false;
  static int max = 270;
  static int minFromOtherSide = 360;

  static void initialize() async {
    final String jsonData = await _loadAsset();
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

    _complementHue(jsonDict);
    _completed = true;
  }

  static void _complementHue(Map<dynamic, dynamic> jsonDict){
    List<int> notExisting = [];
    int left = minFromOtherSide, right = minFromOtherSide;

    for (int i = max + 360 - minFromOtherSide; i >= 0; i--) {
      int targetHue = (i - 360 + minFromOtherSide) % 360;

      if (jsonDict[targetHue.toString()] != null) {
        left = right;
        right = targetHue;
        wavelengthByHue[targetHue] = jsonDict[targetHue.toString()];

        for (int j = 0; j < notExisting.length; j++) {
          wavelengthByHue[notExisting[j]] = ((notExisting.length - j) * wavelengthByHue[left]! + (j + 1) * wavelengthByHue[right]!) /
                  (notExisting.length + 1);
        }
        notExisting.clear();
      }
      else {
        notExisting.add(targetHue);
      }
    }
    wavelengthByHue[360] = wavelengthByHue[0]!;
  }

  static double getWavelength(int hue){
    if(!_completed){
      throw Exception("Not completed");
    }
    return wavelengthByHue[hue]!;
  }

  static Future<String> _loadAsset() async {
    return await rootBundle.loadString('assets/spectrum.json');
  }
}