void setup() {
  fullScreen();
  //size(600, 400);
  noStroke();
  orientation(LANDSCAPE);
  textFont(createFont("PressStart2P.ttf", 32));
  
  UNIT_X = width * 0.01;
  UNIT_Y = UNIT_X;
  FIGHTER_SPRITE_WIDTH = UNIT_X * 22;
  FIGHTER_SPRITE_HEIGHT = UNIT_Y * 22;
  SNAKE_BOXER_LOGO = loadImage("titlescreen/SnakeBoxer1_Logo.png");
}

void setupGame() {
  float deliX = width * 0.5;
  float deliY = height * 0.5;
  String idleSprite = "characters/BoxerJoe/BoxerJoe_Idle.png";
  DELI_SHOP = new DeliShop(deliX, deliY, UNIT_X * 25, UNIT_Y * 25,
                           "DeliShop.png", "DeliShopDestroyed.png");
                           
  LEVEL = 0;
  KNOCKOUTS = 0;
  MAX_LEVEL_KNOCKOUTS = 0;
  GAME_OVER_TIMER = 0;

  // Indexes refer to each silhouette starting from the top-left,
  // and then going anti-clockwise
  ENEMY_SPAWN_UPPER_Y = height * 0.4;
  ENEMY_SPAWN_LOWER_Y = height * 0.6;
  
  SILHOUETTES[0] = new Silhouette(width * 0.35, ENEMY_SPAWN_UPPER_Y, FIGHTER_SPRITE_WIDTH, FIGHTER_SPRITE_HEIGHT, idleSprite);
  SILHOUETTES[1] = new Silhouette(width * 0.35, ENEMY_SPAWN_LOWER_Y, FIGHTER_SPRITE_WIDTH, FIGHTER_SPRITE_HEIGHT, idleSprite);
  SILHOUETTES[2] = new Silhouette(width * 0.65, ENEMY_SPAWN_UPPER_Y, FIGHTER_SPRITE_WIDTH, FIGHTER_SPRITE_HEIGHT, idleSprite);
  SILHOUETTES[3] = new Silhouette(width * 0.65, ENEMY_SPAWN_LOWER_Y, FIGHTER_SPRITE_WIDTH, FIGHTER_SPRITE_HEIGHT, idleSprite);
  // Touching a certain corner of the screen corresponds to a silhouette
  SILHOUETTES[0].setSelectionZone(0, 0, deliX, deliY);
  SILHOUETTES[1].setSelectionZone(0, deliY, deliX, height);
  SILHOUETTES[2].setSelectionZone(deliX, 0, width, deliY);
  SILHOUETTES[3].setSelectionZone(deliX, deliY, width, height);
  SILHOUETTES[0].isSelected = true;
  
  String[] attacksNormal = {"characters/BoxerJoe/BoxerJoe_Attack1.png",
                            "characters/BoxerJoe/BoxerJoe_Attack2.png"};
  PLAYER = new Fighter(width * 0.55, height * 0.45,
                       "characters/BoxerJoe/BoxerJoe_Idle.png",
                       "characters/BoxerJoe/BoxerJoe_Block.png",
                       "characters/BoxerJoe/BoxerJoe_Hurt.png",
                       attacksNormal,
                       FIGHTER_SPRITE_WIDTH, FIGHTER_SPRITE_HEIGHT);
  // Attacking feels a bit slow for some reason
  PLAYER.attack1TimerInc = 10;
  PLAYER.hurtTimerInc = 10;
  // Set the initial enemies using the difficulty increase function
  ENEMIES = new MovingEnemy[16];
  increaseDifficulty();
}

float UNIT_X;
float UNIT_Y;
float FIGHTER_SPRITE_WIDTH;
float FIGHTER_SPRITE_HEIGHT;
DeliShop DELI_SHOP;
Silhouette[] SILHOUETTES = new Silhouette[4];
Fighter PLAYER;
MovingEnemy[] ENEMIES;
float ENEMY_SPEED_UP_FACTOR = 1.25;
float ENEMY_SPAWN_UPPER_Y;
float ENEMY_SPAWN_LOWER_Y;
int LEVEL;
int KNOCKOUTS;
int[] LEVEL_BOUNDARIES = {12, 24, 48};
int MAX_LEVEL_KNOCKOUTS;
int MAX_LEVEL_KNOCKOUTS_BOUNDARY = 20; 
int ENEMY_INC = 4;
PImage SNAKE_BOXER_LOGO;
boolean GAME_STARTED = false;
int GAME_OVER_TIMER = 0;
int GAME_OVER_TIMER_INC = 1;
int GAME_OVER_TIMER_MAX = 120;

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
  textSize(UNIT_X * 2);
  fill(255);
  text("LEVEL:" + LEVEL, width * 0.25, height - (UNIT_Y * 6));
  text("KNOCKOUTS:" + KNOCKOUTS, width * 0.5, height - (UNIT_Y * 6));
}

