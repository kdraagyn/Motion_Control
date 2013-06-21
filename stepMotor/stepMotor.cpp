/*
	stepMotor.cpp - Library for greater control of a stepper motor.
	Created by Keith Nygaard, June 6, 2013.
	Released into the public domain.
*/
#include "Arduino.h"
#include "stepMotor.h"

stepMotor::stepMotor (int stepsPR, int a, int b, int c, int d) 
{
	pin1 = a;
	pin2 = b;
	pin3 = c;
	pin4 = d;
	pinMode(pin1,OUTPUT);
	pinMode(pin2,OUTPUT);
	pinMode(pin3,OUTPUT);
	pinMode(pin4,OUTPUT);
	SPR = stepsPR;
	lastStepTime = 0;
	phase = 1;
	setPhase(phase);
}
/*
	Set the speed of the motor and depending on the sign of the input set the direction
	of the motor. The time step is in microSeconds
*/
void stepMotor::setSpeed (long inSpeed) 
{	
	speed = inSpeed;
	if(inSpeed != 0)
	{
		if(inSpeed >= 0) 
		{
			this->timeDelay = 60L * 1000L * 1000L / this->SPR / inSpeed;
			dir = true;
		} 
		else 
		{
			this->timeDelay = 60L * 1000L * 1000L / this->SPR / ( -inSpeed);
			dir = false;
		}
	}
	else
	{
		timeDelay = -1;
	}
}
/*
	Switch statement to help fine tune the specific step sequence to be used. 
	The idea is to allow for greater flexability of the motor stepper sequence.
*/
void stepMotor::setPhase(int a) 
{
	switch(a) 
	{
		case 1:
			digitalWrite(pin1,HIGH);
			digitalWrite(pin2,LOW);
			digitalWrite(pin3,HIGH);
			digitalWrite(pin4,LOW);
			break;
		
		case 2:
			digitalWrite(pin1,LOW);
			digitalWrite(pin2,HIGH);
			digitalWrite(pin3,HIGH);
			digitalWrite(pin4,LOW);
			break;
		
		case 3:
			digitalWrite(pin1,LOW);
			digitalWrite(pin2,HIGH);
			digitalWrite(pin3,LOW);
			digitalWrite(pin4,HIGH);
			break;
		
		case 4:
			digitalWrite(pin1,HIGH);
			digitalWrite(pin2,LOW);
			digitalWrite(pin3,LOW);
			digitalWrite(pin4,HIGH);
			break;
		
		default:
			digitalWrite(pin1,LOW);
			digitalWrite(pin2,LOW);
			digitalWrite(pin3,LOW);
			digitalWrite(pin4,LOW);
			break;
	}

}
  
void stepMotor::step(long time)
{
	if(time == -1) 
	{
		time = micros();
	}
	if (timeDelay == -1)
	{
		setPhase(0);
	}
	else
	{
		if(time >= (lastStepTime + timeDelay))
		{
			if (dir) 
			{
				if(phase == 4) 
				{
					phase = 1;
				}
				else
				{
					phase++;
				}
			}
			else
			{
				if(phase == 1) 
				{
					phase = 4;
				}
				else
				{
					phase--;
				}
			}
			setPhase(phase);
			lastStepTime = time;
		}
	}
}

unsigned long stepMotor::getDelay(void) 
{
	return timeDelay;
}

long stepMotor::getSpeed(void) 
{
	return speed;
}
