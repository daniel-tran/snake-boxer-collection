float UNIT_X;
float UNIT_Y;
Background BACKDROP;
DeliShop DELI_SHOP;
Silhouette[] SILHOUETTES = new Silhouette[4];
Fighter PLAYER;
MovingEnemy[] ENEMIES;
float ENEMY_SPAWN_UPPER_Y;
float ENEMY_SPAWN_LOWER_Y;
int LEVEL;
int KNOCKOUTS;
int[] LEVEL_BOUNDARIES = {12, 24, 48};
int MAX_LEVEL_KNOCKOUTS;
TitleScreen TITLE_SCREEN;

// These global variables are placed here to make it easier to adjust the difficulty of the game.
// Number of knockouts required to level up after reaching the max. level
final int MAX_LEVEL_KNOCKOUTS_BOUNDARY = 20;
// The point at which the level stops increasing and knockouts stop being counted.
// This is mainly to prevent the level number from overflowing into the knockouts text
// due to the number of digits required to represent it.
final int LEVEL_CAP = 99999;
// The speed multiplier at which that enemies cannot increase once exceeded.
// If allowed too high, the enemies essentially disappear off the screen almost instantly.
final float ENEMY_SPEED_UP_FACTOR_MAX = 40;
// Speed multiplier for enemies upon levelling up
final float ENEMY_SPEED_UP_FACTOR = 1.25;
// Number of enemies to add upon levelling up
final int ENEMY_INC = 4;
// Total number of enemies that can be fought
final int ENEMIES_COUNT = 16;

void setup() {
  fullScreen();
  //size(600, 400);
  noStroke();
  orientation(LANDSCAPE);
  textFont(createFont("PressStart2P.ttf", 32));
  
  UNIT_X = width * 0.01;
  UNIT_Y = UNIT_X;
  TITLE_SCREEN = new TitleScreen("titlescreen/SnakeBoxer1_Logo.png",
                                 "PROTECT THE DELI SHOP!\n\nPRESS THE SCREEN TO MOVE AROUND!\nALSO PRESS TO PUNCH!",
                                 width * 0.22, height * 0.6,
                                 UNIT_X, UNIT_Y);
}

void mousePressed() {
  if (TITLE_SCREEN.isStarted()) {
    int pressedIndex = -1;
    for (int i = 0; i < SILHOUETTES.length; i++) {
      // Getting hurt stuns the player briefly, preventing movement
      if (SILHOUETTES[i].wasPressed(mouseX, mouseY) && !SILHOUETTES[i].isSelected &&
          !PLAYER.isUsingHurtImage() && DELI_SHOP.isActive()) {
        // New silhouette was selected, which means all others need be deselected
        SILHOUETTES[i].isSelected = true;
        pressedIndex = i;
        // Reset attack timer during silhouette reselection, as it counts
        // as a newly made attack
        PLAYER.attack1Timer.reset();
        break;
      }
    }
    
    if (pressedIndex >= 0) {
      for (int i = 0; i < SILHOUETTES.length; i++) {
        // Deselect all unselected silhouettes
        if (i != pressedIndex) {
          SILHOUETTES[i].isSelected = false;
        }
      }
    }
    
    // User has made an attack.
    // This logic is not called during draw() to prevent continuous attacking
    // by holding down a single key.
    // Also check the sprite to avoid quick recovery after getting hurt.
    if (PLAYER.isPlayable() && !PLAYER.isUsingHurtImage() && DELI_SHOP.isActive()) {
      PLAYER.startAttack();
    }
    
    if (!DELI_SHOP.isActive()) {
      // User can quickly start a new game instead of waiting for the timer to finish
      TITLE_SCREEN.forceReset();
    }
  } else {
    TITLE_SCREEN.setStartState(true);
    setupGame();
  }

}

void keyPressed() {
  //increaseDifficulty();
  //speedUpEnemies();
  // setupGame();
}

void draw() {
  if (!TITLE_SCREEN.isStarted()) {
    TITLE_SCREEN.drawTitleScreen();
  } else {
    BACKDROP.drawBackground();
    drawHealthBar();
    drawScoreAndLevel();
    drawUserResources();
    drawEnemies();
    checkGameOverTimer();
  }
}

