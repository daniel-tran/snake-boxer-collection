class Silhouette {
  float x;
  float y;
  PImage imgDrawn;
  float imgWidth;
  float imgHeight;
  float selectionMinX;
  float selectionMaxX;
  float selectionMinY;
  float selectionMaxY;
  boolean isSelected = false;
  
  Silhouette(float initialX, float initialY, float spriteWidth, float spriteHeight,
             String filename) {
    x = initialX;
    y = initialY;
    imgWidth = spriteWidth;
    imgHeight = spriteHeight;
    imgDrawn = loadImage(filename);
    // Default selection zone is set to the sprite dimensions
    selectionMinX = x - (imgWidth * 0.25);
    selectionMaxX = x + (imgWidth * 0.25);
    selectionMinY = y - (imgHeight * 0.25);
    selectionMaxY = y + (imgHeight * 0.25);
  }
  
  void setSelectionZone(float minX, float minY, float maxX, float maxY) {
    selectionMinX = minX;
    selectionMaxX = maxX;
    selectionMinY = minY;
    selectionMaxY = maxY;
  }
  
  void drawImage(boolean flipImage) {
    float tempX = x;
    // Flipping an image requires rescaling but also adjustment of the x, y
    // member variables based on said rescaling.
    pushMatrix();
    if (flipImage) {
      scale(-1, 1);
      x *= -1;
    }
    
    if (isSelected) {
      // Don't bother showing the silhouette, as the player will be drawn here
      tint(255, 0);
    } else {
      // Apply transparency without changing color
      tint(255, 126);
    }
    imageMode(CENTER);
    image(imgDrawn, x, y, imgWidth, imgHeight);
    
    // Revert back to original x,y coordinates now that the image is drawn
    popMatrix();
    x = tempX;
  }
  
  boolean wasPressed(float pressX, float pressY) {
    return pressX >= selectionMinX &&
           pressX < selectionMaxX &&
           pressY >= selectionMinY &&
           pressY < selectionMaxY;
  }
}
