import procontroll.*;
import java.io.*;

class textButton {
  
  String statement;
  PFont font;
  
  int locX;
  int locY;
  int w;
  int h;
  int size;
  
  private int OFFSET = 5;
  
  textButton(String name, int x, int y)
  {
    statement = name;
    locX = x;
    locY = y;
    font = loadFont("BodoniMT-24.vlw");
    w = int(textWidth(name));
    h = int(textWidth("T") * 1.5);
  }
  
  boolean hover()
  {
    if ((mouseX < (locX + w) && mouseX > locX) && (mouseY < (locY) && mouseY > (locY - h + OFFSET))) {
      return true;
    } else {
      return false;
    }
  }
  
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
}
