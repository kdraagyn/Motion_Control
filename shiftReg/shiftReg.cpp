/*
	shiftReg.cpp - Library to greater control and impliment a shift register into a project.
	Created by Keith Nygaard, June 25, 2013.
	Released into the public domain.
*/

#include "Arduino.h"
#include "shiftReg.h"

/*
	Constructor to initialize the shift register that is used. All arguments that are passed are the pins that are connected to the arduino;
*/
shiftReg::shiftReg(int latch, int data, int clock) 
{
	latchPin = latch;
	dataPin = data;
	clockPin = clock;
	pinMode(latchPin, OUTPUT);
	pinMode(dataPin, OUTPUT);
	pinMode(clockPin, OUTPUT);
	clear();
}

//This will treat the incoming byte will be put to the first digits of the shift byte sequence
 void shiftReg::import(byte in, int set)
{
 	 clear();
	 switch(set)
	 {
	 	 case 1:
	 		send += in;
	 		break;
	 	 case 2:
	 		send = in;
	 		send <<= 4;
	 		break;
	 	 default:
	 		break;
	 }
}
 
 /*
  * Wrtie the send byte sequence to the shift register pins. This method
  * includes the begin and end methods internally so no need to worry about
  * the latch sequences in the main code.
  */
 void shiftReg::write(void)
 {
	 begin();
	 //shift the data to shift register IC, not sure what MSBFIRST means other
	 //than the direction of the pins
	 shiftOut(dataPin,clockPin,MSBFIRST,send);
	 end();
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
	 send = B00000000;
	 write();
 }
