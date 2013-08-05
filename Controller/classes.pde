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
  void display () {
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
  void timeMap () {
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
  
  void newData (float newD) {
    
    //add another array value to the data array
    data = append(data, newD);
    
    //set the program time of the data point
    dataTime = append(dataTime, clock.getTime());
    
    //setThe step time from the last point
    dataTimeStep = append(dataTimeStep, clock.getStepSize());
  }
  
  void playback(float a) {
    int i = int(a);
    strokeWeight(5);
    stroke(0, 150, 0);
    line(scaleW * dataTime[0 + i] + offsetX, scaleH + offsetY, scaleW * dataTime[i] + offsetX, -scaleH + offsetY);
    strokeWeight(1);
  }
  
  String sendFormat(float in) 
  {
    if( in % 1 == 0) 
    {
      int frame = int(in);
      String sendString = " ";
      if(data[frame] > 0)
      {
        sendString += name;
      }
      else
      {
        sendString += char(int(name) - ' ');
      }
      sendString += form(frame);
      return sendString;
    }
    else
    {
      return "J";
    }
  }
  
  String form(int frame) 
  {
    int dataSend = int(abs(data[frame] * aMult));
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
          char1 = char(dataSend);
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
          char2 = char(dataSend - '~');
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
          char3 = char(dataSend - ('~' * 2));
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

  float getData(float a) {
    int i = int(a);
    return data[i];
  }
  
  int getSize() {
    return data.length - 2;
  }
  
  void delete() {
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
  void setBorder( int iB) {
    border = iB;
  }
  
  //container of graphs
  void show () {
    x.display();
    y.display();
    z.display();
    output();
  }
  
  //take in the new data from the controller and augment the time to when the recording started
  void inputInstant(float ix, float iy, float iz) {
    x.newData(ix);
    y.newData(iy);
    z.newData(iz);
  }
  
  void playback() {
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
  void timelapse(float in)
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
  
  String sendFormat()
  {
    String send = " ";
    send += x.sendFormat(frame);
    send += y.sendFormat(frame);
//    send += z.sendFormat();
    println(send);
    return send;
  }
  
  void output() {
    if(!saved) {
      frame = x.getSize() + 1;
    } 
    ellipse(width * 15 / 16, height / 2, 50 + 20 * x.getData(frame), 50 + 20 * x.getData(frame));
    ellipse(width * 15 / 16, height / 2 + 100, 50 + 20 * y.getData(frame), 50 + 20 * y.getData(frame));
    ellipse(width * 15 / 16, height / 2 + 200, 50 + 20 * z.getData(frame), 50 + 20 * z.getData(frame));
  }
  
  void delete() {
    x.delete();
    y.delete();
    z.delete();
  }
  
  int getNumberOfRuns() {
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
    padding = int (w / 6);
    spacing = int (h / 5);
  }

  void populate() {
    for (int i = 0; i < menuNames.length; i++)
    {
      states[i] = new textButton(menuNames[i], locX + padding, locY + padding + spacing * (i + 1));
    }
  }
  
  void fullScreen() {
    populate();
    locX = width  * 2 / 5;
    locY = height / 3 - 50;
    display();
  }


  void smallScreen() {
    populate();
    locX = width * 6 / 7;
    locY = 50;
    display();
  }

  void display() {
    setAlpha();
    rect(locX, locY, w, h);
    for (int i = 0; i < states.length; i++) {
      states[i].show();
    }
  }

  boolean hover () {
    if (mouseX > locX && mouseX < locX + w && mouseY > locY && mouseY  < locY + h) {
      return true;
    } else {
      return false;
    }
  }

  void setAlpha() {
    if (hover()) {
      stroke(0, 0, 0, 255);
      fill(125, 125, 125, 255);
    } else {
      stroke(0, 0, 0, 0);
      fill(0, 0, 0, 0);
    }
  }

  void setPadding(int ip) {
    padding = ip;
  }

  void clicked() {
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
    h = textWidth("T") * 1.5;
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
  
  void setToggled() 
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
