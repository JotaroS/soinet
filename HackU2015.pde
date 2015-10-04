

/*
THIS PROGRAM WORKS WITH PulseSensorAmped_Arduino-xx ARDUINO CODE
 THE PULSE DATA WINDOW IS SCALEABLE WITH SCROLLBAR AT BOTTOM OF SCREEN
 PRESS 'S' OR 's' KEY TO SAVE A PICTURE OF THE SCREEN IN SKETCH FOLDER (.jpg)
 MADE BY JOEL MURPHY AUGUST, 2012
 */


import processing.serial.*;
import controlP5.*;

import twitter4j.conf.*;
import twitter4j.*;
import twitter4j.auth.*;
import twitter4j.api.*;

Twitter myTwitter;

String msg = "Hi i'm jotaro accessing from my processing sketch.";

String consumerKey = "zSGkuI4cuhBTt9hbF5V3MKk2S";
String consumerSecret = "MfiaPHNIpN9wFLGQo1geXPRds9mBl9CoNLar2pW5couK6Tl1un";
String accessToken = "916808642-TZf1Iio7nXf4DJp6xHnRe1bFEjxdZomGxhqyRnat";
String accessSecret = "FvKX7EN1Q1bzNDGOPTcUbhZtFCJAvud2g2JksBizuJA44";
String[] names;

PFont font;
PFont bigfont;
PFont smallfont;
ControlP5 cp5;
controlP5.Button button;
Scrollbar scaleBar;

Serial bluetooth;

Serial port;     

