/*
Rabbit Algebra:
- Correctly calculate x in the given equation
- You have three attempts before the game is over
- Technically, you're allowed to use a calculator or other means to get the answer
*/
class MinigameRabbitAlgebra extends MinigameManager {
  float buttonWidth = localUnitX * 2;
  float buttonHeight = localUnitY * 2;
  PImage imgRabbit = loadImage("minigames/RabbitAlgebra/Rabbit.png");
  
  int onesValue = 0;
  float onesX = width * 0.5;
  float onesY = height * 0.75;
  float onesButtonWidth = buttonWidth * 2;
  float onesButtonHeight = buttonWidth * 2;
  int tensValue = 0;
  float tensX = onesX - (localUnitX * 9);
  float tensY = onesY;
  float tensButtonWidth = onesButtonWidth;
  float tensButtonHeight = onesButtonHeight;
  ClickableButton tensUpButton = new ClickableButton(tensX, tensY - (localUnitY * 10),
                                                     tensButtonWidth, tensButtonHeight);
  ClickableButton tensDownButton = new ClickableButton(tensX, tensY + (localUnitY * 5),
                                                     tensButtonWidth, tensButtonHeight);
  ClickableButton onesUpButton = new ClickableButton(onesX, onesY - (localUnitY * 10),
                                                     onesButtonWidth, onesButtonHeight);
  ClickableButton onesDownButton = new ClickableButton(onesX, onesY + (localUnitY * 5),
                                                     onesButtonWidth, onesButtonHeight);
  ClickableButton equalsButton = new ClickableButton(onesX + (localUnitX * 9), onesY - (localUnitY * 3),
                                                     buttonWidth * 3, buttonHeight * 3);
  boolean showRetryMessage = false;
  Timer retryTimer = new Timer(1, 60, false);
  
  int valueRangePositive = 100;
  int valueRangeNegative = -valueRangePositive;
  // To make the game slightly more achievable, x is always a positive integer
  int xValue = (int)random(0, valueRangePositive);
  int xMultiplier = (int)random(valueRangeNegative, valueRangePositive);
  int offsetValue = (int)random(valueRangeNegative, valueRangePositive);
  
  int randomScore = (int)random(1000);
  int randomScoreInc = xValue;
  int mansValue = 3;
  int mansMultiplier = (int)random(1, 10);
  
  MinigameRabbitAlgebra(float localUnitWidth, float localUnitHeight) {
    super(localUnitWidth, localUnitHeight);
    setText("", 255);
    // Instruction text is permanently displayed during play
    instructionTimer.time = instructionTimer.timeMax;
    float buttonEqualsFontSize = localUnitX * 5;
    float buttonUpDownFontSize = localUnitX * 3;
    equalsButton.setButtonText("=", buttonEqualsFontSize);
    onesUpButton.setButtonText("+", buttonUpDownFontSize);
    onesDownButton.setButtonText("-", buttonUpDownFontSize);
    tensUpButton.setButtonText("+", buttonUpDownFontSize);
    tensDownButton.setButtonText("-", buttonUpDownFontSize);
  }
  
  void drawMinigame() {
    background(48, 96, 207);
    
    drawHeader();
    drawBlurb();
    drawNumberSelectionUI();
    drawRabbit();
    drawEquation();
  }
  
  void drawHeader() {
    float headerX = width * 0.5;
    float headerY = height * 0.05;
    float headerWidth = width;
    float headerHeight = headerY * 2;
    float scoreX = localUnitX * 15;
    float scoreY = localUnitY * 4;
    float mansX = width - localUnitX * 15;
    float mansY = scoreY;
    float headerTextFontSize = localUnitX * 2;

    // Draw header background
    rectMode(CENTER);
    fill(0);
    noStroke();
    rect(headerX, headerY, headerWidth, headerHeight);
    stroke(255);
    strokeWeight(5);
    line(0, headerHeight, headerWidth, headerHeight);
    noStroke();
    
    // Draw the header text    
    fill(255);
    textSize(headerTextFontSize);
    // Use text alignment to have two pieces of related text joined while still
    // being able to control the font colour of each text piece independently
    textAlign(RIGHT);
    text("score: ", scoreX, scoreY);
    textAlign(LEFT);
    fill(255, 255, 0);
    text(randomScore, scoreX, scoreY);
    // Draw the mans counter
    textAlign(RIGHT);
    fill(255);
    text("mans: ", mansX, mansY);
    textAlign(LEFT);
    fill(255, 255, 0);
    text(mansMultiplier + "x=" + (mansMultiplier * mansValue), mansX, mansY);
  }
  
