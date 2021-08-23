float UNIT_X;
float UNIT_Y;
Fighter PLAYER;
Fighter ENEMY;
ClickableButton UPGRADE_BUTTON;
DialogBoxUpgrade UPGRADE_MENU;
ClickableButton RANK_UP_BUTTON;
DialogBoxRankUp RANK_UP_MENU;
ClickableButton EVENT_BUTTON;
DialogBoxEvent EVENT_MENU;
TitleScreen TITLE_SCREEN;

void setup() {
  fullScreen();
  //size(960, 540); // Approximate screen resolution for the Moto E (2nd generation)
  noStroke();
  orientation(LANDSCAPE);
  textFont(createFont("PressStart2P.ttf", 32));
  
  UNIT_X = width * 0.01;
  UNIT_Y = UNIT_X;
  
  TITLE_SCREEN = new TitleScreen("titlescreen/SnakeBoxer3_Logo.png",
                                 "USE THE SCREEN!\n\nTOUCH= PUNCH\nUPGRADE= POWER UP USING DIPLOMACY\nRANK UP= DOUBLES UPGRADES\nEVENT= FREE DIPLOMACY SOMETIMES",
                                 width * 0.22, height * 0.7,
                                 UNIT_X, UNIT_Y);
  TITLE_SCREEN.setTagline("SOLVING PROBLEMS\nTHROUGH DIPLOMACY", width * 0.225, height * 0.55);
  TITLE_SCREEN.setGeneralItemImage("titlescreen/SnakeBoxer3_Image.png",
                                   width * 0.8, height * 0.65,
                                   UNIT_X * 22, UNIT_Y * 22);
  PLAYER = new Fighter(width * 0.55, height * 0.65,
                       "characters/BoxerJoe/BoxerJoe_Idle.png",
                       "characters/BoxerJoe/BoxerJoe_Block.png",
                       "characters/BoxerJoe/BoxerJoe_Hurt.png",
                       new String[]{
                         "characters/BoxerJoe/BoxerJoe_Attack1.png",
                         "characters/BoxerJoe/BoxerJoe_Attack2.png"
                       },
                       UNIT_X * 22, UNIT_Y * 22);
  PLAYER.isFlippedX = true;
                       
  ENEMY = new Fighter(width * 0.425, height * 0.65,
                       "characters/Snake/Snake_Idle.png",
                       "characters/Snake/Snake_Block.png",
                       "characters/Snake/Snake_Hurt.png",
                       new String[]{
                         "characters/Snake/Snake_Attack1.png"
                       },
                       UNIT_X * 22, UNIT_Y * 22);
  
  float buttonX = width * 0.5;
  float buttonY = height * 0.9;
  float buttonXOffset = width * 0.25;
  float buttonWidth = UNIT_X * 22;
  float buttonHeight = UNIT_Y * 7;
  float buttonFontSize = UNIT_X * 3;
  float dialogBoxX = width * 0.5;
  float dialogBoxY = height * 0.5;
  float dialogBoxWidth = width * 0.9;
  float dialogBoxHeight = height * 0.9; 
  RANK_UP_BUTTON = new ClickableButton(buttonX - buttonXOffset, buttonY, buttonWidth, buttonHeight);
  RANK_UP_BUTTON.setButtonText("RANK UP", buttonFontSize);
  RANK_UP_BUTTON.setButtonColour(51, 153, 51);
  RANK_UP_MENU = new DialogBoxRankUp(dialogBoxX, dialogBoxY,
                               dialogBoxWidth, dialogBoxHeight,
                               buttonWidth, buttonHeight, true);
  RANK_UP_MENU.setTextSize(buttonFontSize);
  
  UPGRADE_BUTTON = new ClickableButton(buttonX, buttonY, buttonWidth, buttonHeight);
  UPGRADE_BUTTON.setButtonText("UPGRADE", buttonFontSize);
  UPGRADE_BUTTON.setButtonColour(254, 153, 153);
  UPGRADE_MENU = new DialogBoxUpgrade(dialogBoxX, dialogBoxY,
                               dialogBoxWidth, dialogBoxHeight,
                               UNIT_X * 16, buttonHeight, false);
  UPGRADE_MENU.setTextSize(buttonFontSize);
  UPGRADE_MENU.setDialogTextSize(UNIT_X * 2.3);
  setUpgradeMenuHeading();
  
  EVENT_BUTTON = new ClickableButton(buttonX + buttonXOffset, buttonY, buttonWidth, buttonHeight);
  EVENT_BUTTON.setButtonText("EVENT", buttonFontSize);
  EVENT_BUTTON.setButtonColour(255, 204, 0);
  EVENT_MENU = new DialogBoxEvent(dialogBoxX, dialogBoxY,
                               dialogBoxWidth, dialogBoxHeight,
                               buttonWidth, buttonHeight, false);
  EVENT_MENU.setTextSize(buttonFontSize);
  EVENT_MENU.setText("Random event!", "FLAGRANT SYSTEM ERROR!");
}

