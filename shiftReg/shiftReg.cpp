/*
	shiftReg.cpp - Library to greater control and impliment a shift register into a project.
	Created by Keith Nygaard, June 25, 2013.
	Released into the public domain.
*/

#include "Arduino.h"
#include "shiftReg.h"

/*
	Constructor to initialize the shift register that is used. All arguments that are passed
	are the pins that are connected to the arduino. This constructor is assuming a standard
	8 bit register shifter like the SN74HC595N.
*/
shiftReg::shiftReg(int latch, int data, int clock) 
{
	latchPin = latch;
	dataPin = data;
	clockPin = clock;
	pinSize = 8;
	pinMode(latchPin, OUTPUT);
	pinMode(dataPin, OUTPUT);
	pinMode(clockPin, OUTPUT);
	clear();
}

shiftReg::shiftReg(int latch, int data, int clock, int _pinSize)
{
	latchPin = latch;
	dataPin = data;
	clockPin = clock;
	pinSize = _pinSize;
	pinMode(latchPin, OUTPUT);
	pinMode(dataPin, OUTPUT);
	pinMode(clockPin, OUTPUT);
	clear();
}

//This will treat the incoming byte will be put to the first digits of the shift byte sequence
 void shiftReg::import(void)
{
	 for(int i = 0; i < pinSize; i++)
	 {
		 Serial.print(pinState[i]);
		 Serial.print(" ");

		 pinState[i] <<= i;
		 send += byte(pinState[i]);
	 }
}
 
 /*
  * Wrtie the send byte sequence to the shift register pins. This method
  * includes the begin and end methods internally so no need to worry about
  * the latch sequences in the main code.
  */
 void shiftReg::write(void)
 {
	 import();	//convert the pinState array to the send byte.
	 begin();	//pull latcher pin HIGH to be ready to load in values

	 //shift the data to shift register IC, not sure what MSBFIRST means other
	 //than the direction of the pins
	 shiftOut(dataPin,clockPin,MSBFIRST,send);

	 end();		//pull latcher pin LOW to display values
	 clear();	//set send to B00000000 so that we dont get any counting values
 }
 
 byte shiftReg::getSendByte(void)
 {
	 return send;
 }
 
 /*
  * Sets the latchPin low so that the pins on the shift register can be set
  * through other methods.
  */
 void shiftReg::begin(void)
 {
	 digitalWrite(latchPin,HIGH);
 }
 
 /*
  * Sets the latchPin high so data is no longer being trasferred and the pins
  * can output the correct values to the motor.
  */
 void shiftReg::end(void)
 {
	 digitalWrite(latchPin,LOW);
 }

 void shiftReg::clear(void)
 {
	 for(int i = 0; i < pinSize; i++)
	 {
		 pinState[i] = 0;
	 }
	 send = B00000000;
 }

/*
 * Write a the pin state of a designated pin on the register shifter. This is meant to be as easy
 * to use as the arduino 'digitalWrite(int,int)' method in the Arduino API.
 */
 void shiftReg::pinWrite(int _pin, int state)
 {
	 if(_pin <= pinSize)
	 {
		 if(state == HIGH)
		 {
			 state = 1;
		 }
		 else if (state == LOW)
		 {
			 state = 0;
		 }
		 pinState[_pin - 1] = byte(state);
	 }
 }

 /*
  * Imports an input byte into the correct location in the pinState array to be built in
  * the import method. _send is the input byte of varying length and startPin is the lowest pin
  * that is being edited.
  */
 void shiftReg::multiPinWrite(byte _send, int startPin, int size)
 {
	 size--;
	 for (int i = 0; i < size; i++)
	 {
		 //first digit cannot be shifted or else it will be lost
		 if (i > 0)
		 {
			 _send >>= 1;
		 }
		 pinWrite(i + startPin, int(_send) % 2);
	 }
	 //outside so because remainder by 2 of 1 is 0
	 _send >>= 1;	//still needs to be bitshifted once though
	 pinWrite(size + startPin, int(_send));
 }
