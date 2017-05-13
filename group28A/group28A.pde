import processing.video.*;

Movie movie;
PrintWriter output;

int strobeCurrent;
int strobeInterval = 2;
int strobeStoredFrames;

PImage image;

int threshold = 20000;

int[][] histogramCurrent;
int[][] histogramLast;

//TODO change those two parametres
int imageWidth = 320;
int imageHeight = 240;

void setup(){
  strobeCurrent = 0;
  strobeStoredFrames = 0;
  //TODO exchange
  size(320,240);
  //TODO exchange
  movie = new Movie(this, "PCMLab9.mov");
  movie.play();
  output = createWriter("1_time-indices.txt");
}

void draw(){
  if(movie.available()){
    movie.read();
  }
  if((int)movie.time() == strobeCurrent){ 
    //saveFrame("1_frames/frame-##.png");
    String filename = "1_frames/segment-" + strobeStoredFrames + ".png";
    saveFrame(filename);
    output.println("segment-" + strobeStoredFrames + " time: " + movie.time() + "\n");
    strobeStoredFrames++;
    strobeCurrent += strobeInterval;
  } 
  if(histogramLast != null && histogramCurrent != null){
    int differenceHistograms = calculateDifferenceHistograms();
    println("difference: " + differenceHistograms);  
    
    //cut detected
    if(differenceHistograms > threshold){
      
    }
  }
  if(histogramCurrent != null){
    histogramLast = histogramCurrent;  
  }
  histogramCurrent = calculateHistogram(movie);
  image(movie,0,0);
}

void keyPressed(){
  output.flush();
  output.close();
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


int calculateDifferenceHistograms(){
  
  int differenceRed = 0;
  int differenceGreen = 0;
  int differenceBlue = 0;

  for(int bin = 0; bin < histogramCurrent[0].length; bin++){
    //sum up everything, first seperated by color channel, then add everything together 
    differenceRed += Math.abs(histogramCurrent[0][bin] - histogramLast[0][bin]);
    differenceGreen += Math.abs(histogramCurrent[1][bin] - histogramLast[1][bin]);
    differenceBlue += Math.abs(histogramCurrent[2][bin] - histogramLast[2][bin]);
  }

  int differenceSum = differenceRed + differenceGreen + differenceBlue;

  return differenceSum;
}