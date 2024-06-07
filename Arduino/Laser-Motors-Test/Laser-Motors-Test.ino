#include <SoftwareSerial.h>
#include <AccelStepper.h>
#include <stdio.h>
#include "Adafruit_VL53L0X.h"

///////// Constantes ///////////

#define interface 1  // AccelStepper::DRIVER
#define stepPinZ 3
#define directionPinZ 5

#define stepFigPin 6
#define directionFigPin 9

#define M0 2
#define M1 4
#define M2 7

#define HM_TX 10
#define HM_RX 11
#define HM_STATE 12

#define scannerHeight 45.0
#define distanceToMiddle 26
//#define PI 3.1415926535897932384626433832795

// Definir las instancias de los steppers.
AccelStepper stepperZ = AccelStepper(interface, stepPinZ, directionPinZ);
AccelStepper stepperFigure = AccelStepper(interface, stepFigPin, directionFigPin);

// Definir manejador Bluetooth
SoftwareSerial BT(HM_TX, HM_RX);

Adafruit_VL53L0X lox = Adafruit_VL53L0X();

///////// Variables ///////////
bool isScanning = false;
bool isPaused = false;
bool finishedScanning = false;
bool hasBeenConnected = false;

int speed = 200;
int stepperFigurePosition = 0;

double radians = 0;
double angle = 0;
double heightDifference = 0.5;
double z = 0;

unsigned long previousMillis = 0;
unsigned long interval = 1000;

void setup() {
  BT.begin(9600);
  Serial.begin(9600);

  pinMode(HM_STATE, INPUT);

  pinMode(M0, OUTPUT);
  pinMode(M1, OUTPUT);
  pinMode(M2, OUTPUT);

  stepperZ.setMaxSpeed(3000);
  stepperZ.setAcceleration(1000);
  stepperZ.setCurrentPosition(0);

  stepperFigure.setMaxSpeed(500);
  stepperFigure.setAcceleration(500);
  stepperFigure.setCurrentPosition(0);

  // wait until serial port opens for native USB devices
  while (!Serial) delay(1);
  
  if (!lox.begin()) {
    Serial.println(F("Failed to boot VL53L0X"));
    while(1);
  }

  digitalWrite(M0, LOW);
  digitalWrite(M1, LOW);
  digitalWrite(M2, LOW);

  radians = (PI / 180.0) * (360.0 / (double) speed);
  interval = heightDifference * 1000L / 0.5L;

  for (int i = 5; i >= 0; i--) {
    Serial.print("Starting scan in ");
    Serial.print(i);
    Serial.println("...");
    delay(500);
  }
}

bool flag = false;

void loop() {  
    double measurement = measureLaserDistance(50);
    Serial.println(measurement);
    if (z >= scannerHeight) {
      if (!flag) {
        Serial.println("Finished!");
        // AQUI MOSTRAR CUANTO TARDO
        flag = true;
      }

      return;
    }
    if (measurement <= 0) return;
    //Serial.print(measurement);
    //Serial.println(" cm.");

    double distance = distanceToMiddle - measurement;
    //Serial.println(distance);

    double x = sin(angle) * distance;
    double y = cos(angle) * distance;  
    
    angle += radians;

    char message[50];
    dtostrf(x, 6, 4, message);
    strcat(message, " ");
    dtostrf(y, 6, 4, message + strlen(message));
    strcat(message, " ");
    dtostrf(z, 6, 4, message + strlen(message));
    //Serial.println(message);

    stepperFigure.move(1);
    stepperFigure.run();
    stepperFigurePosition += 1;

    // Motor de figura ha dado una vuelta completa, subir el motor Z height difference.
    if (stepperFigurePosition == speed) {
      previousMillis = millis();
      while (true) {
        unsigned long currentMillis = millis();

        if (currentMillis - previousMillis <= interval) {
          stepperZ.setSpeed(600);
          stepperZ.runSpeed();
        } else {
          break; 
        }
      }

      z += heightDifference;

      stepperFigurePosition = 0;
      angle = 0;

      delay(300);
    }

    //delay(200);
}

double measureLaserDistance(int amount) {
  VL53L0X_RangingMeasurementData_t measure;
  double sum = 0.0;
  int a = 0;

  for (int i = 0; i < amount; i++) {
    lox.rangingTest(&measure, false);
    
    if (measure.RangeStatus != 4) {
      sum += (double) measure.RangeMilliMeter / 10.0;
      a += 1;
    }
  }

  if (a == 0) return 0;
  return sum / (double) a;
/*
  lox.rangingTest(&measure, false); 

  if (measure.RangeStatus != 4) {  // phase failures have incorrect data
    return (double) measure.RangeMilliMeter / 10.0;
  } else {
    return -1.0;
  }*/
}