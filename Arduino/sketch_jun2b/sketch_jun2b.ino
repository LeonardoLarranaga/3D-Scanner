#include <AccelStepper.h>
#include <Adafruit_VL53L0X.h>

///////// Constantes ///////////

#define interface 1  // AccelStepper::DRIVER
#define stepPinZ 3
#define directionPinZ 5

#define stepFigPin 6
#define directionFigPin 9

#define M0 2
#define M1 4
#define M2 7

// Definir las instancias de los steppers.
AccelStepper stepperZ = AccelStepper(interface, stepPinZ, directionPinZ);
AccelStepper stepperFigure = AccelStepper(interface, stepFigPin, directionFigPin);

Adafruit_VL53L0X lox = Adafruit_VL53L0X();

void setup() {
  Serial.begin(9600);

  stepperFigure.setMaxSpeed(500);
  stepperFigure.setAcceleration(100);
  stepperFigure.setCurrentPosition(0);

  stepperZ.setMaxSpeed(3000);
  stepperZ.setAcceleration(1000);
  stepperZ.setCurrentPosition(0);

  pinMode(M0, OUTPUT);
  pinMode(M1, OUTPUT);
  pinMode(M2, OUTPUT);  
 
  Serial.println("VL53L0X started!");
  pinMode(1, INPUT_PULLUP);

  digitalWrite(M0, LOW);
  digitalWrite(M1, LOW);
  digitalWrite(M2, LOW);
}

void loop() {
  moveZ();
  //moveFigure();
  //stepFigure();
  //readMeasure();
}

void moveZ() {
  stepperZ.setSpeed(digitalRead(1) == HIGH ? 1500 : -1500);
  stepperZ.runSpeed();
}

void moveFigure() {
  stepperFigure.setSpeed(digitalRead(1) == HIGH ? 600 : -600);
  stepperFigure.runSpeed();
}

void stepFigure() {
  stepperFigure.move(1);
  stepperFigure.run();
  delay(200);
}

void readMeasure() {
  while (!lox.begin()) Serial.println(F("Failed to boot VL53L0X"));
  VL53L0X_RangingMeasurementData_t measure;
  lox.rangingTest(&measure, false);

  if (measure.RangeStatus != 4) {  // phase failures have incorrect data
    Serial.print("Distance (mm): "); 
    Serial.println(measure.RangeMilliMeter);
  } else {
    Serial.println(" out of range ");
  }
}