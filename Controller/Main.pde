//---------------------------MAIN PROCESSING LOOPS-----------------------------//
void setup() 
{
  //set frame rate and size of window
  frameRate(100);
  size(int(displayWidth * displayMult), int(displayHeight  * displayMult), OPENGL);

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
  graphSect = new XYZ(100, (width - width / 8) / 2, height - 20);

  //time class to make timing all windows and playback easier
  clock = new time();

  //create state menu on the side of the screen
  statesMenu = new capsule();
}

void draw()
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

    //default the menu to full screen.
  default:
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
    
    //check to toggle the pause button
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
    clock.restart();
  }
}

void record() {
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

void instance() {
  graphSect.inputInstant(s1x.getValue(), s2y.getValue(), s3z.getValue());
}

