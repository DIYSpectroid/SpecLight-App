import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

import '../analysis_page.dart';

class CompareResult{
    late int result;
    late double accuracy;

    CompareResult(int result, double accuracy)
    {
        this.result = result;
        this.accuracy = accuracy;
    }
}

Future<List<CompareResult>> ComparePeaks(List<LinearData> peaks) async {
    List<CompareResult> result = <CompareResult>[]; // final result which will be displayed in app

    String jsonString = await rootBundle.loadString('assets/testspectra.json'); // we load json so we can compare with it
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
        for(int j = 0; j < peaks.length; j++) // second iteration (by peaks in file)
            {
                print("dupa1");
            LinearData closestMatch = new LinearData(-1, -1);
            double difference = double.infinity; // create something that always will be beaten by others
                print("dupa2");
            for(int h = 0; h < json[i]["peaks"].length; h++) // third iteration (by peaks from photo)
                {
                print("dupa69");
                double currentDifference = ((json[i]["peaks"][h]["wavelength"].toDouble()) - peaks[j].x).abs();
                print("dupa3");// calculating difference between photo and file peaks to determine which two we can compare
                if(currentDifference < difference)
                {
                    difference = currentDifference;
                    print("dupa4");
                    double x = json[i]["peaks"][h]["wavelength"].toDouble();
                    print("dupa44");
                    double y = json[i]["peaks"][h]["intensity"].toDouble();
                    print("dupa444");
                    closestMatch = new LinearData(x, y);
                    print("dupa5");
                }
            }
            print("dupa2137");
            double currentAccuracy = (pow((peaks[j].x - closestMatch.x).abs(), 3) +
                pow((peaks[j].y - closestMatch.y).abs(), 3) ) as double;
            print("duppa");
            cumulatedAccuracy += currentAccuracy;
        }
        unconvertedResults.add(new CompareResult(i, cumulatedAccuracy));
        cumulatedAccuracy = 0;
    }

    unconvertedResults.sort((a, b) => a.accuracy.compareTo(b.accuracy));

    result = unconvertedResults;

    return result;
}