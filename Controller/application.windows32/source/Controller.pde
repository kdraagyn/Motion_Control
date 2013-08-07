/*
* This is a program that will display and save input from a dual analog stick controller much
 * like a plastation controller. The UI will be able to control an arduino motor controller, 
 * it will be able to save the sessions using their controller, and it will allow you to edit
 * your own curves that program can playback. 
 * 
 * Author:Keith Nygaard
 * Updated:6/9/2013
 *
 * Still needs to be added:
 *   Clock for all edit and record windows
 *     timing marks on graph display
 *     input filter for smooth change in stepper motors
 *   Curve editor
 *   Serial output to designated COM port
 *   Controller curve editor
 */

//-----------------------------IMPORTED LIBRARIES-----------------------------------//

import procontroll.*;
import java.io.*;
import processing.opengl.*;
import processing.serial.*;


//------------------------------GLOBAL VARIABLES------------------------------------//
//create the proControll instances
//for library reference: http://creativecomputing.cc/p5libs/procontroll/index.htm
ControllIO controll;
ControllDevice device;
ControllSlider s1x;
ControllSlider s2y;
ControllSlider s3z;
ControllButton buttons[];

static int SPACING = 50;        //the padding around each section in pixels
static float displayMult = .8;  //the size of window for the application with 1 as full screen >.5 works the best

int numberDevices; //Number of devices connected to the computer to use
int deviceN;       //device number in list of devices from controll.getNumberOfDevices()

//create a menu array with the device and ports list
textButton[] menu;
textButton[] ports;
textButton timelapse;

String timelapseName = "Time Lapse";

boolean picked = false;       //remember if a device has been picked or not
boolean initialized = false;  //remember if the chosen device has been initialized
boolean stopped = false;      //remember if the data stream has been stopped
boolean saved = false;        //remember if the data has been saved for playback
boolean restart = false;      //remember if the data is going to be cleared to start over;
boolean connected = false;
PFont disFont;                //create a font instance for all fonts used in the program

//time variables to help display, save, and repeat each save
time clock;

//the container for the graphs
XYZ graphSect;

//state variable(r for record, c for curve editor)
char state;

capsule statesMenu;

//Serial instance to talk to arduino
Serial serialOut;
String comPort;

//variables for the text input for correct COM port
String Ttyping = "";
String Tsaved = "";
Boolean TdoneTyping = false;

