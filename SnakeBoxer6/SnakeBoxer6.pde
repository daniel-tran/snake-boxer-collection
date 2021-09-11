float UNIT_X;
float UNIT_Y;
float ZONE_ATTACK;
float ZONE_BLOCK;
float ZONE_MOVE_UP;
float ZONE_MOVE_DOWN;

Background BACKDROP;
Fighter PLAYER;
AIFighter ENEMY;
Timer READY_TIMER = new Timer(1, 30, false);
Timer GO_TIMER = new Timer(1, 30, false);
Timer BACK_TO_FIGHTER_SELECTION_TIMER = new Timer(1, 60, false);
WorldMap WORLD;

FighterSelection FIGHTER_SELECTION;
boolean HAS_STARTED_1P_GAME;
// Title screen start state is to track the transition from title screen to fighter selection.
// Another variable is needed to track whether the user has transitioned to the fight.
TitleScreen TITLE_SCREEN;
boolean GAME_STARTED = false;

void setup() {
  fullScreen();
  //size(600, 400);
  noStroke();
  orientation(LANDSCAPE);
  textFont(createFont("PressStart2P.ttf", 32));
  
  UNIT_X = width * 0.01;
  UNIT_Y = UNIT_X;
  ZONE_ATTACK = width * 0.5;
  ZONE_BLOCK = width * 0.8;
  ZONE_MOVE_UP = height * 0.5;
  ZONE_MOVE_DOWN = height * 0.5;

  TITLE_SCREEN = new TitleScreen("titlescreen/SnakeBoxer_Logo.png",
                                 "USE THE SCREEN!\n\nTOUCH UP/DOWN= MOVE\nTOUCH RIGHT= BLOCK\n" +
                                 "HOLD RIGHT= CHARGE\nTOUCH LEFT= PUNCH\n\nTOUCH= START",
                                 width * 0.22, height * 0.65,
                                 UNIT_X, UNIT_Y);
  TITLE_SCREEN.setTagline("NOW THE SNAKES HAVE\nFISTS TOO", width * 0.225, height * 0.5);
  TITLE_SCREEN.setGeneralItemImage("titlescreen/SnakeBoxer_BoxArt.png",
                                   width * 0.75, height * 0.75, UNIT_X * 27, UNIT_Y * 27);

  // Need to set up the World during setup, since the draw() function uses it to check for the game state
  WORLD = new WorldMap(UNIT_X, UNIT_Y, width, height, "BOXER JOE");
  
  setupFighterSelection();
}

void mousePressed() {
  if (WORLD.locationIndex < 0) {
    if (!TITLE_SCREEN.isStarted()) {
      // Title screen
      // Press any part of the screen to move beyond the title screen.
      TITLE_SCREEN.setStartState(true);
    } else if (HAS_STARTED_1P_GAME) {
      // Location selection screen
      if (WORLD.locationIndex < 0) {
        WORLD.locationIndex = WORLD.getLocation(mouseX, mouseY);
        // Pick a location and load the fight
        if (WORLD.locationIndex >= 0) {
          GAME_STARTED = true;
          BACKDROP = WORLD.locationBackground[WORLD.locationIndex];
          ENEMY = WORLD.getLocationFighter(WORLD.locationIndex);
          WORLD.hasFightStarted = false;
          
          PLAYER.y = ENEMY.y;
          PLAYER.isStalled = true;
          ENEMY.isStalled = true;
          READY_TIMER.reset();
          GO_TIMER.reset();
        }
      }
    } else {
      // Fighter selection screen
      FIGHTER_SELECTION.updateFighterSelection();
      FIGHTER_SELECTION.updateModeSelection(mouseX, mouseY);
      
      if (FIGHTER_SELECTION.hasSelectedFighter() && FIGHTER_SELECTION.hasPressedStart(mouseX, mouseY) && !GAME_STARTED) {
        HAS_STARTED_1P_GAME = true;
        PLAYER = new Fighter(width * 0.55, height * 0.45, UNIT_X * 22, UNIT_Y * 22, FIGHTER_SELECTION.getPresetNameOfPlayer(0));
        PLAYER.setLives(3);
        PLAYER.isFlippedX = true;
        // Set the world after the player is set up to perform enemy exclusion (player cannot fight their own character copy)
        setupWorld();
      }
    }
  } else {
    // User has made an attack.
    // This logic is not called during draw() to prevent continuous attacking
    // by holding down a single key.
    // Also check the sprite to avoid quick recovery after getting hurt.
    if (GAME_STARTED && mouseX < ZONE_ATTACK && PLAYER.isPlayable() &&
        !PLAYER.isUsingHurtImage() && !PLAYER.isUsingAttackImage()) {
      PLAYER.startAttack();
    }
  }
  
  // This is the last action to ensure the user can't select a fighter and
  // move past the title screen at the same time.
  if (WORLD.isFadingBack) {
    // User pressed the screen after clearing 1P mode
    returnToFighterSelection();
  }
}

