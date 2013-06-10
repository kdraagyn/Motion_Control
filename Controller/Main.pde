//---------------------------MAIN PROCESSING LOOPS-----------------------------//
void setup(){
  size(int(displayWidth * displayMult),int(displayHeight  * displayMult), OPENGL);
  
  //initialize the procontroll I/O to find devices
  controll = ControllIO.getInstance(this);
  numberDevices = controll.getNumberOfDevices();
  
  //initialize the menu array to the size of the number of devices
  textButton[] button = new textButton[controll.getNumberOfDevices()];
  menu = button;                                                        //save this to the 'menu' object
  
  //load fonts and set the font for text outputs
  disFont = loadFont("BodoniMT-24.vlw");
  textFont(disFont);
  
  //initialize the graphs container (padding, locX, locY)
  graphSect = new XYZ(100, width / 2, height - 20);
}

void draw()
{
  if (!picked) {
    devicesMenu();
  } else {
    if (!saved) {
      read();
      time = (millis() - clickTime - runningClearTime) / 1000;
    } else {
      play();
    }
  }
}

//-------------------------DEVICE INITIALIZATION-------------------------//
void initializeDevice() {
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
  
  //document the time that recording starts
  clickTime = millis();
}

//--------------------------DEVICE READ---------------------------------//

void read() {
  if (!initialized) {
      initializeDevice();
    }
    if (!stopped) {
    //get values from the controller
    graphSect.inputInstant(s1x.getValue(),s2y.getValue(),s3z.getValue());
    
    //display everything on the window
    HUD();
    }
    
    //toggle the pause button
    if (buttons[4].getValue() == 8 && stopped == false) {
      stopped = true;
      pauseTime = millis();
    } 
    
    //resume
    if (buttons[3].getValue() == 8 && stopped == true) {
      stopped = false;
      runningClearTime += millis() - pauseTime;
    }
    
    //save
    if (buttons[9].getValue() == 8 && stopped == true) {
      saved = true;
    }
  for (int i = 0; i < 16; i++) {
    float value = buttons[i].getValue();
    print("  " + i + ": " + value);
  }
  println("");
}

void play() {
  graphSect.playback();
  if (buttons[10].getValue() == 8 && saved == true) {
      println("delete");
      initialized = false;
      stopped = false;
      saved = false;
      graphSect.delete();
    }
}
