//Kelvin Lin Pd.4

import java.util.ArrayList;
//lanes to switch between to avoid a ConcurrentModificationException
ArrayList<Lane> lanes = new ArrayList<Lane>();
ArrayList<Lane> altLanes = new ArrayList<Lane>();
ArrayList<Lane> inUse = lanes;
ArrayList<Lane> notUse = altLanes;
boolean laneSwitch = false, altLaneSwitch = true;

//booleans to determine which screen to display
boolean titleScreen = true, gameOver = false, waterDeath = false;
//determines how the player has died
boolean[] deathCause = {false, false, false, false};

//values indicating x position, difficulty, and score
int xPlayer, difficulty = 0, score = 0;
//represents the time the player has in each lane
long startTime, endTime, timeRemaining, givenTime;


void setup() {
  //size, background, and other defaults
  size(800, 800);
  background(255);
  rectMode(CENTER);
  
  //adds 5 lanes to begin since only 5 can fit on the screen at difficulty 0
  lanes.add(new Lane(createCar(600, (int)(Math.random() * 2)), null, null));
  altLanes.add(new Lane(createCar(600, (int)(Math.random() * 2)), null, null));
  lanes.add(new Lane(createCar(400, (int)(Math.random() * 2)), null, null));
  altLanes.add(new Lane(createCar(400, (int)(Math.random() * 2)), null, null));
  lanes.add(new Lane(createCar(200, (int)(Math.random() * 2)), null, null));
  altLanes.add(new Lane(createCar(200, (int)(Math.random() * 2)), null, null));
  lanes.add(new Lane(createCar(0, (int)(Math.random() * 2)), null, null));
  altLanes.add(new Lane(createCar(0, (int)(Math.random() * 2)), null, null));
  lanes.add(new Lane(createCar(-200, (int)(Math.random() * 2)), null, null));
  altLanes.add(new Lane(createCar(-200,(int)(Math.random() * 2)), null, null));
  
  //player's x position is intially the middle
  xPlayer = width / 2;
}