void keyPressed() {
  // Use this to debug by manually triggering an event, such as enemy health loss
  //PLAYER.startHurt(95);
  //ENEMY.startHurt(95);
  // Toggle between 1P and 2P mode
  //FIGHTER_SELECTION.playersCount = (FIGHTER_SELECTION.playersCount % 2) + 1;
  //FIGHTER_SELECTION.playerSelectionIndex = 0;
}

void draw() {
  if (WORLD.locationIndex < 0) {
    if (!TITLE_SCREEN.isStarted()) {
      TITLE_SCREEN.drawTitleScreen();
    } else if (HAS_STARTED_1P_GAME) {
      WORLD.drawMap();
    } else {
      FIGHTER_SELECTION.drawFighterSelection();
    }
  } else {
    BACKDROP.drawBackground();
    drawHealthBars();
    
    drawPlayer();
    drawEnemy();
    registerDamage();
    updateStalling();
    
    drawFightText();
    WORLD.updateFightStatus(ENEMY.isUsingGameOverImage());
    WORLD.drawWhiteOut();
    
    // Allow a way to return to the fighter selection screen from a fight
    if (BACK_TO_FIGHTER_SELECTION_TIMER.isOvertime()) {
      BACK_TO_FIGHTER_SELECTION_TIMER.reset();
      returnToFighterSelection();
    }
  }
}

void setupFighterSelection() {
  FIGHTER_SELECTION = new FighterSelection(UNIT_X, UNIT_Y);
  
  resetFighterSelection();
}

void resetFighterSelection() {
  TITLE_SCREEN.forceReset();
  GAME_STARTED = false;
  WORLD.hasFightStarted = false;
  HAS_STARTED_1P_GAME = false;
  FIGHTER_SELECTION.reset();
}

void setupWorld() {
  if (FIGHTER_SELECTION.playersCount <= 1) {
    // Player's fighter selection affects the opponents in 1P mode
    WORLD = new WorldMap(UNIT_X, UNIT_Y, width, height, PLAYER.name);
  } else {
    WORLD = new WorldMap(UNIT_X, UNIT_Y, width, height,
                         FIGHTER_SELECTION.getPresetNameOfPlayer(0),
                         FIGHTER_SELECTION.getPresetNameOfPlayer(1));
  }
}

