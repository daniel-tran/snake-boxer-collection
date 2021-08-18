void setup() {
  fullScreen();
  //size(960, 540); // Approximate screen resolution for the Moto E (2nd generation)
  noStroke();
  orientation(LANDSCAPE);
  textFont(createFont("PressStart2P.ttf", 32));
  
  UNIT_X = width * 0.01;
  UNIT_Y = UNIT_X;
  ZONE_ATTACK = width * 0.5;
  ZONE_BLOCK = width * 0.8;
  ZONE_MOVE_UP = height * 0.5;
  ZONE_MOVE_DOWN = height * 0.5;
  
  SNAKE_BOXER_LOGO = loadImage("titlescreen/SnakeBoxer_Logo.png");
  SNAKE_BOXER_SNAKE = loadImage("titlescreen/SnakeBoxer_Snake.png");
}

PImage SNAKE_BOXER_LOGO;
PImage SNAKE_BOXER_SNAKE;
boolean GAME_STARTED = false;
float UNIT_X = 24;
float UNIT_Y = UNIT_X;
float ZONE_ATTACK;
float ZONE_BLOCK;
float ZONE_MOVE_UP;
float ZONE_MOVE_DOWN;
int GAME_OVER_TIMER = 0;
int GAME_OVER_TIMER_INC = 1;
int GAME_OVER_TIMER_MAX = 120;

Fighter PLAYER;
AIFighter ENEMY;

void setupPlayers() {
  String[] attacksNormal = {"characters/BoxerJoe/BoxerJoe_Attack1.png",
                            "characters/BoxerJoe/BoxerJoe_Attack2.png"};
  PLAYER = new Fighter(width * 0.55, height * 0.45,
                       "characters/BoxerJoe/BoxerJoe_Idle.png",
                       "characters/BoxerJoe/BoxerJoe_Block.png",
                       "characters/BoxerJoe/BoxerJoe_Hurt.png",
                       attacksNormal,
                       UNIT_X * 22, UNIT_Y * 22);
  PLAYER.setLives(3);
  
  String[] attacksSnake = {"characters/Snake/Snake_Attack1.png"};
  ENEMY = new AIFighter(width * 0.425, height * 0.45,
                       "characters/Snake/Snake_Idle.png",
                       "characters/Snake/Snake_Block.png",
                       "characters/Snake/Snake_Hurt.png", attacksSnake,
                       UNIT_X * 22, UNIT_Y * 22);
  ENEMY.setLives(Integer.MAX_VALUE);
  ENEMY.randomiseTintOnLifeRecovery = true;
}

void drawTitleScreen() {
  background(49, 52, 74);
  noTint();
  imageMode(CENTER);
  image(SNAKE_BOXER_LOGO, width * 0.5, height * 0.25, UNIT_X * 60, UNIT_Y * 30);
  image(SNAKE_BOXER_SNAKE, width * 0.7, height * 0.75 + UNIT_Y, UNIT_X * 18, UNIT_Y * 27);
  
  textSize(UNIT_X * 2);
  fill(255);
  text("USE THE SCREEN!\n\nTOUCH UP/DOWN= MOVE\nTOUCH RIGHT= BLOCK\nTOUCH LEFT= PUNCH\n\nTOUCH= START",
       width * 0.22, height * 0.6);
}

void drawStage() {
  float mainStageX = width * 0.3;
  float mainStageY = height * 0.25 - (UNIT_Y * 4);
  float mainStageWidth = width * 0.35;
  float mainStageHeight = height * 0.5;

  // Background colour outside of the stage area
  background(0);

  // Main stage
  fill(204);
  rect(mainStageX, mainStageY, mainStageWidth, mainStageHeight);
  
  fill(255);
  // Horizontal fencing
  float rightmostFenceX = mainStageX + mainStageWidth + UNIT_X;
  rect(mainStageX - (UNIT_X * 2), mainStageY, UNIT_X, mainStageHeight);
  rect(rightmostFenceX, mainStageY, UNIT_X, mainStageHeight);
  // Vertical fencing
  float topmostFenceY = mainStageY - (UNIT_Y * 2); 
  rect(mainStageX, topmostFenceY, mainStageWidth, UNIT_Y);
  rect(mainStageX, mainStageY + mainStageHeight + UNIT_Y, mainStageWidth, UNIT_Y);
       
  // Diagonal fencing
  for (int i = 0; i < 4; i++) {
    // Split increments into separate variables, if we ever want to skew the diagonal fencing
    float incrementX = UNIT_X * i;
    float incrementY = UNIT_Y * i;
    
    // Top left
    rect(mainStageX - (UNIT_X * 2) + incrementX, mainStageY - (UNIT_Y * 2) + incrementY,
       UNIT_X, UNIT_Y);
    // Top right
    rect(mainStageX + mainStageWidth + UNIT_X - incrementX, mainStageY - (UNIT_Y * 2) + incrementY,
         UNIT_X, UNIT_Y);
    // Bottom right
    rect(mainStageX + mainStageWidth + UNIT_X - incrementX, mainStageY + mainStageHeight + UNIT_Y - incrementY,
         UNIT_X, UNIT_Y);
    // Bottom left
    rect(mainStageX - (UNIT_X * 2) + incrementX, mainStageY + mainStageHeight + UNIT_Y - incrementY,
         UNIT_X, UNIT_Y);
  }
  
  // Draw UI components relative to the stage
  drawPlayerLives(rightmostFenceX + (UNIT_X * 4), mainStageY);
  drawScore(mainStageX + (UNIT_X * 12), topmostFenceY - UNIT_Y);
  
  // Draw player relative to the stage to keep them within the stage boundaries
  drawPlayer(mainStageY, mainStageY + mainStageHeight);
  drawEnemy(mainStageY, mainStageY + mainStageHeight);
}

