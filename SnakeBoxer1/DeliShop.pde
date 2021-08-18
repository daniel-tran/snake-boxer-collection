class DeliShop {
  float x;
  float y;
  float hpMax = 100;
  float hp = hpMax;
  PImage imgDrawn;
  PImage imgIdle;
  PImage imgDestroyed;
  float imgWidth;
  float imgHeight;
  int recoveryFlashTimer = 0;
  int recoveryFlashTimerInc = 5;
  int recoveryFlashTimerMax = 10;
  int recoveryFlashCount = 0;
  int recoveryFlashCountMax = 10;
  PImage imgDestroyedFlash = loadImage("Empty.png");
  
  DeliShop(float initialX, float initialY, float spriteWidth, float spriteHeight,
           String filenameIdle, String filenameDestroyed) {
    x = initialX;
    y = initialY;
    imgWidth = spriteWidth;
    imgHeight = spriteHeight;
    imgIdle = loadImage(filenameIdle);
    imgDrawn = imgIdle;
    imgDestroyed = loadImage(filenameDestroyed);
  }
  
  boolean isActive() {
    return hp > 0;
  }
  
  void drawImage() {
    imageMode(CENTER);
    if (hp <= 0) {
      drawDestroyedImage();
    }
    image(imgDrawn, x, y, imgWidth, imgHeight);
  }
  
  void drawDestroyedImage() {
    if (recoveryFlashCount < recoveryFlashCountMax) {
      recoveryFlashTimer += recoveryFlashTimerInc;
      if (recoveryFlashTimer >= recoveryFlashTimerMax) {
        recoveryFlashCount++;
        recoveryFlashTimer = 0;
  
        // Sprite flashing is done by switching between the idle and empty
        // images, leveraging much of the existing draw logic.
        if (recoveryFlashCount % 2 == 0) {
          imgDrawn = imgIdle;
        } else {
          imgDrawn = imgDestroyedFlash;
        }
      }
    } else {
      imgDrawn = imgDestroyed;
    }
  }
  
  void startHurt() {
    // It turns out the game is difficult enough as is with static damage
    hp -= 10;
  }
}
