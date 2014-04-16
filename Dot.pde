/*The Dot class defines the dots on the screen that Pacman eats during game play.
 it takes an X and Y in it's constructor to use as the coordinates for the dots.*/
class Dot {
  int xPos;
  int yPos;
  int radius = 5;
  boolean special;
  
  Dot( int X, int Y) {
    xPos = X;
    yPos = Y;
  }
  
  /*The update method draws the dot on screen when called. */
  void update() {
    fill(255);
    if(special) {
      radius = 15;
    }
    ellipse(xPos,yPos,radius,radius);
  }
}
