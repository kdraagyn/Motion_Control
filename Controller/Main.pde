//---------------------------MAIN PROCESSING LOOPS-----------------------------//


void setup(){
  //set frame rate and size of window
  frameRate(100);
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
  
  //time class to make timing all windows and playback easier
  clock = new time();
}

void draw()
{
  switch (state) {
    case 'R':
      
      //set the window to the record window.
      record();
      break;
    case 'C':
    
      //set the window to the curve editor
      curves();
      break;
    default:
    
      //show the menu to set the state.
      menu();
      break;
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
}

//--------------------------DEVICE READ---------------------------------//

void read() {
  if (!initialized) {
      initializeDevice();
  } else {
    
    //display everything on the window
    HUD();
    
    if (!stopped) {
      //get values from the controller
      instance();
    }
      
    println(stopped);
    //toggle the pause button
    //toggle button on my snakeByte controller is square.
    if (buttons[4].getValue() == 8 && stopped == false) {
      stopped = true;
      clock.pause();
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
    }
    
    fill(0);
    for (int i = 0; i < 16; i++) {
      float value = buttons[i].getValue();
      text("  " + i + ": " + value, width / 10 + 75 * i, height - 100);
    }
  }
}

void play() {
  HUD();
  graphSect.playback();
  
  //reset
  //reset button on my snakeByte controller is 'START'
  if (buttons[10].getValue() == 8 && saved == true) {
      println("delete");
      initialized = false;
      stopped = false;
      saved = false;
      graphSect.delete();
    }
}

void record() {
  clock.setTime();
  background(100);
  if (!picked) {
    devicesMenu();
  } else {
    if (!saved) {
      if ( graphSect.getNumberOfRuns() == 0) {
        clock.start();
      }
      read();
    } else {
      clock.start();
      play();
    }
  }
}

void instance() {
    graphSect.inputInstant(s1x.getValue(),s2y.getValue(),s3z.getValue());
}


