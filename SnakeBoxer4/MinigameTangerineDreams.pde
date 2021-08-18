/*
Tangerine Dreams:
- Move the icons to the right place on the desktop
- Icons in the ight location are immovable
- Some icons might already be in their correct locations
*/
class MinigameTangerineDreams extends MinigameManager {
  PImage[] imgIcons = {
    loadImage("minigames/TangerineDreams/SBEmail.png"),
    loadImage("minigames/TangerineDreams/SoCoolAFlash.png"),
    loadImage("minigames/TangerineDreams/TheCheatHD.png")
  };
  PImage imgTangerineDreamsLogo = loadImage("minigames/TangerineDreams/TangerineDreamsLogo.png");
  PImage[] imgIconsMissing = imgIcons;
  float[][] imgIconsCoordinates = new float[imgIcons.length][2];
  float[][] imgIconsMissingCoordinates = new float[imgIconsMissing.length][2];
  int iconSelectionIndex;
  IntList movedIcons = new IntList();
  float topBarHeight = height * 0.05;
  float topBarHeightBoundary = topBarHeight * 3;
  float gameSpaceHeight = height * 0.8;
  
  MinigameTangerineDreams(float localUnitWidth, float localUnitHeight) {
    super(localUnitWidth, localUnitHeight);
    setText("Move them!", 0);
    // Start the game having selected no icon
    deselectIcon();
    
    // Ensure this value is always below the number of icons, as the player should
    // still be required to do something to win
    int preMatchedIconsCount = (int)random(1, imgIcons.length);
    for (int i = 0; i < imgIconsCoordinates.length; i++) {
      // Random x,y position for the icon within the movable space
      imgIconsCoordinates[i][0] = random(0, width);
      imgIconsCoordinates[i][1] = random(topBarHeightBoundary, gameSpaceHeight);
      
      boolean isPrematchedIcon = random(1) >= 0.5;
      if (isPrematchedIcon && preMatchedIconsCount > 0) {
        // Pre-matched icon 
        preMatchedIconsCount--;
        imgIconsMissingCoordinates[i][0] = imgIconsCoordinates[i][0];
        imgIconsMissingCoordinates[i][1] = imgIconsCoordinates[i][1];
        registerIconMatch(i);
      } else {
        // Icon slot is also randomly placed, and can also be in the same
        // position as its corresponding icon, though this would be very rare.
        imgIconsMissingCoordinates[i][0] = random(0, width);
        imgIconsMissingCoordinates[i][1] = random(topBarHeightBoundary, gameSpaceHeight);
      }
    }
  }
  
  void drawMinigame() {
    background(49, 207, 206);
    
    // Draw toolbar
    fill(255);
    rectMode(CORNER);
    rect(0, 0, width, topBarHeight);
    // Draw toolbar bottom border
    stroke(0);
    strokeWeight(1);
    line(0, topBarHeight, width, topBarHeight);
    noStroke();
    
    // Draw toolbar text
    float topBarFontSize = localUnitX * 1.5;
    float topBarTextX = width * 0.05;
    float topBarTextY = height * 0.04;
    fill(0);
    textSize(topBarFontSize);
    textAlign(LEFT);
    text("File  Edit  Help", topBarTextX, topBarTextY);
    
    drawLogo();
    drawIcons();
  }
  
  void drawLogo() {
    float logoX = localUnitX * 2;
    float logoY = localUnitY * 1.5;
    float logoWidth = localUnitX * 2;
    float logoHeight = localUnitY * 2;

    image(imgTangerineDreamsLogo, logoX, logoY, logoWidth, logoHeight);
  }
  
  void drawIcons() {
    float iconWidth = localUnitX * 16;
    float iconHeight = localUnitY * 16;

    // Draw icon slots
    tint(0);
    for (int i = 0; i < imgIconsCoordinates.length; i++) {
      image(imgIconsMissing[i], imgIconsMissingCoordinates[i][0], imgIconsMissingCoordinates[i][1], iconWidth, iconHeight);
    }
    
    // Draw icons after the slots so that it properly overlaps it
    noTint();
    for (int i = 0; i < imgIconsCoordinates.length; i++) {
      image(imgIcons[i], imgIconsCoordinates[i][0], imgIconsCoordinates[i][1], iconWidth, iconHeight);
    }
  }
  
  void deselectIcon() {
    iconSelectionIndex = -1;
  }
  
  void registerIconMatch(int iconIndex) {
    movedIcons.append(iconIndex);
  }
  
  void screenPressed() {
    float pressRadius = localUnitX * 5;
    // Traverse the icons in reverse order to achieve the effect where an icon that
    // is drawn above another will be detected first if both are within the same
    // press area
    for (int i = imgIconsCoordinates.length - 1; i >= 0; i--) {
      if (dist(mouseX, mouseY, imgIconsCoordinates[i][0], imgIconsCoordinates[i][1]) <= pressRadius &&
          !movedIcons.hasValue(i)) {
        iconSelectionIndex = i;
        break;
      }
    }
  }
  
  void screenReleased() {
    deselectIcon();
  }
  
  void screenDragged() {
    float slotSnapRadius = localUnitX * 2;
    
    if (iconSelectionIndex >= 0) {
      // X position doesn't need to be bound, as there are no inaccessible side zones
      imgIconsCoordinates[iconSelectionIndex][0] = mouseX;
      // Can't drag the icon past the toolbar or the timer UI.
      // But allow the icon to be dragged along the boundary line.
      imgIconsCoordinates[iconSelectionIndex][1] = min(max(mouseY, topBarHeightBoundary), gameSpaceHeight);
      
      if (dist(imgIconsCoordinates[iconSelectionIndex][0],
               imgIconsCoordinates[iconSelectionIndex][1],
               imgIconsMissingCoordinates[iconSelectionIndex][0],
               imgIconsMissingCoordinates[iconSelectionIndex][1]) <= slotSnapRadius &&
          !movedIcons.hasValue(iconSelectionIndex)) {
                 // Snap the icon into the slot
                 imgIconsCoordinates[iconSelectionIndex][0] = imgIconsMissingCoordinates[iconSelectionIndex][0];
                 imgIconsCoordinates[iconSelectionIndex][1] = imgIconsMissingCoordinates[iconSelectionIndex][1];
                 registerIconMatch(iconSelectionIndex);
                 deselectIcon();
                 
                 // Check if this is the last icon that needs to be moved
                 if (!hasWon && movedIcons.size() >= imgIcons.length) {
                   hasWon = true;
                   enableWinTimer = true;
                 }
               }
    }
  }
}
