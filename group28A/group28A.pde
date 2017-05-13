import processing.video.*;

Movie movie;
PrintWriter output1;
PrintWriter output2;


int strobeCurrent;
int strobeInterval = 2;
int strobeStoredFrames;
int histogramStoredFrames;

PImage image;

//TODO adapt when we have the actual video
int thresholdSimpleDifferences = 20000;
int thresholdSquaredDifferences = 3;

//first dimension are color channels, second the actual histogram per channel
int[][] histogramCurrent;
int[][] histogramLast;

//TODO change those two parametres
int imageWidth = 320;
int imageHeight = 240;

void setup(){
  strobeCurrent = 0;
  strobeStoredFrames = 0;
  histogramStoredFrames = 0;
  //TODO exchange
  size(320,240);
  //TODO exchange
  movie = new Movie(this, "PCMLab9.mov");
  movie.play();
  output1 = createWriter("1_time-indices.txt");
  output2 = createWriter("2_time-indices.txt");
}

void draw(){
  if(movie.available()){
    movie.read();
  }
  if((int)movie.time() == strobeCurrent){ 
    //saveFrame("1_frames/frame-##.png");
    String filename = "1_frames/segment-" + strobeStoredFrames + ".png";
    saveFrame(filename);
    output1.println("segment-" + strobeStoredFrames + " time: " + movie.time() + "\n");
    strobeStoredFrames++;
    strobeCurrent += strobeInterval;
  } 
  if(histogramLast != null && histogramCurrent != null){
    int differenceHistograms = calculateDifferenceHistograms();
    //use the print line to determine new threshold
    println("difference: " + differenceHistograms);  
    
    //cut detected
    if(differenceHistograms > thresholdSquaredDifferences){
      String filename = "2_frames/segment-" + histogramStoredFrames + ".png";
      saveFrame(filename);
      output2.println("segment-" + histogramStoredFrames + " time: " + movie.time() + "\n");
      histogramStoredFrames++;
    }
  }
  if(histogramCurrent != null){
    histogramLast = histogramCurrent;  
  }
  histogramCurrent = calculateHistogram(movie);
  image(movie,0,0);
}

//write the txt files before ending the program
void keyPressed(){
  output1.flush();
  output1.close();
  output2.flush();
  output2.close();
  exit();
}

int[][] calculateHistogram(PImage image){
  
  int[] histogramRed = new int[256];
  int[] histogramGreen = new int[256];
  int[] histogramBlue = new int[256];
  
  PImage result = createImage(imageWidth, imageHeight, RGB);
  result.copy(image,0,0,imageWidth,imageHeight,0,0,imageWidth,imageHeight);

  result.loadPixels();
  
  //fill every bin for the grayscale value with 0 to increase it later
  for(int i = 0; i < histogramRed.length; i++){
    histogramRed[i] = 0;
    histogramGreen[i] = 0;
    histogramBlue[i] = 0;
  }
  
  for(int x = 0; x < image.width; x++){
    for(int y = 0; y < image.height; y++){
      color c = result.get(x,y);
      int red = (int)red(c);
      int green = (int)green(c);
      int blue = (int)blue(c);
      
      histogramRed[red]++;
      histogramGreen[green]++;
      histogramBlue[blue]++;
    }
  }
  
  //first array are the color channels, second the histogram of each channel
  int[][] resultHistogram = {histogramRed, histogramGreen, histogramBlue};
  return resultHistogram;
}

/*
calculates the difference between histogramCurrent and histogramLast which are variables
of the file. If needed you can change this to giving the histograms as parametres, but 
remember to change it also in the function calls
*/
int calculateDifferenceHistograms(){
  
  int differenceRed = 0;
  int differenceGreen = 0;
  int differenceBlue = 0;

  for(int bin = 0; bin < histogramCurrent[0].length; bin++){
    //sum up everything, first seperated by color channel, then add everything together 
    //simple
    //differenceRed += Math.abs(histogramCurrent[0][bin] - histogramLast[0][bin]);
    //differenceGreen += Math.abs(histogramCurrent[1][bin] - histogramLast[1][bin]);
    //differenceBlue += Math.abs(histogramCurrent[2][bin] - histogramLast[2][bin]);
    
    //squared differences
    differenceRed += Math.pow(Math.abs(histogramCurrent[0][bin] - histogramLast[0][bin]),2);
    differenceGreen += Math.pow(Math.abs(histogramCurrent[1][bin] - histogramLast[1][bin]),2);
    differenceBlue += Math.pow(Math.abs(histogramCurrent[2][bin] - histogramLast[2][bin]),2);
    
    //still squared differences
    if(histogramLast[0][bin] != 0){
      differenceRed /= histogramLast[0][bin];
    }
    if(histogramLast[1][bin] != 0){
      differenceGreen /= histogramLast[1][bin];
    }
    if(histogramLast[2][bin] != 0){
      differenceBlue /= histogramLast[2][bin];
    }
  }

  int differenceSum = differenceRed + differenceGreen + differenceBlue;

  return differenceSum;
}