#include <shiftReg.h>
#include <stepMotor.h>

/*
  A program to control 3 motors on an arduino given input from a processing program.
  
  Start date: 5/25/2013
*/

const int xSteps = 200;
const int ySteps = 200;

stepMotor x(xSteps,3,2);
stepMotor y(ySteps);

int val;
int dir;
long time;
long xSpeed = 0;
long ySpeed = 0;

void setup() 
{
  Serial.begin(115200);
  x.setSpeed(0);
  y.setSpeed(0);
  while(!Serial);
}

void loop() 
{
  time = micros();
  Serial.flush();
  checkAxis();
  Serial.print(ySpeed );
  Serial.print(": ");
  Serial.println(xSpeed);
  x.stepDriver(time);
}

void checkAxis()
{
  if(Serial.available() > 0)
  {
    val = Serial.read();
    Serial.println(val);
    Serial.flush();
    switch (val)
    {
      case 120:
        xSpeed = (Serial.read() - '0') + (Serial.read() - '0') + (Serial.read() - '0');
        x.setSpeed(xSpeed);
        break;
      case 121:
        ySpeed = (Serial.read() - '0') + (Serial.read() - '0') + (Serial.read() - '0');
        y.setSpeed(ySpeed);
        break;
      case 122:
        Serial.println("Silly, that hasn't been shown yet");
        break;
      case 'X':
        xSpeed = -((Serial.read() - '0') + (Serial.read() - '0') + (Serial.read() - '0'));
        x.setSpeed(xSpeed);
        break;
      case 'Y':
        ySpeed = -((Serial.read() - '0') + (Serial.read() - '0') + (Serial.read() - '0'));
        y.setSpeed(ySpeed);
        break;
      default:
        Serial.println("wrong motor selector");
        Serial.flush();
        break;
    }
  }
}