int Sensor;      // HOLDS PULSE SENSOR DATA FROM ARDUINO
int IBI;         // HOLDS TIME BETWEN HEARTBEATS FROM ARDUINO
int BPM;         // HOLDS HEART RATE VALUE FROM ARDUINO
int[] RawY;      // HOLDS HEARTBEAT WAVEFORM DATA BEFORE SCALING
int[] ScaledY;   // USED TO POSITION SCALED HEARTBEAT WAVEFORM
int[] rate;      // USED TO POSITION BPM DATA WAVEFORM
int[] favs;
float zoom;      // USED WHEN SCALING PULSE WAVEFORM TO PULSE WINDOW
float offset;    // USED WHEN SCALING PULSE WAVEFORM TO PULSE WINDOW
color eggshell = color(255, 253, 248);
int heart = 0;   // This variable times the heart image 'pulse' on screen
//  THESE VARIABLES DETERMINE THE SIZE OF THE DATA WINDOWS
int PulseWindowWidth = 510;
int PulseWindowHeight = 356; 
int BPMWindowWidth = 180;
int BPMWindowHeight = 440;
boolean beat = false;    // set when a heart beat is detected, then cleared when the BPM graph is advanced
PImage header;
PImage back;
PImage comment;
float shift_x  = 0;
float shift_x_to  = 0;
float pl_x = 0;
float pl_x_to = 0;
Button testButton;
Button[] hearts = new Button[10];
Button[] likes = new Button[10];
Button playButton;
Button stopButton;
Button backButton;
Button twitterButton;
void setup() {
  size(1280, 800);  // Stage size
  frameRate(100);  
  //font = loadFont("Arial-BoldMT-24.vlw");
  font = createFont("Hiragino Sans GB W6.vlw", 18, true);
  bigfont = createFont("03SmartFontUI", 90, true);
  smallfont = createFont("03SmartFontUI", 50, true);
  textFont(font);
  textAlign(CENTER);
  rectMode(CENTER);
  ellipseMode(CENTER);  
  // Scrollbar constructor inputs: x,y,width,height,minVal,maxVal
  scaleBar = new Scrollbar (400, 575, 180, 12, 0.5, 1.0);  // set parameters for the scale bar
  RawY = new int[PulseWindowWidth];          // initialize raw pulse waveform array
  ScaledY = new int[PulseWindowWidth];       // initialize scaled pulse waveform array
  rate = new int [BPMWindowWidth];           // initialize BPM waveform array
  zoom = 0.75;                               // initialize scale of heartbeat window

  
  ConfigurationBuilder cb = new ConfigurationBuilder();
  cb.setOAuthConsumerKey(consumerKey);
  cb.setOAuthConsumerSecret(consumerSecret);
  cb.setOAuthAccessToken(accessToken);
  cb.setOAuthAccessTokenSecret(accessSecret);
  myTwitter = new TwitterFactory(cb.build()).getInstance();

  // set the visualizer lines to 0
  for (int i=0; i<rate.length; i++) {
    rate[i] = 555;      // Place BPM graph line at bottom of BPM Window
  }
  for (int i=0; i<RawY.length; i++) {
    RawY[i] = height/2; // initialize the pulse window data line to V/2
  }
  // GO FIND THE ARDUINO
  bluetooth = new Serial(this, "/dev/tty.RNBT-65E5-RNI-SPP", 115200);
  bluetooth.clear();
  println(Serial.list());    // print a list of available serial ports
  // choose the number between the [] that is connected to the Arduino
  port = new Serial(this, "/dev/cu.usbserial-AH01J63C", 9800);  // make sure Arduino is talking serial at this baud rate


  port.clear();            // flush buffer
  port.bufferUntil('\n');  // set buffer full flag on receipt of carriage return


  cp5 = new ControlP5(this);
  PImage img = loadImage("heart.png");
  PImage miniHeart = loadImage("miniHeart.png");
  header = loadImage("soinet_logo.png");
  comment = loadImage("comment.png");
  //testButton =   new Button(100, 100, 100, 100, img,cp5);

  PFont _font = createFont("", 0); 
  println(_font.list());   

  //place heart button for top page
  for (int i =0; i < 3; i ++) {
    hearts[i] = new Button(100+270*i - (int)shift_x, 200, 100, 100, "h" + str(i), img, cp5);
  }
  for (int i =3; i < 6; i ++) {
    hearts[i] = new Button(100+270*(i-3)- (int)shift_x, 500, 100, 100, "h" + str(i), img, cp5);
  }
  //place heart button for top page
  for (int i =0; i < 3; i ++) {
    likes[i] = new Button(270+270*i- (int)shift_x, 385, 30, 30, "l" + str(i), miniHeart, cp5);
  }
  for (int i =3; i < 6; i ++) {
    likes[i] = new Button(270+270*(i-3)- (int)shift_x, 685, 30, 30, "l" + str(i), miniHeart, cp5);
  }
  playButton = new Button(1300, 630, 100, 100, "p", loadImage("play.png"), cp5);
  stopButton = new Button(1500, 630, 100, 100, "s", loadImage("stop.png"), cp5);
  backButton = new Button(1500, 30, 100, 100, "z", loadImage("back.png"), cp5);
  twitterButton = new Button(1500, 550, 100, 100, "t", loadImage("twitter.png"), cp5);
  favs = new int[]{12,213,32,43,52,46};
}
void draw() {
  background(255, 231, 231);
  noStroke();

  textAlign(CENTER);
  textFont(font);
  //DRAW OUT THE PULSE WINDOW
  drawHeader();
  drawWaveForm();
  // PRINT THE DATA AND VARIABLE VALUES
  //fill(eggshell);                                       // get ready to print text
  //text("あいう 1.1", 245, 30);     // tell them what you are
  //  text("IBI " + IBI + "mS", 600, 585);                    // print the time between heartbeats in mS
  //  text(BPM + " BPM", 600, 200);                           // print the Beats Per Minute
  //  text("Pulse Window Scale " + nf(zoom, 1, 2), 150, 585); // show the current scale of Pulse Window

  //  DO THE SCROLLBAR THINGS
  //  scaleBar.update (mouseX, mouseY);
  //  scaleBar.display();
  moveButtons();
  textFont(font);
  drawTexts();
  //
}  //end of draw loop

