class MovingEnemy {
  float hpMax = 1;
  float hp = hpMax;
  float x;
  float y;
  float[] positionOptionsX;
  float[] positionOptionsY;
  PImage imgHurt;
  PImage[] imgMoving;
  boolean isRecoveryFlashing = false;
  PImage imgRecoveryFlash = loadImage("Empty.png");
  float imgWidth;
  float imgHeight;
  PImage imgDrawn;
  int imgMovingIndex = 0;
  Timer imgMovingTimer = new Timer(1, 3, true);
  Timer recoveryFlashTimer = new Timer(1, 2, true);
  int recoveryFlashCount = 0;
  int recoveryFlashCountMax = 10;
  float speedXMultiplier = 1;
  boolean isFlipped = false; // True if the enemy is moving from right to left
  
  MovingEnemy(float initialX, float initialY, String filenameHurt,
              String[] filenamesIdle, float spriteWidth, float spriteHeight,
              float[] posssibleX, float[] posssibleY) {
    positionOptionsX = posssibleX;
    positionOptionsY = posssibleY;
    
    imgHurt = loadImage(filenameHurt);
    imgMoving = new PImage[filenamesIdle.length];
    for (int i = 0; i < filenamesIdle.length; i++) {
      imgMoving[i] = loadImage(filenamesIdle[i]);       
    }
    imgWidth = spriteWidth;
    imgHeight = spriteHeight;
    // Manually assign the x,y coordinates after resetting so that the initial
    // x,y, parameters take an effect.
    // Mainly done this way to minimise logic duplication.
    reset();
    x = initialX;
    y = initialY;
    setFlipStatus();
  }
  
  void drawImage() {
    float tempX = x;
    
    if (!isRecoveryFlashing) {
      // Toggles between the movement images over time
      imgMovingTimer.tick();
      if (imgMovingTimer.isOvertime()) {
        imgMovingIndex++;
        // Loop back to the first image after a full cycle
        imgMovingIndex %= imgMoving.length;
        imgDrawn = imgMoving[imgMovingIndex];
      }
    }
    
    pushMatrix();
    if (isFlipped) {
      // Flipping an image requires rescaling but also adjustment of the x, y
      // variables based on said rescaling.
      scale(-1, 1);
      x *= -1;
    }
    
    imageMode(CENTER);
    image(imgDrawn, x, y, imgWidth, imgHeight);
    popMatrix();
    x = tempX;
  }
  
  void step(float stepX) {
    int flipFactor = 1;
    if (isFlipped) {
      flipFactor *= -1;
    }
    x += stepX * speedXMultiplier * flipFactor;
  }
  
  void startHurt() {
    // The enemy is about to perish, but the function is called
    // "startHurt" to be consistent with other classes
    isRecoveryFlashing = true;
    imgDrawn = imgHurt;
  }
  
  void processAction() {
    if (isRecoveryFlashing) {
      if (recoveryFlashCount < recoveryFlashCountMax) {
        recoveryFlashTimer.tick();
        
        // Transition between individual flashes
        if (recoveryFlashTimer.isOvertime()) {
          recoveryFlashCount++;
          
          // Sprite flashing is done by switching between the idle and empty
          // images, leveraging much of the existing draw logic.
          if (recoveryFlashCount % 2 == 0) {
            imgDrawn = imgHurt;
          } else {
            imgDrawn = imgRecoveryFlash;
          }
        }
      } else {
        reset();
      }
    }
  }
  
  void reset() {
    int randomY = (int)random(positionOptionsY.length);
    int randomX = (int)random(positionOptionsX.length);
    
    isRecoveryFlashing = false;
    recoveryFlashCount = 0;
    recoveryFlashTimer.reset();
    hp = hpMax;
    x = positionOptionsX[randomX];
    y = positionOptionsY[randomY];
    imgDrawn = imgMoving[0];
    setFlipStatus();
  }
  
  void setFlipStatus() {
    isFlipped = x > (width * 0.5);
  }
}