void draw() {
  textAlign(CENTER);
  //displays title screen when the titleScreen boolean is true
  if(titleScreen){
    background(color(153, 255, 153));
    fill(110);
    if(abs(mouseX - 400) <= 80 && abs(mouseY - 500) <= 40){
      fill(95);
      //detects press on the rectangle
      if(mousePressed){
        titleScreen = false;
        givenTime = 21;
        startTime = System.currentTimeMillis();
        endTime = startTime + (givenTime * 1000);
      }
    }
    rect(width / 2, 500, 160, 80);
    fill(255);
    textFont(createFont("Arial", 25));
    text("Click to\nBegin", width / 2,  490);
    textFont(createFont("Arial", 50));
    fill(0);
    text("Totally Not\nCrossy Road", width / 2,  250);
    textFont(createFont("Arial", 25));
    text("Project by Kelvin Lin", width / 2,  400);
    textFont(createFont("Arial", 20));
    text("Arrow Keys To Move - You May Only Move Up, Right, Or Left", width / 2,  600);
    text("You Are Allowed To Go Through The Sides Of The Screen", width / 2,  640);
  }
  //displays game over screen if the gameOver boolean is true
  else{
    if(gameOver){
      //prints game over screen
      String deathMessage = "";
      if(deathCause[0] == true)
        deathMessage = "You Were Ran\nOver By A Car!";
      else if(deathCause[1] == true)
        deathMessage = "You Have Fallen\nInto A River!";
      else if(deathCause[2] == true)
        deathMessage = "You Were Ran\nOver By A Train!";
      else if(deathCause[3] == true)
        deathMessage = "You Have Ran\nOut Of Time!";
      background(color(200, 0, 0));
      fill(0);
      textFont(createFont("Arial", 35));
      text(deathMessage + "\nScore: " + score, width / 2, height / 4);
    }
    else{
      //clears every time draw is run
      background(color(50, 205, 50));
      //the starting back lane for aesthetics 
      if(score == 0){
        fill(color(200, 0, 0));
        rect(width / 2, height, width, 90);
        fill(0);
        textFont(createFont("Arial", 30));
        text("Start!", width / 2, height - 15);
      }
      //constantly updates difficulty based on player's score
      difficulty = score / 10;
      //sets time according to difficulty
      if(difficulty <= 6){
        givenTime = 23 - 2 * difficulty;
      }
      else{
        givenTime = 11;
      }
      timeRemaining = endTime - System.currentTimeMillis();
      //if the player runs out of time, the game is over
      if(timeRemaining <= 0){
        gameOver = true; 
        deathCause[3] = true;
      }
      
      //shows borders
      //flashes red when the time left is 3 or less
      for(int i = 0; i <= 8; i++){
        if(timeRemaining / 1000 <= 3)
          fill(color(150, 14, 41));
        else
          fill(0);
        rect(width / 2, (i * 100) + 50, width, 10);
      }
      //if a lane gets out of view, a new lane must be added to the ArrayList
      //a ConcurrentModificationException will be thrown if we modify the ArrayList that is being iterated
      //this program modifies a second ArrayList and switches between which to iterate
      if(lanes.get(0).outOfView && altLaneSwitch){
        altLaneSwitch = false;
        laneSwitch = true;
        altLanes = new ArrayList<Lane>();
        //copies all lanes from other ArrayList that are on screen
        for(Lane l: lanes){
          if(l.ypos <= 1000)
            altLanes.add(l);
        }
        altLanes.remove(0);
        //determines number of lanes to add based on difficulty
        if(difficulty <= 1)
          altLanes.add(createRandLane1((int)(Math.random() * 9))); //<>//
        else if(difficulty <= 5){
          addRandLane23(altLanes, 2, altLanes.get(altLanes.size() - 1).ypos);
        }
        else if(difficulty <= 7){
          addRandLane23(altLanes, (int)(Math.random() * 2) + 2, altLanes.get(altLanes.size() - 1).ypos);
        }
        else{
          addRandLane23(altLanes, 3, altLanes.get(altLanes.size() - 1).ypos);
        }
        //switches the lanes in use
        inUse = altLanes;
        notUse = lanes;
      }
      //duplicate of the previous if statement
      else if(altLanes.get(0).outOfView && laneSwitch){
        laneSwitch = false;
        altLaneSwitch = true;
        lanes = new ArrayList<Lane>();
        for(Lane l: altLanes){
          if(l.ypos <= 1000)
            lanes.add(l);
        }
        lanes.remove(0);
        if(difficulty <= 1)
          lanes.add(createRandLane1((int)(Math.random() * 9)));
        else if(difficulty <= 5){
          addRandLane23(lanes, 2, lanes.get(lanes.size() - 1).ypos);
        }
        else if(difficulty <= 7){
          addRandLane23(lanes, (int)(Math.random() * 2) + 2, lanes.get(lanes.size() - 1).ypos);
        }
        else{
          addRandLane23(lanes, 3, lanes.get(lanes.size() - 1).ypos);
        }
        inUse = lanes;
        notUse = altLanes;
      }
      //iterates the ArrayList that is currently "in use"
      if(inUse == lanes){
        for(Lane l: lanes){
          l.updateLane();
        }
      }
      else if(inUse == altLanes){
        for(Lane l: altLanes){
          l.updateLane();
        }
      }
      
      //Shows the player's box and time
      fill(color(0, 0, 200));
      rect(xPlayer, 700, 40, 40);
      fill(0);
      rect(xPlayer + 10, 690, 9, 9);
      rect(xPlayer - 10, 690, 9, 9);
      rect(xPlayer, 710, 25, 8);
      fill(0);
      textFont(createFont("Arial", 20));
      text((int)(timeRemaining / 1000), xPlayer, 675);
    }
  }
}

//randomly creates 1 lane
Lane createRandLane1(int ranNum){
  Lane tempLane = new Lane(null, null, null);
  if(ranNum < 4){
    tempLane = new Lane(createCar(-100, (int)(Math.random() * 2)), null, null);  
  }
  else if(ranNum < 6){
    tempLane = new Lane(null, createLilyPad(-100), null);  
  }
  else{
    tempLane = new Lane(null, null, createTrain(-100, (int)(Math.random() * 2)));  
  }
  return tempLane;
}

