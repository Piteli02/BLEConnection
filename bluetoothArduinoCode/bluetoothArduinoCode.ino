#include "SoftwareSerial.h"

SoftwareSerial bluetooth(3, 2); //3 = RX ; 2 = TX

void setup() {

  Serial.begin(9600);
  bluetooth.begin(9600);

}

void loop() {

  bluetooth.print("Success!"); 

  delay(2000); // Wait two seconds to send the next message

  bluetooth.print("Well done!");

  delay(2000);

}