void drawHealthBars() {
  float healthBarSectionX = UNIT_X * 2;
  float healthBarSectionY = height - (UNIT_Y * 10);
  float healthBarSectionWidth = width - (UNIT_X * 4);
  float healthBarSectionHeight = height - healthBarSectionY - (UNIT_Y * 2);
  
  float healthBarPlayerX = healthBarSectionX + (healthBarSectionWidth * 0.55);
  float healthBarPlayerY = healthBarSectionY + (UNIT_Y * 2);
  float healthBarWidth = healthBarSectionWidth * 0.4;
  float healthBarHeight = UNIT_Y * 2;
  float healthBarPlayerWidth = (PLAYER.hp / PLAYER.hpMax) * healthBarWidth;
  
  // Health bar section for drawing health bars on
  rectMode(CORNER);
  fill(0, 96, 252);
  rect(healthBarSectionX, healthBarSectionY, healthBarSectionWidth, healthBarSectionHeight);
  
  // Player HP, drawn as a percentage of remaining health multiplied by a static width
  fill(237, 28, 36);
  rect(healthBarPlayerX, healthBarPlayerY, healthBarPlayerWidth, healthBarHeight);
  
  // Enemy HP
  fill(181, 230, 29);
  float healthBarEnemyX = healthBarSectionX + (healthBarSectionWidth * 0.05);
  float healthBarEnemyWidth = (ENEMY.hp / ENEMY.hpMax) * healthBarWidth;
  rect(healthBarEnemyX, healthBarPlayerY, healthBarEnemyWidth, healthBarHeight);
  
  // Draw player lives
  float playerLivesX = healthBarPlayerX;
  float playerLivesY = healthBarPlayerY + (UNIT_Y * 3);
  float playerLivesXInc = UNIT_X * 4;
  float playerLivesWidth = UNIT_X * 2;
  float playerLivesHeight = UNIT_Y * 2;
  fill(237, 28, 36);
  // Draw a row of life icons for the player
  for (int i = 0; i < PLAYER.lives; i++) {
    rect(playerLivesX + (playerLivesXInc * i), playerLivesY, playerLivesWidth, playerLivesHeight);
  }
  // Draw a row of life icons for the enemy
  fill(181, 230, 29);
  for (int i = 0; i < ENEMY.lives; i++) {
    rect(healthBarEnemyX + (playerLivesXInc * i), playerLivesY, playerLivesWidth, playerLivesHeight);
  }
}

void drawPlayer() {
  float playerMinY = height * 0.25;
  float playerMaxY = playerMinY + (height * 0.5);
  
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
        if (!PLAYER.isUsingBlockImage()) {
          // Ensure the player begins blocking in a clean state
          PLAYER.resetToIdle();
        }
        PLAYER.startBlock();
      }
    } else if (!PLAYER.isUsingHurtImage()) {
      if (PLAYER.isChargedForSpecialAttack()) {
        // User is doing a special attack 
        PLAYER.startSpecialAttack();
      } else if (!PLAYER.isUsingAttackImage()) {
        // User is doing nothing
        PLAYER.resetToIdle();
      }
    }
  }
  
  // User is only allowed to move on the Y axis
  PLAYER.keepWithinBoundary(PLAYER.x, PLAYER.x,
                            playerMinY + PLAYER.hitBoundaryYUp + (UNIT_Y * 2),
                            playerMaxY - PLAYER.hitBoundaryYDown - (UNIT_Y * 4)); 
  PLAYER.processAction();
  
  // Resize the player sprite according to the screen dimensions
  PLAYER.drawImage();
}

void drawEnemy() {
  float playerMinY = height * 0.25;
  float playerMaxY = playerMinY + (height * 0.5);
  
  if (ENEMY.isPlayable() && ENEMY.isUsingIdleImage()) {
    float stepSizeY = UNIT_Y * 0.5 * ENEMY.speedYMultiplier;
    if (ENEMY.directionY == ENEMY.directionYUp) {
      ENEMY.y -= stepSizeY;
    } else if (ENEMY.directionY == ENEMY.directionYDown) {
      ENEMY.y += stepSizeY;
    }
  }
  
  ENEMY.keepWithinBoundary(ENEMY.x, ENEMY.x,
                           playerMinY + ENEMY.hitBoundaryYUp + (UNIT_Y * 2), 
                           playerMaxY - ENEMY.hitBoundaryYDown - (UNIT_Y * 4));
  ENEMY.defaultDirectionSwitch(ENEMY.x, ENEMY.x,
                           playerMinY + ENEMY.hitBoundaryYUp + (UNIT_Y * 2), 
                           playerMaxY - ENEMY.hitBoundaryYDown - (UNIT_Y * 4));
  ENEMY.decideAction();
  ENEMY.processAction();
  ENEMY.drawImage();
}

