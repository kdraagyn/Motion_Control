import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import procontroll.*; 
import java.io.*; 
import processing.opengl.*; 
import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Controller extends PApplet {

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
static float displayMult = .8f;  //the size of window for the application with 1 as full screen >.5 works the best

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

//------------------------------DISPLAY FUNCTIONS----------------------------//

//display the menu with all the devices connected to the computer
public void devicesMenu() {
  fill(0);
  int p = 0;
  //title of the menu
  text("Choose an available controller to use", width / 3, (height / 3) - SPACING);

  for (int i = 0; i < numberDevices; i++) {
    device = controll.getDevice(i);
    if ( device.getNumberOfSliders () > 4) {
      p++;
      text(device.getName(), width / 3, (height / 3) + SPACING * p);
      menu[i] = new textButton(device.getName(), width / 3, (height / 3) + SPACING * p);
      menu[i].show();
      if (menu[i].clicked()) {
        deviceN = i;
        picked = true;
        break;
      }
    }
  }
}

public void HUD() {
  if (!stopped) {
    //get values from the controller
    instance();
  }
  graphSect.show();
  timelapse.show();
  clock.display(width * 9 / 10, height * 9 / 10);
  timelapse.show();
  if (!connected) {
    
  } else {
    //draw the graphs to the screen
    graphSect.show();
    
    //send command to arduino
    serialOut.write(graphSect.sendFormat());
  }
  
  if(timelapse.clicked() == true)
  {
    timelapse.setToggled();
  }
  
    serialOut.write(graphSect.sendFormat());
}

public void curves() {
  statesMenu.smallScreen();
  statesMenu.clicked();
  clock.display( width * 9 / 10, height * 9 / 10);
}

public void menu() {
  statesMenu.fullScreen();
  statesMenu.clicked();
}

public void portsSetup() 
{
  statesMenu.smallScreen();
  statesMenu.clicked();
  fill(0);
  text("Click the arduino's COM port", width * 2 / 5, height / 2 - 80);
  int p = 0;
//  String[] list = Serial.list();
//  for (int i = 0; i < list.length; i++) {
//    p++;
//    text(list[i], width / 3, (height / 3) + SPACING * p);
//    ports[i] = new textButton(list[i], width / 3, (height / 3) + SPACING * p);
//    ports[i].show();
//    if (ports[i].clicked() && connected == false) {
//      serialOut = new Serial(this, Serial.list()[i], 115200);
//      connected = true;
//      break;
//    }
//  }
}
//---------------------------MAIN PROCESSING LOOPS-----------------------------//
public void setup() 
{
  //set frame rate and size of window
  frameRate(100);
  size(PApplet.parseInt(displayWidth * displayMult), PApplet.parseInt(displayHeight  * displayMult));

  //initialize the procontroll I/O to find devices
  controll = ControllIO.getInstance(this);
  numberDevices = controll.getNumberOfDevices();

  //initialize the menu array to the size of the number of devices
  textButton[] button = new textButton[controll.getNumberOfDevices()];
  textButton[] portInstance = new textButton[Serial.list().length];
  textButton TL = new textButton("Time Lapse", width * 7 / 8 + 100, height * 7 / 8 + 100);
  timelapse = TL;
  menu = button;                                                        //save this to the 'menu' object
  ports = portInstance;                                                 //save portInstance to the 'ports' menu object

  //load fonts and set the font for text outputs
  disFont = loadFont("BodoniMT-24.vlw");
  textFont(disFont);

  //initialize the graphs container (padding, locX, locY)
  graphSect = new XYZ(100, (width - width / 8) / 2, height - 20);

  //time class to make timing all windows and playback easier
  clock = new time();

  //create state menu on the side of the screen
  statesMenu = new capsule();
  
  serialOut = new Serial(this, "COM14",115200);
}

public void draw()
{
  background(200);
  switch (state) {
    //set the window to the record window.
  case 'r':
    record();
    break;

    //set the window to the curve editor
  case 'c':
    curves();
    break;
    
  case 's':
    portsSetup();
    break;

    //default the menu to full screen.
  default:
    menu();
    break;
  }
}

//-------------------------DEVICE INITIALIZATION-------------------------//
public void initializeDevice() {
  device.printSticks();
  device.printSliders();
  device.printButtons();
  initialized = true;

  //initialize the left and right stick needed rotations
  s1x = device.getSlider(2);
  s2y = device.getSlider(3);
  s3z = device.getSlider(4);

  //initialize all the buttons
  int bs = device.getNumberOfButtons();
  buttons = new ControllButton[bs];
  for (int i = 0; i < bs; i++) {
    buttons[i] = device.getButton(i);
  }
}

//--------------------------DEVICE READ---------------------------------//

public void read() {
  if (!initialized) {
    initializeDevice();
  } else {

    //display everything on the window
    HUD();
    if (!stopped) {
      //get values from the controller
      instance();
    }
    
    //check to toggle the pause button
    //toggle button on my snakeByte controller is square.
    if (buttons[4].getValue() == 8 && stopped == false) {
        stopped = true;
        clock.pause();
    } 
    
    //check to toggle the timelapse button
    //toggle button on the snakeByte controller is triangle.
    if (buttons[1].getValue() == 8)
    {
      timelapse.setToggled(); 
    }
    
    //resume
    //resume button on my snakeByte controller is X
    if (buttons[3].getValue() == 8 && stopped == true) {
      stopped = false;
      clock.resume();
    }

    //save
    //save button on my snakeByte controller is 'SELECT'
    if (buttons[9].getValue() == 8 && stopped == true) {
      saved = true;
      clock.reInitialize();
    }

    fill(0);
    for (int i = 0; i < 16; i++) {
      float value = buttons[i].getValue();
      text("  " + i + ": " + value, width / 23 + 75 * i, height - 100);
    }
  }
}

//-----------------DATA PLAYBACK--------------------------//
public void play() {
  HUD();
  if(timelapse.toggled == true)
  {
    graphSect.timelapse(0.5f);
  }
  else
  {
    graphSect.playback();
  }
  
  //reset
  //reset button on my snakeByte controller is 'START'
  if (buttons[10].getValue() == 8 && saved == true) {
    println("delete");
    initialized = false;
    stopped = false;
    saved = false;
    graphSect.delete();
    clock.restart();
  }
}

public void record() {
  clock.setTime();
  if (!picked) {
    devicesMenu();
  } else {
    if (!saved) {
      if ( graphSect.getNumberOfRuns() == 0) {
        clock.restart();
      }
      read();
    } else {
      if (graphSect.frame == 0) {
        clock.restart();
      }
      play();
    }
  }
  statesMenu.smallScreen();
  statesMenu.clicked();
}

public void instance() {
  graphSect.inputInstant(s1x.getValue(), s2y.getValue(), s3z.getValue());
}

//-------------------------TEXT IN---------------------------//
public void keyPressed() {
  // If the return key is pressed, save the String and clear it
  if (key == '\n' ) {
    Tsaved = Ttyping;
    // A String can be cleared by setting it equal to ""
    Ttyping = ""; 
    TdoneTyping = true;
  } else {
    if(keyCode == 8)
    {
      Ttyping = Ttyping.substring(0, Ttyping.length() - 1);
    }
    else
    {
    // Otherwise, concatenate the String
    // Each character typed by the user is added to the end of the String variable.
    Ttyping = Ttyping + key; 
    }
  }
}
//---------------------------GRAPH CLASS DEFINITIONS------------------------//

class graph {
  int globalX, globalY;
  float offsetX, offsetY;
  float w, h;
  
  //controller storage data
  float[] data = {};      //(-1 to 1)
  float[] dataTime = {};
  float[] dataTimeStep = {};
  float scaleW, scaleH;
  int l;
  int aMult = 100;
  
  char name;
  
  // initialize graphs (locX, locY, width, height,send name ('x','y','z')
  graph (int ix, int iy, int iw, int ih, char in)
  {
    globalX = ix;
    globalY = iy;
    
    name = in;
    
    w = iw;
    h = ih;
    
    //initialize the offsets of x and y to translate the graph lines to the correct spot
    offsetX = globalX - (w / 2);
    offsetY = globalY;
    
    //set the scale of Height for the data lines 1 is the max output from controller
    scaleH = (h / 2);
  }
  
  //display the graph
  public void display () {
    rectMode(CENTER);
    fill(240);
    stroke(100);
    rect(globalX, globalY, w, h, h / 200);
    strokeWeight(2);
    line(globalX - (w / 2), globalY, globalX + (w / 2), globalY);
    timeMap();
    rectMode(CORNER);
  }

  //map the time to the width of the graph window
  //display the data lines over the graph window
  public void timeMap () {
    strokeWeight(1);
    if (!stopped) {
      scaleW = w / clock.getTime();
    }
    l = data.length;
    
    if ((l != 1 || l != 1) || (l != 0 || l != 0)) {
      for (int i = 1; i < l; i++) {
        stroke(0);
        line(scaleW * dataTime[i - 1] + offsetX, scaleH * data[i - 1] + offsetY, scaleW * dataTime[i] + offsetX, scaleH * data[i] + offsetY);
      }
    }
  }
  
  public void newData (float newD) {
    
    //add another array value to the data array
    data = append(data, newD);
    
    //set the program time of the data point
    dataTime = append(dataTime, clock.getTime());
    
    //setThe step time from the last point
    dataTimeStep = append(dataTimeStep, clock.getStepSize());
  }
  
  public void playback(float a) {
    int i = PApplet.parseInt(a);
    strokeWeight(5);
    stroke(0, 150, 0);
    line(scaleW * dataTime[0 + i] + offsetX, scaleH + offsetY, scaleW * dataTime[i] + offsetX, -scaleH + offsetY);
    strokeWeight(1);
  }
  
  public String sendFormat(float in) 
  {
    if( in % 1 == 0) 
    {
      int frame = PApplet.parseInt(in);
      String sendString = " ";
      if(data[frame] > 0)
      {
        sendString += name;
      }
      else
      {
        sendString += PApplet.parseChar(PApplet.parseInt(name) - ' ');
      }
      sendString += form(frame);
      return sendString;
    }
    else
    {
      return "J";
    }
  }
  
  public String form(int frame) 
  {
    int dataSend = PApplet.parseInt(abs(data[frame] * aMult));
    String stSend = "";
    
    char char1;
    char char2;
    char char3;
    int full = dataSend / ('~');
    switch(full) 
    {
      case 0:
        if (dataSend == 0)
        {
          char1 = '0';
        }
        else
        {
          char1 = PApplet.parseChar(dataSend);
        }
        char2 = '0';
        char3 = '0';
        break;
      case 1:
        char1 = '~';
        if (dataSend == 0)
        {
          char2 = '0';
        }
        else
        {
          char2 = PApplet.parseChar(dataSend - '~');
        }
        char3 = '0';
        break;
      case 2:
        char1 = '~';
        char2 = '~';
        if (dataSend == 0)
        {
          char3 = '0';
        }
        else
        {
          char3 = PApplet.parseChar(dataSend - ('~' * 2));
        };
        break;
      default:
        char1 = '0';
        char2 = '0';
        char3 = '0';
        break;
    }
    stSend += char3;
    stSend += char2;
    stSend += char1;
    
    return stSend;
  }

  public float getData(float a) {
    int i = PApplet.parseInt(a);
    return data[i];
  }
  
  public int getSize() {
    return data.length - 2;
  }
  
  public void delete() {
    data = expand(data,0); 
    dataTime = expand(data,0);
    dataTimeStep = expand(data,0);
  }
}

class XYZ {
  graph x;
  graph y;
  graph z;
  
  int w;
  int h;
  int locX, locY;
  int border;
  
  //keep track time in the loop
  float frame = 0;
  float step = 0;
  
  //initialize the graph container with three graphs inside of it
  XYZ (int iB, int ix, int iy) {
    w = width * 5 / 6;
    h = height;
    border = iB;
    locX = ix;
    locY = iy;
    
    x = new graph(locX, h / 6, w - border, (h - border) / 3, 'x');
    y = new graph(locX, (h * 3) / 6, w - border, (h - border) / 3, 'y');
    z = new graph(locX, (h * 5) / 6, w - border, (h - border) / 3, 'z');
  }
   
  //set the amount of padding around each graph 
  //bare in mind that the border in between graphs will be twice as big
  public void setBorder( int iB) {
    border = iB;
  }
  
  //container of graphs
  public void show () {
    x.display();
    y.display();
    z.display();
    output();
  }
  
  //take in the new data from the controller and augment the time to when the recording started
  public void inputInstant(float ix, float iy, float iz) {
    x.newData(ix);
    y.newData(iy);
    z.newData(iz);
  }
  
  public void playback() {
    if (frame < x.getSize() && frame < y.getSize() && frame < z.getSize()) {
      x.playback(frame);
      y.playback(frame);
      z.playback(frame);
      frame += 2;
    } else {
      frame = 0;
    }
  }
  
  //input the amount of time between frames
  public void timelapse(float in)
  {
   step = 2 / (in * 30);
   if((frame) < x.getSize() && frame < y.getSize() && frame < z.getSize()) {
     x.playback(frame);
     y.playback(frame);
     z.playback(frame);
     frame += step;
   }
   else
   {
     frame = 0;
   }
  }
  
  public String sendFormat()
  {
    String send = " ";
    send += x.sendFormat(frame);
    send += y.sendFormat(frame);
//    send += z.sendFormat();
    println(send);
    return send;
  }
  
  public void output() {
    if(!saved) {
      frame = x.getSize() + 1;
    } 
    ellipse(width * 15 / 16, height / 2, 50 + 20 * x.getData(frame), 50 + 20 * x.getData(frame));
    ellipse(width * 15 / 16, height / 2 + 100, 50 + 20 * y.getData(frame), 50 + 20 * y.getData(frame));
    ellipse(width * 15 / 16, height / 2 + 200, 50 + 20 * z.getData(frame), 50 + 20 * z.getData(frame));
  }
  
  public void delete() {
    x.delete();
    y.delete();
    z.delete();
  }
  
  public int getNumberOfRuns() {
    return x.getSize();
  }
}

class capsule {
  textButton[] states;
  int locX, locY;
  float w, h;
  int padding;
  int spacing;
  String[] menuNames = {"Menu", "Recorder", "Curve Editor", "Setup"};
  char[] clickedName = {'m', 'r', 'c', 's'};

  capsule() {
    states = new textButton[menuNames.length];

    w = width / 8;
    h = height / 3;
    padding = PApplet.parseInt (w / 6);
    spacing = PApplet.parseInt (h / 5);
  }

  public void populate() {
    for (int i = 0; i < menuNames.length; i++)
    {
      states[i] = new textButton(menuNames[i], locX + padding, locY + padding + spacing * (i + 1));
    }
  }
  
  public void fullScreen() {
    populate();
    locX = width  * 2 / 5;
    locY = height / 3 - 50;
    display();
  }


  public void smallScreen() {
    populate();
    locX = width * 6 / 7;
    locY = 50;
    display();
  }

  public void display() {
    setAlpha();
    rect(locX, locY, w, h);
    for (int i = 0; i < states.length; i++) {
      states[i].show();
    }
  }

  public boolean hover () {
    if (mouseX > locX && mouseX < locX + w && mouseY > locY && mouseY  < locY + h) {
      return true;
    } else {
      return false;
    }
  }

  public void setAlpha() {
    if (hover()) {
      stroke(0, 0, 0, 255);
      fill(125, 125, 125, 255);
    } else {
      stroke(0, 0, 0, 0);
      fill(0, 0, 0, 0);
    }
  }

  public void setPadding(int ip) {
    padding = ip;
  }

  public void clicked() {
    for ( int i = 0; i < menuNames.length; i++) {
      if(states[i].clicked())
      {
        state = clickedName[i];
      }
    }
  }
}

//--------------------------MENU CLASS DEFINITIONS-------------------------------//

//create a menu item with a statement and ability to toggle
class textButton {
  String statement;
  
  int locX;
  int locY;
  float w;
  float h;
  int size;
  Boolean toggled = false;
  
  int OFFSET = 5;
  
  //initialize the botton with the device name and location on the screen
  textButton(String name, int x, int y)
  {
    textSize(25);
    statement = name;
    locX = x;
    locY = y;
    
    //assign the width and height of the background boxes to the width of the menu text
    w = textWidth(statement);
    h = textWidth("T") * 1.5f;
  }
  
  //check if the mouse is hovering over the menu item
  public boolean hover()
  {
    if ((mouseX < (locX + w) && mouseX > locX) && (mouseY < (locY + OFFSET) && mouseY > (locY - h + OFFSET))) {
      return true;
    } else {
      return false;
    }
  }
  
  //display the menu item
  public void show()
  {
    if (hover() || toggled) {
      fill(155);
    } else {
      fill(0);
    }
    stroke(0);
    rect(locX, locY - h + OFFSET, w, h);
    fill(255);
    text(statement, locX, locY);
  }
  
  //check if the the mouse has clicked the menu item
  public boolean clicked()
  {
    if (mousePressed)
    {
      if(hover()) 
      {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
  
  public void setToggled() 
  {
    if (toggled)
    {
      toggled = false;
    }
    else
    {
      toggled = true;
    }
  }
}
class time {
  float progTime;
  float stopTime;
  float pauseTime;
  float resumeTime;
  float playTime;
  float totalStop;
  
  float lastStep;
  float stepSize;
  
  boolean paused;
  
  //initialize the time so that the progTime (program time) will return same as millis()
  time() {
    totalStop = 0;
    lastStep = 0;
    stopTime = 0;
    paused = false;
  }
  
  //reinitialize the time object so that the same actions can be repeated with no bugs.
  public void reInitialize() {
    lastStep = 0;
    stopTime = 0;
    paused = false;
    restart();
  }
  
  /*  get the current program time if the window has not been paused and if the window has
  *   has been paused then return the time at which the time was paused to be printed to
  *   the screen
  */
  public float getTime() {
    if ( !paused) {
      return progTime;
    } else {
      return pauseTime;
    }
  }
  
  //easy class method to return the time that program has been running
  public float time () {
    return millis();
  }
  
  //calculate the amount of time from one frame to the next for use with data aquisition
  public void calcStepSize() {
    float time = time();
    stepSize = time - lastStep;
    lastStep = time;
  }
  
  //return the most resent frame's step size
  public float getStepSize() {
    return stepSize;
  }
  
  //return the minutes of progTime in int form (NO DECIMALS!)
  public int getMinute () {
    int minute = PApplet.parseInt(getTime() / (1000 * 60)) % 60;
    return minute;    
  }
  
  //return the seconds of progTime in int form (NO DECIMALS!)
  public int getSecond () {
    int second = PApplet.parseInt(getTime() / 1000) % 60;
    return second;
  }
  
  //return the milliseconds of progTime in int form.
  public int getMilli() {
    return PApplet.parseInt(getTime() % 1000);
  }
  
  //calculate all the required changes to the time object relative to the last call
  public void setTime() {
    calcTime();
    calcStepSize();
  }
  
  //set total stoppage time equal to the time the program has been running ultimately 
  //making progTime = 0
  public void restart() {
    totalStop = time();
  }
  
  //set the clock to paused so progTime returned is the same while paused and set 
  //pause time to current progTime
  public void pause() {
    stopTime = time();
    pauseTime = getTime();
    paused = true;
  }
  
  //set the clock back to resumed so that the time returned is the correct progTime 
  //and calc progTime with the totalStop
  public void resume() {
    resumeTime = time();
    calcTotalStop();
    paused = false;
  }
  
  public void calcTime() {
    progTime = time() - totalStop;
  }
  
  public void calcTotalStop() {
    totalStop += (resumeTime - stopTime);
  }
  
  public void display(int x, int y) {
    fill(0);
    textSize(40);
    text(getMinute() + ":" + getSecond(), x, y);
    textSize(25);
    text(getMilli(), x + 75, y - 10);
    fill(255);
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Controller" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