//adds 2-3 lanes based on number
void addRandLane23(ArrayList<Lane> laneList, int laneNum, int ypos){
  int ranNum = (int)(Math.random() * 4);
  if(ranNum < 2){
    laneList.add(new Lane(createCar(ypos - 100, (int)(Math.random() * 2)), null, null)); 
    laneList.add(new Lane(createCar(ypos - 200, (int)(Math.random() * 2)), null, null)); 
    if(laneNum == 3){
      laneList.add(new Lane(createCar(ypos - 300, (int)(Math.random() * 2)), null, null)); 
    }
  }
  else if(ranNum == 2){
    laneList.add(new Lane(createCar(ypos - 100, (int)(Math.random() * 2)), null, null)); 
    if(laneNum == 3){
      laneList.add(new Lane(createCar(ypos - 200, (int)(Math.random() * 2)), null, null));
      laneList.add(new Lane(null, createLilyPad(ypos - 300), null));
    }
    else
      laneList.add(new Lane(null, createLilyPad(ypos - 200), null));
  }
  else{
    laneList.add(new Lane(null, null, createTrain(ypos - 100, (int)(Math.random() * 2))));  
    laneList.add(new Lane(null, null, createTrain(ypos - 200, (int)(Math.random() * 2)))); 
    if(laneNum == 3){
      laneList.add(new Lane(null, null, createTrain(ypos - 300, (int)(Math.random() * 2))));  
    }
  }
}

//creates a new car
ArrayList<Car> createCar(int yCoord, int direct){
  int amt;
  //amt of cars in a lane increase with difficulty
  switch(difficulty){
    case 0: amt = 2; break;
    case 1: amt = 2; break;
    case 2: amt = 3; break;
    case 3: amt = 3; break;
    case 4: amt = 3; break;
    case 5: amt = 4; break;
    default: amt = 4; break;
  }
  //equations to avoid overlapping cars and increasing randomization
  ArrayList<Car> newCars = new ArrayList<Car>();
  int startPos = (int)(Math.random() * 100), parameters = 0;
  for(int i = 0; i < amt; i++){
    parameters = (width - startPos) / (amt - i);
    startPos += (int)(Math.random() * (parameters - 49)) + 90;
    newCars.add(new Car(startPos, yCoord, direct));
  }
  return newCars;
}
ArrayList<LilyPad> createLilyPad(int yCoord){
  int amt;
  //amt of lilypads in a lane decrease with difficulty
  switch(difficulty){
    case 0: amt = 4; break;
    case 1: amt = 3; break;
    case 2: amt = 3; break;
    case 3: amt = 2; break;
    case 4: amt = 2; break;
    case 5: amt = 1; break;
    default: amt = 1; break;
  }
  //lilypads must be on locations where the player can move to (multiple of 50)
  ArrayList<LilyPad> newLilypads = new ArrayList<LilyPad>();
  ArrayList<Integer> yPositions = new ArrayList<Integer>();
  int ranPos;
  for(int i = 0; i < amt; i++){
    ranPos = (int)(Math.random() * 8) * 100 + 50; 
    while(yPositions.contains(ranPos))
      ranPos = (int)(Math.random() * 8) * 100 + 50;
    yPositions.add(ranPos);
    newLilypads.add(new LilyPad(ranPos, yCoord));
  }
  return newLilypads;
}
ArrayList<Train> createTrain(int yCoord, int direct){
  int delay;
  //the delay for a train decreases with difficulty
  switch(difficulty){
    case 0: delay = 4; break;
    case 1: delay = 3; break;
    case 2: delay = 4; break;
    case 3: delay = 4; break;
    case 4: delay = 3; break;
    case 5: delay = 3; break;
    default: delay = 2; break;
  }
  ArrayList<Train> newTrains = new ArrayList<Train>();
  newTrains.add(new Train(delay, yCoord, direct));
  return newTrains;
}

