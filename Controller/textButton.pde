//--------------------------MENU CLASS DEFINITIONS-------------------------------//

//create a menu item with a statement and ability to toggle
class textButton {
  String statement;
  
  int locX;
  int locY;
  int w;
  int h;
  int size;
  
  int OFFSET = 5;
  
  //initialize the botton with the device name and location on the screen
  textButton(String name, int x, int y)
  {
    statement = name;
    locX = x;
    locY = y;
    
    //assign the width and height of the background boxes to the width of the menu text
    w = int(textWidth(statement));
    h = int(textWidth("T") * 1.5);
  }
  
  //check if the mouse is hovering over the menu item
  boolean hover()
  {
    if ((mouseX < (locX + w) && mouseX > locX) && (mouseY < (locY + OFFSET) && mouseY > (locY - h + OFFSET))) {
      return true;
    } else {
      return false;
    }
  }
  
  //display the menu item
  void show()
  {
    if (hover()) {
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
  boolean clicked()
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
}
