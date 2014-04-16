/*Simple wall class to define the size and location of a wall. It takes in an X and Y variable and sizes in the constructor then
uses drawWall to actually draw the wall.*/
class wall {
  int myX;
  int myY;
  int myW;
  int myH;
  wall(int X, int Y, int rectW, int rectH){
    myX = X;
    myY = Y;
    myW = rectW;
    myH = rectH;
  }
 void drawWall() {
     fill(0,0,255);
     rect(myX, myY, myW, myH);
  }
}
