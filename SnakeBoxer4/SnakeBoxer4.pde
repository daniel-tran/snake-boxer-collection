void setup() {
  fullScreen();
  //size(600, 400);
  noStroke();
  orientation(LANDSCAPE);
  textFont(createFont("PressStart2P.ttf", 32));
  
  SNAKE_BOXER_LOGO = loadImage("titlescreen/SnakeBoxer4_Logo.png");
  SNAKE_BOXER_TITLE_SCREEN_SNAKE = loadImage("titlescreen/SnakeBoxer4_Snake.png");
  
  UNIT_X = width * 0.01;
  UNIT_Y = UNIT_X;
}

void setupGame() {
  LEVEL = 0;
  SCORE = 0;
  // Need to set the speed multiplier here to ensure the difficulty doesn't persist
  DIFFICULTY_SPEED_MULTIPLIER = 1;
  
  setupPlayer();
  setupEnemies();
  setupBackgroundElements();
  
  selectNextMinigame();
  TRANSITION_TIMER.reset();
}

void setupPlayer() {
  float playerX = width * 0.75;
  PLAYER = new Fighter(playerX, height * 0.6,
                       "characters/BoxerJoe/BoxerJoe_Idle.png",
                       "characters/BoxerJoe/BoxerJoe_Block.png",
                       "characters/BoxerJoe/BoxerJoe_Hurt.png",
                       new String[]{
                         "characters/BoxerJoe/BoxerJoe_Attack1.png",
                         "characters/BoxerJoe/BoxerJoe_Attack2.png"
                       },
                       UNIT_X * 22, UNIT_Y * 22);
  PLAYER.lives = 4;
  PLAYER.hp = PLAYER.lives;
  PLAYER_PUSHBACK_X = new float[PLAYER.lives + 1];
  
  // Mark the positions that the player moves back to each time they lose a life.
  // Since the movement if from right to left, determine the positions from last to first.
  float pushbackInc = UNIT_X * 6;
  for (int i = PLAYER_PUSHBACK_X.length - 1; i >= 0 ; i--) {
    PLAYER_PUSHBACK_X[i] = playerX;
    playerX -= pushbackInc;
  }
}

void setupEnemies() {
  ENEMIES = new MovingEnemy[11];
  String[] idleImages = {"characters/Snake/Snake_Idle.png",
                         "characters/Snake/Snake_Idle2.png"};
  float[] possibleX = {0};
  float[] possibleY = {0};
  
  // Enemies are just created mainly as part of the UI, and aren't expected to respawn
  for (int i = 0; i < ENEMIES.length; i++) {
    ENEMIES[i] = new MovingEnemy(0, 0,
                                 "characters/Snake/Snake_Hurt.png",
                                 idleImages,
                                 PLAYER.imgWidth, PLAYER.imgHeight,
                                 possibleX, possibleY);
    ENEMIES[i].imgMovingTimer.timeMax *= 2;
    ENEMIES[i].recoveryFlashTimer.timeMax *= 2;
  }
  
  // Set the position of each individual snake
  float backrowX = width * 0.02;
  float backrowYFactor = 0.25;
  float midrowX = width * 0.13;
  float frontrowX = width * 0.24;
  float leadrowX = width * 0.4;
  ENEMIES[0].x = backrowX;
  ENEMIES[0].y = height * 0.5;
  ENEMIES[1].x = backrowX;
  ENEMIES[1].y = ENEMIES[0].y + (ENEMIES[0].imgHeight * backrowYFactor); 
  ENEMIES[2].x = backrowX;
  ENEMIES[2].y = ENEMIES[1].y + (ENEMIES[1].imgHeight * backrowYFactor);
  
  ENEMIES[3].x = midrowX;
  ENEMIES[3].y = height * 0.45;
  ENEMIES[4].x = midrowX;
  ENEMIES[4].y = ENEMIES[3].y + (ENEMIES[3].imgHeight * backrowYFactor);
  ENEMIES[5].x = midrowX;
  ENEMIES[5].y = ENEMIES[4].y + (ENEMIES[4].imgHeight * backrowYFactor);
  ENEMIES[6].x = midrowX;
  ENEMIES[6].y = ENEMIES[5].y + (ENEMIES[5].imgHeight * backrowYFactor);
  
  ENEMIES[7].x = frontrowX;
  ENEMIES[7].y = height * 0.5;
  ENEMIES[8].x = frontrowX;
  ENEMIES[8].y = ENEMIES[7].y + (ENEMIES[7].imgHeight * backrowYFactor);
  ENEMIES[9].x = frontrowX;
  ENEMIES[9].y = ENEMIES[8].y + (ENEMIES[8].imgHeight * backrowYFactor);
  
  ENEMIES[10].x = leadrowX;
  ENEMIES[10].y = ENEMIES[8].y;
  
  for (int i = 0; i < ENEMIES.length; i++) {
    float[] enemyPossibleX = {ENEMIES[i].x};
    float[] enemyPossibleY = {ENEMIES[i].y};
    ENEMIES[i].positionOptionsX = enemyPossibleX;
    ENEMIES[i].positionOptionsY = enemyPossibleY;
  }
}

