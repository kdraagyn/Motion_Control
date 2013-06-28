/*
	shiftReg - A shift register class to allow for greater control of the shifter if more than one component is connected to the IC.
	Created by Keith Nygaard, June 25, 2013
	Realeased into the public domain.
*/

#ifndef shiftReg_h
#define shiftReg_h

#include "Arduino.h"

class shiftReg 
{
	public:
		shiftReg(int,int,int);				//(latch pin, data pin, clock pin)
		shiftReg(int,int,int,int);			//(latch pin, data pin, clock pin, register size)
		void import(void);
		void write(void);
		byte getSendByte(void);
		void begin(void);
		void end(void);
		void clear(void);
		void pinWrite(int,int);				//(set pin, state)
		void multiPinWrite(byte,int,int);	//(byte sequence, start pin, length)

	
	private:
		int latchPin;
		int clockPin;
		int dataPin;
		byte send;
		int pinSize;
		int pinState[8];
};

#endif	
