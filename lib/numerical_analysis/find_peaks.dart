import '../pages/analysis_page.dart';

List<LinearData> FindPeaks(List<LinearData> data, double minProminence, double maxProminence, int minWidth, double relevanceFactor){

  List<LinearData> peaks = [];

  for(int i = 1; i < data.length - 1; i++) {
      //check for points which can be extremes
        if(data[i].y >  data[i - 1].y && data[i].y >  data[i + 1].y){
          //prominence check
          double referenceY = double.infinity;
          double leftMinimum = 0;
          double rightMinimum = 0;
          bool hit = false;
          //check to the left
          for(int j = i - 1; j >= 0 && !hit; j--)
          {
            if(data[j].y >= data[i].y || j == 0){
              hit = true;
              if(j == 0){
                referenceY = data[j].y;
              }
            }
            else {
              if (data[j].y < referenceY && data[j].y > relevanceFactor) {
                referenceY = data[j].y;
              }
            }
          }
          leftMinimum = referenceY;

          //reset
          referenceY = double.infinity;
          hit = false;
          //check to the right
          for(int j = i + 1; j < data.length && !hit; j++)
          {
            if(data[j].y >= data[i].y || j == (data.length - 1)){
              hit = true;
              if(j == (data.length - 1)){
                referenceY = data[j].y;
              }
            }
            else {
              if (data[j].y < referenceY && data[j].y > relevanceFactor) {
                referenceY = data[j].y;
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



          bool widthCheck = true;
          //width checking
          for(int j = 0; j < minWidth && (i + j) < data.length && (i - j) > 0; j++)
          {
            // right
            if(data[i + j].y > data[i].y)
            {
              widthCheck = false;
            }
            // left
            if(data[i - j].y > data[i].y)
            {
              widthCheck = false;
            }
          }

          if((data[i].y - referenceY) >= minProminence && (data[i].y - referenceY) <= maxProminence && widthCheck) {
            peaks.add(data[i]);
          }
        }
      }
  return peaks;
}