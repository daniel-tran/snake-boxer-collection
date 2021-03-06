/*
Score Card:
- Punch all the holes on the Strong Bad Rewards Score Card
- Some points might already be pre-punched
*/
class MinigameScoreCard extends MinigameManager {
  PImage imgScoreCard = loadImage("minigames/ScoreCard/ScoreCardCheatless.png");
  PImage imgPointActive = loadImage("minigames/ScoreCard/PointActiveFilled.png");
  PImage imgPointInactive = loadImage("minigames/ScoreCard/PointInactive.png");
  PImage imgOK = loadImage("minigames/ScoreCard/OK.png");
  float scoreCardX = random(width * 0.25, width * 0.75);
  float scoreCardY = random(height * 0.25, height * 0.55);
  float scoreCardWidth = width * 0.7;
  float scoreCardHeight = height * 0.8;
  float pointInitialX = scoreCardX - (scoreCardWidth * 0.275);
  float pointInitialY = scoreCardY + (scoreCardHeight * 0.375);

  int pointCount = 5;
  int pointsScored = 0;
  boolean[] pointPunchedStates = new boolean[pointCount];
  ClickableButton[] pointAreas = new ClickableButton[pointCount];
  
  MinigameScoreCard(float localUnitWidth, float localUnitHeight) {
    super(localUnitWidth, localUnitHeight);
    setText("Punch holes!", 0);
    
    // Integer rounding ensures we always have at least one unpunched point
    int pointsPrepunchedCount = (int)random(pointCount);
    for (int i = 0; i < pointPunchedStates.length; i++) {
      float isPrepunched = random(1);
      float pointIncX = scoreCardWidth * 0.15;
      float pointIncY = -scoreCardHeight * 0.05;
      // The game can start with fewer prepunched points than calculated,
      // which adds a bit more variation to each play
      if (isPrepunched > 0.5 && pointsPrepunchedCount > 0) {
        punchPoint(i);
        pointsPrepunchedCount--;
      } else {
        pointPunchedStates[i] = false;
      }

      // Set up each point as a button, but only use it for press detection.
      // This is to avoid having multiple copies of the same image in memory, as the minigame
      // is slow enough in Java mode.
      pointAreas[i] = new ClickableButton(pointInitialX + (pointIncX * i), pointInitialY + (pointIncY * i),
                                          localUnitX * 8, localUnitY * 8);
    }
  }
  
  void drawMinigame() {
    background(128, 96, 0);
    
    // Draw scorecard
    imageMode(CENTER);
    image(imgScoreCard, scoreCardX, scoreCardY, scoreCardWidth, scoreCardHeight);
    
    if (hasWon) {
      drawSpeechBubble();
    }
    
    drawPoints();
  }
  
  void drawSpeechBubble() {
    float speechBubbleX = scoreCardX - (localUnitX * 7);
    float speechBubbleY = scoreCardY - (localUnitY * 5);
    float speechBubbleWidth = localUnitX * 11;
    float speechBubbleHeight = localUnitY * 11;

    image(imgOK, speechBubbleX, speechBubbleY, speechBubbleWidth, speechBubbleHeight);
  }
  
  void drawPoints() {
    for (int i = 0; i < pointPunchedStates.length; i++) {
      PImage imgPointDrawn;
      if (pointPunchedStates[i]) {
        imgPointDrawn = imgPointActive;
      } else {
        imgPointDrawn = imgPointInactive;
      }
      
      // Draw the point using positioning information from the point area
      image(imgPointDrawn, pointAreas[i].x, pointAreas[i].y, pointAreas[i].buttonWidth, pointAreas[i].buttonHeight);
    }
  }
  
  void punchPoint(int index) {
    pointPunchedStates[index] = true;
    pointsScored++;
  }
  
  void screenPressed() {
    for (int i = 0; i < pointPunchedStates.length; i++) {
      if (pointAreas[i].isPressed(mouseX, mouseY) && !pointPunchedStates[i]) {
        punchPoint(i);
        // Since only one point can be punched at a time, no point in continuing the loop
        break;
      }
    }
    
    if (pointsScored >= pointPunchedStates.length && !hasWon) {
      // All the points have been punched
      hasWon = true;
      enableWinTimer = true;
    }
  }
}
