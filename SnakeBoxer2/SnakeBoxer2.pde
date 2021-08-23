Fighter PLAYER;
MovingEnemy[] ENEMIES;
MovingCollectible[] COLLECTIBLES;
float UNIT_X;
float UNIT_Y;
float PLAYER_BOUNDARY_MIN_Y;
float PLAYER_BOUNDARY_MAX_Y;
float ENEMY_RESET_X;
int SCORE;
int LEVEL;
int MAX_LEVEL_SCORE;
TitleScreen TITLE_SCREEN;
String[] FILENAMES_POSITIVE = {"items/Strawberry.png",
                               "items/Beer.png",
                               "items/RoastPig.png",
                               "items/Egg.png"};
String[] FILENAMES_NEGATIVE = {"items/Arrow.png",
                               "items/Bomb.png"};
PImage[] SHOWCASE_COLLECTIBLES_POSITIVE;
PImage[] SHOWCASE_COLLECTIBLES_NEGATIVE;
Background BACKDROP;
boolean JOYSTICK_ACTIVE;

// These global variables are placed here to make it easier to adjust the difficulty of the game.
// Number of enemies to add upon levelling up
int ENEMY_INC = 4;
// Number of collectibles to add upon levelling up
int COLLECTIBLE_INC = 2;
// Score increment upon defeating an enemy
int ENEMY_SCORE_INCREMENT = 50;
// Score decrement upon colliding with an enemy
int ENEMY_SCORE_DECREMENT = -ENEMY_SCORE_INCREMENT;
// Health loss amount upon colliding with an enemy
int BASE_HURT_DAMAGE = 5;
// Score boundaries that enable a level up
int[] LEVEL_BOUNDARIES = {500, 1000, 2000};
// Score boundary that enables a level up when at the max. level
int MAX_LEVEL_SCORE_BOUNDARY = 1000;
// Speed multiplier for enemies upon levelling up
float ENEMY_SPEED_UP_FACTOR = 1.25;
// Speed multiplier for collectibles upon levelling up
float COLLECTIBLE_SPEED_UP_FACTOR = ENEMY_SPEED_UP_FACTOR;

void setup() {
  fullScreen();
  //size(600, 400);
  noStroke();
  orientation(LANDSCAPE);
  textFont(createFont("PressStart2P.ttf", 32));
  
  SHOWCASE_COLLECTIBLES_POSITIVE = new PImage[FILENAMES_POSITIVE.length];
  for (int i = 0; i < SHOWCASE_COLLECTIBLES_POSITIVE.length; i++) {
    SHOWCASE_COLLECTIBLES_POSITIVE[i] = loadImage(FILENAMES_POSITIVE[i]); 
  }
  SHOWCASE_COLLECTIBLES_NEGATIVE = new PImage[FILENAMES_NEGATIVE.length];
  for (int i = 0; i < SHOWCASE_COLLECTIBLES_NEGATIVE.length; i++) {
    SHOWCASE_COLLECTIBLES_NEGATIVE[i] = loadImage(FILENAMES_NEGATIVE[i]); 
  }
  
  UNIT_X = width * 0.01;
  UNIT_Y = UNIT_X;
  PLAYER_BOUNDARY_MIN_Y = height * 0.15;
  PLAYER_BOUNDARY_MAX_Y = height * 0.7;
  ENEMY_RESET_X = -UNIT_X;
  // Instructions will be drawn separately, as they contain images
  TITLE_SCREEN = new TitleScreen("titlescreen/SnakeBoxer2_Logo.png",
                                 "", 0, 0,
                                 UNIT_X, UNIT_Y);
  TITLE_SCREEN.setTagline("THE BITING OF\n  BOXER JOE", width * 0.225, height * 0.5);
  TITLE_SCREEN.setGeneralItemImage("titlescreen/SnakeBoxer_Snake.png", width * 0.75, height * 0.7,
                                   UNIT_X * 30, UNIT_Y * 30);
  setupGame();
}

void keyPressed() {
  // Since there is no multi-touch on a PC, this is used as the computer specific
  // way for making an attack while already moving.
  registerPlayerAttack();
}

