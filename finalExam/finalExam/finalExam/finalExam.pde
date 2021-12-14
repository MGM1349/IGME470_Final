/**
 * Simple Read
 * 
 * Read data from the serial port and change the color of a rectangle
 * when a switch connected to a Wiring or Arduino board is pressed and released.
 * This example works with the Wiring / Arduino program that follows below.
 */


import processing.serial.*;

Serial myPort;  // Create object from Serial class
String val;      // Data received from the serial port
Player player;
PVector movement;

PVector level1StartingPosition;
PVector level2StartingPosition;
PVector level3StartingPosition;
PVector smallMovingWallSP;
PVector largeMovingWallSP;
float speed;
float totalTime;
float savedTime;

//list that will hold the objects that need to move after input
ArrayList<MovingObject> currentMovingObjects;

//holds all the walls that are in thelevel 1.
UnmovingWall level1Goal;
ArrayList<UnmovingWall> level1Walls;
ArrayList<UnmovingWall> level1CloseWalls;
ArrayList<UnmovingWall> level1FarWalls;
ArrayList<UnmovingWall> level1MidWalls;
ArrayList<ArrayList<UnmovingWall>> level1ChangeWalls;

//holds all the walls that are in thelevel 2.
UnmovingWall level2Goal;
ArrayList<UnmovingWall> level2Walls;
ArrayList<UnmovingWall> level2CloseWalls;
ArrayList<UnmovingWall> level2FarWalls;
ArrayList<UnmovingWall> level2MidWalls;
ArrayList<ArrayList<UnmovingWall>> level2ChangeWalls;

//holds all the walls that are in thelevel 3.
UnmovingWall level3Goal;
ArrayList<UnmovingWall> level3Walls;
ArrayList<UnmovingWall> level3CloseWalls;
ArrayList<UnmovingWall> level3FarWalls;
ArrayList<UnmovingWall> level3MidWalls;
ArrayList<ArrayList<UnmovingWall>> level3ChangeWalls;

//All the objects that will move.
ArrayList<MovingObject> allMovingWalls;

//Hashmaps that will change different groups of walls for each level.
HashMap<Integer, ArrayList<ArrayList<UnmovingWall>>> allChangingWalls; //holds all changing walls for all levels
HashMap<Integer, ArrayList<UnmovingWall>> allStaticWalls; //holds all the static walls in the game
HashMap<Integer, UnmovingWall> allLevelGoals; //holds all the goals of the g
HashMap<Integer, PVector> allStartingPositions; //all starting positions for the game

MovingWall largeMovingWall;
MovingWall smallMovingWall;

int level;
int distance;
PFont font;
boolean gameWin;
boolean stillMoving;

