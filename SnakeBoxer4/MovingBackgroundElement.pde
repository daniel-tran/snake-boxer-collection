class MovingBackgroundElement {
  float x;
  float y;
  float elementWidth;
  float elementHeight;
  float[] positionOptionsX;
  float[] positionOptionsY;
  float resetX;
  float speedXMultiplier = 1;
  IntDict fillColour;
  
  MovingBackgroundElement(float initialX, float initialY,
                          float[] posssibleX, float[] posssibleY,
                          float initialWidth, float initialHeight, 
                          float resetBoundaryX) {
    positionOptionsX = posssibleX;
    positionOptionsY = posssibleY;
    x = initialX;
    y = initialY;
    elementWidth = initialWidth;
    elementHeight = initialHeight;
    resetX = resetBoundaryX;
    // Default colour is white
    fillColour = new IntDict();
    fillColour.set("R", 255);
    fillColour.set("G", 255);
    fillColour.set("B", 255);
  }
  
  void setFillColour(int r, int g, int b) {
    fillColour.set("R", r);
    fillColour.set("G", g);
    fillColour.set("B", b);
  }
  
  void reset() {
    int randomY = (int)random(positionOptionsY.length);
    int randomX = (int)random(positionOptionsX.length);
    
    x = positionOptionsX[randomX];
    y = positionOptionsY[randomY];
  }
  
  void step(float stepX) {
    x += stepX * speedXMultiplier;
    if (x <= resetX) {
      reset();
    }
  }
  
  void drawElement() {
    fill(fillColour.get("R"), fillColour.get("G"), fillColour.get("B"));
    rectMode(CENTER);
    rect(x, y, elementWidth, elementHeight);
  }
}
