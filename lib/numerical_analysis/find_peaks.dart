import '../pages/analysis_page.dart';

List<LinearData> FindPeaks(Map<double, double> data, double minProminence, double maxProminence){

  List<LinearData> dataConverted = [];
  List<LinearData> peaks = [];
  for (double key in data.keys) {
    dataConverted.add(LinearData(key, data[key]!));
  }

  for(int i = 0; i < data.length; i++) {
      //edge cases
      if(i == 0){
        if(dataConverted[i].y >  dataConverted[i + 1].y ) {
          double referenceY = double.infinity;
          bool hit = false;
          for(int j = i + 1; j < data.length && !hit; j++)
          {
            if(dataConverted[j].y >= dataConverted[i].y || j == (data.length - 1)){
              hit = true;
            }
            else {
              if (dataConverted[j].y < referenceY) {
                referenceY = dataConverted[j].y;
              }
            }
          }
          if((dataConverted[i].y - referenceY) >= minProminence && (dataConverted[i].y - referenceY) <= maxProminence) {
            peaks.add(dataConverted[i]);
          }
        }
      }
      else if(i == dataConverted.length - 1){
        if(dataConverted[i].y >  dataConverted[i - 1].y ) {
          double referenceY = double.infinity;
          bool hit = false;
          for(int j = i - 1; j >= 0 && !hit; j--)
          {
            if(dataConverted[j].y >= dataConverted[i].y || j == 0){
              hit = true;
            }
            else {
              if (dataConverted[j].y < referenceY) {
                referenceY = dataConverted[j].y;
              }
            }
          }

          if((dataConverted[i].y - referenceY) >= minProminence && (dataConverted[i].y - referenceY) <= maxProminence) {
            peaks.add(dataConverted[i]);
          }
        }
      }
      //main case
      else{
        if(dataConverted[i].y >  dataConverted[i - 1].y && dataConverted[i].y >  dataConverted[i + 1].y){
          //prominence check
          double referenceY = double.infinity;
          double leftMinimum = 0;
          double rightMinimum = 0;
          bool hit = false;
          //check to the left
          for(int j = i - 1; j >= 0 && !hit; j--)
          {
            if(dataConverted[j].y >= dataConverted[i].y || j == 0){
              hit = true;
            }
            else {
              if (dataConverted[j].y < referenceY) {
                referenceY = dataConverted[j].y;
              }
            }
          }
          leftMinimum = referenceY;
          hit = false;
          //check to the right
          for(int j = i + 1; j < data.length && !hit; j++)
          {
            if(dataConverted[j].y >= dataConverted[i].y || j == (data.length - 1)){
              hit = true;
            }
            else {
              if (dataConverted[j].y < referenceY) {
                referenceY = dataConverted[j].y;
              }
            }
          }
          rightMinimum = referenceY;

          //choosing bigger value as per algorithm
          if(rightMinimum > leftMinimum){
            referenceY = rightMinimum;
          }
          else{
            referenceY = leftMinimum;
          }

          if((dataConverted[i].y - referenceY) >= minProminence && (dataConverted[i].y - referenceY) <= maxProminence) {
            peaks.add(dataConverted[i]);
          }
        }
      }
  }

  return peaks;
}