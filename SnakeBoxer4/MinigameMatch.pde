/*
Match:
- Find two cards with the same name
- Selecting two non-matching cards results in a short delay
- As difficulty increases, the delay on selecting non-matching cards also increases
*/
class MinigameMatch extends MinigameManager {
  int gridCountRows = 5;
  int gridCountColumns = 6;
  float[][][] gridCellPositions = new float[gridCountColumns][gridCountRows][2];
  String[][] gridCellPrize = new String[gridCountColumns][gridCountRows];
  StringList gridCellPrizeNames = new StringList();
  boolean hasSelectedFirstChoice = false;
  boolean hasSelectedSecondChoice = false;
  int gridFirstChoiceX;
  int gridFirstChoiceY;
  int gridSecondChoiceX;
  int gridSecondChoiceY;
  boolean isResettingGridSelection = false;
  float gridSelectionTimer = 0;
  float gridSelectionTimerInc = 1;
  float gridSelectionTimerMax = 30;
  
  float gridInitialX = width * 0.05;
  float gridInitialY = height * 0.1;
  float cellWidth = localUnitX * 14;
  float cellHeight = localUnitY * 4;
  float cellWidthOffset = localUnitX * 0.5;
  float cellHeightOffset = localUnitY * 0.5;
  
  StringList playerNames = new StringList(
    "OLDENBUT",
    "BERNAU",
    "SYMPTOMO",
    "TOPTOAST"
  );
  int playerTurn = 0;
  int playerCount = 2;
  int[] playerNamesSelection = new int[playerCount];
  StringDict prizeWorth = new StringDict();
  
  MinigameMatch(float localUnitWidth, float localUnitHeight) {
    super(localUnitWidth, localUnitHeight);
    setText("Match a prize!", 255);
    
    // Some prize names won't get selected when there are more names than (total cells * 0.5)
    String[] prizeNames = {
      "BETAMAX",
      "FRIENDLYWARE",
      "TURKEY FARM",
      "GOLD RING",
      "VOLKSWAGEN",
      "ROLEX CAMERA",
      "MX-80 PRINTER",
      "TRIP TO JAPAN",
      "MOBILE HOME",
      "CB-RADIO",
      "BRICK HOME",
      "CORVETTE",
      "TAMPA NUGGET",
      "SURF BOARD",
      "BRASS BED",
      "6 PACK/COORS"
    };
    
    // Select unique player names from a randomised list of options
    playerNames.shuffle();
    for (int i = 0; i < playerNamesSelection.length; i++) {
      playerNamesSelection[i] = i;
    }
    
    // Generate a randomised order for the prize names.
    for (int i = 0; i < prizeNames.length; i++) {
      addPrize(prizeNames[i]);
    }
    gridCellPrizeNames.shuffle();
    
    // Assign each prize to a grid cell
    for (int indexX = 0; indexX < gridCountColumns; indexX++) {
      for (int indexY = 0; indexY < gridCountRows; indexY++) {
        float innerCellX = gridInitialX + ((cellWidth + cellWidthOffset) * indexX);
        float innerCellY = gridInitialY + ((cellHeight + cellHeightOffset) * indexY);
        gridCellPositions[indexX][indexY][0] = innerCellX;
        gridCellPositions[indexX][indexY][1] = innerCellY;
        // Remove the prize name so that the next prize can be selected
        gridCellPrize[indexX][indexY] = gridCellPrizeNames.remove(0);
      }
    }
  }
  
  void addPrize(String prizeName) {
    // Two copies of the prize name, so it can be matched
    gridCellPrizeNames.append(prizeName);
    gridCellPrizeNames.append(prizeName);
    String worth = "$" + nfc(random(0.5, 9999.99), 2);
    prizeWorth.set(prizeName, worth);
  }
  
  String getColumnLetter(int index) {
    switch (index) {
      case 0: return "A";
      case 1: return "B";
      case 2: return "C";
      case 3: return "D";
      case 4: return "E";
      case 5: return "F";
      default: return "";
    }
  }
  
  String getPlayerName() {
    return playerNames.get(playerNamesSelection[playerTurn]);
  }
  
  void drawMinigame() {  
    background(0);
    
    stroke(255, 0, 0);
    strokeWeight(1);
    rectMode(CORNER);
    noFill();
    // Draw the outer grid outline
    rect(gridInitialX - cellWidthOffset, gridInitialY - cellHeightOffset,
         ((cellWidth + cellWidthOffset) * gridCountColumns) + cellWidthOffset,
         ((cellHeight + cellHeightOffset) * gridCountRows) + cellHeightOffset);
         
    drawCells();
    processGridSelectionReset();
    drawActionText();
  }
  
