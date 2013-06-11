class time {
  float progTime;
  float stopTime;
  float globalTime;
  float resumeTime;
  float playTime;
  float totalStop;
  
  float lastStep;
  float stepSize;
  
  time() {
    totalStop = 0;
    lastStep = 0;
  }
  
  float getTime() {
    return progTime;
  }
  
  float time () {
    return millis();
  }
  
  void calcStepSize() {
    float time = time();
    stepSize = time - lastStep;
    lastStep = time;
  }
  float getStepSize() {
    return stepSize;
  }
  
  void setTime() {
    calcTime();
    calcStepSize();
  }
  
  void start() {
    totalStop = time();
  }
  
  void pause() {
    stopTime = time();
  }
  
  void resume() {
    resumeTime = time();
    calcTotalStop();
  }
  
  void calcTime() {
    progTime = time() - totalStop;
  }
  
  void calcTotalStop() {
    totalStop += (resumeTime - stopTime);
  }
}
