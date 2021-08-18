class MovingCollectible {
  float x;
  float y;
  float[] positionOptionsX;
  float[] positionOptionsY;
  PImage imgDrawn;
  PImage[] imgSelectionPositive;
  PImage[] imgSelectionNegative;
  boolean isNegative = false;
  boolean isCollected = false;
  int collectValue = 0;
  int collectValueBase = 100;
  int collectedTimer = 0;
  int collectedTimerInc = 1;
  int collectedTimerMax = 15;
  float speedXMultiplier = 1;
  float imgWidth;
  float imgHeight;
  
  MovingCollectible(float initialX, float initialY, float[] optionsX, float[] optionsY, 
                    String[] filenamesPositive, String[] filenamesNegative,
                    float spriteWidth, float spriteHeight) {
    positionOptionsX = optionsX;
    positionOptionsY = optionsY;
    imgSelectionPositive = new PImage[filenamesPositive.length];
    for (int i = 0; i < filenamesPositive.length; i++) {
      imgSelectionPositive[i] = loadImage(filenamesPositive[i]);       
    }
    imgSelectionNegative = new PImage[filenamesNegative.length];
    for (int i = 0; i < filenamesNegative.length; i++) {
      imgSelectionNegative[i] = loadImage(filenamesNegative[i]);       
    }
    // Use the reset function to set the initial image 
    reset();
    // Constructor x,y values take priority over random position
    x = initialX;
    y = initialY;
    imgWidth = spriteWidth;
    imgHeight = spriteHeight;
  }
  
  void reset() {
    int randomY = (int)random(positionOptionsY.length);
    int randomX = (int)random(positionOptionsX.length);
    x = positionOptionsX[randomX];
    y = positionOptionsY[randomY];
    
    isNegative = random(1) > 0.5;
    if (isNegative) {
      int randomImageIndex = (int)random(imgSelectionNegative.length);
      imgDrawn = imgSelectionNegative[randomImageIndex];
      collectValue = -collectValueBase * (randomImageIndex + 1);
    } else {
      int randomImageIndex = (int)random(imgSelectionPositive.length);
      imgDrawn = imgSelectionPositive[randomImageIndex];
      collectValue = collectValueBase * (randomImageIndex + 1); 
    }
    
    isCollected = false;
  }
  
  void step(float stepX) {
    if (!isCollected) {
      x += stepX * speedXMultiplier;
    }
  }
  
  boolean checkCollection(float initialX, float initialY) {
    return initialX >= x - (imgWidth * 0.5) &&
           initialX <= x + (imgWidth * 0.5) &&
           initialY >= y - (imgHeight * 0.5) &&
           initialY <= y + (imgHeight * 0.5);
  }
  
  void drawImage() {
    if (!isCollected) {
      imageMode(CENTER);
      image(imgDrawn, x, y, imgWidth, imgHeight);
    } else {
      // Show a brief message of what happened when the item was collected
      String collectionText = "+" + collectValue;
      if (isNegative) {
        fill(255, 0, 0);
        collectionText = "OUCH!";
      } else {
        fill(0, 255, 0);
      }
      text(collectionText, x, y);
      
      // Respawn item after a brief period
      collectedTimer += collectedTimerInc;
      if (collectedTimer >= collectedTimerMax) {
        collectedTimer = 0;
        reset();
      }
    }
  }
}