//includes all the cars, trains, lilypads
class Lane{
  ArrayList<Car> cars = new ArrayList<Car>();
  ArrayList<LilyPad> lilyPads = new ArrayList<LilyPad>();
  ArrayList<Train> trains = new ArrayList<Train>();
  boolean outOfView = false;
  boolean upPressed = false;
  int ypos;
  //simple constructor
  Lane(ArrayList<Car> carList, ArrayList<LilyPad> lpList, ArrayList<Train> trainList){
    cars = carList;
    lilyPads = lpList;
    trains = trainList;
    if(carList != null)
      ypos = cars.get(0).ypos;
    else if(lpList != null)
      ypos = lilyPads.get(0).ypos;
    else if(trainList != null)
     ypos = trains.get(0).ypos;
  }
  //constantly runs in draw
  void updateLane(){
    //uses car is that is the lane type
    if(cars != null){
      if(cars.get(0).ypos <= 800){
        //backdrop
        fill(color(128, 128, 128));
        rect(width / 2, cars.get(0).ypos, width, 90);
        //enables movement of cars towards the player
        for(Car c: cars){
          c.move();
        }
      }
      else if(!outOfView){
        outOfView = true;
      }
    }
    //uses lilypads if that is the lane type
    else if(lilyPads != null){
      if(lilyPads.get(0).ypos <= 800){
        //backdrop
        fill(color(25, 217, 255));
        rect(width / 2, lilyPads.get(0).ypos, width, 90);
        //enables lilypads to move towards the player
        for(LilyPad lp: lilyPads){
          lp.move();
        }
        //if player does not land on a lilypad, the game is over
        if(lilyPads.get(0).ypos == 700){
          waterDeath = true;
          for(LilyPad lp: lilyPads){
            if(lp.xpos == xPlayer)
              waterDeath = false;
          }
          if(waterDeath){
            gameOver = true;
            deathCause[1] = true;
          }
        }
      }
      else if(!outOfView){
        outOfView = true; 
      }
    }
    //uses trains if that is the lane type
    else if(trains != null){
      if(trains.get(0).ypos <= 800){
        //backdrop
        fill(color(169, 169, 169));
        rect(width / 2, trains.get(0).ypos, width, 90);
        for(int i = 0; i < 8; i++){
          fill(color(139, 69, 19));
          rect(i * 100 + 50, trains.get(0).ypos, 10, 110);      
        }
        if((trains.get(0).remainTime / 1000) <= 1)
          fill(color(255, 0, 0));
        else
          fill(color(60, 179, 113));
        ellipse(width /2, trains.get(0).ypos, 40, 40);
        textFont(createFont("Arial", 25));
        fill(0);
        text(((int)(trains.get(0).remainTime / 1000)), width / 2 + 1, trains.get(0).ypos + 8);
        //enables trains to move towards the player
        for(Train t: trains){
          t.move();
        }
      }
      else if(!outOfView){
        outOfView = true;
      }
    }
  }
}

class Car{
  int xpos;
  int ypos;
  int speed;
  int direction; //0-Right, 1-Left
  boolean upPressed = false;
  color carColor = color((int)(Math.random() * 256), (int)(Math.random() * 256), (int)(Math.random() * 256));
  Car(int x, int y, int d){
    xpos = x;
    ypos = y;
    direction = d;
  }
  //moves if up is pressed
  //detects collision of player with the cars
  void move(){
    if(keyPressed && key == CODED){
      if(keyCode == UP && upPressed){
        upPressed = false;
        ypos += 100;
      }
    }
    else if(!keyPressed || key != CODED || keyCode != UP){
      upPressed = true;
    } 
    //speed increases with difficulty
    switch(difficulty){
      case 0: speed = 4; break;
      case 1: speed = 4; break;
      case 2: speed = 6; break;
      case 3: speed = 6; break;
      case 4: speed = 7; break;
      case 5: speed = 7; break;
      case 6: speed = 8; break;
      default: speed = 8; break;
    }
    //if the car goes off the screen
    if(direction == 0){
      xpos += speed;
      if(xpos - 40 > width)
        xpos = -40;
    }
    else if(direction == 1){
      xpos -= speed;
      if(xpos + 40 < 0)
        xpos = width + 40;
    }
    //car's visuals
    fill(0);
    rect(xpos - 25, ypos - 25, 15, 8);
    rect(xpos - 25, ypos + 25, 15, 8);
    rect(xpos + 25, ypos - 25, 15, 8);
    rect(xpos + 25, ypos + 25, 15, 8);
    fill(carColor);
    rect(xpos, ypos, 80, 40);
    if(ypos == 700 && Math.abs(xPlayer - xpos) - 60 <= 0){
      gameOver = true;
      deathCause[0] = true;
    }
  }
}