void mousePressed() {
  // Since there is no keyboard enabled while running on an Android device,
  // this is used as the computer alternative of touching the screen.
  registerPlayerAttack();
}

void mouseReleased() {
  resetJoystick();
}

void touchStarted() {
  // This is a special in-built function that is only called when touching the
  // screen while running on an Android device.
  // It is not continuously called while the touch point is held down, so the player
  // can still move around and make attacks.
  //
  // Note that since the touches array can't be used (otherwise this won't compile
  // in Java mode), the x,y, coordinates of touch points after the first initial
  // one can't be tracked.
  // As a result of this technical limitation, the game exhibits a mechanical 
  // behaviour where the player cannot move without first making an attack.
  // As a side effect, this technically makes the game somewhat playable with
  // one (left) hand.
  registerPlayerAttack();
}

void draw() {
  if (!TITLE_SCREEN.isStarted()) {
    drawTitleScreen();
  } else {
    BACKDROP.drawBackground();
    drawPlayer();
    drawHealthBars();
    drawScoreAndLevel();
    drawJoystick();
    drawEnemies();
    drawCollectibles();
    
    checkGameOverTimer();
  }
}

void setupGame() {
  LEVEL = 0;
  SCORE = 0;
  MAX_LEVEL_SCORE = SCORE;
  
  PLAYER = new Fighter(width * 0.35, height * 0.45,
                       "characters/BoxerJoe/BoxerJoe_Idle.png",
                       "characters/BoxerJoe/BoxerJoe_Block.png",
                       "characters/BoxerJoe/BoxerJoe_Hurt.png",
                       new String[]{
                         "characters/BoxerJoe/BoxerJoe_Attack1.png",
                         "characters/BoxerJoe/BoxerJoe_Attack2.png"
                       },
                       UNIT_X * 22, UNIT_Y * 22);
  // Attacking feels a bit slow for some reason
  PLAYER.attack1Timer.timeInc *= 2;
  ENEMIES = new MovingEnemy[16];
  COLLECTIBLES = new MovingCollectible[16];
  // Set the initial enemies using the difficulty increase function
  increaseDifficulty();
  // Randomise the background, but don't use the special backdrops
  BACKDROP = new Background(0, height * 0.15, UNIT_X);
  BACKDROP.selectBackground((int)random(BACKDROP.backgroundCount - 1));
  // Joystick is not being used upon game start
  resetJoystick();
}

void increaseDifficulty() {
  float[] possibleX = {width + UNIT_X};
  // Possible Y coordinates for respawning is based on the height of the 
  // playable space split into separate lanes.
  int possibleYCount = 14;
  float possibleYInc = (PLAYER_BOUNDARY_MAX_Y - PLAYER_BOUNDARY_MIN_Y) / possibleYCount;
  float[] possibleY = new float[possibleYCount];
  for (int i = 0; i < possibleYCount; i++) {
    // First position should start at the first increment instead of 0
    possibleY[i] = PLAYER_BOUNDARY_MIN_Y + (possibleYInc * (i + 1));
  }
  // Assign level dependent variables before incrementing the level
  // otherwise some enemies and collectibles won't be utilised
  int firstEnemyIndex = LEVEL * ENEMY_INC;
  int lastEnemyIndex = firstEnemyIndex + ENEMY_INC;
  int firstCollectibleIndex = LEVEL * COLLECTIBLE_INC;
  int lastCollectibleIndex = firstCollectibleIndex + COLLECTIBLE_INC;
  LEVEL++;
  
  // Maximum level is when all enemies are utilised
  if (lastEnemyIndex < ENEMIES.length) {
    for (int i = firstEnemyIndex; i < lastEnemyIndex; i++) {
      // Set the spawn distance between each enemy
      float initialOffsetX = PLAYER.imgWidth * i;
      possibleX[0] += initialOffsetX;
      float initialX = possibleX[(int)random(possibleX.length)];
      float initialY = possibleY[(int)random(possibleY.length)];
      ENEMIES[i] = new MovingEnemy(initialX, initialY,
                                   "characters/Snake/Snake_Hurt.png",
                                   new String[]{
                                     "characters/Snake/Snake_Idle.png",
                                     "characters/Snake/Snake_Idle2.png"
                                   },
                                   PLAYER.imgWidth, PLAYER.imgHeight,
                                   possibleX, possibleY);
      // Default enemy image alternation speed is a bit slow
      ENEMIES[i].imgMovingTimer.timeMax *= 2;                                   
    }
  }

  if (lastCollectibleIndex < COLLECTIBLES.length) {
    for (int i = firstCollectibleIndex; i < lastCollectibleIndex; i++) {
      // Set the spawn distance between each collectible
      float initialOffsetX = PLAYER.imgWidth * i;
      possibleX[0] += initialOffsetX;
      float initialX = possibleX[(int)random(possibleX.length)];
      float initialY = possibleY[(int)random(possibleY.length)];
      float collectibleSizeFactor = 0.35;
      COLLECTIBLES[i] = new MovingCollectible(initialX, initialY,
                                            possibleX, possibleY,
                                            FILENAMES_POSITIVE, FILENAMES_NEGATIVE,
                                            PLAYER.imgWidth * collectibleSizeFactor,
                                            PLAYER.imgHeight * collectibleSizeFactor);
    }
  }
}

