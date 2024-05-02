#include <SoftwareSerial.h>
#include <stdio.h>

SoftwareSerial BT(2, 3); 

void setup() {
  BT.begin(9600);
  Serial.begin(9600);
}

int i = 0;

void loop() {
  // Llega un dato por BT, se envía serial.
  if (BT.available()) { 
    Serial.write(BT.read());
  }

  if (Serial.available()) {
    BT.write(Serial.read());
  }

  char data[255];

  sprintf(data, "Enviando datos %d", i);
  //Serial.println(data);
  i += 1;
}
