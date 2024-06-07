void setup() {
  Serial.begin(9600);
  Serial.println("Beginning of program");
}

void loop() {
  //Serial.println(analogRead(A0));
    Serial.print("Distance: ");
    Serial.print(measureDistance());
    Serial.println(" cm");
    
}

double measureDistance() {
  return pow(10, log10(analogAverage() / 4404.2) / -0.918);
}

double analogAverage() {
  double sum = 0;
  for (int i = 0; i < 100; i++) sum += analogRead(A0);
  return sum / 100.0;
}