class LilyPad{
  int xpos;
  int ypos;
  boolean upPressed = false;
  LilyPad(int x, int y){
    xpos = x;
    ypos = y;
  }
  //moves when player presses up
  void move(){
    fill(color(63, 255, 0));
    ellipseMode(CENTER);
    ellipse(xpos, ypos, 60, 60);
    if(keyPressed && key == CODED){
        if(keyCode == UP && upPressed){
          upPressed = false;
          ypos += 100;
        }
    }
    else if(!keyPressed || key != CODED || keyCode != UP){
      upPressed = true;
    }
  }

}

class Train{
  int xpos;
  int ypos;
  int delay;
  int direction;
  long trainStart, trainEnd, remainTime;
  boolean upPressed = false;
  Train(int d, int y, int direct){
    delay = d;
    ypos = y;
    direction = direct;
    trainStart = System.currentTimeMillis();
    trainEnd = trainStart + delay * 1000;
    if(direct == 0)
      xpos = -270;
    else if(direct == 1)
      xpos = width + 270;
  }
  //moves when player presses up
  //detects collision
  //causes train to appear after the timer hits 0
  void move(){
    if(keyPressed && key == CODED){
      if(keyCode == UP && upPressed){
        upPressed = false;
        ypos += 100;
      }
    }
    else if(!keyPressed || key != CODED || keyCode != UP){
      upPressed = true;
    }
    if(trainEnd - System.currentTimeMillis() < 1000){
      remainTime = 0;
      if(direction == 0){
        xpos += 25;
        rect(xpos + 220, ypos, 100, 60);
        rect(xpos + 110, ypos, 100, 60);
        rect(xpos, ypos, 100, 60);
        rect(xpos - 110, ypos, 100, 60);
        rect(xpos - 220, ypos, 100, 60);
      }
      else if(direction == 1){
        xpos -= 25;
        rect(xpos + 220, ypos, 100, 60);
        rect(xpos + 110, ypos, 100, 60);
        rect(xpos, ypos, 100, 60);
        rect(xpos - 110, ypos, 100, 60);
        rect(xpos - 220, ypos, 100, 60);
      }
      if(trainEnd - System.currentTimeMillis() < 200){
        trainStart = System.currentTimeMillis();
        trainEnd = trainStart + delay * 1000;
        remainTime = delay;
        if(direction == 0)
          xpos = -270;
        else if(direction == 1)
          xpos = width + 270;
      }
    }
    else
      remainTime = trainEnd - System.currentTimeMillis() + 1;
    if(ypos == 700 && Math.abs(xPlayer - xpos) - 310 <= 0){
      gameOver = true;
      deathCause[2] = true;
    }
  }
}

//allows player to move left and right
void keyPressed(){
  if(key == CODED){  
    if(keyCode == RIGHT){
     if(xPlayer + 50 >= width)
       xPlayer = 50;
       else
         xPlayer += 50;
     }
     if(keyCode == LEFT){
       if(xPlayer - 50 <= 0)
          xPlayer = width - 50;
       else
         xPlayer -= 50;
     }
  }
}

//increases score and resets time everytime the player crosses a lane
void keyReleased(){
  if(key == CODED){
    if(keyCode == UP && !gameOver){
      score += 1;
      startTime = System.currentTimeMillis();
      endTime = startTime + (givenTime * 1000);
    }
  }
}
