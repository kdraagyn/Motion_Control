class time {
  float progTime;
  float stopTime;
  float pauseTime;
  float resumeTime;
  float playTime;
  float totalStop;
  
  float lastStep;
  float stepSize;
  
  boolean paused;
  
  //initialize the time so that the progTime (program time) will return same as millis()
  time() {
    totalStop = 0;
    lastStep = 0;
    stopTime = 0;
    paused = false;
  }
  
  //reinitialize the time object so that the same actions can be repeated with no bugs.
  void reInitialize() {
    lastStep = 0;
    stopTime = 0;
    paused = false;
    restart();
  }
  
  /*  get the current program time if the window has not been paused and if the window has
  *   has been paused then return the time at which the time was paused to be printed to
  *   the screen
  */
  float getTime() {
    if ( !paused) {
      return progTime;
    } else {
      return pauseTime;
    }
  }
  
  //easy class method to return the time that program has been running
  float time () {
    return millis();
  }
  
  //calculate the amount of time from one frame to the next for use with data aquisition
  void calcStepSize() {
    float time = time();
    stepSize = time - lastStep;
    lastStep = time;
  }
  
  //return the most resent frame's step size
  float getStepSize() {
    return stepSize;
  }
  
  //return the minutes of progTime in int form (NO DECIMALS!)
  int getMinute () {
    int minute = int(getTime() / (1000 * 60)) % 60;
    return minute;    
  }
  
  //return the seconds of progTime in int form (NO DECIMALS!)
  int getSecond () {
    int second = int(getTime() / 1000) % 60;
    return second;
  }
  
  //return the milliseconds of progTime in int form.
  int getMilli() {
    return int(getTime() % 1000);
  }
  
  //calculate all the required changes to the time object relative to the last call
  void setTime() {
    calcTime();
    calcStepSize();
  }
  
  //set total stoppage time equal to the time the program has been running ultimately 
  //making progTime = 0
  void restart() {
    totalStop = time();
  }
  
  //set the clock to paused so progTime returned is the same while paused and set 
  //pause time to current progTime
  void pause() {
    stopTime = time();
    pauseTime = getTime();
    paused = true;
  }
  
  //set the clock back to resumed so that the time returned is the correct progTime 
  //and calc progTime with the totalStop
  void resume() {
    resumeTime = time();
    calcTotalStop();
    paused = false;
  }
  
  void calcTime() {
    progTime = time() - totalStop;
  }
  
  void calcTotalStop() {
    totalStop += (resumeTime - stopTime);
  }
  
  void display(int x, int y) {
    fill(0);
    textSize(40);
    text(getMinute() + ":" + getSecond(), x, y);
    textSize(25);
    text(getMilli(), x + 75, y - 10);
    fill(255);
  }
}
