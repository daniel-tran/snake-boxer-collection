TitleScreen TITLE_SCREEN;
float UNIT_X;
float UNIT_Y;
float ZONE_ATTACK;
float ZONE_BLOCK;
float ZONE_MOVE_UP;
float ZONE_MOVE_DOWN;
Fighter PLAYER;
AIFighter ENEMY;
Background BACKDROP;

// These global variables are placed here to make it easier to adjust the difficulty of the game.
// Number of lives allowed in the game
int PLAYER_LIVES = 3;

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

  TITLE_SCREEN = new TitleScreen("titlescreen/SnakeBoxer5_Logo.png",
                                 "USE THE SCREEN!\n\nTOUCH UP/DOWN= MOVE\nTOUCH RIGHT= BLOCK\nTOUCH LEFT= PUNCH\n\nTOUCH= START",
                                 width * 0.22, height * 0.6,
                                 UNIT_X, UNIT_Y);
  TITLE_SCREEN.setGeneralItemImage("titlescreen/SnakeBoxer5_Snake.png",
                                   width * 0.7, height * 0.75 + UNIT_Y,
                                   UNIT_X * 18, UNIT_Y * 27);

  // The boxing stadium background is a special background,
  // and does not make use of some initial parameters.
  BACKDROP = new Background(6, 0, 0);
}

void mousePressed() {
  // User has made an attack.
  // This logic is not called during draw() to prevent continuous attacking
  // by holding down a single key.
  // Also check the sprite to avoid quick recovery after getting hurt.
  if (TITLE_SCREEN.isStarted() && mouseX < ZONE_ATTACK && PLAYER.isPlayable() && !PLAYER.isUsingHurtImage()) {
    PLAYER.startAttack();
  }
  
  if (!TITLE_SCREEN.isStarted()) {
    TITLE_SCREEN.setStartState(true);
    setupPlayers();
  } else if (PLAYER.isUsingGameOverImage() || ENEMY.isUsingGameOverImage()) {
    // User can quickly start a new game instead of waiting for the timer to finish 
    TITLE_SCREEN.forceReset();
  }
}

void keyPressed() {
  // Use this to debug by manually triggering an event, such as enemy health loss
  //PLAYER.startHurt(95);
}

void draw() {
  if (TITLE_SCREEN.isStarted()) {
    BACKDROP.drawBackground();

    // Draw UI components before the fighters to ensure that any possible overlap
    // results in the fighters getting visual priority when drawing.
    drawPlayerLives();
    drawScore();
    drawHealthBars();

    // Draw player and enemy
    float fighterMinY = height * 0.21;
    float fighterMaxY = height * 0.71;
    drawPlayer(fighterMinY, fighterMaxY);
    drawEnemy(fighterMinY, fighterMaxY);

    // Process general state changes after everything has been drawn
    registerDamage();
    updateStalling();
    checkGameOverTimer();
  } else {
    TITLE_SCREEN.drawTitleScreen();
  }
}

void setupPlayers() {
  PLAYER = new Fighter(width * 0.55, height * 0.45,
                       "characters/BoxerJoe/BoxerJoe_Idle.png",
                       "characters/BoxerJoe/BoxerJoe_Block.png",
                       "characters/BoxerJoe/BoxerJoe_Hurt.png",
                       new String[] {
                         "characters/BoxerJoe/BoxerJoe_Attack1.png",
                         "characters/BoxerJoe/BoxerJoe_Attack2.png"
                       },
                       UNIT_X * 22, UNIT_Y * 22);
  PLAYER.setLives(PLAYER_LIVES);
  PLAYER.isFlippedX = true;
  
  ENEMY = new AIFighter(width * 0.425, PLAYER.y,
                       "characters/Snake/Snake_Idle.png",
                       "characters/Snake/Snake_Block.png",
                       "characters/Snake/Snake_Hurt.png",
                       new String[] {
                         "characters/Snake/Snake_Attack1.png"
                       },
                       PLAYER.imgWidth, PLAYER.imgHeight);
  ENEMY.setLives(Integer.MAX_VALUE);
  ENEMY.randomiseTintOnLifeRecovery = true;
  // Behaviours are not randomised upon respawn
  setEnemyBehaviour();
  ENEMY.useRandomBehaviour = false;
  // Initial enemy settings to make the early fights easier
  ENEMY.setChanceOfActionAfterHurt(0);
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
  } else if (ENEMY.imgTint != 255) {
    // If the base sprite isn't using white as the predominant colour,
    // the health bar colour will sometimes mismatch with the sprite
    fill(ENEMY.imgTint);
  }
  rect(healthBarSectionX + (UNIT_X * 10), healthBarSectionY + UNIT_Y, (ENEMY.hp / ENEMY.hpMax) * (width * 0.75), UNIT_Y * 2);
  // Player HP, drawn as a percentage of remaining health multiplied by a static width
  fill(237, 28, 36);
  rect(healthBarSectionX + (UNIT_X * 10), healthBarSectionY + (UNIT_Y * 4), (PLAYER.hp / PLAYER.hpMax) * (width * 0.75), UNIT_Y * 2);
}