void drawHealthBars() {
  float healthBarSectionX = UNIT_X * 2;
  float healthBarSectionY = height - (UNIT_Y * 10);
  float healthBarSectionWidth = width - (UNIT_X * 4);
  float healthBarSectionHeight = height - healthBarSectionY - (UNIT_Y * 2);
  
  // Health bar section for drawing health bars on
  fill(0, 96, 252);
  rect(healthBarSectionX, healthBarSectionY, healthBarSectionWidth, healthBarSectionHeight);
  
  // Enemy HP, drawn as a percentage of remaining health multiplied by a static width
  if (ENEMY.lives >= ENEMY.livesMax || !ENEMY.randomiseTintOnLifeRecovery) {
    // The first level always uses the same colour for the healthbar
    fill(181, 230, 29);
  } else if (ENEMY.imgTint.size() > 0) {
    // If the base sprite isn't using white as the predominant colour,
    // the health bar colour will sometimes mismatch with the sprite
    fill(ENEMY.imgTint.get("R"), ENEMY.imgTint.get("G"), ENEMY.imgTint.get("B"));
  }
  rect(healthBarSectionX + (UNIT_X * 10), healthBarSectionY + UNIT_Y, (ENEMY.hp / ENEMY.hpMax) * (width * 0.75), UNIT_Y * 2);
  // Player HP, drawn as a percentage of remaining health multiplied by a static width
  fill(237, 28, 36);
  rect(healthBarSectionX + (UNIT_X * 10), healthBarSectionY + (UNIT_Y * 4), (PLAYER.hp / PLAYER.hpMax) * (width * 0.75), UNIT_Y * 2);
}

void drawPlayerLives(float playerLivesX, float playerLivesY) {
  float playerLivesWidth = UNIT_X * 2;
  float playerLivesHeight = UNIT_Y * 2;
  
  fill(237, 28, 36);
  // Draw a column of life icons
  for (int i = 0; i < PLAYER.lives; i++) {
    rect(playerLivesX, playerLivesY + (UNIT_Y * i * 4), playerLivesWidth, playerLivesHeight);
  }
}

void drawScore(float textX, float textY) {
  textSize(UNIT_X * 2);
  fill(255);
  text("KNOCKOUTS:" + abs(ENEMY.livesMax - ENEMY.lives), textX, textY);
}

void drawPlayer(float playerMinY, float playerMaxY) {
  if (PLAYER.isPlayable()) {
    if (mousePressed) {
      
      // User made a movement action
      // This should only be done when the user is not initiating another action 
      if (mouseX > ZONE_ATTACK && mouseX < ZONE_BLOCK && PLAYER.isUsingIdleImage()) {
        if (mouseY < ZONE_MOVE_UP) {
          PLAYER.y -= UNIT_Y * 0.5 * PLAYER.speedYMultiplier;
        } else if (mouseY > ZONE_MOVE_DOWN && PLAYER.y + PLAYER.hitBoundaryYDown < playerMaxY) {
          // Unit Y offset is to account for the sprite's height
          PLAYER.y += UNIT_Y * 0.5 * PLAYER.speedYMultiplier;
        }
        
      } else if (mouseX > ZONE_BLOCK && !PLAYER.isUsingHurtImage()) {
        // User made a valid blocking action.
        // Move this to mousePressed() to force players to press the screen
        // within the block zone.
        PLAYER.startBlock();
      }
    } else if (!PLAYER.isUsingHurtImage()) {
      // User is doing nothing
      PLAYER.resetToIdle();
    }
  }
  
  // User is only allowed to move on the Y axis
  PLAYER.keepWithinBoundary(PLAYER.x, PLAYER.x,
                            playerMinY + PLAYER.hitBoundaryYUp + (UNIT_Y * 2),
                            playerMaxY - PLAYER.hitBoundaryYDown - (UNIT_Y * 2)); 
  PLAYER.processAction();
  
  // Resize the player sprite according to the screen dimensions
  imageMode(CENTER);
  tint(PLAYER.imgTint.get("R"), PLAYER.imgTint.get("G"), PLAYER.imgTint.get("B"));
  image(PLAYER.imgDrawn, PLAYER.x, PLAYER.y, PLAYER.imgWidth, PLAYER.imgHeight);
}