  void drawCells() {
    float cellTextFontSize = localUnitX;
    float cellXOffset = cellWidth * 0.5;
    float cellYOffset = cellHeight * 0.65;
    float cellHiddenWidthOffset = cellWidthOffset * 0.5;
    float cellHiddenHeightOffset = cellHeightOffset * 2;

    textSize(cellTextFontSize);
    for (int indexX = 0; indexX < gridCountColumns; indexX++) {
      for (int indexY = 0; indexY < gridCountRows; indexY++) {
        // Draw the inner cell outline
        stroke(255, 0, 0);
        noFill();
        float innerCellX = gridCellPositions[indexX][indexY][0];
        float innerCellY = gridCellPositions[indexX][indexY][1];
        rect(innerCellX, innerCellY, cellWidth, cellHeight);
        
        String cellText;
        if (
            (hasSelectedFirstChoice && gridFirstChoiceX == indexX && gridFirstChoiceY == indexY) ||
            (hasSelectedSecondChoice && gridSecondChoiceX == indexX && gridSecondChoiceY == indexY)
           ) {
          // Reveal the prize name if it's been selected
          fill(88, 209, 208);
          cellText = gridCellPrize[indexX][indexY];
        } else {
          // Show the prize in its hidden state
          fill(128);
          noStroke();
          // Hidden prize is a smaller rectangle within the cell
          rect(innerCellX + cellHiddenWidthOffset,
               innerCellY + cellHiddenHeightOffset,
               cellWidth - (cellHiddenWidthOffset * 2),
               cellHeight - (cellHiddenHeightOffset * 2));
          fill(0);
          cellText = getColumnLetter(indexX) + (indexY + 1);
        }
        // Draw the cell text in the middle of the cell
        text(cellText, innerCellX + cellXOffset, innerCellY + cellYOffset);
      }
    }
  }
  
  void drawActionText() {
    float actionTextX = width * 0.5;
    float actionTextY = height * 0.65;
    float actionTextFontSize = localUnitX * 2;
    float worthTextX = actionTextX;
    float worthTextY = height * 0.8;
    textSize(actionTextFontSize);
    fill(255);
    textAlign(CENTER);
    
    String actionText;
    if (!hasWon) {
      
      if (!isResettingGridSelection) {
        // Player is still selecting their choices
        String choiceText = "FIRST";
        if (hasSelectedFirstChoice && !hasSelectedSecondChoice) {
          choiceText = "SECOND";
        }
        actionText = getPlayerName() + ", What Is Your " + choiceText + " Choice?";
      } else {
        // Player did not match prizes
        applyActionTextFill();
        actionText = "SORRY " + getPlayerName() + ", But No Match";
      }
    } else {
      // Show winning text
      applyActionTextFill();
      actionText = "ALLRIGHT! A Match!";
    }
    text(actionText, actionTextX, actionTextY);
    
    if (!hasWon && (hasSelectedFirstChoice || hasSelectedSecondChoice)) {
      // Show the monetary value of the first prize only, unless they've won already
      applyActionTextFill();
      text("Worth " + prizeWorth.get(gridCellPrize[gridFirstChoiceX][gridFirstChoiceY]), worthTextX, worthTextY);
    }
  }
  
  void applyActionTextFill() {
    fill(7, 123, 122);
  }
  
  void processGridSelectionReset() {
    if (isResettingGridSelection) {
      // Player is being delayed for selecting non-matching prizes
      gridSelectionTimer += gridSelectionTimerInc;
      if (gridSelectionTimer >= gridSelectionTimerMax) {
        gridSelectionTimer = 0;
        gridFirstChoiceX = 0;
        gridFirstChoiceY = 0;
        gridSecondChoiceX = 0;
        gridSecondChoiceY = 0;
        isResettingGridSelection = false;
        hasSelectedFirstChoice = false;
        hasSelectedSecondChoice = false;
        // Next player's turn
        playerTurn = (playerTurn + 1) % playerCount;
      }
    }
  }
  
  void screenPressed() {
    for (int indexX = 0; indexX < gridCountColumns; indexX++) {
      for (int indexY = 0; indexY < gridCountRows; indexY++) {
        boolean hasPressedPrize = mouseX > gridCellPositions[indexX][indexY][0] &&
                                  mouseX < gridCellPositions[indexX][indexY][0] + cellWidth &&
                                  mouseY > gridCellPositions[indexX][indexY][1] &&
                                  mouseY < gridCellPositions[indexX][indexY][1] + cellHeight;
        boolean hasReselectedFirstPrize = hasSelectedFirstChoice && !hasSelectedSecondChoice &&
                                          indexX == gridFirstChoiceX &&
                                          indexY == gridFirstChoiceY;
        if (hasPressedPrize && !hasReselectedFirstPrize && !hasWon) {
          if (!hasSelectedFirstChoice) {
            // Keep track of the player's first selection
            gridFirstChoiceX = indexX;
            gridFirstChoiceY = indexY;
            hasSelectedFirstChoice = true;
          } else if (!hasSelectedSecondChoice) {
            // Keep track of the player's second selection
            gridSecondChoiceX = indexX;
            gridSecondChoiceY = indexY;
            hasSelectedSecondChoice = true;
            
            if (gridCellPrize[gridFirstChoiceX][gridFirstChoiceY] ==
                gridCellPrize[indexX][indexY]) {
              hasWon = true;
              enableWinTimer = true;
            } else {
              // Player doesn't lose if they didn't make a match
              isResettingGridSelection = true;
            }
          }
          // Player can only press one prize at a time, so no point in checking the others 
          break;
        }
      }
    }
  }

}
