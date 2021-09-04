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
  Timer recoveryFlashTimer = new Timer(1, 2, true);
  int recoveryFlashCount = 0;
  int recoveryFlashCountMax = 10;
  boolean isDrawable = true;
  
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

    if (isDrawable) {
      image(imgDrawn, x, y, imgWidth, imgHeight);
    }
  }
  
  void drawDestroyedImage() {
    if (recoveryFlashCount < recoveryFlashCountMax) {
      recoveryFlashTimer.tick();
      if (recoveryFlashTimer.isOvertime()) {
        recoveryFlashCount++;
  
        // Sprite flashing is done by switching between the idle and empty
        // images, leveraging much of the existing draw logic.
        isDrawable = (recoveryFlashCount % 2 == 0);
      }
    } else {
      imgDrawn = imgDestroyed;
    }
  }
  
  void startHurt() {
    // It turns out the game is difficult enough as is with static damage
    hp -= 10;
  }
  
  boolean isUsingDestroyedImage() {
    return imgDrawn == imgDestroyed;
  }
}