void setup() 
{
  speed = 4;
  totalTime = 1000;
  size(1000, 800);
  stillMoving = false;
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
  movement = new PVector(0,0);
  distance = 0;
  level = 0;
  font = createFont("Arial",16,true);
  gameWin = false;
  
  //hold all the starting positions for the player and the moving walls
  level1StartingPosition = new PVector(100,100);
  level2StartingPosition = new PVector(100,600);
  level3StartingPosition = new PVector(200,600);
  smallMovingWallSP = new PVector(200,600);
  largeMovingWallSP = new PVector(200,600);
  
  currentMovingObjects = new ArrayList<MovingObject>();
  
  //instantializing all the lists needed for the levels
  level1Walls = new ArrayList<UnmovingWall>();
  level1CloseWalls = new ArrayList<UnmovingWall>();
  level1FarWalls = new ArrayList<UnmovingWall>();
  level1MidWalls = new ArrayList<UnmovingWall>();
  level1ChangeWalls = new ArrayList<ArrayList<UnmovingWall>>();
  
  level2Walls = new ArrayList<UnmovingWall>();
  level2CloseWalls = new ArrayList<UnmovingWall>();
  level2FarWalls = new ArrayList<UnmovingWall>();
  level2MidWalls = new ArrayList<UnmovingWall>();
  level2ChangeWalls = new ArrayList<ArrayList<UnmovingWall>>();
  
  level3Walls = new ArrayList<UnmovingWall>();
  level3CloseWalls = new ArrayList<UnmovingWall>();
  level3FarWalls = new ArrayList<UnmovingWall>();
  level3MidWalls = new ArrayList<UnmovingWall>();
  level3ChangeWalls = new ArrayList<ArrayList<UnmovingWall>>();
  allMovingWalls = new ArrayList<MovingObject>();
  
  //instantializing all the hash maps for the levels
  allChangingWalls = new HashMap<Integer, ArrayList<ArrayList<UnmovingWall>>>();
  allStaticWalls = new HashMap<Integer, ArrayList<UnmovingWall>>();
  allLevelGoals = new HashMap<Integer, UnmovingWall>();
  allStartingPositions = new HashMap<Integer, PVector>();
  
  //add the change walls to the level list
  level1ChangeWalls.add(level1CloseWalls);
  level1ChangeWalls.add(level1MidWalls);
  level1ChangeWalls.add(level1FarWalls);
  
  //add the change walls to the level list
  level2ChangeWalls.add(level2CloseWalls);
  level2ChangeWalls.add(level2MidWalls);
  level2ChangeWalls.add(level2FarWalls);
  
  //add the change walls to the level list
  level3ChangeWalls.add(level3CloseWalls);
  level3ChangeWalls.add(level3MidWalls);
  level3ChangeWalls.add(level3FarWalls);
  
  //change the level list to the hashmap
  allChangingWalls.put(0, level1ChangeWalls);
  allChangingWalls.put(1, level2ChangeWalls);
  allChangingWalls.put(2, level3ChangeWalls);
  
  //add all the static walls to the hashmap
  allStaticWalls.put(0, level1Walls);
  allStaticWalls.put(1, level2Walls);
  allStaticWalls.put(2, level3Walls);
  
  //add all the starting positions for the player to a hashmap 
  allStartingPositions.put(0, level1StartingPosition);
  allStartingPositions.put(1, level2StartingPosition);
  allStartingPositions.put(2, level3StartingPosition);
  
  setupLevelWalls();
}