void speedUpEnemies() {
  for (int i = 0; i < ENEMIES.length; i++) {
    if (ENEMIES[i] != null) {
      ENEMIES[i].speedXMultiplier *= ENEMY_SPEED_UP_FACTOR;
    }
  }
  for (int i = 0; i < COLLECTIBLES.length; i++) {
    if (COLLECTIBLES[i] != null) {
      COLLECTIBLES[i].speedXMultiplier *= COLLECTIBLE_SPEED_UP_FACTOR;
    }
  }
}

void registerPlayerAttack() {
  if (TITLE_SCREEN.isStarted()) {
    if (PLAYER.isPlayable() && !PLAYER.isUsingAttackImage() && !PLAYER.isUsingHurtImage()) {
      PLAYER.startAttack();
    }
    
    if (!PLAYER.isPlayable()) {
      // User can quickly start a new game instead of waiting for the timer to finish  
      TITLE_SCREEN.forceReset();
    }
  } else {
    TITLE_SCREEN.setStartState(true);
    setupGame();
  }
}

void drawTitleScreen() {
  TITLE_SCREEN.drawTitleScreen();

  // Draw instructions, with images drawn in relation to some words
  textSize(UNIT_X * 2);
  fill(255);
  text("KEYBOARD/\nTOUCH SCREEN= PUNCH\n\nJOYSTICK= MOVE\n\nGET:\n\nAVOID:",
       width * 0.22, height * 0.65);

  // Draw showcase images of collectibles
  float imgShowcaseWidth = UNIT_X * 5;
  float imgShowcaseHeight = UNIT_Y * 5;
  float imgShowcasePositiveX = width * 0.32;
  float imgShowcasePositiveY = height * 0.86;
  float imgShowcaseNegativeX = width * 0.37;
  float imgShowcaseNegativeY = height * 0.95;
  float imgShowcasePositiveIncX = width * 0.05;
  float imgShowcaseNegativeIncX = imgShowcasePositiveIncX;
  for (int i = 0; i < SHOWCASE_COLLECTIBLES_POSITIVE.length; i++) {
    image(SHOWCASE_COLLECTIBLES_POSITIVE[i],
          imgShowcasePositiveX + (imgShowcasePositiveIncX * i),
          imgShowcasePositiveY, imgShowcaseWidth, imgShowcaseHeight);    
  }
  for (int i = 0; i < SHOWCASE_COLLECTIBLES_NEGATIVE.length; i++) {
    image(SHOWCASE_COLLECTIBLES_NEGATIVE[i],
          imgShowcaseNegativeX + (imgShowcaseNegativeIncX * i),
          imgShowcaseNegativeY, imgShowcaseWidth, imgShowcaseHeight);    
  }
}

