//------------------------------DISPLAY FUNCTIONS----------------------------//

//display the menu with all the devices connected to the computer
void devicesMenu() {
  fill(0);
  
  //title of the menu
  text("Choose the correct controller to use", width / 3, (height / 3) - SPACING);
       
  for(int i = 0; i < numberDevices; i++) {
    device = controll.getDevice(i);
    
    text(device.getName(), width / 3 , (height / 3) + SPACING * i);
    menu[i] = new textButton(device.getName(), width / 3 , (height / 3) + SPACING * i);
    menu[i].show();
    if(menu[i].clicked())
    {
      deviceN = i;
      picked = true;
      break;
    }
  }
}

void HUD () {
  background(50);
  
  //display the graph's contatiner and subsequently the graphs as well
  graphSect.show();    
}


