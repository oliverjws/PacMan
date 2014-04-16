//Oliver Westlake-Simm 


//Import loads the minim library.

import ddf.minim.*;
/*Global arrays used to store the wall and ghost objects*/
wall[] myWalls;
Ghost[] Ghosts;
/*ArrayList of Dot objects, in this case it is best to use an arrayList
  as it allows us to dynamically shift the size of the arrays as objects
  are removed. This helps in offloading some of the processing work by not
  forcing the program to check every single dot every single frame */
ArrayList<Dot> myDots = new ArrayList<Dot>();
//Creates a pacman object.
MrPacMan pacman;
/*Loads the image holders for the various ghost images that are used throughout the game.
  the images are the original ones used in the Pacman game, no copyright infrigement is intended.
  The ghosts were created by cutting them from the original PNG image and saving them as their own
  files. This original can be found here: http://www.spritestitch.com/pacman-mini-cross-stitch-and-needlepoint-patterns/ */
PImage redGhost;
PImage greenGhost;
PImage orangeGhost;
PImage pinkGhost;
PImage scaredGhost;
PImage timeGhost;
//Loads two fonts used throughout the game to convey different messages.
PFont scoreFont;
PFont gameOverFont;
/*Ints used globally. Game score tracks the point socre, remaining lives tracs the number of lives
  that pacman has remaining. Level Display Count is a timer that is used to gauge how long to
  display the level up text. The level counter is used to tell what level the game is currenlty on. */
int gameScore = 0;
int remainingLives = 2;
int levelDisplayCount = 0;
int level = 1;
/*Booleans Used to track the state of the game */
boolean gameOver = false;
boolean levelUp = false;
/*Cretes the minim object which allows for the driving of the audio players created out of the minim library.*/
Minim minim;

/* Creation of the playable audiopfiles where the sounds will be stored.*/
AudioPlayer beginningMusic;
AudioPlayer chomp;
AudioPlayer death;
AudioPlayer eatGhost;
AudioPlayer intermission;
AudioPlayer ghostSiren;

void setup() {
//Set the size of the screen and call the function to construct the walls of the map.   
  size(530, 650);
  buildWalls();
//Load the Ghost Images that are used to draw the ghosts throughout the game.
  redGhost = loadImage("redghost.png");
  greenGhost = loadImage("GreenGhost.png");
  orangeGhost = loadImage("OrangeGhost.png");
  pinkGhost = loadImage("PinkGhost.png");
  scaredGhost = loadImage("ScaredGhost.png");
  timeGhost = loadImage("TimeOut.png");
//Loads the fonts from the data file. 
  scoreFont = loadFont("ScoreFont.vlw");
  gameOverFont = loadFont("GameOverFont.vlw");
//Intializes the minim object.  
  minim = new Minim(this);
//Uses the loadFile method to load the sound files into their various audio players. 
  beginningMusic = minim.loadFile("pacman_beginning.wav");
  chomp = minim.loadFile("pacman_chomp.wav");
  death = minim.loadFile("pacman_death.wav");
  eatGhost = minim.loadFile("pacman_eatghost.wav");
  intermission = minim.loadFile("pacman_intermission.wav");
  ghostSiren = minim.loadFile("pacman_siren.mp3");
//Calls the reset game method (see for further explanation) to trigger creation of game objects. 
  resetGame();
}

