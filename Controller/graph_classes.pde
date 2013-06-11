//---------------------------GRAPH CLASS DEFINITIONS------------------------//

class graph {
  int globalX, globalY;
  float offsetX, offsetY;
  float w, h;
  float[] data = {};
  float[] dataTime = {};
  float[] dataTimeStep = {};
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
    timeMap();
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
  
  void playback(int i) {
    strokeWeight(5);
    stroke(0, 150, 0);
    line(scaleW * dataTime[0 + i] + offsetX, scaleH + offsetY,scaleW * dataTime[i] + offsetX,-scaleH + offsetY);
  }

  float getData(int i) {
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
  int frame = 0;
  
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
  
  void output() {
    int counter;
    if(!saved) {
      frame = x.getSize() + 1;
    } 
    ellipse(100,100,50 + 40 * x.getData(frame),50 + 40 * x.getData(frame));
    ellipse(200,100,50 + 40 * y.getData(frame),50 + 40 * y.getData(frame));
    ellipse(300,100,50 + 40 * z.getData(frame),50 + 40 * z.getData(frame));
    println(frame);
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