public void drawHeader() {
  fill(255);
  strokeWeight(2);
  stroke(#FBADB1);
  rect(width/2, 50, width, 150);
  image(header, width/2-header.width/2, 10);
}
public void drawTexts() {
  //Draw out text pad.
  fill(#E84689);
  noStroke();
  for (int i =0; i < 3; i ++) {
    rect(180+270*i- shift_x, 400, 140, 30, 30);
  }
  for (int i =0; i < 3; i ++) {
    rect(180+270*i- shift_x, 700, 140, 30, 30);
  }
  pushMatrix();
  {
    textAlign(CENTER);
    translate(-shift_x, 0);
    fill(255);
    text("じょうさん", 180, 407);
    text("まゆりさん", 180+270, 407);
    text("ゆうきさん", 180+270*2, 407);

    text("あやかさん", 180, 707);
    text("よしはしさん", 180+270, 707);
    text("ましこさん", 180+270*2, 707);


    fill(255);
    stroke(254, 180, 182);
    strokeWeight(2);
    rect(1060, 450, 300, 500, 30);
    fill(254, 180, 182);
    textFont(bigfont, 35);
    
    fill(254, 180, 182,100);
    noStroke();
    ellipse(200,280,100+150*sin((float)frameCount/30),100+150*sin((float)frameCount/30));
    text("soinet News!", 1060, 250);
    image(comment, 935, 260);
  }
  popMatrix();
}
public void moveButtons() {
  //_b.b.position().x = lerp(testButton.b.position().x,shift_x_to, 0.1);
  shift_x = lerp(shift_x, shift_x_to, 0.08);
  pl_x = lerp(pl_x, pl_x_to, 0.08);

  for (int i =0; i < 3; i ++) {
    hearts[i].b.position().x = 100+270*i - (int)shift_x;
  }
  for (int i =3; i < 6; i ++) {
    hearts[i].b.position().x =100+270*(i-3)- (int)shift_x;
  }
  //place heart button for top page
  for (int i =0; i < 3; i ++) {
    likes[i].b.position().x =270+270*i- (int)shift_x;
  }
  for (int i =3; i < 6; i ++) {
    likes[i].b.position().x = 270+270*(i-3)- (int)shift_x;
  }
  playButton.b.position().x = 1390+pl_x;
  stopButton.b.position().x = 1610+pl_x;
  backButton.b.position().x = 1400+pl_x;
  twitterButton.b.position().x = 2200+pl_x;
}

public void drawWaveForm() {
  // DRAW THE PULSE WAVEFORM
  // prepare pulse data points   
  pushMatrix();
  {
    translate(1300+pl_x, 0);
    fill(#E84689);
    textFont(smallfont, 50);
    text("BPM:", 150, 280);

    textFont(bigfont, 120);
    text(BPM, 380, 280);
    rect(300, height/2+100, PulseWindowWidth, PulseWindowHeight+50, 30);
    stroke(255);
    strokeWeight(5);
    noFill();
    rect(300, height/2+70, PulseWindowWidth-50, PulseWindowHeight-100, 30);
    zoom = 0.4; 
    RawY[RawY.length-1] = (1023 - Sensor) - 12;   // place the new raw datapoint at the end of the array
    //zoom = scaleBar.getPos();                      // get current waveform scale value
    offset = map(zoom, 0.5, 1, 150, 0);                // calculate the offset needed at this scale
    for (int i = 0; i < RawY.length-1; i++) {      // move the pulse waveform by
      RawY[i] = RawY[i+1];                         // shifting all raw datapoints one pixel left
      float dummy = RawY[i] * zoom + offset;       // adjust the raw data to the selected scale
      ScaledY[i] = constrain(int(dummy), 24, 456);   // transfer the raw data array to the scaled array
    }
    stroke(255);                               // red is a good color for the pulse waveform
    noFill();
    beginShape();                                  // using beginShape() renders fast
    for (int x = 50; x < ScaledY.length-1; x++) {    
      vertex(x+20, ScaledY[x]+140);                    //draw a line connecting the data points
    }
    //vertex(ScaledY.length-1 + 20, 456);
    //vertex(70, 456);
    endShape();

    textFont(font, 35);
    textAlign(LEFT);
    fill(#E84689);
    text("じょうさんのHeart", 650, 280);
    textFont(smallfont, 50);
    text("Date : 2015/10/03", 650, 400);
    text("Likes: "+favs[0], 650, 480);
    text("Share:", 650, 640);
  }
  popMatrix();
}

public void drawHeartBeat() {
  // DRAW THE HEART AND MAYBE MAKE IT BEAT
  fill(250, 0, 0);
  stroke(250, 0, 0);
  // the 'heart' variable is set in serialEvent when arduino sees a beat happen
  heart--;                    // heart is used to time how long the heart graphic swells when your heart beats
  heart = max(heart, 0);       // don't let the heart variable go into negative numbers
  if (heart > 0) {             // if a beat happened recently, 
    strokeWeight(8);          // make the heart big
  }
  smooth();   // draw the heart with two bezier curves
  bezier(width-100, 50, width-20, -20, width, 140, width-100, 150);
  bezier(width-100, 50, width-190, -20, width-200, 140, width-100, 150);
  strokeWeight(1);          // reset the strokeWeight for next time
}


public void controlEvent(ControlEvent theEvent) {
  int num;
  char prefix;
  String str;
  //println(theEvent.getController().getName());
  str = theEvent.getController().getName();
  switch(str.charAt(0)) {
  case 'h':
    println("heart pressed");
    println("x " +(mouseX) + "y " + (mouseY));
    if (int(str.substring(1))==0) {
      shift_x_to = width;
      pl_x_to = -1300;
    }
    break;
  case 'z':
    shift_x_to = 0;
    pl_x_to = 0;
    break;
      case 'l':
      favs[int(str.substring(1))]++;
    break;
  case 't':
    try {
      Status st = myTwitter.updateStatus("soinetで癒やされました! #hacku");
    }
    catch(TwitterException e) {
    } 
    break;
  default:
    break;
  }
  return ;
}