void resetJoystick() {
  JOYSTICK_ACTIVE = false;
}

void drawJoystick() {
  float joystickX = width * 0.1;
  float joystickY = height * 0.9;
  float joystickTiltedX = joystickX;
  float joystickTiltedY = joystickY;
  float joystickDistance = UNIT_X * 6;

  // Draw base joystick area
  fill(192);
  ellipse(width * 0.1, height * 0.9, UNIT_X * 15, UNIT_Y * 15);

  // The joystick must be pulled from within the disk area, but can be pulled to an arbitrary distance
  // until the screen press is released.
  if (!JOYSTICK_ACTIVE) {
    JOYSTICK_ACTIVE = mousePressed &&
                      abs(joystickX - mouseX) <= joystickDistance &&
                      abs(joystickY - mouseY) <= joystickDistance;
  }

  if (JOYSTICK_ACTIVE && PLAYER.isPlayable()) {
    // Keep the joystick within the disk area, but results in a square-shaped bounding box
    joystickTiltedX = min(max(mouseX, joystickX - joystickDistance), joystickX + joystickDistance);
    joystickTiltedY = min(max(mouseY, joystickY - joystickDistance), joystickY + joystickDistance);
    if (!PLAYER.isUsingHurtImage()) {
      // Scale the increment to vary the player's speed relative to the joystick
      float speedFactor = 0.25;
      PLAYER.x += (mouseX - joystickX) * speedFactor;
      PLAYER.y += (mouseY - joystickY) * speedFactor;
      keepPlayerInBoundaries();
    }    
  }
  // Draw the joystick, either tilted in the direction of movement
  // or in its default position
  fill(64);
  ellipse(joystickTiltedX, joystickTiltedY, UNIT_X * 4, UNIT_Y * 4);
}

void drawHealthBars() {
  float healthBarSectionX = UNIT_X * 14;
  float healthBarSectionY = height - (UNIT_Y * 10);
  float healthBarSectionWidth = width - (UNIT_X * 18);
  float healthBarSectionHeight = height - healthBarSectionY - (UNIT_Y * 2);
  
  // Health bar section for drawing health bars on
  rectMode(CORNER);
  fill(0, 96, 252);
  rect(healthBarSectionX, healthBarSectionY, healthBarSectionWidth, healthBarSectionHeight);
  
  // Player HP, drawn as a percentage of remaining health multiplied by a static width
  fill(237, 28, 36);
  rect(healthBarSectionX + (UNIT_X * 10), healthBarSectionY + (UNIT_Y * 4), (PLAYER.hp / PLAYER.hpMax) * (width * 0.65), UNIT_Y * 2);
}

void drawScoreAndLevel() {
  textSize(UNIT_X * 2);
  fill(255);
  text("LEVEL:" + LEVEL, width * 0.25, height - (UNIT_Y * 6));
  text("SCORE:" + SCORE, width * 0.5, height - (UNIT_Y * 6));
}

void drawPlayer() {
  PLAYER.drawImage();
  keepPlayerInBoundaries();
  PLAYER.processAction();
}

void keepPlayerInBoundaries() {
  // Player minimum Y boundary is shifted down slightly so that they don't
  // move around the horizon
  PLAYER.keepWithinBoundary(UNIT_X, width - UNIT_X,
                            PLAYER_BOUNDARY_MIN_Y + (PLAYER.imgHeight * 0.25), PLAYER_BOUNDARY_MAX_Y);
}