void mousePressed() {
  // The initial press to get past the title screen should not count as scoring
  if (!TITLE_SCREEN.isStarted()) {
    TITLE_SCREEN.setStartState(true);
    return;
  }
  
  if (!UPGRADE_MENU.isActive() && !RANK_UP_MENU.isActive() && !EVENT_MENU.isActive()) {
    if (UPGRADE_BUTTON.isPressed(mouseX, mouseY)) {
      UPGRADE_MENU.show();
    } else if (RANK_UP_BUTTON.isPressed(mouseX, mouseY) && RANK_UP_MENU.isAbleToRankUp(UPGRADE_MENU.getPoints())) {
      // Only show the rank up menu when there are still ranks to be promoted to
      if (RANK_UP_MENU.isAbleToRankUp(UPGRADE_MENU.getPoints())) {
        RANK_UP_MENU.show();
      }
    } else if (EVENT_BUTTON.isPressed(mouseX, mouseY) && EVENT_MENU.isTimeForEvent()) {
      if (EVENT_MENU.isTimeForEvent()) {
        EVENT_MENU.show();
      }
    } else if (PLAYER.isPlayable()) {
      // Player has just presed the screen normally
      PLAYER.startAttack();
      ENEMY.startHurt(0);
      UPGRADE_MENU.incrementPoints();
      EVENT_MENU.incrementEventCountdown(UPGRADE_MENU.getPoints());
    }
  } else if (UPGRADE_MENU.isActive()) {
    UPGRADE_MENU.registerButtonPress(mouseX, mouseY);
  } else if (RANK_UP_MENU.isActive()) {
    
    if (RANK_UP_MENU.hasPressedYes(mouseX, mouseY)) {
      RANK_UP_MENU.rankUp();
      UPGRADE_MENU.resetPoints();
      UPGRADE_MENU.rankUp();
      EVENT_MENU.setEventCountdown();
      setUpgradeMenuHeading();
    }
    
    // Make an action based on the button pressed before registering it,
    // leaving critical state changes as the last action.
    RANK_UP_MENU.registerButtonPress(mouseX, mouseY);
  } else if (EVENT_MENU.isActive()) {
    
    if (EVENT_MENU.hasPressedYes(mouseX, mouseY)) {
      UPGRADE_MENU.incrementPoints(EVENT_MENU.getPointsYes());
      EVENT_MENU.setEventCountdown();
    } else if (EVENT_MENU.hasPressedNo(mouseX, mouseY)) {
      UPGRADE_MENU.incrementPoints(EVENT_MENU.getPointsNo());
      EVENT_MENU.setEventCountdown();
    } else if (EVENT_MENU.hasPressedOK(mouseX, mouseY)) {
      UPGRADE_MENU.incrementPoints(EVENT_MENU.getPointsOK());
      EVENT_MENU.setEventCountdown();
    }
    
    // Make an action based on the button pressed before registering it,
    // leaving critical state changes as the last action.
    EVENT_MENU.registerButtonPress(mouseX, mouseY);
  }
}

void keyPressed() {
  // Use this for debug purposes
  //UPGRADE_MENU.points += 1000000;
}

