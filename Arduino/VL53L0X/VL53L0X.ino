#include "Adafruit_VL53L0X.h"

Adafruit_VL53L0X lox = Adafruit_VL53L0X();

void setup() {
  Serial.begin(9600);

  // wait until serial port opens for native USB devices
  while (!Serial) {
    delay(1);
  }
  
  while (!lox.begin()) Serial.println(F("Failed to boot VL53L0X"));

    // power 
  Serial.println(F("VL53L0X API Simple Ranging example\n\n")); 
}


void loop() {
  //double measure = averageCM();
  double measure = measureDistance();
  Serial.print(measure);
  Serial.println(" cm.");
  delay(200);
}

double averageCM(int amount) {
  int sum = 0;
  VL53L0X_RangingMeasurementData_t measure;

  for (int i = 0; i < amount; i++) {
    lox.rangingTest(&measure, false);
    if (measure.RangeStatus != 4) sum += measure.RangeMilliMeter;
    Serial.println(sum);
  }
  
  return (double) sum / amount / 10.0;
}

double measureDistance() {
  VL53L0X_RangingMeasurementData_t measure;
  lox.rangingTest(&measure, false);
  
  if (measure.RangeStatus != 4)
    return (double) measure.RangeDMaxMilliMeter / 10.0;
  else
    return 0;
}