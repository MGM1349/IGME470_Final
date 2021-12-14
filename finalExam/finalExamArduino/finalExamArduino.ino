
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
  //Sets up the pin modes for all the buttons
  pinMode(increaseView, INPUT);
  pinMode(decreaseView, INPUT);
  pinMode(gravity, INPUT);
  pinMode(antiGravity, INPUT);

  //Begins the serial port
  Serial.begin(9600);
}

void loop() {
  
  //Will have a half second timer before data
  //is pushed out to the serial port
  float passedTime = millis() - savedTime;
  if(passedTime < totalTime){
    return;
  }

  savedTime = millis();
  
  // read the state of the pushbutton value:
  gravityState = digitalRead(gravity);
  
  //get the photocell and the petentiametor values
  lightValue = analogRead(photocellIn);
  petentiametorValue = analogRead(petentiametorIn);

  //gather the first 20 standing light levels
  if(amountCalculated < 20){
    totalValue += analogRead(photocellIn);
    amountCalculated++;
  }
  //then calculate the mean of that
  else{
    meanValue = totalValue / 20;
    doneCalculating = true;
  }

  //if the petentiametor value is greater than the middle
  //plus some padding, send out a serial port of "left"
  if(petentiametorValue > (midPValue + 100)){
    Serial.println("left");
  }
    
  //if the petentiametor value is greater than the middle
  //plus some padding, send out a serial port of right
  if(petentiametorValue < (midPValue - 100)){
    Serial.println("right");
  }

  //if the light level is greater than the mean value then 
  //print out increaseSpeed
  if(lightValue > (meanValue + 125) && doneCalculating){
    Serial.println("increaseSpeed");
  }

  //if the light level is less than the mean value then
  //print out decreaseSpeed
  if(lightValue < (meanValue - 125) && doneCalculating){
    Serial.println("decreaseSpeed");
  }

  
  //check if the gravity button has been pushed if so then print that out
  if (gravityState == HIGH) {
    Serial.println("gravity");
  }

  //check if the anti gravity button is high then print antigravity out
  antiGravityState = digitalRead(antiGravity);
  if(antiGravityState == HIGH){
    Serial.println("antigravity");
  }

  //check for the buttons for the view state of the game
  //if they have been pushed print that out the serial port
  icreaseViewState = digitalRead(increaseView);
  if(icreaseViewState == HIGH){
    Serial.println("increase");
  }

  decreaseViewState = digitalRead(decreaseView);
  if(decreaseViewState == HIGH){
    Serial.println("decrease");
  }
}
