/*
	stepMotor.cpp - Library for greater control of a stepper motor.
	Created by Keith Nygaard, June 6, 2013.
	Released into the public domain.
*/

#include "Arduino.h"
#include "stepMotor.h"

//constructor where all motor controlling pins are connected to arduino
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
	shiftRegister = false;
}

//constructor where motor is connected to shift register and then to arduino
stepMotor::stepMotor (int stepsPR)
{
	phase = 1;
	lastStepTime = 0;
	SPR = stepsPR;
	shiftRegister = true;
}

/*
*	Constructor for a stepper motor connected to a stepper motor driver. 
*	The arguments are the number of steps per revalution, the pin on driver that
*	controls direction, and the pin on driver that controls the step.
*/
stepMotor::stepMotor(int stepsPR, int dirPin, int stepPin)
{
	SPR = stepsPR;
	_dirPin = dirPin;
	_stepPin = stepPin;
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

	This would be with no register shifter connected.
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

/*
 * Returns the step Byte sequence for the shift register. This would be an
 * input to the shift register methods.
 */
byte stepMotor::bytePhase(int a)
{
	switch(a)
	{
		case 1:
			return B1010;
			break;
		
		case 2:
			return B0110;
			break;
		
		case 3:
			return B0101;
			break;
		
		case 4:
			return B1001;
			break;
			
		default:
			return B0000;
			break;
	}
}
  
/*
 * Steps through the step sequence. If the time interval given in the input
 * is greater than the time delay for the motor's speed than the phase is set 
 * to the next phase configuration.
 */
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
			if (!shiftRegister)
			{
				setPhase(phase);				
			}
			lastStepTime = time;
		}
	}
}

/*
*	Step the stepper motor connected through a stepper motor driver.
*	This has the same effect as step except phase not a parameter.
*/
void stepMotor::stepDriver()
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
			if(dir)
			{
				digitalWrite(_dirPin,HIGH);
			}
			else
			{
				digitalWrite(_dirPin,LOW);
			}
			digitalWrite(_stepPin,HIGH);
		}
	}
}

//Set the direction of the motor. True for CW and false for CCW
void stepMotor::setDirection(boolean direct)
{
	dir = direct;
}

/*
 * 	Returns the step motor Byte sequence instead of setting the pins.
 * 	Inputs of time just like the step() and impliments timing the exact same
 * 	as in step().
 */
byte stepMotor::stepByte(long time)
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
			lastStepTime = time;
		}
		return bytePhase(phase);
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
