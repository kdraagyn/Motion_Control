/*
  Program to send arduino information over serial to effectively control it's movements in the rig.
  To control the axis, the graphs will be setup with respect to time and controlled ultimately using bezier curves to smoothly
  move between key-frames in the motion.
  
  start date: 5/25/2013
*/

import processing.serial.* ;

Serial port;

void setup () {
  size(700,700); 
  port = new Serial(this, "COM12", 9600);
  background(0, 0, 0);
}

void draw() {
  
}

void serialEvent (Serial port) {
  
}
