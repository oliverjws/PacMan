/*This class handles the creation and methods of a pacman object.*/
class MrPacMan {
  int state = 4;
  float speed = 1;
  int xPos = 265;
  int yPos = 440;
  int startR = -150;
  int endR = 150;
  int radius = 35;
  int animationTimer = 0;
  
  boolean mouthOpen = true;
  boolean isMoving = true;
  
  /*Draws pacMan. If his mouth is open then an arc is drawn, if his mouth is closed then a simple circle will suffice.*/
  void drawPacMan() {
    fill(255,255,0);
    if(mouthOpen) {
      arc(xPos,yPos,radius,radius,radians(startR),radians(endR));
    } else {
      ellipse(xPos, yPos, radius, radius);
    }
  }
  
  /*The update method uses an animation timer to determine when to open pacman's mouth and when to close it. It also uses
  pacman's state to determine his direction of travel and thus which direction to add the speed variable to.*/
  void update() {
    if(isMoving) {
      animationTimer += 1;
      checkSideTunnels();
      if(animationTimer == 15) {
        animationTimer = 0;
        mouthOpen = !mouthOpen;
      }
      if(state == 1) {
        yPos -= speed;
      } else if(state == 2) {
        xPos += speed;
      } else if(state == 3) {
        yPos += speed;
      } else if(state == 4) {
        xPos -= speed;
      }
    }
  }
  
/*When called it takes in the new state for pacman (called from the keyPressed method). The method then changes the state variable
and the start and endR which are used to determine the black portion (mouth) of the arc*/ 
  void changeDirection (int newState) {
    state = newState;
    isMoving = true;
    if(state == 1) {
      startR = -60;
      endR = 240;
    } else if(state == 2) {
      startR = 30;
      endR = 330;
    } else if(state == 3) {
      startR = 120;
      endR = 420;
    } else if(state == 4) {
      startR = -150;
      endR = 150;
    }
  }
  
/*checkSideTunnels is used to determine if the object has left the screen via the tunnels on the side and resets them to the 
other side of the board if they have. */
  void checkSideTunnels() {
    if(xPos <= -radius-2) {
      xPos = width+radius-10;
    }
    if(xPos >= width+radius+2) {
      xPos = -radius;
    }
  }
  
 /*The check collision method for pacman checks if pacman has collided with a wall. It takes in an array of walls, the state
 to be checked, and whether or not it is pre check (a Check made before movment is made). If it is not a normal check then pacman looks
 ahead for a wall. If a pre check is enabled then pacman looks slightly further ahead, this method is used to determine if a wall is
 overhead pacman preventing him from turning. We want to know this so that he doesn't turn up in the middle of the board, but
 if the same distnace was used for both then pacman would also just stop in the middle of the board as well. Based on the state being checked
 pacman looks at only the walls that are "infront" of him, so we don't check other walls in a tunnel for instance. It then runs a distance
 equation on these walls to determine if a collision has occured, if one has then true is returned.*/ 
  boolean checkCollision(wall[] walls, int checkState, boolean preCheck) {
    int checkDistance;
    if(!preCheck) {
      checkDistance = 26;
    } else {
      checkDistance = 35;
    }
    if(checkState == 1 && isMoving) {
      for( int i=0; i<walls.length; i++) {
        if(walls[i].myX <= xPos+15 && walls[i].myX+walls[i].myW >= xPos-15 && walls[i].myY < yPos) {
          if(abs(dist(xPos,yPos,xPos,walls[i].myY)) + 2 < checkDistance){
            return true;
          }
        }
      }
    } else if(checkState == 2 && isMoving) {
      for( int i=0; i<walls.length; i++) {
        if(walls[i].myY <= yPos+15 && walls[i].myY+walls[i].myH+2>= yPos-15 && walls[i].myX > xPos) {
          if(abs(dist(xPos,yPos,walls[i].myX,yPos)) < checkDistance) {
            return true;
          }
        }
      }
    } else if(checkState == 3 && isMoving) {
      for(int i=0; i<walls.length; i++) {
        if(walls[i].myX <= xPos+15 && walls[i].myX+walls[i].myW >= xPos-15 && walls[i].myY > yPos) {
          if(abs(dist(xPos,yPos,xPos,walls[i].myY)) < checkDistance) {
            return true;
          }
        }
      }
    } else if(checkState == 4 && isMoving) {
      for( int i=0; i<walls.length; i++) {
        if(walls[i].myY <= yPos+15 && walls[i].myY+walls[i].myH+1 >= yPos-15 && walls[i].myX < xPos) {
          if(abs(dist(xPos,yPos,walls[i].myX,yPos)) < checkDistance) {
            return true;
          }
        }
      }
    }
   
    return false;
  }
}
