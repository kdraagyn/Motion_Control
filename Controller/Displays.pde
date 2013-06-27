//------------------------------DISPLAY FUNCTIONS----------------------------//

//display the menu with all the devices connected to the computer
void devicesMenu() {
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

void HUD () {
  if (!stopped) {
    //get values from the controller
    instance();
  }
  //draw the graphs to the screen
  graphSect.show();
  
  //send command to arduino
  serialOut.write(graphSect.sendFormat());
    
  clock.display(width * 9 / 10, height * 9 / 10);
}

void curves() {
  statesMenu.smallScreen();
  statesMenu.clicked();
  clock.display( width * 9 / 10, height * 9 / 10);
}

void menu() {
  statesMenu.fullScreen();
  statesMenu.clicked();
}

void portsSetup() 
{
  statesMenu.smallScreen();
  statesMenu.clicked();
  fill(0);
  text("Click the arduino's COM port", width * 2 / 5, height / 2 - 80);
  int p = 0;
  
  String[] list = Serial.list();
  for (int i = 0; i < list.length; i++) {
    p++;
    text(list[i], width / 3, (height / 3) + SPACING * p);
    ports[i] = new textButton(list[i], width / 3, (height / 3) + SPACING * p);
    ports[i].show();
    if (ports[i].clicked() && connected == false) {
      serialOut = new Serial(this, Serial.list()[i], 115200);
      connected = true;
      break;
    }
  }
}