void drawEnemies() {
  for (int i = 0; i < ENEMIES.length; i++) {
    // Ignore enemies that haven't been loaded, since the level is too low
    if (ENEMIES[i] == null) {
      continue;
    }
    // If the game is over, the enemy stops moving but still wiggles in place
    if (!ENEMIES[i].isRecoveryFlashing && PLAYER.isPlayable()) {
      ENEMIES[i].step(UNIT_X);
    }
    // Enemy respawns when off-screen and not defeated 
    if (ENEMIES[i].x <= ENEMY_RESET_X) {
      ENEMIES[i].reset();
    }
    boolean contactZone = PLAYER.x <= ENEMIES[i].x &&
          PLAYER.x >= ENEMIES[i].x - (UNIT_X * 11) &&
          PLAYER.y <= ENEMIES[i].y + (UNIT_Y * 4) &&
          PLAYER.y >= ENEMIES[i].y - (UNIT_Y * 4);
    boolean contactZoneBack = PLAYER.x > ENEMIES[i].x &&
          PLAYER.x <= ENEMIES[i].x + (UNIT_X * 2) &&
          PLAYER.y <= ENEMIES[i].y + (UNIT_Y * 4) &&
          PLAYER.y >= ENEMIES[i].y - (UNIT_Y * 4);
    if (!ENEMIES[i].isRecoveryFlashing && !PLAYER.isUsingHurtImage()) {
      if (contactZone) {        
        // Player collided with the enemy with the possibility of defeating them
        if (PLAYER.isUsingAttackImage()) {
          ENEMIES[i].startHurt();
          registerScore(ENEMY_SCORE_INCREMENT);
        } else if (!ENEMIES[i].isRecoveryFlashing) {
          registerPlayerHurt(i);
        }
      } else if (contactZoneBack) {
        // Player collided with the enemy's back, in which the player is damaged
        // regardless of whether they were attacking or not
        registerPlayerHurt(i);
      }
    }
    
    ENEMIES[i].processAction();
    ENEMIES[i].drawImage();
  }
}

void drawCollectibles() { 
  for (int i = 0; i < COLLECTIBLES.length; i++) {
    // Ignore collectibles that haven't been loaded, since the level is too low
    if (COLLECTIBLES[i] == null) {
      continue;
    }
    if (!COLLECTIBLES[i].isCollected && PLAYER.isPlayable()) {
      COLLECTIBLES[i].step(-UNIT_X);
    }
    // Collectible respawns when off-screen and not collected 
    if (COLLECTIBLES[i].x <= ENEMY_RESET_X) {
      COLLECTIBLES[i].reset();
    }
    // Collectible collided with the player where both are in valid states
    if (COLLECTIBLES[i].checkCollection(PLAYER.x, PLAYER.y) && 
        !COLLECTIBLES[i].isCollected &&
        PLAYER.isPlayable() && !PLAYER.isUsingHurtImage()) {
      COLLECTIBLES[i].isCollected = true;
      // Negative items should naturally have a non-positive value
      registerScore(COLLECTIBLES[i].collectValue);
      if (COLLECTIBLES[i].isNegative) {
        damagePlayer();
      }
    }
    
    COLLECTIBLES[i].drawImage();
  }
}

void damagePlayer() {
  // Amplified damage in later levels means higher probablility of losing
  PLAYER.startHurt(BASE_HURT_DAMAGE * LEVEL);
}

void registerPlayerHurt(int enemyIndex) {
  registerScore(ENEMY_SCORE_DECREMENT);
  ENEMIES[enemyIndex].reset();
  damagePlayer();
}

void registerScore(int points) {
  SCORE += points;
  if (LEVEL >= LEVEL_BOUNDARIES.length) {
    // Max level score is used to determine when a level up occurs after the
    // player has reached the level where all enemies and collectibles are utilised
    MAX_LEVEL_SCORE += points;
  }
  
  if (LEVEL <= LEVEL_BOUNDARIES.length) {
    // Level up based on the required score
    if (LEVEL > 0 && SCORE >= LEVEL_BOUNDARIES[LEVEL - 1]) {
      increaseDifficulty();
      speedUpEnemies();
    }
  } else {
    if (MAX_LEVEL_SCORE >= MAX_LEVEL_SCORE_BOUNDARY) {
      // Any leftover points beyond the score boundary don't count to the next level up 
      MAX_LEVEL_SCORE = 0;
      // Manually increase the level counter, as the regular
      // level up function is not being called
      LEVEL++;
      speedUpEnemies();
    }
  }
}

void checkGameOverTimer() {
  // Pause for a brief period after a game over, then reset the game
  if (!PLAYER.isPlayable()) {
    TITLE_SCREEN.resetByTimer();
  }
}
