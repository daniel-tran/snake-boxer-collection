/*
Virus Scan:
- Drag the mouse or touch point to the right to make the progress bar increase
*/
class MinigameVirusScan extends MinigameManager {
  float progressBarInitialX = width * 0.25;
  float progressBarInitialY = height * 0.65;
  float progressBarFinalX = progressBarInitialX + localUnitX;
  float progressBarFinalY = progressBarInitialY + (height * 0.05);
  float progressBarMeasureFromX = progressBarInitialX;
  float progressBarWinAtX = width * 0.8;
  float progressBarInc = 15;
  
  // "Viruses Found" number is formatted with a comma separator
  // Also setting the minimum value to 2 just so that we don't need to consider using
  // the singular noun "virus" in the game blurb if virusesFound happens to be 1  
  String virusesFound = nfc((int)random(2, 1000000));
  
  MinigameVirusScan(float localUnitWidth, float localUnitHeight) {
    super(localUnitWidth, localUnitHeight);
    setText("Pull the progress!", 255);
  }
  
  void drawMinigame() {
    float gameBlurbX = width * 0.5;
    float gameBlurbY = height * 0.2;
    float gameBlurbYInc = height * 0.1;
    float gameBlurbFontSize = localUnitX * 2;
    float virusesFoundFontSize = localUnitX * 5;
    
    background(0);
    
    if (!hasWon) {
      // Draw the game blurb
      textSize(gameBlurbFontSize);
      fill(255, 255, 0);
      text("Virus Protection\nversion .0001", gameBlurbX, gameBlurbY);
      fill(255);
      text("Last scan was NEVER ago.", gameBlurbX, gameBlurbY + (gameBlurbYInc * 2));
                    
      // Draw the actual progress bar
      rectMode(CORNERS);
      noStroke();
      fill(194, 194, 3);
      rect(progressBarInitialX, progressBarInitialY,
           progressBarFinalX, progressBarFinalY);

      // Draw dividers that make the progress bar look like a row of blocks
      stroke(0);
      strokeWeight(5);
      for (float i = progressBarInitialX; i < progressBarWinAtX; i += localUnitX) {
        line(i, progressBarInitialY, i, progressBarFinalY);
      }
      noStroke();
    } else {
      // Draw the game blurb upon winning
      textSize(gameBlurbFontSize);
      fill(255, 255, 0);
      text("Scan Complete!", gameBlurbX, gameBlurbY);
      textSize(virusesFoundFontSize);
      fill(255, 0, 0);
      text(virusesFound, gameBlurbX, gameBlurbY + (gameBlurbYInc * 2));
      textSize(gameBlurbFontSize);
      fill(255);
      text("Viruses Found", gameBlurbX, gameBlurbY + (gameBlurbYInc * 3));
      fill(255, 255, 0);
      text("A New Record!!", gameBlurbX, gameBlurbY  + (gameBlurbYInc * 4));
    }    
  }
  
  void screenDragged() {
    // Mouse is dragged past the initial touch point
    if (mouseX > progressBarMeasureFromX && !hasWon) {
      progressBarFinalX += progressBarInc;
      // Player must continue their rightward swiping to continue progress,
      // or start a new drag motion
      progressBarMeasureFromX = mouseX;
      
      if (progressBarFinalX >= progressBarWinAtX) {
        progressBarFinalX = progressBarWinAtX;
        hasWon = true;
      }
    }
  }
  
  void screenPressed() {
    // Dragging the mouse is determined relative to where the initial touch point was
    progressBarMeasureFromX = mouseX;
  }
}
