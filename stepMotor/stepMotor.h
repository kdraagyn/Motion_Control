/* 
	stepMotor - A stepper class outside of the normal class given in arduino to allow for greater control of the 
		stepper motor;
	Created by Keith Nygaard, June 6, 2013
	Released into the public domain.
*/

#ifndef stepMotor_h
#define stepMotor_h

#include "Arduino.h"

class stepMotor 
{
  public:
    stepMotor(int stepsPR, int a, int b, int c, int d);
    void setSpeed (long);
    void setPhase(int);
	unsigned long getDelay(void);
	void stepTime(unsigned long,unsigned long);
	void step(void);
	long getSpeed(void);

	
  private:
    unsigned long lastStepTime;
	int pin1,pin2,pin3,pin4;
    unsigned long SPR;
    unsigned long timeDelay;
	long speed;
	boolean dir;	//true for CW and false for CCW
	long position;
	int phase;
};

#endif
  