void drawFightText() {
  String fightText = "READY";
  READY_TIMER.tick();
  
  // Pause for a bit before the actual fight starts
  if (READY_TIMER.isOvertime()) {
    if (!WORLD.hasFightStarted) {
      // One-off actions once the initial pre-fighht countdown is over
      WORLD.hasFightStarted = true;
      PLAYER.isStalled = false;
      ENEMY.isStalled = false;
    }
    
    if (!GO_TIMER.isOvertime()) {
      // Fight has started, but still keep some text on screen to indicate this.
      fightText = "GO!";
      GO_TIMER.tick();
    } else {
      // Fight is underway, and now the on screen text is just used for the final winner
      if (PLAYER.lives <= 0 && PLAYER.isUsingGameOverImage()) {
        // Lose text varies on the mode
        if (FIGHTER_SELECTION.isSelectedVSMode()) {
          fightText = ENEMY.name + " WINS!";
        } else if (FIGHTER_SELECTION.isSelected1PMode()) {
          fightText = "YOU LOSE!";
        }
        // Player will return to the fighter selection afterwards
        BACK_TO_FIGHTER_SELECTION_TIMER.tick();
      } else if (ENEMY.lives <= 0 && ENEMY.isUsingGameOverImage()) {
        // Win text varies on the mode
        if (FIGHTER_SELECTION.isSelectedVSMode()) {
          fightText = PLAYER.name + " WINS!";
          BACK_TO_FIGHTER_SELECTION_TIMER.tick();
        } else if (FIGHTER_SELECTION.isSelected1PMode()) {
          fightText = "YOU WIN!";
        }
        // Location reselect timer is handled in the WorldMap class
      } else {
        // Nobody has won yet
        fightText = "";
      }
    }
  }
  
  // Show match status text
  fill(255, 0, 0);
  textAlign(CENTER);
  textSize(UNIT_X * 5);
  text(fightText, width * 0.5, height * 0.3);
}

void registerDamage() {
  // Player hit registration is determined first to prevent them
  // from overriding the enemy's attack
  if (ENEMY.isUsingAttackImage() && PLAYER.isPlayable() && !PLAYER.isUsingBlockImage() &&
     PLAYER.isWithinHitBoundary(PLAYER.x, PLAYER.x,
                                ENEMY.y - ENEMY.hitBoundaryYUp,
                                ENEMY.y + ENEMY.hitBoundaryYDown) 
     ) {
    PLAYER.startHurt(ENEMY.getAttackDamage());
    ENEMY.presetActivateOnHitAbility();
    if (PLAYER.hp <= 0) {
      ENEMY.isStalled = true;
      // Need to process the hit to prevent survival on exactly 0 HP
      PLAYER.processAction();
    }
  }
  if (PLAYER.isUsingAttackImage() && ENEMY.isPlayable() && !ENEMY.isUsingBlockImage() &&
     ENEMY.isWithinHitBoundary(ENEMY.x, ENEMY.x,
                               PLAYER.y - PLAYER.hitBoundaryYUp,
                               PLAYER.y + PLAYER.hitBoundaryYDown) &&
     !ENEMY.invincibleTimer.isActive()
     ) {
    ENEMY.startHurt(PLAYER.getAttackDamage());
    PLAYER.presetActivateOnHitAbility();
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
  }
  if (PLAYER.recoveryFlashCount >= PLAYER.recoveryFlashCountMax && PLAYER.lives > 0) {
    ENEMY.isStalled = false;
  }
}

void returnToFighterSelection() {
  // Game has been finished
  setupWorld();
  resetFighterSelection();
}
