#include <AccelStepper.h>

#define interface 1  // AccelStepper::DRIVER
#define stepPinZ 3
#define directionPinZ 5

#define stepFigPin 10
#define directionFigPin 9

#define M0 7
#define M1 8
#define M2 11

#define distanceToMiddle = 26

// Definir las instancias de los steppers.
AccelStepper stepperZ = AccelStepper(interface, stepPinZ, directionPinZ);
AccelStepper stepperFigure = AccelStepper(interface, stepFigPin, directionFigPin);


void setup() {
  pinMode(6, OUTPUT);
  pinMode(5, OUTPUT);
  stepperZ.setMaxSpeed(3000);
  stepperZ.setAcceleration(1000);
  stepperZ.setCurrentPosition(0);

  pinMode(10, OUTPUT);
  pinMode(9, OUTPUT);
  stepperFigure.setMaxSpeed(3500);
  stepperFigure.setAcceleration(2000);
  stepperFigure.setCurrentPosition(0);

  pinMode(M0, OUTPUT);
  pinMode(M1, OUTPUT);
  pinMode(M2, OUTPUT);

  digitalWrite(M0, LOW);
  digitalWrite(M1, LOW);
  digitalWrite(M2, LOW);

  Serial.begin(9600);
}

int pos = 0;
unsigned long previousMillis = 0;
void loop() {
  //stepperFigure.move(1);
  //stepperFigure.run();
  //delay(250);
  //stepperZ.move(600);
  //stepperZ.run();
  //delay(1000);
  stepperZ.setSpeed(-600);
  stepperZ.runSpeed();
  //delay(250);
  // stepperZ.setSpeed(600);
  //stepperZ.runSpeed();

  /*unsigned long currentMillis = millis();

  double heightDifference = 0.1;
  unsigned long interval = heightDifference * 1000L / 5L;

  // Gira el motor hasta que suba heightDifference
  if (currentMillis - previousMillis <= interval) {
    stepperZ.setSpeed(600);
    stepperZ.runSpeed();
  } else {
    // Detiene el motor por el intervalo calculado.
    stepperZ.stop();
    if (currentMillis - previousMillis >= 20 * interval) {
      previousMillis = currentMillis;
    }
  }*/

  //delay(1000);
  //stepperZ.stop();
  //delay(1000);
}
