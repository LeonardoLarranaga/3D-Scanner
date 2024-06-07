#include <SoftwareSerial.h>
#include <AccelStepper.h>
#include <stdio.h>
#include "Adafruit_VL53L0X.h"

///////// Constantes ///////////

// CAMBIAR EL PROCESO DE HEIGHT DIFFERENCE A CM!!!!!!!!

#define interface 1  // AccelStepper::DRIVER
#define stepPinZ 3
#define directionPinZ 5

#define stepFigPin 6
#define directionFigPin 9

#define M0 2
#define M1 4
#define M2 7

#define measurementsAmount 100

#define HM_TX 10
#define HM_RX 11
#define HM_STATE 12

#define scannerHeight 45
#define distanceToMiddle 18.5

// Definir las instancias de los steppers.
AccelStepper stepperZ = AccelStepper(interface, stepPinZ, directionPinZ);
AccelStepper stepperFigure = AccelStepper(interface, stepFigPin, directionFigPin);

// Definir manejador Bluetooth
SoftwareSerial BT(HM_TX, HM_RX);

// Definir sensor láser
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
  stepperFigure.setAcceleration(100);
  stepperFigure.setCurrentPosition(0);
}

void loop() {
  // Detectar conexión a Bluetooth.
  if (digitalRead(HM_STATE) == HIGH) hasBeenConnected = true;
  if ((!hasBeenConnected || digitalRead(HM_STATE) == LOW) && !finishedScanning) return;

  // Leer datos de control de Bluetooth. Serial.available para debugging.
  if (BT.available()) {
    String btRead = BT.readString();
    BT.write("RM");

    // Leer velocidad del motor.
    if (isNumber(btRead)) setFigureMotorSpeed(btRead.toInt());  // Pines de resolución de micropasos.
    
    /*
     Configurar diferencia de altura en cada rotación.
     1 segundo = 5.0mm.
     */
    else if (isDecimalNumber(btRead)) {
      heightDifference = btRead.toDouble();
      interval = heightDifference * 1000L / 5L;
    }

    // Iniciar, detener, continuar y terminar escaneo.
    else if (btRead.equals("START")) {
      isScanning = true;
      isPaused = false;
      finishedScanning = false;
    } 
    else if (btRead.equals("STOP")) isPaused = true;
    else if (btRead.equals("CONTINUE")) isPaused = false;
    else if (btRead.equals("END")) {
      isScanning = false;
      finishedScanning = true;
    }
  }

  if (isPaused) return;

  if (isScanning) {
    double measurement = measureLaserDistance(10);

    double distance = distanceToMiddle - measurement;
    angle += radians;

    double x = cos(angle) * distance;
    double y = sin(angle) * distance; 

    // Crear mensaje de Bluetooth.
    char message[50];
    strcat(message, "SM ");
    dtostrf(x, 6, 4, message);
    strcat(message, " ");
    dtostrf(y, 6, 4, message + strlen(message));
    strcat(message, " ");
    dtostrf(z, 6, 4, message + strlen(message));

    // Enviar mediciones por Bluetooth.
    BT.write(message);

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
          previousMillis = currentMillis;
          break;
        }

        z += heightDifference;
      }

      stepperFigurePosition = 0;
      angle = 0;
    }
    delay(200);
  }

  if (finishedScanning) {
    Serial.println("Scan finished.");
  }
}

bool isNumber(String str) {
  for (int i = 0; i < str.length(); i++)
    if (!isdigit(str.charAt(i))) return false;

  return true;
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
}

void setFigureMotorSpeed(int sp) {
  speed = sp;

  radians = (PI / 180.0) * (360.0 / speed);

  switch (speed) {
    // Paso completo.
    case 200:
      digitalWrite(M0, LOW);
      digitalWrite(M1, LOW);
      digitalWrite(M2, LOW);
      break;

    // 1/2 paso.
    case 400:
      digitalWrite(M0, HIGH);
      digitalWrite(M1, LOW);
      digitalWrite(M2, LOW);
      break;

    // 1/4 paso.
    case 800:
      digitalWrite(M0, LOW);
      digitalWrite(M1, HIGH);
      digitalWrite(M2, LOW);
      break;

    // 1/8 paso.
    case 1600:
      digitalWrite(M0, HIGH);
      digitalWrite(M1, HIGH);
      digitalWrite(M2, LOW);
      break;

    // 1/16 paso.
    case 3200:
      digitalWrite(M0, LOW);
      digitalWrite(M1, LOW);
      digitalWrite(M2, HIGH);
      break;

    // 1/32 paso.
    case 6400:
      digitalWrite(M0, HIGH);
      digitalWrite(M1, HIGH);
      digitalWrite(M2, HIGH);
      break;
  }
}

bool isDecimalNumber(String str) {
  // Eliminar espacios en blanco al principio y al final de la cadena
  str.trim();

  // Comprobar si la cadena está vacía
  if (str.length() == 0) return false;

  // Comprobar si hay un solo punto decimal
  int dotIndex = str.indexOf('.');
  if (dotIndex == -1) return false;

  // Hay un punto decimal, comprobar la parte entera y la parte decimal
  for (int i = 0; i < str.length(); i++) 
    if (i != dotIndex && !isdigit(str.charAt(i)))
      return false;

  return true;
}