  void drawBlurb() {
    float blurbTextFontSize = localUnitX * 5;
    float blurbTextX = width * 0.5;
    float blurbTextY = height * 0.3;
    
    textAlign(CENTER);
    textSize(blurbTextFontSize);
    String blurbText;
    if (hasWon) {
      // Show the winning text
      fill(0, 255, 0);
      int correctValue;
      if (xIsMultipliedBy0()) {
        // Note that any x value is correct if its multiplier is 0
        correctValue = getEnteredValue();
      } else {
        correctValue = xValue;
      }
      blurbText = "CORRECT!! x = " + correctValue;
    } else if (showRetryMessage) {
      // Show retry message, which onlys shows temporarily
      fill(255, 127, 39);
      blurbText = "TRY AGAIN";
      retryTimer.tick();
      if (retryTimer.isOvertime()) {
        retryTimer.reset();
        showRetryMessage = false;
      }
    } else if (enableLoseTimer) {
      fill(255, 127, 39);
      blurbText = "WRONG!! x = " + xValue;
    } else {
      // Game is in the neutral state
      fill(255, 255, 0);
      blurbText = "SOLVE FOR X!!";
    }
    text(blurbText, blurbTextX, blurbTextY);
  }
  
  void drawNumberSelectionUI () {
    fill(255);
    // Draw the values.
    // Keep these drawings together so we don't have to keep switching font settings unnecessarily after drawing the buttons
    text(tensValue, tensX, tensY);
    text(onesValue, onesX, onesY);
    // Draw the buttons to modify the tens value
    tensUpButton.drawButton();
    tensDownButton.drawButton();
    // Draw the buttons to modify the ones value
    onesUpButton.drawButton();
    onesDownButton.drawButton();
    // Draw the equals button and its symbol on top
    equalsButton.drawButton();
  }
  
  void drawRabbit() {
    float rabbitX = width * 0.125;
    float rabbitY = height * 0.76;
    float rabbitWidth = localUnitX * 15;
    float rabbitHeight = localUnitY * 15;

    image(imgRabbit, rabbitX, rabbitY, rabbitWidth, rabbitHeight);
  }
  
  void drawEquation() {
    float equationX = width * 0.5;
    float equationY = height * 0.5;
    float equationSpeechBubbleX = equationX;
    float equationSpeechBubbleY = equationY - (height * 0.05);
    float equationSpeechBubbleWidth = width * 0.95;
    float equationSpeechBubbleHeight = height * 0.125;
    float equationSpeechBubbleRoundingRadius = localUnitX * 4;
    // You can add (equationSpeechBubbleHeight * 0.45) to the first two points' Y coordinate
    // to align the triangle edge with the speech bubble's bottom edge
    float[][] equationSpeechBubbleTrianglePoints = {
      {width * 0.25, equationSpeechBubbleY},
      {width * 0.35, equationSpeechBubbleY},
      {width * 0.20, height * 0.65}
    };
    int finalValue = (xMultiplier * xValue) + offsetValue;

    // Draw the equation speech bubble
    // Due to technical limitations of the Processing API, having an outline on
    // the entire speech bubble isn't easy, since it's a combination of two shapes.
    fill(255);
    rect(equationSpeechBubbleX, equationSpeechBubbleY, equationSpeechBubbleWidth, equationSpeechBubbleHeight, equationSpeechBubbleRoundingRadius);
    triangle(equationSpeechBubbleTrianglePoints[0][0], equationSpeechBubbleTrianglePoints[0][1],
             equationSpeechBubbleTrianglePoints[1][0], equationSpeechBubbleTrianglePoints[1][1],
             equationSpeechBubbleTrianglePoints[2][0], equationSpeechBubbleTrianglePoints[2][1]);
    
    // Draw the equation
    char offsetSymbol;
    if (offsetValue < 0) {
      offsetSymbol = '-';
    } else {
      offsetSymbol = '+';
    }
    fill(0);
    textAlign(CENTER);
    text(xMultiplier + "x " + offsetSymbol + " " + abs(offsetValue) + " = " + finalValue, equationX, equationY);
  }
  
  void screenPressed() {
    if (onesUpButton.isPressed(mouseX, mouseY)) {
      // Loop back to 0 if exceeding 9
      onesValue = (onesValue + 1) % 10;
    } else if (onesDownButton.isPressed(mouseX, mouseY)) {
      // Loop back to 9 if undercutting 0
      onesValue = (10 + (onesValue - 1)) % 10;
    }

    if (tensUpButton.isPressed(mouseX, mouseY)) {
      // Loop back to 0 if exceeding 9
      tensValue = (tensValue + 1) % 10;
    } else if (tensDownButton.isPressed(mouseX, mouseY)) {
      // Loop back to 9 if undercutting 0
      tensValue = (10 + (tensValue - 1)) % 10;
    }

    if (equalsButton.isPressed(mouseX, mouseY) && !hasWon && !enableLoseTimer && !retryTimer.isActive()) {
      // If the x multiplier is 0, x can be any value for a correct equation
      if (getEnteredValue() == xValue || xIsMultipliedBy0()) {
        hasWon = true;
        enableWinTimer = true;
        randomScore += randomScoreInc;
      } else {
        randomScore -= randomScoreInc;
        mansValue--;
        if (mansValue <= 0) {
          // Player has used all their mans and it's GAME OVER
          enableLoseTimer = true;
        } else {
          // Player can still re-attempt with one less man
          showRetryMessage = true;
        }
      }
    }
  }
  
  boolean xIsMultipliedBy0() {
    return xMultiplier == 0;
  }
  
  int getEnteredValue() {
    return (tensValue * 10) + onesValue;
  }
}
