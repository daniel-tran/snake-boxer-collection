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

  SNAKE_BOXER_LOGO = loadImage("titlescreen/SnakeBoxer5_Logo.png");
  SNAKE_BOXER_SNAKE = loadImage("titlescreen/SnakeBoxer5_Snake.png");
  
  // The boxing stadium background is a special background,
  // and does not make use of some initial parameters.
  BACKDROP = new Background(6, 0, 0);
}

PImage SNAKE_BOXER_LOGO;
PImage SNAKE_BOXER_SNAKE;
boolean GAME_STARTED = false;
float UNIT_X;
float UNIT_Y;
float ZONE_ATTACK;
float ZONE_BLOCK;
float ZONE_MOVE_UP;
float ZONE_MOVE_DOWN;
Timer GAME_OVER_TIMER = new Timer(1, 120, false);

Fighter PLAYER;
AIFighter ENEMY;
Background BACKDROP;

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
  PLAYER.setLives(3);
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
}

void drawTitleScreen() {
  background(49, 52, 74);
  noTint();
  imageMode(CENTER);
  image(SNAKE_BOXER_LOGO, width * 0.5, height * 0.25, UNIT_X * 60, UNIT_Y * 30);
  image(SNAKE_BOXER_SNAKE, width * 0.7, height * 0.75 + UNIT_Y, UNIT_X * 18, UNIT_Y * 27);
  
  textAlign(LEFT);
  textSize(UNIT_X * 2);
  fill(255);
  text("USE THE SCREEN!\n\nTOUCH UP/DOWN= MOVE\nTOUCH RIGHT= BLOCK\nTOUCH LEFT= PUNCH\n\nTOUCH= START",
       width * 0.22, height * 0.6);
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
    GAME_OVER_TIMER.tick();
    if (GAME_OVER_TIMER.isOvertime()) {
      GAME_OVER_TIMER.reset();
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
    GAME_OVER_TIMER.time = GAME_OVER_TIMER.timeMax;
  }
}

void keyPressed() {
  // Use this to debug by manually triggering an event, such as enemy health loss
  //PLAYER.startHurt(95);
}

void draw() {
  if (GAME_STARTED) {
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
    drawTitleScreen();
  }
}
