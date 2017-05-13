import processing.video.*;

Movie movie;
PrintWriter output;

int strobeCurrent;
int strobeInterval = 2;
int storedFrames;

/*  
import processing.video.*;
Movie myMovie;

void setup() {
  size(200, 200);
  //frameRate(30);
  myMovie = new Movie(this, "PCMLab9.mov");
  myMovie.loop();
}

void draw() {
  background(255);
  if (myMovie.available()) {
    myMovie.read();
  }
  image(myMovie, 0, 0);
  // Draws a line on the screen
  // when the movie half-finished
  float md = myMovie.duration();
  float mt = myMovie.time();
  if (mt > md/2.0) {
    line(0, 0, width, height);
  }
}
*/
void setup(){
  strobeCurrent = 0;
  storedFrames = 0;
  //TODO exchange
  size(320,240);
  //TODO exchange
  movie = new Movie(this, "PCMLab9.mov");
  movie.play();
  output = createWriter("time-indices.txt");
}

void draw(){
  if(movie.available()){
    movie.read();
  }
  if((int)movie.time() == strobeCurrent){ 
    //saveFrame("1_frames/frame-##.png");
    String filename = "1_frames/segment-" + storedFrames + ".png";
    saveFrame(filename);
    output.println("segment-" + storedFrames + " time: " + movie.time() + "\n");
    storedFrames++;
    strobeCurrent += strobeInterval;
  } 
  image(movie,0,0);
}

void keyPressed(){
  output.flush();
  output.close();
  exit();
}