void setupLevelWalls(){
  //player
  player = new Player(100,100,100, 100);
  
  //LEVEL 1 WALL SETUP
  level1Goal = new UnmovingWall(800,600,100,100);
  level1Walls.add(new UnmovingWall(0,0,1000,100));
  level1Walls.add(new UnmovingWall(0,700,1000,100));
  level1Walls.add(new UnmovingWall(0,0,100,800));
  level1Walls.add(new UnmovingWall(900,0,100,800));
  level1Walls.add(new UnmovingWall(700,500,100,200));
  
  level1CloseWalls.add(new UnmovingWall(100,500, 100,100));
  level1CloseWalls.add(new UnmovingWall(100,600, 200, 100));
  level1CloseWalls.add(new UnmovingWall(700,300, 100, 200));
  
  level1MidWalls.add(new UnmovingWall(300,100,100, 200));
  level1MidWalls.add(new UnmovingWall(600,600,100, 100));
  level1MidWalls.add(new UnmovingWall(600,400,100, 100));
  level1MidWalls.add(new UnmovingWall(800,100,100, 100));
  
  level1FarWalls.add(new UnmovingWall(400,100,100, 400));
  level1FarWalls.add(new UnmovingWall(500,100,100, 200));
  
  
  //LEVEL 2 WALL SETUP
  level2Goal = new UnmovingWall(600,200,100,100);
  level2Walls.add(new UnmovingWall(0,600,100,100));
  level2Walls.add(new UnmovingWall(0,700,200,100));
  level2Walls.add(new UnmovingWall(300,700,200,100));
  level2Walls.add(new UnmovingWall(900,400,100,300));
  level2Walls.add(new UnmovingWall(500,200,100,100));
  level2Walls.add(new UnmovingWall(600,300,100,100));
 
  level2CloseWalls.add(new UnmovingWall(300,600,100,100));
  level2CloseWalls.add(new UnmovingWall(900,300,100,100));
  level2CloseWalls.add(new UnmovingWall(700,0,100,100));
  level2CloseWalls.add(new UnmovingWall(300,300,200,100));
  
  level2MidWalls.add(new UnmovingWall(900,100,100, 100));
  level2MidWalls.add(new UnmovingWall(500,300,100,100));
  level2MidWalls.add(new UnmovingWall(500,700,200, 100));
  level2MidWalls.add(new UnmovingWall(100,100,300, 100));
  
  level2FarWalls.add(new UnmovingWall(0,0,100, 300));
  level2FarWalls.add(new UnmovingWall(500,100,200, 100));
  level2FarWalls.add(new UnmovingWall(800,300,100,200));
  level2FarWalls.add(new UnmovingWall(0,500,200,100));
 
  
  //LEVEL 3 WALL SETUP
  level3Goal = new UnmovingWall(300,200,100,100);
  level3Walls.add(new UnmovingWall(0,0,200,100));
  level3Walls.add(new UnmovingWall(200,200,100,100));
  level3Walls.add(new UnmovingWall(300,100,100,100));
  level3Walls.add(new UnmovingWall(300,300,200,100));
  
  level3CloseWalls.add(new UnmovingWall(700,100,100,100));
  level3CloseWalls.add(new UnmovingWall(800,500,200,100));
  level3CloseWalls.add(new UnmovingWall(900,600,100,100));
  level3CloseWalls.add(new UnmovingWall(800,200,100,100));
  level3CloseWalls.add(new UnmovingWall(500,300,100,100));
  
  level3MidWalls.add(new UnmovingWall(0,200,100,100));
  level3MidWalls.add(new UnmovingWall(800,100,100,100));
  level3MidWalls.add(new UnmovingWall(400,100,100,100));
  level3MidWalls.add(new UnmovingWall(0,500,100,100));
  level3MidWalls.add(new UnmovingWall(500,700,100,100));
  level3MidWalls.add(new UnmovingWall(200,300,100,100));
  level3MidWalls.add(new UnmovingWall(900,300,100,200));
  
  level3FarWalls.add(new UnmovingWall(300,600,200,100));
  level3FarWalls.add(new UnmovingWall(700,400,100,100));
  level3FarWalls.add(new UnmovingWall(900,0,100,300));
  level3FarWalls.add(new UnmovingWall(500,100,200,100));
  level3FarWalls.add(new UnmovingWall(100,700,100,100));
  
  largeMovingWall = new MovingWall(200,400,100,200);
  largeMovingWallSP = new PVector(200,400);
  smallMovingWall = new MovingWall(900,700,100,100);
  smallMovingWallSP = new PVector(900,700);
  
  allMovingWalls.add(largeMovingWall);
  allMovingWalls.add(smallMovingWall);
  allMovingWalls.add(player);
  
  allLevelGoals.put(0, level1Goal);
  allLevelGoals.put(1, level2Goal);
  allLevelGoals.put(2, level3Goal);
}

//method that will draw all objects onto the screen.
void draw()
{
  Update();
  
  //IF the player has won override the rest of the draw for the game win screen
  if(gameWin){
     GameWin();
     return;
  }
  
  //create a grey background.
  background(155);  
 
 //draw all the walls for a given level and the current changing walls shown
  for(UnmovingWall wall : allChangingWalls.get(level).get(distance)){
    wall.drawWall();
  }
  fill(color(0,255,0));
  
  //draw the player
  player.drawObject(); 
  fill(0,0,0);
  
  //draw all the static walls for a level
  for(UnmovingWall wall : allStaticWalls.get(level)){
    wall.drawWall();
  }
  fill(color(0,0,255));
  
  //draw the goal for the current wall
  allLevelGoals.get(level).drawWall();
  if(level == 2){
    fill(color(210,105,30)); 
  }
  else{
    fill(color(255,0,0));
  }
  
  //if this is the final level draw moveable walls.
  if(level == 2){
    smallMovingWall.drawObject();
    largeMovingWall.drawObject();
      fill(color(255,0,0));  
   }
}