void draw() {
//Draws a black Background.
  background(0);
//Loops through the walls array and draws them on the screen.
  fill(0, 0, 255);
  for (int i=0; i<myWalls.length; i++) {
    myWalls[i].drawWall();
  }
//Prints the score and lives text that can alwasy be seen on the screen.
  fill(255,255,0);
  textFont(scoreFont, 25);
    text("SCORE: " + gameScore,10,600);
    text("LIVES: ",325,600);
  int tempX = 420;
  for(int i=0; i<remainingLives; i++) {
    arc(tempX,590,30,30,radians(30),radians(330));
    tempX += 40;
  }
/*The primary operator for the game, these sets of if statements determine the stateo of the game and takes
  the appropriate action*/
  
/*If the game is not over and we are not leveling up then game play is occuring, thus we first want to check if we 
  need to level up by calling level up. The game then loops through the dots, draws them, and checks if they have been
  eaten. Pacman is updated and drawn and it is determined if Pacman has run into a wall and thus needs to stop. The game 
  also drives the ghosts by calling their update method. Finally the game makes sure that pacman hasn't died.*/
  if(!gameOver && !levelUp) {
    checkLevelUp();
    for(int i=0; i<myDots.size(); i++) {
      myDots.get(i).update();
      checkEaten(myDots.get(i));
    }
    pacman.update();
    pacman.drawPacMan();
    if(pacman.checkCollision(myWalls,pacman.state,false)){
      pacman.isMoving = false;
    }
    for(int i=0; i<Ghosts.length; i++) {
       Ghosts[i].update();
    }
    checkTurnOver();
  }
/*If the game is determined to be over then Game Over is printed on the screen and the player is asked to click to restart.*/
  else if(gameOver) {
    fill(255,0,0);
    textFont(gameOverFont, 70);
    text("Game Over",100,300);
    textFont(gameOverFont,30);
    text("Click Anywhere to Restart",105,350);
  }
 /*During the levelup period the game prints the next level and counts down the display timer. When that display timer
   hits zero then the game is reset and advanced to the next level.*/
  else if(levelUp) {
    fill(255);
    textFont(gameOverFont, 70);
    text("Level " + level, 150,300);
    levelDisplayCount--;
    if(levelDisplayCount == 0) {
      levelUp = false;
      resetGame();
    }
  }
}

/*Key press methods watch the arrow keys to get input on the driving of pacman. Everytime the button is pressed the   
  checkCollision method is called on pacman and the precheck is enabled, this causes pacman to look further than usual 
  in the direction of his inteneded turn. This way Pacman won't be allowed to turn when there is a wall direcly next to him*/
void keyPressed() {
  if(key == CODED) {
    if( keyCode == UP && !pacman.checkCollision(myWalls,1,true) && !gameOver) {
      pacman.changeDirection(1);
    } else if(keyCode == RIGHT && !pacman.checkCollision(myWalls,2,true) && !gameOver) {
      pacman.changeDirection(2);
    } else if(keyCode == DOWN && !pacman.checkCollision(myWalls,3,true) && !gameOver) {
      pacman.changeDirection(3);
    } else if(keyCode == LEFT && !pacman.checkCollision(myWalls,4,true) && !gameOver) {
      pacman.changeDirection(4);
    }
  }
}

/*Used in the gameOver phase, this method resets the game to default values when the user clicks during the gameover screen.*/
void mousePressed() {
  if(gameOver) {
    resetGame();
    gameScore = 0;
    remainingLives = 2;
    gameOver = false;
  }
}

/*Method used to reset the gamestate when called. It makes an all new list of dots, ghosts, a new pacman, and restarts
  the music. */
void resetGame() {
  populateDots();
  Ghosts = fillGhosts();
  pacman = new MrPacMan();
  beginningMusic.rewind();
  beginningMusic.play();
  ghostSiren.loop();
}

/*Checks if all of the dots have been eaten, if they have, then the game changes to the levelup state, plays the intermission music,
  advances the level, and adds to the levelDisplayCount counter that acts as a timer. */
void checkLevelUp() {
  if(myDots.size() <= 0) {
    levelUp = true;
    levelDisplayCount += 275;
    level++;
    intermission.rewind();
    intermission.play();
    ghostSiren.pause();
  }
}

/*This file populates the wall array. It does so by creating a buffered reader and an array of size 64. This reader then uses
a try catch loop (used to catch errors without crashing the program) to access a file in the data folder contianing the coordinates
for the walls. These wall lines are read one by one, split by their commmas, transformed from strings to ints, and finally 
inputed into the array to create the walls for the game.*/
void buildWalls() {
  myWalls = new wall[64];
  BufferedReader reader;
  String line;
  int index = 0;
  reader = createReader("BoardLayout.txt");
  try {
    line = reader.readLine();
  } 
  catch (IOException e) {
    e.printStackTrace();
    line = null;
  }
  while (line != null) {
    String[] pieces = split(line, ",");
    myWalls[index] = new wall(int(pieces[0]), int(pieces[1]), int(pieces[2]), int(pieces[3]));
    index++;
    try {
      line = reader.readLine();
    } 
    catch (IOException e) {
      e.printStackTrace();
      line = null;
    }
  }
}

/*Method used to create the ghosts, it creates an empty array, creates the 4 types of ghosts in that array and then returns
the temporary array. */
Ghost[] fillGhosts() {
  Ghost[] temp = new Ghost[4];
  temp[0] = new Ghost(1, redGhost);
  temp[1] = new Ghost(2, greenGhost);
  temp[2] = new Ghost(3, orangeGhost);
  temp[3] = new Ghost(4, pinkGhost);
  return temp;
}

