/* 
	Arduino driver to control an A3988 stepper driver at different speeds and different directions. 
	Author:Keith Nygaard
	Edit Date:8/2/13
	Released into the public domain
*/

#include "Arduino.h"
#include "A3988.h"

/*
	Constructor to create an A3988 object. This takes two arguments, the step pin on the arduino that will pulled
	high or low for a given step and the direction pin that is pulled high for one direction and low for the 
	opposite. This will also set the designated pins on the arduino to OUTPUT.
*/
A3988:A3988 (int dirPin, int stepPin) 
{
	_dirPin = dirPin;
	_stepPin = stepPin;
	pinMode(_dirPin, OUTPUT);
	pinMode(_stepPin, OUTPUT);
}

/*
	If the direction argument is 1 then the direction will be set to CCW and vice vursa.
*/
void A3988::setDirection(int dir) 
{
	if(int == 1)
	{
		digitalWrite(_dirPin,HIGH);
	} 
	else 
	{
		digitalWrite(_dirPin,LOW);
	}
}