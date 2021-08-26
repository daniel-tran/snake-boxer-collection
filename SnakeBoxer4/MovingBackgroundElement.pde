class MovingBackgroundElement {
  float x;
  float y;
  float elementWidth;
  float elementHeight;
  float[] positionOptionsX;
  float[] positionOptionsY;
  float resetX;
  float speedXMultiplier = 1;
  color fillColour;
  
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
    setFillColour(255, 255, 255);
  }
  
  void setFillColour(int r, int g, int b) {
    fillColour = color(r, g, b);
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
    fill(fillColour);
    rectMode(CENTER);
    rect(x, y, elementWidth, elementHeight);
  }
}
