/*
	Class header file for an A3988 stepper driver or any similar stepper motor driver with the 
	ability to take a step given a pulse of 'step' pin and an input for a direction pin. This is 
	a pretty straightforward class definition because of the amount of control already given by the
	A3988.
	Author: Keith Nygaard
	Edit Date: 8/2/13
	Released into the public domain.
*/

#ifndef A3988_h
#define A3988_h

#include "Arduino.h"

class A3988
{
public:
	A3988(int, int);
	void setDirection(int);
	void setDirection(String);
	String getDirection();
	int step();


private:
	int _stepPin;
	int _dirPin;
};

#endif