void setupBackgroundElements() {
  float[] possibleBackgroundElementX = {width + UNIT_X};
  int possibleYCount = 14;
  float possibleYBoundaryMin = UNIT_Y;
  float possibleYInc = height / possibleYCount;
  float[] possibleBackgroundElementY = new float[possibleYCount];
  for (int i = 0; i < possibleYCount; i++) {
    // First position should start at the first increment instead of 0
    possibleBackgroundElementY[i] = possibleYBoundaryMin + (possibleYInc * (i + 1));
  }
  int[][] backgroundElementColours = {
    {255, 255, 255},
    {56, 184, 248},
    {24, 72, 200},
  };
  BACKGROUND_ELEMENTS = new MovingBackgroundElement[16];
  for (int i = 0; i < BACKGROUND_ELEMENTS.length; i++) {
    // Set the spawn distance between each enemy
    float initialX = UNIT_X + (UNIT_X * 11 * i);
    float initialY = possibleBackgroundElementY[(int)random(possibleBackgroundElementY.length)];
    BACKGROUND_ELEMENTS[i] = new MovingBackgroundElement(initialX, initialY,
                                 possibleBackgroundElementX, possibleBackgroundElementY,
                                 UNIT_X, UNIT_Y,
                                 -UNIT_X
                                 );
    int randomFillColour = (int)random(backgroundElementColours.length);
    BACKGROUND_ELEMENTS[i].setFillColour(
      backgroundElementColours[randomFillColour][0],
      backgroundElementColours[randomFillColour][1],
      backgroundElementColours[randomFillColour][2]
    );
  }
}

float UNIT_X;
float UNIT_Y;
int SCORE;
int LEVEL;
Fighter PLAYER;
MovingEnemy[] ENEMIES;
MovingBackgroundElement[] BACKGROUND_ELEMENTS;
float[] PLAYER_PUSHBACK_X;
boolean ENEMIES_WERE_HURT = false;
float DIFFICULTY_SPEED_MULTIPLIER;
PImage SNAKE_BOXER_LOGO;
PImage SNAKE_BOXER_TITLE_SCREEN_SNAKE;
boolean GAME_STARTED = false;
Timer GAME_OVER_TIMER = new Timer(1, 120, false);

MinigameManager MM;
Timer TRANSITION_TIMER = new Timer(1, 30, false);

void drawPlayerLives(float playerLivesX, float playerLivesY) {
  float playerLivesWidth = UNIT_X * 2;
  float playerLivesHeight = UNIT_Y * 2;
  
  fill(237, 28, 36);
  // Draw a column of life icons
  for (int i = 0; i < PLAYER.lives; i++) {
    rect(playerLivesX + (UNIT_X * i * 8), playerLivesY, playerLivesWidth, playerLivesHeight);
  }
}

void drawBackgroundElements() {
  float backgroundElementStepX = -UNIT_X * 5;
  
  background(0);
  noStroke();
  for (int i = 0; i < BACKGROUND_ELEMENTS.length; i++) {
    if (PLAYER.isPlayable()) {
      BACKGROUND_ELEMENTS[i].step(backgroundElementStepX * DIFFICULTY_SPEED_MULTIPLIER);
    }
    BACKGROUND_ELEMENTS[i].drawElement();
  }
}

