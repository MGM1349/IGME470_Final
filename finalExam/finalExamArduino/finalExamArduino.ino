
// constants won't change. They're used here to set pin numbers:
const int increaseView = 2;     // the number of the pushbutton pin
const int decreaseView = 3;
const int gravity = 4;
const int antiGravity = 5;
const int photocellIn = A0;
const int petentiametorIn = A1;
const int maxPValue = 1024;
const int midPValue = maxPValue / 2;

// variables will change:
int gravityState = 0;         // variable for reading the pushbutton status
int antiGravityState = 0;
int leftState = 0;
int rightState = 0;
int icreaseViewState = 0;
int decreaseViewState = 0;
int lightValue = 0;
int petentiametorValue = 0;
String previousLightValue;
float meanValue = 0;
float totalValue = 0;
int amountCalculated = 0;
bool doneCalculating = false;
float totalTime = 500;
float savedTime = millis();

void setup() {
  pinMode(increaseView, INPUT);
  pinMode(decreaseView, INPUT);
  pinMode(gravity, INPUT);
  pinMode(antiGravity, INPUT);

  Serial.begin(9600);
}

void loop() {
  
  float passedTime = millis() - savedTime;
  if(passedTime < totalTime){
    return;
  }

  savedTime = millis();
  
  // read the state of the pushbutton value:
  gravityState = digitalRead(gravity);
  lightValue = analogRead(photocellIn);
  petentiametorValue = analogRead(petentiametorIn);

  if(amountCalculated < 20){
    totalValue += analogRead(photocellIn);
    amountCalculated++;
  }
  else{
    meanValue = totalValue / 20;
    doneCalculating = true;
  }

  if(petentiametorValue > (midPValue + 100)){
    Serial.println("left");
  }
    
  if(petentiametorValue < (midPValue - 100)){
    Serial.println("right");
  }

  if(lightValue > (meanValue + 125) && doneCalculating){
    Serial.println("increaseSpeed");
  }

  if(lightValue < (meanValue - 125) && doneCalculating){
    Serial.println("decreaseSpeed");
  }

  
  // check if the pushbutton is pressed. If it is, the buttonState is HIGH:
  if (gravityState == HIGH) {
    Serial.println("gravity");
  }

  antiGravityState = digitalRead(antiGravity);
  if(antiGravityState == HIGH){
    Serial.println("antigravity");
  }

  icreaseViewState = digitalRead(increaseView);
  if(icreaseViewState == HIGH){
    Serial.println("increase");
  }

  decreaseViewState = digitalRead(decreaseView);
  if(decreaseViewState == HIGH){
    Serial.println("decrease");
  }
}
