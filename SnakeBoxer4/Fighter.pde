class Fighter {
  String name = "";
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
  PImage imgDrawn;
  boolean useAltAttack = false;
  Timer attack1Timer = new Timer(1, 10, false);
  int attack1Damage = 5;
  float attack1Multiplier = 1;
  boolean useSpecialAttack = false;
  Timer attackSpecialTimer = new Timer(1, 20, false);
  int attackSpecialDamage = 5;
  float attackSpecialMultiplier = 1;
  PImage imgAttackCharged;
  PImage imgAttackSpecial;
  Timer attackChargeTimer = new Timer(1, 60, false);
  Timer hurtTimer = new Timer(5, 100, false);
  boolean isRecoveryFlashing = false;
  PImage imgRecoveryFlash = loadImage("Empty.png");
  PImage imgGameOver = loadImage("GameOver.png");
  float imgWidth;
  float imgHeight;
  Timer recoveryFlashTimer = new Timer(1, 6, true);
  int recoveryFlashCount = 0;
  int recoveryFlashCountMax = 10;
  float hitBoundaryYUp;
  float hitBoundaryYDown;
  float speedXMultiplier = 1;
  float speedYMultiplier = 1;
  float damageMultiplier = 1;
  boolean isStalled = false;
  IntDict imgTint;
  boolean randomiseTintOnLifeRecovery = false;
  // Default direction is right, so true = facing left
  boolean isFlippedX = false;
  
  Fighter(float initialX, float initialY, String filenameIdle, String filenameBlock,
          String filenameHurt, String[] filenamesAttackNormal, float spriteWidth,
          float spriteHeight) {
    x = initialX;
    y = initialY;
    setImageIdle(filenameIdle);
    setImageBlock(filenameBlock);
    setImageHurt(filenameHurt);
    setImageAttackNormal(filenamesAttackNormal);
    imgDrawn = imgIdle;
    
    imgWidth = spriteWidth;
    imgHeight = spriteHeight;
    setHitBoundaryDefault();
    // Default image tint is to use no tinting
    imgTint = new IntDict();
    imgTint.set("R", 255);
    imgTint.set("G", 255);
    imgTint.set("B", 255);
  }
  
  Fighter(float initialX, float initialY, float spriteWidth, float spriteHeight, String presetName) {
    // Use an empty image as placeholder sprites
    this(initialX, initialY,
         "Empty.png",
         "Empty.png",
         "Empty.png",
         new String[]{
           "Empty.png",
           "Empty.png"
         },
         spriteWidth, spriteHeight);
         
    String presetNameUpperCase = presetName.toUpperCase();
    assignName(presetNameUpperCase);
    if (hasPresetName("BOXER JOE")) {
      setImageIdle("characters/BoxerJoe/BoxerJoe_Idle.png");
      setImageBlock("characters/BoxerJoe/BoxerJoe_Block.png");
      setImageHurt("characters/BoxerJoe/BoxerJoe_Hurt.png");
      setImageAttackNormal(new String[]{
        "characters/BoxerJoe/BoxerJoe_Attack1.png",
        "characters/BoxerJoe/BoxerJoe_Attack2.png"
      });
      // Ability: Speed boost
      speedYMultiplier *= 2;
    } else if (hasPresetName("COBRA JOE")) {
      setImageIdle("characters/CobraJoe/CobraJoe_Idle.png");
      setImageBlock("characters/CobraJoe/CobraJoe_Block.png");
      setImageHurt("characters/CobraJoe/CobraJoe_Hurt.png");
      setImageAttackNormal(new String[]{
        "characters/CobraJoe/CobraJoe_Attack1.png"
      });
      setChargeAttack("characters/CobraJoe/CobraJoe_Charged.png",
                      "characters/CobraJoe/CobraJoe_Attack2.png");
      // Ability: Powerful charged attack but requires considerable time to prepare 
      attackChargeTimer.timeMax *= 2;
      attackSpecialMultiplier *= 5;
    } else if (hasPresetName("CRAB")) {
      setImageIdle("characters/Crab/Crab_Idle.png");
      setImageBlock("characters/Crab/Crab_Block.png");
      setImageHurt("characters/Crab/Crab_Hurt.png");
      setImageAttackNormal(new String[]{
        "characters/Crab/Crab_Attack1.png",
        "characters/Crab/Crab_Attack2.png"
      });
      // Ability: All damage taken is halved
      damageMultiplier *= 0.5;
    } else if (hasPresetName("ICE BREAKER")) {
      setImageIdle("characters/IceBreaker/IceBreaker_Idle.png");
      setImageBlock("characters/IceBreaker/IceBreaker_Block.png");
      setImageHurt("characters/IceBreaker/IceBreaker_Hurt.png");
      setImageAttackNormal(new String[]{
        "characters/IceBreaker/IceBreaker_Attack1.png",
        "characters/IceBreaker/IceBreaker_Attack2.png"
      });
      setChargeAttack("characters/IceBreaker/IceBreaker_Charged.png",
                      "characters/IceBreaker/IceBreaker_Attack3.png");
      // Ability: Charged attack that powers up as the enemy is hit
      attackSpecialMultiplier *= 2;
    } else if (hasPresetName("SNAKE")) {
      setImageIdle("characters/Snake/Snake_Idle.png");
      setImageBlock("characters/Snake/Snake_Block.png");
      setImageHurt("characters/Snake/Snake_Hurt.png");
      setImageAttackNormal(new String[]{
        "characters/Snake/Snake_Attack1.png"
      });
      // Ability: Boosted speed, attack and defence each time the fighter loses a life
    } else if (hasPresetName("SNAKE FIST")) {
      setImageIdle("characters/SnakeFist/SnakeFist_Idle.png");
      setImageBlock("characters/SnakeFist/SnakeFist_Block.png");
      setImageHurt("characters/SnakeFist/SnakeFist_Hurt.png");
      setImageAttackNormal(new String[]{
        "characters/SnakeFist/SnakeFist_Attack1.png",
        "characters/SnakeFist/SnakeFist_Attack2.png"
      });
      setChargeAttack("characters/SnakeFist/SnakeFist_Charged.png",
                      "characters/SnakeFist/SnakeFist_Attack3.png");
      // Ability: Charged attack the scales inversely with HP
      attackSpecialMultiplier *= 3;
    } else if (hasPresetName("STRONG BAD")) {
      setImageIdle("characters/StrongBad/StrongBad_Idle.png");
      setImageBlock("characters/StrongBad/StrongBad_Block.png");
      setImageHurt("characters/StrongBad/StrongBad_Hurt.png");
      setImageAttackNormal(new String[]{
        "characters/StrongBad/StrongBad_Attack1.png",
        "characters/StrongBad/StrongBad_Attack2.png"
      });
      // Ability: Boosted speed, attack and defence until the fighter loses a life
      float multiplier = 2;
      speedXMultiplier *= multiplier;
      speedYMultiplier *= multiplier;
      attack1Multiplier *= multiplier;
      damageMultiplier /= multiplier;
    } else if (hasPresetName("STRONG MAD")) {
      setImageIdle("characters/StrongMad/StrongMad_Idle.png");
      setImageBlock("characters/StrongMad/StrongMad_Block.png");
      setImageHurt("characters/StrongMad/StrongMad_Hurt.png");
      setImageAttackNormal(new String[]{
        "characters/StrongMad/StrongMad_Attack1.png",
        "characters/StrongMad/StrongMad_Attack2.png"
      });
      // Ability: Increased punch range
      setHitBoundary(0.25);
    }
    
    // A shortcut way to set the correct drawn image as idling
    resetToIdle();
  }
  
  boolean isUsingPreset() {
    return name.length() > 0;
  }
  
  boolean hasPresetName(String presetName) {
    return presetName.toUpperCase() == name;
  }
  
  void presetActivateLifeRecoveryAbility() {
    if (isUsingPreset()) {
      if (hasPresetName("SNAKE")) {
        float multiplier = 0.75;
        speedXMultiplier += multiplier;
        speedYMultiplier += multiplier;
        attack1Multiplier += multiplier;
        // Damage multiplier should never reach 0, otherwise the fighter is invincible
        damageMultiplier *= multiplier;
      } else if (hasPresetName("STRONG BAD")) {
        presetDeactivateAbility();
      }
    }
  }
  
  void presetActivateHealthRecoveryAbility() {
    if (isUsingPreset()) {
      if (hasPresetName("SNAKE FIST")) {
        attackSpecialMultiplier = min((hpMax / hp), 8);
      }
    }
  }
  
  void presetActivateOnHitAbility() {
    if (isUsingPreset()) {
      if (hasPresetName("ICE BREAKER")) {
        attackSpecialMultiplier = min(attackSpecialMultiplier + 0.01, 8);
      }
    }
  }
  
  void presetDeactivateAbility() {
    if (isUsingPreset()) {
      setHitBoundaryDefault();
      attackSpecialMultiplier = 1;
      attack1Multiplier = 1;
      speedXMultiplier = 1;
      speedYMultiplier = 1;
      damageMultiplier = 1;
      useSpecialAttack = false;
    }
  }
  
  void setHitBoundary(float factor) {
    // Sets the zone in which an enemy has to be within to receive a hit from the fighter.
    // Measurements are relative to the image centre. 
    hitBoundaryYUp = imgHeight * factor;
    hitBoundaryYDown = imgHeight * factor;
  }
  
  void setHitBoundaryDefault() {
    setHitBoundary(0.125);
  }
  
  void setImageIdle(String filename) {
    imgIdle = loadImage(filename);
  }
  
  void setImageBlock(String filename) {
    imgBlock = loadImage(filename);
  }
  
  void setImageHurt(String filename) {
    imgHurt = loadImage(filename);
  }
  
  void setImageAttackNormal(String[] filenames) {
    imgAttackNormal = new PImage[filenames.length];
    for (int i = 0; i < filenames.length; i++) {
      imgAttackNormal[i] = loadImage(filenames[i]);
    }
  }
  
  void setLives(int initialLives) {
    lives = initialLives;
    livesMax = initialLives;
  }
  
  void resetToIdle() {
    attack1Timer.reset();
    attackSpecialTimer.reset();
    hurtTimer.reset();
    imgDrawn = imgIdle;
    attackChargeTimer.reset();
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
    if (!attack1Timer.isOvertime() && !attackSpecialTimer.isOvertime()) {
      attack1Timer.reset();
      attackSpecialTimer.reset();
      setRegularAttackImage();
    }
  }
  
  void processAction() {
    // This function handles the progression of actions that require
    // some elapsed time to complete, such as attacking or getting hurt.
    
    // User is doing an attack, and midway through completing it.
    if (isUsingAttackImage()) {
      attack1Timer.tick();
      attackSpecialTimer.tick();
      
      // User has finished doing an attack.
      if ((attack1Timer.isOvertime() && !attackChargeTimer.isOvertime()) ||
          (attackSpecialTimer.isOvertime() && attackChargeTimer.isOvertime())) {
        resetToIdle();
      }
    } else if (isUsingHurtImage()) {
      hurtTimer.tick();
      
      // User has recovered from the hit
      if (hurtTimer.isOvertime()) {
        resetToIdle();
        presetActivateHealthRecoveryAbility();
        
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
    } else if (isUsingBlockImage()) {
      // User is blocking
      
      if (useSpecialAttack) {
        attackChargeTimer.tick();
        if (attackChargeTimer.isOvertime()) {
          imgDrawn = imgAttackCharged;
        }
      }
    }
    
    // User is in the midst of recovering from losing a life 
    if (isRecoveryFlashing) {
      if (recoveryFlashCount < recoveryFlashCountMax) {
        recoveryFlashTimer.tick();
        
        // Transition between individual flashes
        if (recoveryFlashTimer.isOvertime()) {
          recoveryFlashCount++;
          recoveryFlashTimer.reset();
          
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
        recoveryFlashTimer.reset();
        
        if (lives <= 0) {
          
          // User is in the GAME OVER stage after losing all lives
          imgDrawn = imgGameOver;
          hp = 0;
        } else {
          
          // User is ready to continue
          resetToIdle();
          presetActivateLifeRecoveryAbility();
          presetActivateHealthRecoveryAbility();
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
    // Check if the current image is the special attack
    if (imgAttackSpecial == imgDrawn) {
      return true;
    }
    
    // Check if the current image is one of the attack images
    for (int i = 0; i < imgAttackNormal.length; i++) {
      if (imgAttackNormal[i] == imgDrawn) {
        return true;
      }
    }
    return false;
  }
  
  boolean isUsingBlockImage() {
    return imgDrawn == imgBlock || (useSpecialAttack && imgDrawn == imgAttackCharged);
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
    if (!isUsingBlockImage() && !isUsingHurtImage()) {
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
    if (useSpecialAttack && imgDrawn == imgAttackSpecial) {
      // If this function is called while the player is using a special
      // attack, use that damage calculation instead.
      return attackSpecialDamage * attackSpecialMultiplier;
    }
    
    // Regular attack calculation
    return attack1Damage * attack1Multiplier;
  }
  
  boolean isWithinHitBoundary(float playerMinX, float playerMaxX,
                              float playerMinY, float playerMaxY) {
    return y >= playerMinY && y <= playerMaxY &&
           x >= playerMinX && x <= playerMaxX;
  }
  
  void randomiseImageTint() {
    imgTint.set("R", (int)random(0, 256));
    imgTint.set("G", (int)random(0, 256));
    imgTint.set("B", (int)random(0, 256));
  }
  
  void drawImage() {
    float tempX = x;
    
    pushMatrix();
    if (isFlippedX) {
      // Flipping an image requires rescaling but also adjustment of the x, y
      // variables based on said rescaling.
      scale(-1, 1);
      x *= -1;
    }
    
    imageMode(CENTER);
    tint(imgTint.get("R"), imgTint.get("G"), imgTint.get("B"));
    image(imgDrawn, x, y, imgWidth, imgHeight);
    
    // Restore normal player coordinates
    popMatrix();
    x = tempX;
  }
  
  void setChargeAttack(String filenameAttackCharged, String filenameAttackSpecial) {
    imgAttackCharged = loadImage(filenameAttackCharged);
    imgAttackSpecial = loadImage(filenameAttackSpecial);
    useSpecialAttack = true;
  }
  
  boolean isChargedForSpecialAttack() {
    return useSpecialAttack && attackChargeTimer.isOvertime();
  }
  
  void startSpecialAttack() {
    // Reuse the regular attack timer for the duration of the special attack
    if (!attackSpecialTimer.isOvertime()) {
      imgDrawn = imgAttackSpecial;
    }
  }
  
  void assignName(String enteredName)  {
    name = enteredName;
  }
  
}