void drawEnemies() {
  int ladySnakeIndex = 10;
  for (int i = 0; i < ENEMIES.length; i++) {
    // Ignore enemies that haven't been loaded, since the level is too low
    if (ENEMIES[i] == null) {
      continue;
    }
    
    // Visual differences for Lady Snake
    if (i == ladySnakeIndex) {
      tint(192, 0, 255);
    }
    
    ENEMIES[i].processAction();
    ENEMIES[i].drawImage();
    noTint();
  }
  
  // After hurting the enemies, score a point after they've finished recovering 
  if (ENEMIES[ladySnakeIndex].recoveryFlashCount > 0) {
    ENEMIES_WERE_HURT = true;
  } else if (ENEMIES_WERE_HURT) {
    ENEMIES_WERE_HURT = false;
    increaseScore();
    TRANSITION_TIMER.reset();
  }
}

void increaseScore() {
  int pointsToIncreaseDifficulty = 5;
  float difficultySpeedMultiplierInc = 0.25;
  
  SCORE++;
  // Increase difficulty after a certain score milestone, rather than after each minigame
  if (SCORE % pointsToIncreaseDifficulty == 0) {
    DIFFICULTY_SPEED_MULTIPLIER += difficultySpeedMultiplierInc;
  }
}

void drawPlayer() {
  // Ensure we don't check for an invalid pushback position
  int pushbackIndex = max(0, PLAYER.lives);
  // Player is pushed back when hurt, moving closer to the snakes
  if (PLAYER.x > PLAYER_PUSHBACK_X[pushbackIndex]) {
    PLAYER.x -= UNIT_X;
  }

  imageMode(CENTER);
  image(PLAYER.imgDrawn, PLAYER.x, PLAYER.y, PLAYER.imgWidth, PLAYER.imgHeight);
  boolean isPlayerHurt = PLAYER.hurtTimer.isActive();
  PLAYER.processAction();

  // Player has recovered from being hurt
  if (isPlayerHurt && PLAYER.hurtTimer.isActive()) {
    TRANSITION_TIMER.reset();
  }
}

void selectNextMinigame() {
  float localUnitX = UNIT_X;
  float localUnitY = UNIT_Y;
  int minigameCount = 10;
  int minigameIndex = (int)random(minigameCount); // Ensure the default case is also a valid selection
  // If the font size is 32, instructions should be 18 characters or less
  switch (minigameIndex) {
    case 0:
      MM = new MinigameCompy(localUnitX, localUnitY);
      MM.setTimerSpeed(DIFFICULTY_SPEED_MULTIPLIER * 0.5);
      break;
    case 1:
      MM = new MinigameBurninatePhonics(localUnitX, localUnitY);
      MM.setTimerSpeed(DIFFICULTY_SPEED_MULTIPLIER);
      MM.enableWinBySurvival = true;
      break;
    case 2:
      MM = new MinigameVidelectrix(localUnitX, localUnitY);
      MM.setTimerSpeed(DIFFICULTY_SPEED_MULTIPLIER);
      break;
    case 3:
      MM = new MinigameScoreCard(localUnitX, localUnitY);
      MM.setTimerSpeed(DIFFICULTY_SPEED_MULTIPLIER);
      break;
    case 4:
      MM = new MinigameRabbitAlgebra(localUnitX, localUnitY);
      MM.setTimerSpeed(DIFFICULTY_SPEED_MULTIPLIER * 0.1);
      break;
    case 5:
      MM = new MinigameVirusScan(localUnitX, localUnitY);
      MM.setTimerSpeed(DIFFICULTY_SPEED_MULTIPLIER);
      break;
    case 6:
      MM = new MinigameMatch(localUnitX, localUnitY);
      MM.setTimerSpeed(DIFFICULTY_SPEED_MULTIPLIER * 0.1);
      break;
    case 7:
      MM = new MinigameTangerineDreams(localUnitX, localUnitY);
      MM.setTimerSpeed(DIFFICULTY_SPEED_MULTIPLIER * 0.75);
      break;
    case 8:
      MM = new MinigameAirplane(localUnitX, localUnitY);
      MM.setTimerSpeed(DIFFICULTY_SPEED_MULTIPLIER * 0.5);
      MM.enableWinBySurvival = true;
      break;
    default:
      MM = new MinigameSaladDaze(localUnitX, localUnitY);
      MM.setTimerSpeed(DIFFICULTY_SPEED_MULTIPLIER);
  }
}

