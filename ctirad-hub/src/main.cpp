/*
* Sketch: Arduino2Arduino_example2_RemoteTemp_Master
* By Martyn Currey
* 11.05.2016
* Written in Arduino IDE 1.6.3
*
* Send a temperature reading by Bluetooth
* Uses the following pins
*
* D8 - software serial RX
* D9 - software serial TX
* A0 - single wire temperature sensor
*
*
* AltSoftSerial uses D9 for TX and D8 for RX. While using AltSoftSerial D10 cannot be used for PWM.
* Remember to use a voltage divider on the Arduino TX pin / Bluetooth RX pin
* Download from https://www.pjrc.com/teensy/td_libs_AltSoftSerial.html
*/
#include <AltSoftSerial.h>
AltSoftSerial BTserial; 

 
// Set DEBUG to true to output debug information to the serial monitor
boolean DEBUG = true;
 

// Variables used for incoming data
const byte maxDataLength = 20;
char receivedChars[21] ;
boolean newData = false;

// Variables used for the timer
unsigned long startTime = 0;
unsigned long waitTime = 1000;

void recvWithStartEndMarkers();
   

void setup()  
{ 
  if (DEBUG)
  {
       // open serial communication for debugging
       Serial.begin(9600);
       Serial.println(__FILE__);
       Serial.println(" ");
  }

    BTserial.begin(9600); 
    if (DEBUG)  {  Serial.println("AltSoftSerial started at 9600");     }

    newData = false; 
    startTime = millis();
 
} // void setup()
 
 

 
void loop()  
{
    if (  millis()-startTime > waitTime ) 
    {
       BTserial.print("<sendTemp>");  
       if (DEBUG) { Serial.println("Request sent"); }
       startTime = millis();
    }

    recvWithStartEndMarkers(); 
    if (newData)  
    {    
      //if (strcmp ("sendTemp",receivedChars) == 0)       

      if (DEBUG) { Serial.print("Data received: "); Serial.println(receivedChars); }         
      newData = false;  
      receivedChars[0]='\0';     
    }    
}
    

       

// function recvWithStartEndMarkers by Robin2 of the Arduino forums
// See  http://forum.arduino.cc/index.php?topic=288234.0
/*
****************************************
* Function recvWithStartEndMarkers
* reads serial data and returns the content between a start marker and an end marker.
* 
* passed:
*  
* global: 
*       receivedChars[]
*       newData
*
* Returns:
*          
* Sets:
*       newData
*       receivedChars
*
*/
void recvWithStartEndMarkers()
{
     static boolean recvInProgress = false;
     static byte ndx = 0;
     char startMarker = '<';
     char endMarker = '>';
     char rc;
 
     if (BTserial.available() > 0) 
     {
          rc = BTserial.read();
          if (recvInProgress == true) 
          {
               if (rc != endMarker) 
               {
                    receivedChars[ndx] = rc;
                    ndx++;
                    if (ndx > maxDataLength) { ndx = maxDataLength; }
               }
               else 
               {
                     receivedChars[ndx] = '\0'; // terminate the string
                     recvInProgress = false;
                     ndx = 0;
                     newData = true;
               }
          }
          else if (rc == startMarker) { recvInProgress = true; }
     }
}