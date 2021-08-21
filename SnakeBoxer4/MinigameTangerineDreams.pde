/*
Tangerine Dreams:
- Move the icons to the right place on the desktop
- Icons in the ight location are immovable
- Some icons might already be in their correct locations
*/
class MinigameTangerineDreams extends MinigameManager {
  PImage imgTangerineDreamsLogo = loadImage("minigames/TangerineDreams/TangerineDreamsLogo.png");
  int iconSelectionIndex;
  IntList movedIcons = new IntList();
  float topBarHeight = height * 0.05;
  float topBarHeightBoundary = topBarHeight * 3;
  String[] iconsPathnames = {
    "minigames/TangerineDreams/SBEmail.png",
    "minigames/TangerineDreams/SoCoolAFlash.png",
    "minigames/TangerineDreams/TheCheatHD.png"
  };
  ClickableButton[] icons = new ClickableButton[iconsPathnames.length];
  ClickableButton[] iconsMissing = new ClickableButton[iconsPathnames.length];
  
  MinigameTangerineDreams(float localUnitWidth, float localUnitHeight) {
    super(localUnitWidth, localUnitHeight);
    setText("Move them!", 0);
    // Start the game having selected no icon
    deselectIcon();
    
    // Ensure this value is always below the number of icons, as the player should
    // still be required to do something to win
    int preMatchedIconsCount = (int)random(1, icons.length);
    float iconWidth = localUnitX * 16;
    float iconHeight = localUnitY * 16;
    for (int i = 0; i < icons.length; i++) {
      icons[i] = new ClickableButton(random(0, width), random(topBarHeightBoundary, gameSpaceHeight),
                                     iconWidth, iconHeight);
      icons[i].setButtonImage(iconsPathnames[i]);
      boolean isPrematchedIcon = random(1) >= 0.5;
      if (isPrematchedIcon && preMatchedIconsCount > 0) {
        // Pre-matched icon
        preMatchedIconsCount--;
        // No need to load an image, since it is overlapped by the proper icon anyway
        iconsMissing[i] = new ClickableButton(icons[i].x, icons[i].y, 0, 0);
        registerIconMatch(i);
      } else {
        iconsMissing[i] = new ClickableButton(random(0, width), random(topBarHeightBoundary, gameSpaceHeight),
                                              iconWidth, iconHeight);
        iconsMissing[i].setButtonImage(iconsPathnames[i]);
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
    // Draw icon slots
    tint(0);
    for (int i = 0; i < iconsMissing.length; i++) {
      iconsMissing[i].drawButton();
    }
    
    // Draw icons after the slots so that it properly overlaps it
    noTint();
    for (int i = 0; i < icons.length; i++) {
      icons[i].drawButton();
    }
  }
  
  void deselectIcon() {
    iconSelectionIndex = -1;
  }
  
  void registerIconMatch(int iconIndex) {
    movedIcons.append(iconIndex);
  }
  
  void screenPressed() {
    // Traverse the icons in reverse order to achieve the effect where an icon that
    // is drawn above another will be detected first if both are within the same
    // press area
    for (int i = icons.length - 1; i >= 0; i--) {
      if (icons[i].isPressed(mouseX, mouseY) &&
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
      icons[iconSelectionIndex].x = mouseX;
      // Can't drag the icon past the toolbar or the timer UI.
      // But allow the icon to be dragged along the boundary line.
      icons[iconSelectionIndex].y = min(max(mouseY, topBarHeightBoundary), gameSpaceHeight);

      if (dist(icons[iconSelectionIndex].x, icons[iconSelectionIndex].y,
               iconsMissing[iconSelectionIndex].x, iconsMissing[iconSelectionIndex].y) <= slotSnapRadius &&
          !movedIcons.hasValue(iconSelectionIndex)) {
            // Snap the icon into the slot
            icons[iconSelectionIndex].x = iconsMissing[iconSelectionIndex].x;
            icons[iconSelectionIndex].y = iconsMissing[iconSelectionIndex].y;
            registerIconMatch(iconSelectionIndex);
            deselectIcon();

            // Check if this is the last icon that needs to be moved
            if (!hasWon && movedIcons.size() >= icons.length) {
              hasWon = true;
              enableWinTimer = true;
            }
         }
    }
  }
}