void draw() {
  if (!TITLE_SCREEN.isStarted()) {
    TITLE_SCREEN.drawTitleScreen();
  } else {
    drawBackground();
    
    // Draw the current points
    fill(0);
    textSize(UNIT_X * 5);
    textAlign(CENTER);
    text(nfc(UPGRADE_MENU.getPoints()), width * 0.5, height * 0.25);
    
    PLAYER.processAction();
    ENEMY.processAction();
    PLAYER.drawImage();
    ENEMY.drawImage();
    
    UPGRADE_BUTTON.drawButton();
    if (RANK_UP_MENU.isAbleToRankUp(UPGRADE_MENU.getPoints())) {
      RANK_UP_BUTTON.drawButton();
    }
    if (EVENT_MENU.isTimeForEvent()) {
      EVENT_BUTTON.drawButton();
    }
    UPGRADE_MENU.drawDialogBox();
    RANK_UP_MENU.drawDialogBox();
    EVENT_MENU.drawDialogBox();
    
    UPGRADE_MENU.processIdleTimer();
  }
}

void setUpgradeMenuHeading() {
  UPGRADE_MENU.setText(RANK_UP_MENU.getCurrentRank() + " Upgrades", "");
}

void drawBackground() {
  // Draw sky stripes.
  // Use background() to set the colour of the largest sky stripe.
  background(106, 155, 188);
  rectMode(CORNER);
  fill(137, 186, 219);
  float skyStripeHeightFirst = height * 0.1;
  float skyStripeHeightSecond = height * 0.15;
  rect(0, 0, width, skyStripeHeightFirst);
  fill(123, 172, 205);
  rect(0, skyStripeHeightFirst, width, skyStripeHeightSecond);
  
  // Draw hills. These are mirrored and are separated by some space.
  fill(0, 102, 0);
  stroke(0, 102, 0);
  strokeWeight(1);
  rectMode(CORNERS);
  // Height units are multiples of the global Y unit, specifying the height of the right hill columns.
  float[] hillHeightUnits = {
    1, 2, 3, 3, 4, 4, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 7, 7, 7, 7,
    6, 6, 6, 6, 5, 5, 5, 5, 6, 6, 6, 5, 5
  };
  float hillSeparationDistance = UNIT_X * 27;
  float hillLeftXInitial = width * 0.35;
  float hillRightXInitial = hillLeftXInitial + hillSeparationDistance;
  float hillY = height * 0.5;
  for (int i = 0; i < hillHeightUnits.length; i++) {
    float hillColumnWidth = UNIT_X;
    float hillHeight = hillY - (UNIT_Y * hillHeightUnits[i]);
    float hillLeftX = hillLeftXInitial - (UNIT_X * i);
    // Draw the left hill
    rect(hillLeftX, hillY, hillLeftX - hillColumnWidth, hillHeight);
    
    // Draw the right hill
    float hillRightX = hillRightXInitial + (UNIT_X * i);
    rect(hillRightX, hillY, hillRightX + hillColumnWidth, hillHeight);
  }
  noStroke();
  
  // Draw land stripes with alternating colours
  rectMode(CORNER);
  float horizonY = height * 0.5;
  int landStripeCount = 6;
  float landStripeHeight = horizonY / landStripeCount;
  for (int i = 0; i < landStripeCount; i++) {
    if (i % 2 == 0) {
      fill(1, 153, 52);
    } else {
      fill(0, 132, 43);
    }
    
    rect(0, horizonY + (landStripeHeight * i), width, landStripeHeight);
  }
  
  // Draw road as a series of smaller rectangles, increasing in width
  fill(204);
  float roadStripeXInitial = hillLeftXInitial;
  float roadStripeWidthInitial = hillSeparationDistance;
  float roadStripeHeight = landStripeHeight * 0.5;
  for (int i = 0; i < landStripeCount * 2; i++) {
    float roadStripeX = roadStripeXInitial - (UNIT_X * i);
    float roadStripeY = horizonY + (roadStripeHeight * i);
    float roadStripeWidth = roadStripeWidthInitial + (UNIT_X * 2 * i);
    rect(roadStripeX, roadStripeY, roadStripeWidth, roadStripeHeight);
  }
}
