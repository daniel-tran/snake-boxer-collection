/*
Salad Daze:
- Press all the vegetables to create the salad
- Pressing a non-vegetable results in losing
*/
class MinigameSaladDaze extends MinigameManager {
  int itemRows = 2;
  int itemColumns = 2;
  int itemSelectionCount = itemRows * itemColumns;
  float itemWidth = localUnitX * 22;
  float itemHeight = localUnitY * 22;
  PImage centreImageInProgress = loadImage("minigames/SaladDaze/QuestionMark.png");
  PImage centreImageWin = loadImage("minigames/SaladDaze/Salad.png");
  PImage centreImageLose = loadImage("minigames/SaladDaze/RedX.png");
  PImage centreImageEmpty = loadImage("minigames/SaladDaze/Empty.png");
  PImage centreImageDrawn = centreImageInProgress;
  // Keep track of the items selected for use in this run of the game
  Object[][] itemMappingSelected = new Object[itemSelectionCount][2];
  // Track which items are valid, and how many valid items have been pressed
  IntList itemIndexesValid = new IntList();
  IntList itemIndexesCorrectlySelected = new IntList();
  
  MinigameSaladDaze(float localUnitWidth, float localUnitHeight) {
    super(localUnitWidth, localUnitHeight);
    setText("Make a salad!", 0);
    
    StringDict itemMappingFull = new StringDict(new String[][]{
      {"0", "minigames/SaladDaze/Carrot.png"},
      {"1", "minigames/SaladDaze/Lettuce.png"},
      {"2", "minigames/SaladDaze/Tomato.png"},
      {"3", "minigames/SaladDaze/Cat.png"},
      {"4", "minigames/SaladDaze/Sneaker.png"},
      {"5", "minigames/SaladDaze/Wrench.png"}
    });
    
    for (int i = 0; i < itemSelectionCount; i++) {
      int randomItemIndex = (int)random(itemMappingFull.size());
      String randomItemKey = itemMappingFull.key(randomItemIndex);
      
      // Load the item and remove it from the pool of selectable items to prevent doubling-up
      itemMappingSelected[i][0] = parseInt(randomItemKey);
      itemMappingSelected[i][1] = loadImage(itemMappingFull.get(randomItemKey));
      itemMappingFull.removeIndex(randomItemIndex);
      
      // Remember which items need to be pressed to win
      if (isValidForSalad((int)itemMappingSelected[i][0])) {
        itemIndexesValid.append((int)itemMappingSelected[i][0]);
      }
    }
  }
  
  void drawMinigame() {
    float centrePointX = width * 0.5;
    float centrePointY = height * 0.45;
    
    background(75);
    
    // Draw screen dividers
    float dividerOffsetX = width * 0.02;
    stroke(255, 242, 0);
    strokeCap(PROJECT);
    line(dividerOffsetX, centrePointY, width - dividerOffsetX, centrePointY);
    line(centrePointX, 0, centrePointX, height);
    
    // Draw middle circle
    ellipseMode(CENTER);
    fill(75);
    stroke(255, 242, 0);
    strokeWeight(10);
    circle(centrePointX, centrePointY, width * 0.25);
    
    // Draw centre image
    imageMode(CENTER);
    image(centreImageDrawn, centrePointX, centrePointY, itemWidth, itemHeight);
    
    drawSelectableImages();
  }
  
  void drawSelectableImages() {
    int itemIndex = 0;
    float itemInitialX = width * 0.25;
    float itemInitialY = height * 0.25;
    float itemDistanceX = width * 0.5;
    float itemDistanceY = height * 0.5;

    for (int r = 0; r < itemRows; r++) {
      for (int c = 0; c < itemColumns; c++) {
        // Traverse left to right and draw by rows 
        image((PImage)itemMappingSelected[itemIndex][1],
              itemInitialX + (itemDistanceX * c),
              itemInitialY + (itemDistanceY * r),
              itemWidth,
              itemHeight);
        itemIndex++;
      }
    }
  }
  
  boolean isValidForSalad(int itemIndex) {
    return itemIndex <= 2;
  }
  
  int calculateSelectedItem(float pressX, float pressY) {
    // Returns the item index based on which part of the screen was touched
    float dividerX = width * 0.5;
    float dividerY = height * 0.45;
    if (pressY <= dividerY) {
      if (pressX <= dividerX) {
        return 0;
      } else {
        return 1;
      }
    } else {
      if (pressX <= dividerX) {
        return 2;
      } else {
        return 3;
      }
    }
  }
  
  void screenPressed() {
    int selectedZoneIndex = calculateSelectedItem(mouseX, mouseY);
    int selectedItemIndex = (int)itemMappingSelected[selectedZoneIndex][0];
    
    if (!itemIndexesValid.hasValue(selectedItemIndex) && !hasWon) {
      // Player has pressed an invalid item while the game hasn't been won
      centreImageDrawn = centreImageLose;
      enableLoseTimer = true;
    } else if (!itemIndexesCorrectlySelected.hasValue(selectedItemIndex) && !enableLoseTimer) {
      // Player has pressed a valid item while the game isn't in a lose state
      itemIndexesCorrectlySelected.append(selectedItemIndex);
      // Visual indicator that the item has been correctly selected
      centreImageDrawn = (PImage)itemMappingSelected[selectedZoneIndex][1];
      itemMappingSelected[selectedZoneIndex][1] = centreImageEmpty;
    }
    
    if (itemIndexesCorrectlySelected.size() == itemIndexesValid.size() && !hasWon) {
      // All the valid items have been pressed.
      // Check for the win flag so that this logic is only run once.
      hasWon = true;
      centreImageDrawn = centreImageWin;
      enableWinTimer = true;
    }
  }
}
