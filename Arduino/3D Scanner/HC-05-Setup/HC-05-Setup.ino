#include <SoftwareSerial.h>

SoftwareSerial BT(2, 3); 

void setup() {
  BT.begin(9600);
  Serial.begin(9600);
}

void loop() {
  // Llega un dato por BT, se envía serial.
  if (BT.available()) { 
    Serial.write(BT.read());
  }

  // Llega un dato por el monitor serial, se envía a BT.
  if (Serial.available()) { 
    BT.write(Serial.read());
  }
}