/*This method populates the dots on screen. In the case of populating the dots it is easier to populate every section of the map
and then remove the dots that aren't needed, rather than coding a set path for every single line. The program first creates a
dot for every square on screen and loads them into the arraylist. It then uses a secondary piece to remove the dots that aren't needed
(I.e.) dots inside the boxes along the top of the screen.*/
void populateDots() {
  int startX = 40;
  int startY = 40;
  for(int i=0; i<11; i++) {
    for(int j=0; j<10; j++) {
      Dot tempDot = new Dot(startX,startY);
      myDots.add(tempDot);
      startX += 50;
    }
    startX = 40;
    startY += 50;
  }
  for(int i=0; i<myDots.size(); i++) {
    if(myDots.get(i).yPos == 90) {
      int xtemp = myDots.get(i).xPos;
      if(xtemp == 90 || xtemp == 190 || xtemp == 340 || xtemp == 440) {
        myDots.remove(i);
        i--;
      }
      if(xtemp == 40 || xtemp == 490) {
        myDots.get(i).special = true;
      }
    }
    if(myDots.get(i).yPos == 240 || myDots.get(i).yPos == 340) {
      int xtemp = myDots.get(i).xPos;
      if(xtemp == 40 || xtemp == 90 || xtemp == 440 || xtemp == 490) {
        myDots.remove(i);
        i--;
      }
    }
    if(myDots.get(i).yPos == 490) {
      if(myDots.get(i).xPos == 40 || myDots.get(i).xPos == 490) {
        myDots.get(i).special = true;
      }
    }
  }
}

/*When called it moves the game to a game over state but dumping all of the objects used in game play  and pausing the muisc*/
void gameOver() {
  ghostSiren.pause();
  gameOver = true;
  pacman = null;
  for(int i=0; i<Ghosts.length; i++) {
    Ghosts[i] = null;
  }
  myDots = new ArrayList<Dot>();
}

/*Checks to see if pacman has died, or if a ghost has died. It uses an absolute distance equation to determine how far pacman
and a ghost are from each other. If this is found to be close enough then action is taken. If the ghosts are in their attack
state then pacman is dead, thus the death sound is played, remaining lives is decreased and new pacman and ghost objects are 
created. If the ghosts are in their flee state then the ghost is dead on contact, they are replaced with a new ghost at the start
point and pacman gets a point bonus.*/
void checkTurnOver() {
  for(int i=0; i<Ghosts.length; i++) {
    if(abs(dist(Ghosts[i].xPos+15,Ghosts[i].yPos+15,pacman.xPos,pacman.yPos)) <= 25 && Ghosts[i].scaredTimer <= 0) {
      death.rewind();
      death.play();
      if(remainingLives > 0) {
        remainingLives --; 
        Ghosts = fillGhosts();
        pacman = new MrPacMan();
      } else {
        gameOver();
        break;
      }
    }
    if(abs(dist(Ghosts[i].xPos+15,Ghosts[i].yPos+15,pacman.xPos,pacman.yPos)) <= 25 && Ghosts[i].scaredTimer > 0) {
      Ghosts[i] = new Ghost(Ghosts[i].ghostType, Ghosts[i].ghostImage);
      gameScore += 200;
      eatGhost.rewind();
      eatGhost.play();
    }
  }
}

/*Checks if pacman has eaten the dots by taking in a specific dot object and checking. It uses a distance equation to see if
pacman has intersected it. If the dot is not a special dot then points are added to the score count, a sound is played and the
dot is removed from the arraylist of dots. If the dot does have speical designation then the same action as before is taken but
time is also added to the ghosts scared counter which causes them to change to a flee state for a set amoutn of time.*/
void checkEaten(Dot theDot) {
  if(abs(dist(pacman.xPos,pacman.yPos,theDot.xPos,theDot.yPos)) <= 13 && !theDot.special) {
    chomp.rewind();
    chomp.play();
    myDots.remove(theDot);
    gameScore += 10;
  }
  if(abs(dist(pacman.xPos,pacman.yPos,theDot.xPos,theDot.yPos))<= 10 && theDot.special) {
    for(int i=0; i<Ghosts.length; i++) {
      Ghosts[i].scaredTimer = 800;
      chomp.rewind();
      chomp.play();
      gameScore += 50;
    }
    myDots.remove(theDot);
  }
 }