//Will perform any updates such as collision detection,
//level wins, no more moving objects, and more.
void Update(){
  ReadSerial();
  
    //checks to see if the small moving wall is off the map then
    //bring it back to its starting position.
    if(smallMovingWall.CheckOutMap()){
        currentMovingObjects.remove(smallMovingWall);
        smallMovingWall.x = smallMovingWallSP.x;
        smallMovingWall.y = smallMovingWallSP.y;
      }
      
      //checks to see if the small moving wall is off the map then
      //bring it back to its starting position.
      if(largeMovingWall.CheckOutMap()){
        currentMovingObjects.remove(largeMovingWall);
        largeMovingWall.x = largeMovingWallSP.x;
        largeMovingWall.y = largeMovingWallSP.y;
      }
  
  //go through the current moving objects and check to see if they collide
  //with the walls within the screen or other moving objects within the screen.
  for(int i = 0; i < currentMovingObjects.size(); i++){
    for(ArrayList<UnmovingWall> list : allChangingWalls.get(level)){
      if(currentMovingObjects.size() > 0){
        //check the collision if there will be collision, remove that object from
        //the list of moving objects.
        if(CheckCollision(movement, currentMovingObjects.get(i), list)){
          currentMovingObjects.remove(currentMovingObjects.get(i));
          return;
        }
      }
    }
  
    if(currentMovingObjects.size() > 0){
      //check the collision if there will be collision, remove that object from
      //the list of moving objects.
      if(CheckCollision(movement, currentMovingObjects.get(i), allStaticWalls.get(level))){
         currentMovingObjects.remove(currentMovingObjects.get(i));
         return;
       }
     }
    
    //if this is level 2 check all the moving objects with other moving 
    //objects to make sure they arn't colliding with each other.
    if(level == 2){
      for(MovingObject object : allMovingWalls){
        if(currentMovingObjects.get(i) != object){
          if(CheckCollision(movement, currentMovingObjects.get(i), object)){
            currentMovingObjects.remove(currentMovingObjects.get(i));
            return;
          }
        }
      }
    }
  }
  
  //for any leftover moving objects, move their positions
  for(MovingObject object : currentMovingObjects){
      object.changePosition(movement);
  }
  
  //if the player is out of the map restart their position
  if(player.CheckOutMap()){
     restartLevel();
     currentMovingObjects.clear();
  }
  
  //if there are objects still in the current moving objects list
  //then make sure there can be no more input.
  if(currentMovingObjects.size() > 0){
    stillMoving = true;
  }
  else{
    stillMoving = false;
  }
  
  //if the player is within the goal win the level.
  if(player.CheckWithinGoal(allLevelGoals.get(level))){
    LevelWin();
  }
  
}

//Method that will read serial input
//Then update the screen
void ReadSerial(){
 
  val = myPort.readStringUntil('\n');
  
  if(val == null){
    return;
  }
  val = val.trim();
  
  println(val);
  
  if(!stillMoving){
    //if gravity is enabled, the player will be pushed down.
    if (val.equals("gravity")) {
      movement = new PVector(0,speed);
      currentMovingObjects.add(player);
      if(level == 2){
        currentMovingObjects.add(smallMovingWall);
        currentMovingObjects.add(largeMovingWall);
      }
    }
    
    //if antigravity is said, the player will be moved upwards
    if (val.equals("antigravity")) {
      movement = new PVector(0,-speed);
      currentMovingObjects.add(player);
      if(level == 2){
        currentMovingObjects.add(smallMovingWall);
        currentMovingObjects.add(largeMovingWall);
      }
    }
    
    //if the serial is read for left the player will move left
    if (val.equals("left")) {
      movement = new PVector(-speed,0);
      currentMovingObjects.add(player);
      if(level == 2){
        currentMovingObjects.add(smallMovingWall);
        currentMovingObjects.add(largeMovingWall);
      }
    }
  
    //if the serial is read for right the player will move right
    if (val.equals("right")) {
      movement = new PVector(speed,0);
      currentMovingObjects.add(player);
      if(level == 2){
        currentMovingObjects.add(smallMovingWall);
        currentMovingObjects.add(largeMovingWall);
      } 
    }
  }
    
    //if the serial is read decrease, then the screen will
    //display new changing blocks depending on the distance.
    if (val.equals("decrease")) {
     if(distance > 0){
       distance--;
     }
    }

    //if the serial is read increaase, then the screen will
    //display new changing blocks depending on the distance.
    if (val.equals("increase")) {         
     if(distance < 2){
       distance++;
     }
    }
    
    //this will increase the player speed
    if(val.equals("increaseSpeed")){
      speed += .2;
    }
    
    //this will decrease the player speed
    if(val.equals("decreaseSpeed")){
      speed -= .2;
      if(speed <= 0){
        speed = .1;
      }
    }
}

