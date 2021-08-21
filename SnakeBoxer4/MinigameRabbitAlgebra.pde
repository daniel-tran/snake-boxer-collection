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
  float onesUpX = onesX;
  float onesUpY = onesY - (localUnitY * 10);
  float onesDownX = onesX;
  float onesDownY = onesY + (localUnitY * 5);
  int tensValue = 0;
  float tensX = onesX - (localUnitX * 9);
  float tensY = onesY;
  float tensUpX = tensX;
  float tensUpY = tensY - (localUnitY * 10);
  float tensDownX = tensX;
  float tensDownY = tensY + (localUnitY * 5);
  float equalsX = onesX + (localUnitX * 9);
  float equalsY = onesY - (localUnitY * 3);
  float equalsButtonWidth = buttonWidth * 1.5;
  float equalsButtonHeight = buttonHeight * 1.5;
  boolean showRetryMessage = false;
  float retryTimer = 0;
  float retryTimerInc = 1;
  float retryTimerMax = 60;
  
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
      retryTimer += retryTimerInc;
      if (retryTimer >= retryTimerMax) {
        retryTimer = 0;
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
    // Draw the tens value
    text(tensValue, tensX, tensY);
    // Draw the button to increase the tens value
    triangle(tensUpX, tensUpY - buttonHeight,
             tensUpX + buttonWidth, tensUpY + buttonHeight,
             tensUpX - buttonWidth, tensUpY + buttonHeight);
    // Draw the button to decrease the tens value
    triangle(tensDownX, tensDownY + buttonHeight,
             tensDownX + buttonWidth, tensDownY - buttonHeight,
             tensDownX - buttonWidth, tensDownY - buttonHeight);
    // Draw the ones value
    text(onesValue, onesX, onesY);
    // Draw the button to increase the ones value
    triangle(onesUpX, onesUpY - buttonHeight,
             onesUpX + buttonWidth, onesUpY + buttonHeight,
             onesUpX - buttonWidth, onesUpY + buttonHeight);
    // Draw the button to decrease the ones value
    triangle(onesDownX, onesDownY + buttonHeight,
             onesDownX + buttonWidth, onesDownY - buttonHeight,
             onesDownX - buttonWidth, onesDownY - buttonHeight);
    // Draw the equals button and its symbol on top
    fill(128);
    rect(equalsX, equalsY, equalsButtonWidth * 2, equalsButtonHeight * 2);
    fill(255);
    // Equals button should align with the displayed numbers, at least on the Y axis
    text("=", equalsX, onesY);
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
    text(xMultiplier + "x " + offsetSymbol + " " + abs(offsetValue) + " = " + finalValue, equationX, equationY);
  }
  
  void screenPressed() {
    boolean onesUpWasPressed = hasPressedArea(onesUpX, onesUpY,
                                              buttonWidth, buttonHeight);
    boolean onesDownWasPressed = hasPressedArea(onesDownX, onesDownY,
                                              buttonWidth, buttonHeight);                                          
    if (onesUpWasPressed) {
      // Loop back to 0 if exceeding 9
      onesValue = (onesValue + 1) % 10;
    } else if (onesDownWasPressed) {
      // Loop back to 9 if undercutting 0
      onesValue = (10 + (onesValue - 1)) % 10;
    }
    
    boolean tensUpWasPressed = hasPressedArea(tensUpX, tensUpY,
                                              buttonWidth, buttonHeight);
    boolean tensDownWasPressed = hasPressedArea(tensDownX, tensDownY,
                                              buttonWidth, buttonHeight);                                        
    if (tensUpWasPressed) {
      // Loop back to 0 if exceeding 9
      tensValue = (tensValue + 1) % 10;
    } else if (tensDownWasPressed) {
      // Loop back to 9 if undercutting 0
      tensValue = (10 + (tensValue - 1)) % 10;
    }
    
    boolean equalsWasPressed = hasPressedArea(equalsX, equalsY,
                                              equalsButtonWidth, equalsButtonHeight);
    if (equalsWasPressed && !hasWon && !enableLoseTimer) {
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