void drawPlayerLives() {
  float playerLivesX = width * 0.7;
  float playerLivesY = height * 0.21;
  float playerLivesWidth = UNIT_X * 2;
  float playerLivesHeight = UNIT_Y * 2;
  
  fill(237, 28, 36);
  // Draw a column of life icons
  for (int i = 0; i < PLAYER.lives; i++) {
    rect(playerLivesX, playerLivesY + (UNIT_Y * i * 4), playerLivesWidth, playerLivesHeight);
  }
}

void drawScore() {
  float textX = width * 0.66;
  float textY = height * 0.16;

  // Alignment is to prevent the score from trailing off the side of the screen
  textAlign(RIGHT);
  textSize(UNIT_X * 2);
  fill(255);
  text("KNOCKOUTS: " + abs(ENEMY.livesMax - ENEMY.lives), textX, textY);
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
    } else if (!PLAYER.isUsingHurtImage() && !PLAYER.isUsingAttackImage()) {
      // User is doing nothing
      PLAYER.resetToIdle();
    }
  }
  
  // User is only allowed to move on the Y axis
  PLAYER.keepWithinBoundary(PLAYER.x, PLAYER.x,
                            playerMinY + PLAYER.hitBoundaryYUp + (UNIT_Y * 2),
                            playerMaxY - PLAYER.hitBoundaryYDown - (UNIT_Y * 2)); 
  PLAYER.processAction();
  PLAYER.drawImage();
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
  ENEMY.drawImage();
}

void registerDamage() {
  // Player hit registration is determined first to prevent them
  // from overriding the enemy's attack
  if (ENEMY.isUsingAttackImage() && PLAYER.isPlayable() && 
     PLAYER.isWithinHitBoundary(PLAYER.x, PLAYER.x,
                                ENEMY.y - ENEMY.hitBoundaryYUp,
                                ENEMY.y + ENEMY.hitBoundaryYDown)
     ) {
    PLAYER.startHurt(ENEMY.getAttackDamage());
    if (PLAYER.hp <= 0) {
      ENEMY.isStalled = true;
      setEnemyBehaviour();
      // Need to process the hit to prevent survival on exactly 0 HP
      PLAYER.processAction();
    }
  }
  if (PLAYER.isUsingAttackImage() && ENEMY.isPlayable() &&
     ENEMY.isWithinHitBoundary(ENEMY.x, ENEMY.x,
                               PLAYER.y - PLAYER.hitBoundaryYUp,
                               PLAYER.y + PLAYER.hitBoundaryYDown) &&
     !ENEMY.invincibleTimer.isActive()
     ) {
    ENEMY.startHurt(PLAYER.getAttackDamage());
    if (ENEMY.hp <= 0) {
      PLAYER.isStalled = true;
      // Need to process the hit to prevent survival on exactly 0 HP
      ENEMY.processAction();
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
    TITLE_SCREEN.resetByTimer();
  }
}

void setEnemyBehaviour() {
  // In the original "Snake Boxer 5", the snakes appear to use the same
  // behaviour regardless of level.
  ENEMY.setBehaviour(2);
}
