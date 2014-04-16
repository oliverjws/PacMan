/*Ghost class defines the methods and variables used in the creation and operation of the pacman ghosts*/
class Ghost {
  int ghostType;
  int xPos;
  int yPos;
  int W = 30;
  int H = 30;
  int state;
  int speed = 1;
  int randomCount = 0;
  int scaredTimer = 0;
  int timeOut = 0;
  
  boolean alive = true;
  boolean isMoving = true;
  
  PImage ghostImage;
  
/*The Ghost constructor takes in an int ghost number (used to tell what kind of ghost) and the ghost image. The ghostnumber becomes
the ghost type and a series of if statemetns determines what coordinates match that ghost and what initial direction the ghost
should travel.*/  
  Ghost(int ghostNumber,PImage ghost) {
    ghostImage = ghost;
    ghostType = ghostNumber;
    if(ghostNumber == 1) {
      xPos = (width/2)- 45;
      yPos = 225;
      state = 4;
    }
    if(ghostNumber == 2 ) {
      xPos = (width/2)+5;
      yPos = 225;
      state = 2;
    }
    if(ghostNumber == 3 ) {
      xPos = (width/2)-45;
      yPos = 270;
      state = 1;
    }
    if(ghostNumber == 4 ) {
      xPos = (width/2)+5;
      yPos = 270;
      state = 1;
    }
  }
  
 /*Update advances the ghost forward and draws them on the screen. It uses the scared timer to determine what kind of ghost to draw.*/
  void update() {
    if(alive && scaredTimer <= 0) {
      image(ghostImage, xPos,yPos,W,H);
    } else if(alive && scaredTimer>0) {
      scaredTimer --;
      if(scaredTimer < 125 && scaredTimer%2 == 0) {
        image(scaredGhost,xPos,yPos,W,H);
      } else if(scaredTimer < 125) {
        image(timeGhost,xPos,yPos,W,H);
      } else {
        image(scaredGhost,xPos,yPos,W,H);
      }
    }
    /*The game checks if the ghost has collided with a wall, if it hasn't then it checks to see if the ghost has moved down the
    side tunnles. The method then uses the state of the ghost to determine which direction to move it. Finally if the ghost is 
    found to be at certain X and Y values then a random spin occurs to cause the ghost to sometimes turn into an area that 
    it otherwise would never reach as there are no walls to impact with. */
    if(isMoving && !checkCollision(myWalls, state)) {
      checkSideTunnels();
      if(state == 1) {
        yPos -= speed;
      } else if(state == 2) {
        xPos += speed;
      } else if(state == 3) {
        yPos += speed;
      } else if(state == 4) {
        xPos -= speed;
      }
      if((yPos == 275|| yPos == 175 || yPos == 375) && (state == 1 || state == 3)) { 
        if(random(1,5000) > 3000) {
          int spin = (int) random(1,3);
          if(spin == 1) {
            state = 4;
          } else {
            state = 2;
          }
        }
      }
      if((xPos == 225 || xPos == 275) && (state == 2 || state == 4) ) {
        if(random(1,5000) > 3000) { 
          int spin = (int) random(1,3);
          if(spin == 1) {
            state = 1;
          } else {
            state = 3;
          }
        }
      }  
      }
      /*If a collison has occurred then the method steps the ghost back by one to get them out of the "no zone." It then stores
      their old state in a temporary variable and enters a while loop, this while loop chooses a random variable and checks to
      see if it is the exact opposite direction from the ghosts previous direction (we don't want ghosts to bounce, we want them
      to turn). When it is found that a new direction has been chosen then the method exists the loop and recursively calls itslef.*/
      else if(isMoving) {
      if(state == 1) {
        yPos += 1;
      } else if(state == 2) {
        xPos += 1;
      } else if(state == 3) {
        yPos -= 1;
      } else if(state == 4) {
        xPos -= 1;
      }
      int oldState = state;
      boolean satisfied = false;
      while(!satisfied) {
        state = (int) random(1,5);
        if( oldState == 1 && state != 3) satisfied = true;
        if( oldState == 2 && state != 4) satisfied = true;
        if( oldState == 3 && state != 1) satisfied = true;
        if( oldState == 4 && state != 2) satisfied = true;
      }
      this.update();
    }
  }

/*checkSideTunnels is used to determine if the object has left the screen via the tunnels on the side and resets them to the 
other side of the board if they have. */
   void checkSideTunnels() {
    if(xPos <= -30) {
      xPos = width+30-10;
    }
    if(xPos >= width+30+2) {
      xPos = -30;
    }
  }
  
/*The checkCollision mehtod is used to determine when a ghost has impacted a wall. It takes in an array of walls, the state(direction)
to check. Based on the direction of travel the ghost looks to the respecitive wall that it is traveling towards and uses a distance
equation to see how far away it is. If a collision is detected then the method returns true. Otherwise it returns false. */  
  boolean checkCollision(wall[] walls, int checkState) {
    int checkDistance = 30;
    if(checkState == 1 && isMoving) {
      for( int i=0; i<walls.length; i++) {
        if(walls[i].myX <= xPos && walls[i].myX+walls[i].myW >= xPos+W && walls[i].myY < yPos) {
          if(abs(dist(xPos+15,yPos+15,xPos,walls[i].myY)) < checkDistance){
            return true;
          }
        }
      }
    } else if(checkState == 2 && isMoving) {
      for( int i=0; i<walls.length; i++) {
        if(walls[i].myY <= yPos && walls[i].myY+walls[i].myH >= yPos+H && walls[i].myX > xPos) {
          if(abs(dist(xPos+15,yPos+15,walls[i].myX,yPos)) < checkDistance) {
            return true;
          }
        }
      }
    } else if(checkState == 3 && isMoving) {
      for(int i=0; i<walls.length; i++) {
        if(walls[i].myX <= xPos && walls[i].myX+walls[i].myW >= xPos+W && walls[i].myY > yPos) {
          if(abs(dist(xPos+15,yPos+15,xPos,walls[i].myY)) < checkDistance) {
            return true;
          }
        }
      }
    } else if(checkState == 4 && isMoving) {
      for( int i=0; i<walls.length; i++) {
        if(walls[i].myY <= yPos && walls[i].myY+walls[i].myH >= yPos+H && walls[i].myX < xPos) {
          if(abs(dist(xPos+15,yPos+15,walls[i].myX,yPos)) < checkDistance) {
            return true;
          }
        }
      }
    }
    return false;
  }
}