void drawGame() {
  if (!TRANSITION_TIMER.isOvertime()) {
    if (PLAYER.isPlayable()) {
      TRANSITION_TIMER.tick();
    }
    // Background elements are drawn first so that everything overlaps them
    drawBackgroundElements();
    
    float scoreFontSize = UNIT_X * 5;
    float scoreX = width * 0.5;
    float scoreY = height * 0.35;
    textAlign(CENTER);
    textSize(scoreFontSize);
    fill(255);
    text(SCORE, scoreX, scoreY);
    drawPlayerLives(width * 0.38, height * 0.1);
    // Player is drawn before the enemies so that the GAME OVER sprite is drawn
    // under the enemy sprite, which looks slightly more correct
    drawPlayer();
    drawEnemies();
  } else {
    MM.drawElements();
    MM.processAction();
    
    if (MM.hasEnded) {
      // Set the transition timer low enough that there's enough time for the
      // player or snake hurt animations to finish playing.
      // This will be set again (properly) once those animations finish.
      TRANSITION_TIMER.time = -TRANSITION_TIMER.timeMax;
      if (MM.hasWon) {
        for (int i = 0; i < ENEMIES.length; i++) {
          ENEMIES[i].startHurt();
        }
      } else {
        PLAYER.lives--;
        PLAYER.startHurt(1);
      }
      selectNextMinigame();
    }
  }
}

void mousePressed() {
  // Prevent players from making actions until the minigame has actually started
  if (GAME_STARTED) {
    if (!MM.isShowingInstructions()) {
      MM.screenPressed();
    }
  } else {
    GAME_STARTED = true;
    setupGame();
  }
}

void mouseReleased() {
  // Prevent players from making actions until the minigame has actually started
  if (GAME_STARTED && !MM.isShowingInstructions()) {
    MM.screenReleased();
  }
}

void mouseDragged() {
  // Prevent players from making actions until the minigame has actually started
  if (GAME_STARTED && !MM.isShowingInstructions()) {
    MM.screenDragged();
  }
}

void keyPressed() {
  // Prevent players from making actions until the minigame has actually started
  if (GAME_STARTED && !MM.isShowingInstructions()) {
    MM.keyboardPressed();
  }
}

void drawTitleScreen() {
  background(49, 52, 74);
  noTint();
  imageMode(CENTER);
  image(SNAKE_BOXER_LOGO, width * 0.5, height * 0.3, UNIT_X * 60, UNIT_Y * 30);
  image(SNAKE_BOXER_TITLE_SCREEN_SNAKE, width * 0.65, height * 0.75, UNIT_X * 33, UNIT_Y * 33);
  textSize(UNIT_X * 2.5);
  textAlign(LEFT);
  fill(255, 0, 0);
  text("LADY SNAKE PARADE",
       width * 0.225, height * 0.55);
  
  textSize(UNIT_X * 2);
  fill(255);
  text("KEYBOARD/\nTOUCH SCREEN/\nDRAG= PLAY",
       width * 0.22, height * 0.7);
}

void checkGameOverTimer() {
  // Pause for a brief period after a game over, then reset the game
  if (!PLAYER.isPlayable()) {
    GAME_OVER_TIMER.tick();
    if (GAME_OVER_TIMER.isOvertime()) {
      GAME_OVER_TIMER.reset();
      GAME_STARTED = false;
      setupGame();
    }
  }
}

void draw() {
  if (!GAME_STARTED) {
    drawTitleScreen();
  } else {
    drawGame();
    checkGameOverTimer();
  }
}
