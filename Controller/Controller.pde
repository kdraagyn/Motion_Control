import procontroll.*;
import java.io.*;
import processing.opengl.*;

ControllCoolieHat analogStick;
ControllIO controll;
ControllDevice device;

float X1;
float Y1;

static int SPACING = 50;
static float displayMult = .75;

PFont disFont;

void setup(){
  size(int(displayWidth * displayMult),int(displayHeight  * displayMult), OPENGL);
  
  X1 = width / 2;
  Y1 = height / 2;
  
  controll = ControllIO.getInstance(this);
  
  disFont = loadFont("BodoniMT-24.vlw");
  textFont(disFont);
}

void draw()
{
  devices('d');
}

void devices(char type) {
  fill(0);
  text("Choose the correct controller to use", width / 3, (height / 3) - SPACING);
       
  for(int i = 0; i < controll.getNumberOfDevices(); i++){
    textButton[] button = new textButton[controll.getNumberOfDevices()];
    ControllDevice tempDevice = controll.getDevice(i);
    
    button[i] = new textButton(tempDevice.getName(), width / 3 , (height / 3) + SPACING * i);
    button[i].show();
  }
}