void drawUserResources() {
  int lastSelectedIndex = -1;
  
  noTint();
  DELI_SHOP.drawImage();
  for (int i = 0; i < SILHOUETTES.length; i++) {
    // Flip the sprites for the right side silhouettes
    SILHOUETTES[i].drawImage(i >= (SILHOUETTES.length * 0.5));
    // Need to track which one was selected to draw the player there
    if (SILHOUETTES[i].isSelected) {
      lastSelectedIndex = i;
    } 
  }
  
  if (lastSelectedIndex >= 0) {
    float playerX = SILHOUETTES[lastSelectedIndex].x;
    float playerY = SILHOUETTES[lastSelectedIndex].y;
    
    boolean isRightSide = lastSelectedIndex >= (SILHOUETTES.length * 0.5);
    pushMatrix();
    if (isRightSide) {
      // Flipping an image requires rescaling but also adjustment of the x, y
      // variables based on said rescaling.
      scale(-1, 1);
      playerX *= -1;
    }
    
    noTint();
    imageMode(CENTER);
    image(PLAYER.imgDrawn, playerX, playerY, PLAYER.imgWidth, PLAYER.imgHeight);
    
    popMatrix();
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
  KNOCKOUTS++;
  if (LEVEL < LEVEL_BOUNDARIES.length) {
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
      // Manually increase the level counter, as the regular
      // level up function is not being called
      LEVEL++;
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
  LEVEL++;
  
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
                                 FIGHTER_SPRITE_WIDTH, FIGHTER_SPRITE_HEIGHT,
                                 possibleX, possibleY);
  }
}

void speedUpEnemies() {
  for (int i = 0; i < ENEMIES.length; i++) {
    if (ENEMIES[i] != null) {
      ENEMIES[i].speedXMultiplier *= ENEMY_SPEED_UP_FACTOR;
    }
  }
}

void mousePressed() {
  if (GAME_STARTED) {
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
        PLAYER.attack1Timer = 0;
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
      GAME_OVER_TIMER = GAME_OVER_TIMER_MAX;
    }
  } else {
    GAME_STARTED = true;
    setupGame();
  }

}

void drawBackground() {
  // Drawing a similar version of the city background from "Where's an Egg?"
  float horizonHeight = height * 0.34;
  float initialX = 0;
  float incX = UNIT_X;
  float widthX = incX * 2;
  // Height factor values are effectively a percentage of sky between the
  // pixel column and the top of the screen.
  // Example: 0.1 = Pixel column covers 90% of the sky height
  float[] heightFactors = {0.4, 0.3, 0.3, 0.3,
                           0.7, 0.7, 0.7, 0.75,
                           0.85, 0.85,
                           0.55, 0.55, 0.55, 0.55,
                           0.7,
                           0.3, 0.3, 0.1, 0.3, 0.3,
                           0.8, 0.8,
                           0.85, 0.9,
                           0.75, 0.75, 0.75, 0.75,
                           0.95,
                           0.85, 0.85,
                           0.5, 0.45, 0.45, 0.5,
                           0.8, 0.8,
                           0.6, 0.6, 0.6, 0.6, 0.6, 0.6,
                           0.85, 0.85,
                           0.1, 0.1, 0.1, 0.1,
                           0.75, 0.75, 0.75,
                           0.55, 0.55,
                           0.8, 0.85, 0.85
                         };
  // 1 background iteration = no repeating background
  int backgroundIterations = 2;

  background(184);
  rectMode(CORNERS);
  
  // Draw the sky
  fill(153, 255, 255);
  rect(0, 0, width, horizonHeight);
  
  // Draw the buildings as a set of pixel columns
  stroke(153, 204, 153);
  fill(153, 204, 153);
  // Background willl repeat, by increasing the value of the x coordinate
  // and persisting its modification after the first cycle.
  for (int c = 0; c < backgroundIterations; c++) {
    for (int i = 0; i < heightFactors.length; i++) {
      rect(initialX, horizonHeight * heightFactors[i], initialX + widthX, horizonHeight);
      // Increment the x coordinate after drawing to avoid having an initial empty gap 
      initialX += incX;
    }
  }
  noStroke();
}

void checkGameOverTimer() {
  // Pause for a brief period after a game over, then reset the game
  if (!DELI_SHOP.isActive()) {
    GAME_OVER_TIMER += GAME_OVER_TIMER_INC;
    if (GAME_OVER_TIMER >= GAME_OVER_TIMER_MAX) {
      GAME_OVER_TIMER = 0;
      GAME_STARTED = false;
    }
  }
}

void drawTitleScreen() {
  background(49, 52, 74);
  noTint();
  imageMode(CENTER);
  image(SNAKE_BOXER_LOGO, width * 0.5, height * 0.25, UNIT_X * 60, UNIT_Y * 30);
  
  textSize(UNIT_X * 2);
  fill(255);
  text("PROTECT THE DELI SHOP!\n\nPRESS THE SCREEN TO MOVE AROUND!\nALSO PRESS TO PUNCH!",
       width * 0.22, height * 0.6);
}

void keyPressed() {
  //increaseDifficulty();
  //speedUpEnemies();
  // setupGame();
}

void draw() {
  if (!GAME_STARTED) {
    drawTitleScreen();
  } else {
    drawBackground();
    drawHealthBar();
    drawScoreAndLevel();
    drawUserResources();
    drawEnemies();
    checkGameOverTimer();
  }
}