//method that will increase the level unless at the end
//which will make the player win the game.
void LevelWin(){
  if(level == 2){
    gameWin = true;
  }
  else{
    level++;
  }
  
  currentMovingObjects.clear();
  player.x = allStartingPositions.get(level).x;
  player.y = allStartingPositions.get(level).y;
}

//changes the text to display they won.
void GameWin(){
  background(0);
  textFont(font,16);
  fill(255);
  text("Game Won!", width/2, height/2);
}

void keyPressed(){
  
 
}

//will restet the players position
void restartLevel(){
  player.x = allStartingPositions.get(level).x;
  player.y = allStartingPositions.get(level).y;
}

//method that will check collision with one moving object with a list of unmoving wall
//will return true if there is a collision otherwise return false.
boolean CheckCollision(PVector movement, MovingObject object, ArrayList<UnmovingWall> list){
    for(UnmovingWall wall: list){
       if((object.x  + object.width + movement.x) > wall.x && 
         (object.x + movement.x) < (wall.x + wall.width) &&
         (object.y + object.height + movement.y) > wall.y &&
         (object.y + movement.y) < (wall.y + wall.height)){
           return true;
       }
    }
    return false;
}

//Method that will check collision with a moving object and another moviing obeject.
//This will return true if there is a collision otherwise return false.
boolean CheckCollision(PVector movement, MovingObject movingObject, MovingObject wallObject){
   if((movingObject.x  + movingObject.width + movement.x) > wallObject.x && 
     (movingObject.x + movement.x) < (wallObject.x + wallObject.width) &&
     (movingObject.y + movingObject.height + movement.y) > wallObject.y &&
     (movingObject.y + movement.y) < (wallObject.y + wallObject.height)){
       return true;
    }
    return false;
}

//A parent class to outline a moving object within the game.
class MovingObject{
  
  float x;
  float y;
  float width;
  float height;
  
  MovingObject(float x, float y, float width, float height){
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    
  }
  
  //method to change the position of the object.
  void changePosition(PVector movement){
    this.x += movement.x;
    this.y += movement.y;
  }
  
  //draw the object
  void drawObject(){
     rect(x,y,width,height);
     //fill(playerColor);
  }
}
  
//Player class that extends a moving object.
class Player extends MovingObject{
  Player(float x, float y, float width, float height){
    super(x,y,width,height);
  }
  
  //method to check if the player has gone off the screen
  boolean CheckOutMap(){
    float centerX = this.x + (this.width / 2);
    float centerY = this.y + (this.height / 2);
    if((centerX) < 0 || 
      (centerX) >  displayWidth ||
      (centerY) < 0 ||
      (centerY) > displayHeight){
        return true;
    } 
    
    return false;
  }
 
//check to see if a player is within a goal
boolean CheckWithinGoal(UnmovingWall goal){
    float centerX = this.x + (this.width / 2);
    float centerY = this.y + (this.height / 2);
    
    if((centerX) > goal.x  && 
      (centerX) <  goal.x + goal.width &&
      (centerY) > goal.y &&
      (centerY) < goal.y + goal.height){
        return true;
    } 
    
    return false;
  }
}

//A class that will create a wall and use it to move around the screen
class MovingWall extends MovingObject{
  MovingWall(float x, float y, float width, float height){
    super(x,y,width,height);
  }

//checks to see if the wall has gone off teh screen
boolean CheckOutMap(){
    float centerX = this.x + (this.width / 2);
    float centerY = this.y + (this.height / 2);
    if((centerX) < 0 || 
      (centerX) >  displayWidth ||
      (centerY) < 0 ||
      (centerY) > displayHeight){
        return true;
    } 
    return false;
}
}

//Class for a wall that will not move at all during the game
class UnmovingWall{
  int x;
  int y;
  int width;
  int height;
  color wallColor;
  
  UnmovingWall(int x, int y, int width, int height){
    this.x = x;
    this. y = y;
    this.width = width;
    this.height = height;
    
  }
  
  //draws the wall.
  void drawWall(){
     rect(x,y,width,height);
     //fill(wallColor);
  }
}
