/*
Trogdor: Let's Burninate Phonics
- Survive the onslaught of letters by burninating them
- Click on a side of the screen to burninate in that direction
- Letters approach you from both sides of the screen
- As difficulty increases, the speed of the letters increase
*/
class MinigameBurninatePhonics extends MinigameManager {
  Fighter Trogdor = new Fighter(width * 0.5, height * 0.5,
                       "minigames/BurninatePhonics/Trogdor.png",
                       "minigames/BurninatePhonics/Empty.png",
                       "minigames/BurninatePhonics/TrogdorHurt.png",
                       new String[]{
                         "minigames/BurninatePhonics/TrogdorAttack.png"
                       },
                       localUnitX * 33, localUnitY * 33);
  boolean trogdorFlipped = false;
  float[][] phonicPositions;
  char[] phonicLetters = new char[]{'a', 'e', 'i', 'o', 'u'};
  
  MinigameBurninatePhonics(float localUnitWidth, float localUnitHeight) {
    super(localUnitWidth, localUnitHeight);
    setText("Burninate phonics!", 0);
    Trogdor.lives = 1;
    Trogdor.hp = Trogdor.lives;
    
    phonicPositions = new float[phonicLetters.length][2];
    for (int i =  0; i < phonicPositions.length; i++) {
      randomisePhonicPositionX(i);
      phonicPositions[i][1] = Trogdor.y;
    }
  }
  
  void randomisePhonicPositionX(int index) {
    boolean isSpawningFromLeft = random(1) < 0.5;
    float phonicSpawnDistance = width * 0.25;

    if (isSpawningFromLeft) {
      phonicPositions[index][0] = -phonicSpawnDistance * (index + 1);
    } else {
      phonicPositions[index][0] = width + (phonicSpawnDistance * (index + 1));
    }
  }
  
  void drawMinigame() {
    background(214, 230, 250);
    
    // Draw the header and blurb text
    float skyStripeHeight = localUnitY * 2;
    float greyHeaderY = height * 0.1;
    float greyHeaderTextTrogdorX = width * 0.35;
    float greyHeaderTextTrogdorY = greyHeaderY * 0.5;
    rectMode(CORNER);
    fill(65, 66, 64);
    rect(0, 0, width, greyHeaderY);
    textAlign(RIGHT);
    textSize(localUnitX * 2);
    fill(118, 200, 60);
    text("Trogdor: ", greyHeaderTextTrogdorX, greyHeaderTextTrogdorY);
    textAlign(LEFT);
    fill(255, 243, 83);
    text("Let's Burninate Phonics", greyHeaderTextTrogdorX, greyHeaderTextTrogdorY);
    
    // Draw the striped part of the sky
    float horizonY = Trogdor.y + (Trogdor.imgHeight * 0.23);
    fill(122, 189, 251);
    rect(0, greyHeaderY, width, skyStripeHeight);
    fill(166, 207, 248);
    rect(0, greyHeaderY + skyStripeHeight, width, skyStripeHeight);
    fill(188, 216, 253);
    rect(0, greyHeaderY + (skyStripeHeight * 2), width, skyStripeHeight);
    fill(219, 205, 115);
    rect(0, horizonY, width, height - horizonY);
    
    drawTrogdor();
    drawPhonics();
  }
  
  void drawTrogdor() {
    pushMatrix();
    float tempX = Trogdor.x;
    if (trogdorFlipped) {
      // Flipping an image requires rescaling but also adjustment of the x, y
      // variables based on said rescaling.
      scale(-1, 1);
      Trogdor.x *= -1;
    }
    image(Trogdor.imgDrawn, Trogdor.x, Trogdor.y, Trogdor.imgWidth, Trogdor.imgHeight);
    Trogdor.processAction();
    
    popMatrix();
    Trogdor.x = tempX;
  }
  
  void drawPhonics() {
    float phonicFontSize = localUnitX * 5;
    float phonicStepSize = localUnitX * timerSpeedMultiplier;
    
    fill(224, 57, 51);
    textSize(phonicFontSize);
    for (int i =  0; i < phonicPositions.length; i++) {
      boolean isPhonicApproachingFromRight = phonicPositions[i][0] > Trogdor.x;
      if (!enableLoseTimer && !isShowingInstructions()) {
        if (isPhonicApproachingFromRight) {
          phonicPositions[i][0] -= phonicStepSize;
        } else {
          phonicPositions[i][0] += phonicStepSize;
        }
      }
      
      
      float trogdorHitboxWidth = Trogdor.imgWidth * 0.15;
      float trogdorBurninateWidth = Trogdor.imgWidth * 0.5;
      boolean hasContactedFromRight = isPhonicApproachingFromRight &&
                                      phonicPositions[i][0] < Trogdor.x + trogdorHitboxWidth &&
                                      (!Trogdor.isUsingAttackImage() || (Trogdor.isUsingAttackImage() && trogdorFlipped));
      boolean hasContactedFromLeft = !isPhonicApproachingFromRight &&
                                     phonicPositions[i][0] > Trogdor.x - trogdorHitboxWidth &&
                                     (!Trogdor.isUsingAttackImage() || (Trogdor.isUsingAttackImage() && !trogdorFlipped));
      boolean hasBurninatedFromRight = isPhonicApproachingFromRight &&
                                       phonicPositions[i][0] < Trogdor.x + trogdorBurninateWidth &&
                                       Trogdor.isUsingAttackImage() &&
                                       !trogdorFlipped;
      boolean hasBurninatedFromLeft = !isPhonicApproachingFromRight &&
                                      phonicPositions[i][0] > Trogdor.x - trogdorBurninateWidth &&
                                      Trogdor.isUsingAttackImage() &&
                                      trogdorFlipped;
      // Phonic is within the hitbox of Trogdor
      if (hasContactedFromRight || hasContactedFromLeft) {
        Trogdor.startHurt(1);
        randomisePhonicPositionX(i);
        enableLoseTimer = true;
        // Ensure there is no win condition
        enableWinBySurvival = false;
      } else if (hasBurninatedFromRight || hasBurninatedFromLeft) {
        randomisePhonicPositionX(i);
      }
      
      text(phonicLetters[i], phonicPositions[i][0], phonicPositions[i][1]);
    }
  }
  
  void screenPressed() {
    if (!enableLoseTimer) {
      Trogdor.attack1Timer = 0;
      Trogdor.imgDrawn = Trogdor.imgIdle;
      
      // Pressing on the screen refreshes the attack
      Trogdor.startAttack();
      // Note that Trogdor's default orientation is to the right
      trogdorFlipped = mouseX <= (width * 0.5);
    }
  }
}
