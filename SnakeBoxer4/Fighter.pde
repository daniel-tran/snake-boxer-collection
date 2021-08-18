class Fighter {
  float hpMax = 100;
  float hp = hpMax;
  int lives = 1;
  int livesMax = lives;
  float x;
  float y;
  PImage imgIdle;
  PImage imgBlock;
  PImage imgHurt;
  PImage[] imgAttackNormal;
  int imgAttackMarker = 0; // Index for which normal attack image to use 
  // PImage imgAttack2; // Charge attack not implemented
  PImage imgDrawn;
  boolean useAltAttack = false;
  int attack1Timer = 0;
  int attack1TimerInc = 5;
  int attack1TimerMax = 100;
  int attack1Damage = 5;
  int hurtTimer = 0;
  int hurtTimerInc = 5;
  int hurtTimerMax = 100;
  boolean isRecoveryFlashing = false;
  PImage imgRecoveryFlash = loadImage("Empty.png");
  PImage imgGameOver = loadImage("GameOver.png");
  float imgWidth;
  float imgHeight;
  int recoveryFlashTimer = 0;
  int recoveryFlashTimerInc = attack1TimerInc;
  int recoveryFlashTimerMax = 30;
  int recoveryFlashCount = 0;
  int recoveryFlashCountMax = 10;
  float hitBoundaryYUp;
  float hitBoundaryYDown;
  float speedXMultiplier = 1;
  float speedYMultiplier = 1;
  float attack1Multiplier = 1;
  // float attack2Multiplier = 1; // Charge attack not implemented
  float damageMultiplier = 1;
  boolean isStalled = false;
  IntDict imgTint;
  boolean randomiseTintOnLifeRecovery = false;
  
  Fighter(float initialX, float initialY, String filenameIdle, String filenameBlock,
          String filenameHurt, String[] filenamesAttackNormal, float spriteWidth,
          float spriteHeight) {
    x = initialX;
    y = initialY;
    imgIdle = loadImage(filenameIdle);
    imgDrawn = imgIdle;
    imgBlock = loadImage(filenameBlock);
    imgHurt = loadImage(filenameHurt);
    imgAttackNormal = new PImage[filenamesAttackNormal.length];
    for (int i = 0; i < filenamesAttackNormal.length; i++) {
      imgAttackNormal[i] = loadImage(filenamesAttackNormal[i]);
    }
    imgWidth = spriteWidth;
    imgHeight = spriteHeight;
    hitBoundaryYUp = spriteHeight * 0.125;
    hitBoundaryYDown = spriteHeight * 0.125;
    // Default image tint is to use no tinting
    imgTint = new IntDict();
    imgTint.set("R", 255);
    imgTint.set("G", 255);
    imgTint.set("B", 255);
  }
  
  void setLives(int initialLives) {
    lives = initialLives;
    livesMax = initialLives;
  }
  
  void resetToIdle() {
    attack1Timer = 0;
    hurtTimer = 0;
    imgDrawn = imgIdle;
  }
  
  void keepWithinBoundary(float playerMinX, float playerMaxX,
                          float playerMinY, float playerMaxY) {
    if (x < playerMinX) {
      x = playerMinX;
    } else if (x > playerMaxX) {
      x = playerMaxX;
    }
                            
    if (y < playerMinY) {
      y = playerMinY;
    } else if (y > playerMaxY) {
      y = playerMaxY;
    }
  }
  
  void startBlock() {
    imgDrawn = imgBlock;
  }
  
  void startAttack() {
    if (attack1Timer < attack1TimerMax) {
      setRegularAttackImage();
    }
  }
  
  void processAction() {
    // This function handles the progression of actions that require
    // some elapsed time to complete, such as attacking or getting hurt.
    
    // User is doing an attack, and midway through completing it.
    if (isUsingAttackImage()) {
      attack1Timer += attack1TimerInc;
      
      // User has finished doing an attack.
      if (attack1Timer > attack1TimerMax) {
        resetToIdle();
      }
    } else if (isUsingHurtImage()) {
      hurtTimer += hurtTimerInc;
      
      // User has recovered from the hit
      if (hurtTimer > hurtTimerMax) {
        resetToIdle();
        
        // After recovering from a hit, there might need to be extra animations
        // to play if the player lost a life.
        isRecoveryFlashing = hp <= 0;
        if (isRecoveryFlashing) {
          lives--;
          
          if (randomiseTintOnLifeRecovery) {
            randomiseImageTint();
          }
          // Health restoration happens before the recovery flashing completes
          if (lives > 0) {
            hp = hpMax;
          }
        }
      }
    }
    
    // User is in the midst of recovering from losing a life 
    if (isRecoveryFlashing) {
      if (recoveryFlashCount < recoveryFlashCountMax) {
        recoveryFlashTimer += recoveryFlashTimerInc;
        
        // Transition between individual flashes
        if (recoveryFlashTimer >= recoveryFlashTimerMax) {
          recoveryFlashCount++;
          recoveryFlashTimer = 0;
          
          // Sprite flashing is done by switching between the idle and empty
          // images, leveraging much of the existing draw logic.
          if (recoveryFlashCount % 2 == 0) {
            imgDrawn = imgIdle;
          } else {
            imgDrawn = imgRecoveryFlash;
          }
        }
      } else {
        
        // User has recovered from losing a life
        isRecoveryFlashing = false;
        recoveryFlashCount = 0;
        recoveryFlashTimer = 0;
        
        if (lives <= 0) {
          
          // User is in the GAME OVER stage after losing all lives
          imgDrawn = imgGameOver;
          hp = 0;
        } else {
          
          // User is ready to continue
          resetToIdle();
        }
      }
    }
  }
  
  void setRegularAttackImage() {
    // Cycle through the regular and alternate attacks
    imgDrawn = imgAttackNormal[imgAttackMarker];
    imgAttackMarker = (imgAttackMarker + 1) % imgAttackNormal.length; 
  }
  
  boolean isUsingAttackImage() {
    // Check if the current image is one of the attack images
    for (int i = 0; i < imgAttackNormal.length; i++) {
      if (imgAttackNormal[i] == imgDrawn) {
        return true;
      }
    }
    return false;
  }
  
  boolean isUsingHurtImage() {
    return imgDrawn == imgHurt;
  }
  
  boolean isUsingIdleImage() {
    return imgDrawn == imgIdle;
  }
  
  boolean isUsingGameOverImage() {
    return imgDrawn == imgGameOver;
  }
  
  void startHurt(float damage) {
    if (imgDrawn != imgBlock && !isUsingHurtImage()) {
      imgDrawn = imgHurt;
      hp -= damage * damageMultiplier;
      if (hp < 0) {
        hp = 0;
      }
    }
  }
  
  boolean isPlayable() {
    // True if the user is allowed to make actions
    return !(isRecoveryFlashing || lives <= 0 || hp <= 0 || isStalled);
  }
  
  float getAttackDamage() {
    // Can be extended to account for different attacks
    return attack1Damage * attack1Multiplier;
  }
  
  boolean isWithinHitBoundary(float playerMinX, float playerMaxX,
                              float playerMinY, float playerMaxY) {
    return y >= playerMinY && y <= playerMaxY;
  }
  
  void randomiseImageTint() {
    imgTint.set("R", (int)random(0, 256));
    imgTint.set("G", (int)random(0, 256));
    imgTint.set("B", (int)random(0, 256));
  }
  
}
