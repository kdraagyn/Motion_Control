//---------------------------GRAPH CLASS DEFINITIONS------------------------//

class graph {
  int globalX, globalY;
  float offsetX, offsetY;
  float w, h;
  float[] data = {};
  float[] dataTime = {};
  float scaleW, scaleH;
  int l;
  
  // initialize graphs (locX, locY, width, height)
  graph(int ix, int iy, int iw, int ih) {
    globalX = ix;
    globalY = iy;
    
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
    strokeWeight(1);
    timeMap();
  }

  //map the time to the width of the graph window
  //display the data lines over the graph window
  void timeMap () {
    scaleW = w / time;
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
    
    //set the time of add
    dataTime = append(dataTime, time);
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
  
  //initialize the graph container with three graphs inside of it
  XYZ (int iB, int ix, int iy) {
    w = width;
    h = height;
    border = iB;
    locX = ix;
    locY = iy;
    
    x = new graph(locX, h / 6, w - border, (h - border) / 3);
    y = new graph(locX, (h * 3) / 6, w - border, (h - border) / 3);
    z = new graph(locX, (h * 5) / 6, w - border, (h - border) / 3);
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
  }
  
  //take in the new data from the controller and augment the time to when the recording started
  void inputInstant(float ix, float iy, float iz) {
    time = (millis() - clickTime) / 1000;
    x.newData(ix);
    y.newData(iy);
    z.newData(iz);
  }
}
