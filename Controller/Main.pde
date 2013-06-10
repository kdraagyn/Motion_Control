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
    if (!initialized) {
      initializeDevice();
    }
    
    //get values from the controller
    graphSect.inputInstant(s1x.getValue(),s2y.getValue(),s3z.getValue());
    
    //display everything on the window
    HUD();
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
  
  //document the time that recording starts
  clickTime = millis();
}