void setupGame() {
  float deliX = width * 0.5;
  float deliY = height * 0.5;
  String idleSprite = "characters/BoxerJoe/BoxerJoe_Idle.png";
  DELI_SHOP = new DeliShop(deliX, deliY, UNIT_X * 25, UNIT_Y * 25,
                           "DeliShop.png", "DeliShopDestroyed.png");

  BACKDROP = new Background(0, height * 0.34, UNIT_X);

  LEVEL = 0;
  KNOCKOUTS = 0;
  MAX_LEVEL_KNOCKOUTS = 0;

  PLAYER = new Fighter(width * 0.55, height * 0.45,
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
  PLAYER.hurtTimer.timeInc *= 2;

  ENEMY_SPAWN_UPPER_Y = height * 0.4;
  ENEMY_SPAWN_LOWER_Y = height * 0.6;

  // Indexes refer to each silhouette starting from the top-left,
  // and then going anti-clockwise
  float silhouetteLeftX = width * 0.35;
  float silhouetteRightX = width * 0.65;
  SILHOUETTES[0] = new Silhouette(silhouetteLeftX, ENEMY_SPAWN_UPPER_Y, PLAYER.imgWidth, PLAYER.imgHeight, idleSprite);
  SILHOUETTES[1] = new Silhouette(silhouetteLeftX, ENEMY_SPAWN_LOWER_Y, PLAYER.imgWidth, PLAYER.imgHeight, idleSprite);
  SILHOUETTES[2] = new Silhouette(silhouetteRightX, ENEMY_SPAWN_UPPER_Y, PLAYER.imgWidth, PLAYER.imgHeight, idleSprite);
  SILHOUETTES[3] = new Silhouette(silhouetteRightX, ENEMY_SPAWN_LOWER_Y, PLAYER.imgWidth, PLAYER.imgHeight, idleSprite);
  // Touching a certain corner of the screen corresponds to a silhouette
  SILHOUETTES[0].setSelectionZone(0, 0, deliX, deliY);
  SILHOUETTES[1].setSelectionZone(0, deliY, deliX, height);
  SILHOUETTES[2].setSelectionZone(deliX, 0, width, deliY);
  SILHOUETTES[3].setSelectionZone(deliX, deliY, width, height);
  SILHOUETTES[0].isSelected = true;
  // Flip the player based on the default selected silhouette
  PLAYER.isFlippedX = true;

  // Set the initial enemies using the difficulty increase function
  ENEMIES = new MovingEnemy[ENEMIES_COUNT];
  increaseDifficulty();
}

void drawHealthBar() {
  float healthBarSectionX = UNIT_X * 2;
  float healthBarSectionY = height - (UNIT_Y * 10);
  float healthBarSectionWidth = width - (UNIT_X * 4);
  float healthBarSectionHeight = height - healthBarSectionY - (UNIT_Y * 2);
  
  // Health bar section for drawing health bars on
  rectMode(CORNER);
  fill(0, 96, 252);
  rect(healthBarSectionX, healthBarSectionY, healthBarSectionWidth, healthBarSectionHeight);
  
  fill(237, 28, 36);
  rect(healthBarSectionX + (UNIT_X * 10), healthBarSectionY + (UNIT_Y * 5),
      (DELI_SHOP.hp / DELI_SHOP.hpMax) * (width * 0.75), UNIT_Y * 2);
}

void drawScoreAndLevel() {
  float textY = height - (UNIT_Y * 6);
  
  textSize(UNIT_X * 2);
  fill(255);
  text("LEVEL:" + LEVEL, width * 0.25, textY);
  text("KNOCKOUTS:" + KNOCKOUTS, width * 0.5, textY);
}

boolean isLeftSilhouette(int index) {
  return index < (SILHOUETTES.length * 0.5);
}

void drawUserResources() {
  int lastSelectedIndex = -1;
  
  noTint();
  DELI_SHOP.drawImage();
  for (int i = 0; i < SILHOUETTES.length; i++) {
    // Flip the sprites for the right side silhouettes
    SILHOUETTES[i].drawImage(isLeftSilhouette(i));
    // Need to track which one was selected to draw the player there
    if (SILHOUETTES[i].isSelected) {
      lastSelectedIndex = i;
    } 
  }
  
  if (lastSelectedIndex >= 0) {
    // Draw the player where the selected silhouette is
    PLAYER.x = SILHOUETTES[lastSelectedIndex].x;
    PLAYER.y = SILHOUETTES[lastSelectedIndex].y;
    // Flipping is toggled based on which side the silhouette is placed
    PLAYER.isFlippedX = isLeftSilhouette(lastSelectedIndex);
    PLAYER.drawImage();
  }
  
  PLAYER.processAction();
}

void drawEnemies() {
  for (int i = 0; i < ENEMIES.length; i++) {
    // Ignore enemies that haven't been loaded, since the level is too low
    if (ENEMIES[i] == null) {
      continue;
    }
    // If the game is over, the enemy stops moving but still wiggles in place
    if (!ENEMIES[i].isRecoveryFlashing && DELI_SHOP.isActive()) {
      ENEMIES[i].step(UNIT_X);
    }
    
    float contactZoneUpperLimitX = UNIT_X * 25;
    float contactZoneLowerLimitX = contactZoneUpperLimitX * 0.25;
    boolean playerContactTopLeft = 
            ENEMIES[i].x >= DELI_SHOP.x - contactZoneUpperLimitX &&
            ENEMIES[i].x < DELI_SHOP.x + contactZoneLowerLimitX &&
            SILHOUETTES[0].isSelected && 
            ENEMIES[i].y == SILHOUETTES[0].y;
    boolean playerContactBottomLeft =
            ENEMIES[i].x >= DELI_SHOP.x - contactZoneUpperLimitX &&
            ENEMIES[i].x < DELI_SHOP.x + contactZoneLowerLimitX &&
            SILHOUETTES[1].isSelected &&
            ENEMIES[i].y == SILHOUETTES[1].y;
    boolean playerContactBottomRight =
            ENEMIES[i].x <= DELI_SHOP.x + (UNIT_X * 25) &&
            ENEMIES[i].x > DELI_SHOP.x - contactZoneLowerLimitX &&
            SILHOUETTES[2].isSelected &&
            ENEMIES[i].y == SILHOUETTES[2].y;
    boolean playerContactTopRight =
            ENEMIES[i].x <= DELI_SHOP.x + (UNIT_X * 25) &&
            ENEMIES[i].x > DELI_SHOP.x - contactZoneLowerLimitX &&
            SILHOUETTES[3].isSelected &&
            ENEMIES[i].y == SILHOUETTES[3].y;        
    if (!ENEMIES[i].isRecoveryFlashing && (
        playerContactTopLeft || playerContactBottomLeft ||
        playerContactBottomRight || playerContactTopRight) ) {
      if (PLAYER.isUsingAttackImage()) {
        ENEMIES[i].startHurt();
        registerKnockout();
      } else if (!ENEMIES[i].isRecoveryFlashing) {
        ENEMIES[i].reset();
        // Just stun, as the player cannot "die" in this particular game 
        PLAYER.startHurt(0);
      }
    }
    
    if (ENEMIES[i].x >= DELI_SHOP.x - (DELI_SHOP.imgWidth * 0.5) && 
        ENEMIES[i].x <= DELI_SHOP.x + (DELI_SHOP.imgWidth * 0.5)) {
      DELI_SHOP.startHurt();
      ENEMIES[i].reset();
    }
    
    ENEMIES[i].processAction();
    ENEMIES[i].drawImage();
  }
}

void registerKnockout() {
  // No point in increasing the score if the level cap has been reached
  if (LEVEL < LEVEL_CAP) {
    KNOCKOUTS++;
  }

  if (LEVEL <= LEVEL_BOUNDARIES.length) {
    // Level up based on the required number of knockouts
    if (LEVEL > 0 && KNOCKOUTS == LEVEL_BOUNDARIES[LEVEL - 1]) {
      increaseDifficulty();
      speedUpEnemies();
    }
  } else if (KNOCKOUTS >= LEVEL_BOUNDARIES[LEVEL_BOUNDARIES.length - 1]) {
    MAX_LEVEL_KNOCKOUTS++;
    
    // After hitting the max level, the player can keep levelling up
    // but it only makes the existing enemies more difficult, since
    // all the enemies are currently utilised
    if (MAX_LEVEL_KNOCKOUTS == MAX_LEVEL_KNOCKOUTS_BOUNDARY) {
      MAX_LEVEL_KNOCKOUTS = 0;
      increaseDifficulty();
      speedUpEnemies();
    }
  }

}

void increaseDifficulty() {
  String[] idleImages = {"characters/Snake/Snake_Idle.png",
                         "characters/Snake/Snake_Idle2.png"};
  float[] possibleX = {0, width};
  float[] possibleY = {ENEMY_SPAWN_UPPER_Y, ENEMY_SPAWN_LOWER_Y};
  int firstEnemyIndex = LEVEL * ENEMY_INC;
  int lastEnemyIndex = firstEnemyIndex + ENEMY_INC;
  LEVEL = min(LEVEL + 1, LEVEL_CAP);
  
  // Maximum level is when all enemies are utilised
  if (lastEnemyIndex >= ENEMIES.length) {
    return;
  }
  
  for (int i = firstEnemyIndex; i < lastEnemyIndex; i++) {
    // Set the spawn distance between each enemy
    float initialOffsetX = (UNIT_X * 22) * i;
    possibleX[0] -= initialOffsetX;
    possibleX[1] += initialOffsetX;
    float initialX = possibleX[(int)random(possibleX.length)];
    float initialY = possibleY[(int)random(possibleY.length)];
    ENEMIES[i] = new MovingEnemy(initialX, initialY,
                                 "characters/Snake/Snake_Hurt.png",
                                 idleImages,
                                 PLAYER.imgWidth, PLAYER.imgHeight,
                                 possibleX, possibleY);
  }
}

void speedUpEnemies() {
  for (int i = 0; i < ENEMIES.length; i++) {
    if (ENEMIES[i] != null && ENEMIES[i].speedXMultiplier <= ENEMY_SPEED_UP_FACTOR_MAX) {
      ENEMIES[i].speedXMultiplier *= ENEMY_SPEED_UP_FACTOR;
    }
  }
}

void checkGameOverTimer() {
  // Pause for a brief period after a game over, then reset the game
  if (!DELI_SHOP.isActive()) {
    TITLE_SCREEN.resetByTimer();
  }
}
