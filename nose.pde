// Processing 3.0x template for receiving raw points from
// Kyle McDonald's FaceOSC v.1.1 
// https://github.com/kylemcdonald/ofxFaceTracker
//
// Adapted by Kaleb Crawford and Golan Levin, 2016-7, after:
// 2012 Dan Wilcox danomatika.com
// for the IACD Spring 2012 class at the CMU School of Art
// adapted from from Greg Borenstein's 2011 example
// https://gist.github.com/1603230

import processing.serial.*; 
import cc.arduino.*;
import oscP5.*;

OscP5 oscP5;
PFont font;
int found;
float[] rawArray;
int highlighted; //which point is selected

PImage lemon;
PImage nose;
int pointX;
int pointY;

int[] sArray;
int turnStatus=0;

Arduino arduino;
int ledPin=13;
int servoPin=9;
int pos=0;

//--------------------------------------------
void setup() {
  
  //---------------------------------------------set up  OSC settings
  size(480,480);
  frameRate(30);
  rawArray = new float[132]; 
  oscP5 = new OscP5(this, 8338);
  oscP5.plug(this, "found", "/found");
  oscP5.plug(this, "rawData", "/raw");
  
  //----------------------------------------------font
  font= createFont("AmaticSC-Bold.ttf",30);
  textFont(font);
  
  //----------------------------------------------arduino
  println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[0], 57600);
  arduino.pinMode(ledPin,Arduino.OUTPUT);
  arduino.pinMode(servoPin,5);
  arduino.analogWrite(servoPin,0);
  
  //-----------------------------------------------processing
  lemon = loadImage("lemon.jpg");
  nose = loadImage("nose.png");
  sArray= new int[2];
  sArray[0]=0;
  sArray[1]=0;

}

//--------------------------------------------
void draw() {
 
  pointX= int(width-rawArray[60]);
  pointY= int(rawArray[61]);
  
  background(255);
  image(lemon,0,0,480,480);
  noStroke();
  println(sArray[1]);
  

  if (found != 0) {
    drawFacePoints(); 
    detect();
    if(sArray[1]==1){
      //---------------------------------------------lemon
      pos=170;
      arduino.digitalWrite(ledPin,Arduino.HIGH);
      arduino.analogWrite(servoPin,pos);
      fill(255,255,255);
      text("LEMON !", pointX-24, pointY-90);
      
    }
    else{
      //---------------------------------------------tree
       pos=90;
       arduino.digitalWrite(ledPin,Arduino.LOW);
       arduino.analogWrite(servoPin,pos);
       fill(255,255,255);
       text("TREE !", pointX-14, pointY-90);
    }
    
    //-------------check
    //println(turnStatus);
    //println("[0]=",sArray[0]);
    //println("[1]=",sArray[1]);
  }
}

//--------------------------------------------draw nose on the screen
void drawFacePoints() {
   image(nose, pointX-74, pointY-116,150,150);
}

//------------------------------------------detect where the nose is, on the lemons or on the trees.
void detect(){
  sArray[0]=sArray[1]; 
  if ((((pointX-110)*(pointX-110)+(pointY-320)*(pointY-320))<7225)||
      (((pointX-350)*(pointX-350)+(pointY-300)*(pointY-300))<10000)||
      (((pointX-230)*(pointX-230)+(pointY-220)*(pointY-220))<6000))
  {
    sArray[1]=1; 
  }else{
    sArray[1]=0;
  }
     
  if(sArray[0]==sArray[1]){
    turnStatus=0;
  }else{
    turnStatus=1;
  }
  
}
//--------------------------------------------
public void found(int i) {
  found = i;
}
public void rawData(float[] raw) {
  rawArray = raw; // stash data in array
}