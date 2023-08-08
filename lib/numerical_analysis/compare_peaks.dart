import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/analysis_page.dart';

class CompareResult{
    late int result;
    late double accuracy;
    late String photo;
    late String name;
    late int category;

    CompareResult(int result, double accuracy, String photo, String name, int category)
    {
        this.result = result;
        this.accuracy = accuracy;
        this.photo = photo;
        this.name = name;
        this.category = category;
    }
}

Future<List<CompareResult>> ComputePeaks(Map map) async{
    await WidgetsFlutterBinding.ensureInitialized();
    String jsonString = await rootBundle.loadString('assets/spectra.json');
    map["json"] = jsonString;
    List<CompareResult> results = await compute(ComparePeaks, map);
    return results;
}

List<CompareResult> ComparePeaks(Map map) {

    List<LinearData> peaks = map['peaks'];
    SharedPreferences prefs = map['prefs'];
    var jsonString = map['json'];

    List<CompareResult> result = <CompareResult>[]; // final result which will be displayed in app

     // we load json so we can compare with it
    List<dynamic> json = jsonDecode(jsonString);

    List<CompareResult> unconvertedResults = <CompareResult>[]; // results before sorting, normalizing etc.

    double cumulatedAccuracy = 0;
    for(int i = 0; i < json.length; i++) // main iteration
    {
        /*for(int j = 0; j < json[i]["peaks"].length; j++) // second iteration (by peaks in file)
        {
            LinearData closestMatch = new LinearData(-1, -1);
            double difference = double.infinity; // create something that always will be beaten by others
            for(int h = 0; h < peaks.length; h++) // third iteration (by peaks from photo)
            {
                double currentDifference = (json[i]["peaks"][j]["wavelength"] - peaks[h].x).abs(); // calculating difference between photo and file peaks to determine which two we can compare
                if(currentDifference < difference)
                {
                    difference = currentDifference;
                    closestMatch = peaks[h];
                }
            }
            double currentAccuracy = (pow((json[i]["peaks"][j]["wavelength"] - closestMatch.x).abs(), 2) +
                pow((json[i]["peaks"][j]["intensity"] - closestMatch.y).abs(), 2) )as double;
            cumulatedAccuracy += currentAccuracy;
        }*/
        for(int j = 0; j < peaks.length; j++) // second iteration (by peaks from photo)
            {
            LinearData closestMatch = new LinearData(-1, -1);
            double difference = double.infinity; // create something that always will be beaten by others
            for(int h = 0; h < json[i]["peaks"].length; h++) // third iteration (by peaks in data)
                {
                double currentDifference = ((json[i]["peaks"][h]["wavelength"].toDouble()) - peaks[j].x).abs(); // calculating difference between photo and file peaks to determine which two we can compare
                if(currentDifference < difference)
                {
                    difference = currentDifference;
                    double x = json[i]["peaks"][h]["wavelength"].toDouble();
                    double y = json[i]["peaks"][h]["intensity"].toDouble();
                    closestMatch = new LinearData(x, y);
                }
            }


            double currentAccuracy = (pow((peaks[j].x - closestMatch.x).abs(), 2) +
                pow((peaks[j].y - closestMatch.y).abs(), 2)) as double;
            cumulatedAccuracy += currentAccuracy;
        }
        unconvertedResults.add(new CompareResult(i, cumulatedAccuracy, json[i]["example_photo"], json[i]["name_" + prefs.getString('language')!], json[i]["class"]));
        cumulatedAccuracy = 0;
    }

    unconvertedResults.sort((a, b) => a.accuracy.compareTo(b.accuracy));



    unconvertedResults.forEach((element) {element.accuracy = (100.0 - element.accuracy / unconvertedResults[unconvertedResults.length-1].accuracy * 100).floorToDouble();});

    result = unconvertedResults;

    return result;
}