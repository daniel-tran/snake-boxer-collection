class MinigameManager {
  float localUnitX;
  float localUnitY;
  boolean hasWon = false;
  boolean hasEnded = false;
  boolean enableWinBySurvival = false;
  String instructionText = "";
  float instructionX = width * 0.5;
  float instructionY = height * 0.5;
  int instructionColour = 255; // For simplicity, this is a black/white colour
  float instructionTimer = 0;
  float instructionTimerInc = 1;
  float instructionTimerMax = 60;
  boolean enableLoseTimer = false;
  float loseTimer = 0;
  float loseTimerInc = instructionTimerInc;
  float loseTimerMax = instructionTimerMax;
  boolean enableWinTimer = false;
  float winTimer = 0;
  float winTimerInc = instructionTimerInc;
  float winTimerMax = instructionTimerMax;
  float timerEndX = width * 0.1;
  float timerSpeedStepX = width * 0.005;
  float timerSpeedMultiplier = 1;
  MovingEnemy timerEnemy = new MovingEnemy(width * 1.1, height * 0.95,
                                 "characters/Snake/Snake_Hurt.png",
                                 new String[]{
                                   "characters/Snake/Snake_Idle.png",
                                   "characters/Snake/Snake_Idle2.png"
                                 },
                                 0, 0,
                                 new float[]{width * 1.1}, new float[]{height * 0.95});
  Fighter timerFighter = new Fighter(timerEndX - (timerSpeedStepX * 8), height * 0.95,
                       "characters/BoxerJoe/BoxerJoe_Idle.png",
                       "characters/BoxerJoe/BoxerJoe_Block.png",
                       "characters/BoxerJoe/BoxerJoe_Hurt.png",
                       new String[]{
                         "characters/BoxerJoe/BoxerJoe_Attack1.png"
                       },
                       0, 0);
  boolean drawPellets = true;
  // Indicates the max. height (from top down) to ensure the items can't overlap with the timer UI
  float gameSpaceHeight = height * 0.8;
  
  MinigameManager(float localUnitWidth, float localUnitHeight) {
    localUnitX = localUnitWidth;
    localUnitY = localUnitHeight;
    
    timerEnemy.imgWidth = localUnitX * 11;
    timerEnemy.imgHeight = localUnitY * 11;
    timerFighter.imgWidth = localUnitX * 11;
    timerFighter.imgHeight = localUnitY * 11;
  }
  
  void setTimerSpeed(float multiplier) {
    timerSpeedMultiplier = multiplier;
  }
  
  void setText(String instructions, int instructionColouring) {
    instructionText = instructions;
    instructionColour = instructionColouring;
  }
  
  boolean isShowingInstructions() {
    return instructionTimer < instructionTimerMax;
  }
  
  void processAction() {
    if (isShowingInstructions()) {
      // Game pauses briefly upfront to give players time to read the task
      instructionTimer += instructionTimerInc;
    } else {
      // The timer is represented as a snake moving towards Boxer Joe,
      // collecting the coloured pellets on the way.
      
      if (timerEnemy.x >= timerEndX) {
        // Timer is still going
        timerEnemy.step(timerSpeedStepX * timerSpeedMultiplier);
      } else if (timerEnemy.recoveryFlashCount <= 0) {
        // Timer has run out, but wait until the hurt animation finishes before
        // considering the game as ended
        timerFighter.startAttack();
        timerEnemy.startHurt();
      }
      
      if (timerEnemy.recoveryFlashCount >= timerEnemy.recoveryFlashCountMax) {
        // Enemy has finished its hurt animation, and the minigame is finally over
        endMinigame();
        // Can't win by survival if the player has already lost the game
        if (enableWinBySurvival && !enableLoseTimer) {
          hasWon = true;
        }
      }
      
      if (enableLoseTimer) {
        loseTimer += loseTimerInc;
        if (loseTimer >= loseTimerMax) {
          // Player's loss is inevitable, so prevent the win conditions from overriding this
          hasWon = false;
          enableWinBySurvival = false;
          endMinigame();
        }
      } else if (enableWinTimer) {
        winTimer += winTimerInc;
        if (winTimer >= winTimerMax) {
          hasWon = true;
          endMinigame();
        }
      }
    }
  }
  
  void screenPressed() {
    // Intended to be overridden by a subclass to implement mouse pressing logic
  }
  
  void screenReleased() {
    // Intended to be overridden by a subclass to implement mouse releasing logic
  }
  
  void screenDragged() {
    // Intended to be overridden by a subclass to implement mouse dragging logic
    // Note that the slower the drag speed, the more this callback is invoked.
  }
  
  void keyboardPressed() {
    // Intended to be overridden by a subclass to implement keyboard pressing logic
  }
  
  void drawMinigame() {
    // Intended to be overridden by a subclass to draw elements
  }
  
  void drawElements() {
    drawMinigame();
    drawInstructions();
    drawTimer();
  }
  
  void drawInstructions() {
    if (isShowingInstructions()) {
      fill(instructionColour);
      textAlign(CENTER);
      textSize(localUnitX * 5);
      text(instructionText, instructionX, instructionY);
    }
  }
  
  void drawTimer() {
    // Draw the timer background
    rectMode(CENTER);
    noStroke();
    fill(128);
    rect(width * 0.5, timerFighter.y, width, timerFighter.imgHeight * 0.6);
    
    float timerPelletDistanceX = timerSpeedStepX * 4;
    float timerPelletsX = timerFighter.x + (timerPelletDistanceX);
    int timerPelletsCount = (int)(timerEnemy.x / timerPelletDistanceX);
    for (int i = 0; i < timerPelletsCount && drawPellets; i++) {
      float pelletX = timerPelletsX + (timerPelletDistanceX * (i + 1));
      if (pelletX >= timerEnemy.x) {
        // No need to draw pellets already consumed by the enemy
        break;
      }
      
      // Pellet colouring as a visual indicator of how much time remains
      if (i < 5) {
        fill(255, 0, 0);
      } else if (i < 20) {
        fill(255, 201, 14);
      } else {
        fill(0, 255, 0);
      }
      rect(pelletX, timerFighter.y, localUnitX, localUnitY);
    }
    
    timerEnemy.drawImage();
    timerEnemy.processAction();
    imageMode(CENTER);
    image(timerFighter.imgDrawn, timerFighter.x, timerFighter.y, timerFighter.imgWidth, timerFighter.imgHeight);
    timerFighter.processAction();
  }
  
  void stopTimer() {
    timerEnemy.speedXMultiplier = 0;
  }
  
  void endMinigame() {
    // This can be called to abruptly end the minigame, so the "win by survival"
    // check is done strictly when the minigame has actually ended properly.
    stopTimer();
    drawPellets = false;
    hasEnded = true;
  }
  
  void reset() {
    // Currently, it is easier to reinitialise the object than to manually reset its internal state
  }
  
  boolean hasPressedArea(float pressX, float pressY, float wide, float high){
    return mouseX >= pressX - wide &&
           mouseX <= pressX + wide &&
           mouseY >= pressY - high &&
           mouseY <= pressY + high;
  }
}