void drawEnemy(float playerMinY, float playerMaxY) {
  if (ENEMY.isPlayable() && ENEMY.isUsingIdleImage()) {
    if (ENEMY.directionY == ENEMY.directionYUp) {
      ENEMY.y -= UNIT_Y * 0.5 * ENEMY.speedYMultiplier;
    } else if (ENEMY.directionY == ENEMY.directionYDown) {
      ENEMY.y += UNIT_Y * 0.5 * ENEMY.speedYMultiplier;
    }
  }
  
  ENEMY.keepWithinBoundary(ENEMY.x, ENEMY.x,
                           playerMinY + ENEMY.hitBoundaryYUp + (UNIT_Y * 2), 
                           playerMaxY - ENEMY.hitBoundaryYDown - (UNIT_Y * 2));
  ENEMY.defaultDirectionSwitch(ENEMY.x, ENEMY.x,
                           playerMinY + ENEMY.hitBoundaryYUp + (UNIT_Y * 2), 
                           playerMaxY - ENEMY.hitBoundaryYDown - (UNIT_Y * 2));
  ENEMY.decideAction();
  ENEMY.processAction();
  
  imageMode(CENTER);
  tint(ENEMY.imgTint.get("R"), ENEMY.imgTint.get("G"), ENEMY.imgTint.get("B"));
  image(ENEMY.imgDrawn, ENEMY.x, ENEMY.y, ENEMY.imgWidth, ENEMY.imgHeight);
}

void registerDamage() {
  if (PLAYER.isUsingAttackImage() && ENEMY.isPlayable() && 
     ENEMY.isWithinHitBoundary(ENEMY.x, ENEMY.x,
                               PLAYER.y - PLAYER.hitBoundaryYUp,
                               PLAYER.y + PLAYER.hitBoundaryYDown) 
     ) {
    ENEMY.startHurt(PLAYER.getAttackDamage());
    if (ENEMY.hp <= 0) {
      PLAYER.isStalled = true;
      // Need to process the hit to prevent survival on exactly 0 HP
      ENEMY.processAction();
    }
  }
  if (ENEMY.isUsingAttackImage() && PLAYER.isPlayable() && 
     PLAYER.isWithinHitBoundary(PLAYER.x, PLAYER.x,
                                ENEMY.y - ENEMY.hitBoundaryYUp,
                                ENEMY.y + ENEMY.hitBoundaryYDown) 
     ) {
    PLAYER.startHurt(ENEMY.getAttackDamage());
    if (PLAYER.hp <= 0) {
      ENEMY.isStalled = true;
      // Need to process the hit to prevent survival on exactly 0 HP
      PLAYER.processAction();
    }
  }
}

void updateStalling() {
  // Unfreezes the player or enemy after the other has recovered from losing a life
  if (ENEMY.recoveryFlashCount >= ENEMY.recoveryFlashCountMax && ENEMY.lives > 0) {
    PLAYER.isStalled = false;
    ENEMY.levelUp();
  }
  if (PLAYER.recoveryFlashCount >= PLAYER.recoveryFlashCountMax && PLAYER.lives > 0) {
    ENEMY.isStalled = false;
  }
}

void checkGameOverTimer() {
  // Pause for a brief period after a game over, then reset the game
  if (PLAYER.isUsingGameOverImage() || ENEMY.isUsingGameOverImage()) {
    GAME_OVER_TIMER += GAME_OVER_TIMER_INC;
    if (GAME_OVER_TIMER >= GAME_OVER_TIMER_MAX) {
      GAME_OVER_TIMER = 0;
      GAME_STARTED = false;
    }
  }
}

void mousePressed() {
  // User has made an attack.
  // This logic is not called during draw() to prevent continuous attacking
  // by holding down a single key.
  // Also check the sprite to avoid quick recovery after getting hurt.
  if (GAME_STARTED && mouseX < ZONE_ATTACK && PLAYER.isPlayable() && !PLAYER.isUsingHurtImage()) {
    PLAYER.startAttack();
  }
  
  if (!GAME_STARTED) {
    GAME_STARTED = true;
    setupPlayers();
  } else if (PLAYER.isUsingGameOverImage() || ENEMY.isUsingGameOverImage()) {
    // User can quickly start a new game instead of waiting for the timer to finish 
    GAME_STARTED = false;
  }
}

void keyPressed() {
  // Use this to debug by manually triggering an event, such as enemy health loss
  // ENEMY.startHurt(95);
}

void keyReleased() {
  // Can add charged attack execution here 
}

void draw() {
  if (GAME_STARTED) {
    drawStage();
    drawHealthBars();
    registerDamage();
    updateStalling();
    checkGameOverTimer();
  } else {
    drawTitleScreen();
  }
}
