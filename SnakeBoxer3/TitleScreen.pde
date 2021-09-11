class TitleScreen {
  boolean isGameStarted = false;
  float localUnitX;
  float localUnitY;

  String instructionText = "";
  float instructionTextX;
  float instructionTextY;

  String taglineText = "";
  float taglineTextX;
  float taglineTextY;

  // Logo is intended to be in a fixed location
  PImage imgLogo;

  PImage imgGeneralItem;
  float imgGeneralItemX;
  float imgGeneralItemY;
  float imgGeneralItemWidth;
  float imgGeneralItemHeight;

  Timer gameResetTimer = new Timer(1, 120, false);

  TitleScreen(String imgLogoPathname, String instructions,
              float instructionsX, float instructionsY, float unitX, float unitY) {
    imgLogo = loadImage(imgLogoPathname);
    instructionText = instructions;
    instructionTextX = instructionsX;
    instructionTextY = instructionsY;
    localUnitX = unitX;
    localUnitY = unitY;
  }

  void setStartState(boolean startState) {
    isGameStarted = startState;
  }

  boolean isStarted() {
    return isGameStarted;
  }

  void setTagline(String tagline, float taglineX, float taglineY) {
    taglineText = tagline;
    taglineTextX = taglineX;
    taglineTextY = taglineY;
  }

  void setGeneralItemImage(String imgGeneralItemPathname, float imgX, float imgY, float imgWidth, float imgHeight) {
    imgGeneralItem = loadImage(imgGeneralItemPathname);
    imgGeneralItemX = imgX;
    imgGeneralItemY = imgY;
    imgGeneralItemWidth = imgWidth;
    imgGeneralItemHeight = imgHeight;
  }

  void drawTitleScreen() {
    background(49, 52, 74);

    // Draw logo
    noTint();
    imageMode(CENTER);
    image(imgLogo, width * 0.5, height * 0.25, localUnitX * 60, localUnitY * 30);

    // Draw general title screen image, if there is one
    if (imgGeneralItem != null) {
      image(imgGeneralItem, imgGeneralItemX, imgGeneralItemY,
            imgGeneralItemWidth, imgGeneralItemHeight);
    }

    // Draw tag line
    textSize(localUnitX * 2.5);
    textAlign(LEFT);
    fill(255, 0, 0);
    text(taglineText, taglineTextX, taglineTextY);

    // Draw instructions
    textAlign(LEFT);
    textSize(localUnitX * 2);
    fill(255);
    text(instructionText, instructionTextX, instructionTextY);
  }
  
  void resetByTimer() {
    gameResetTimer.tick();
    if (gameResetTimer.isOvertime()) {
      gameResetTimer.reset();
      setStartState(false);
    }
  }
  
  void forceReset() {
    // Trigger the reset timer without waiting for it
    gameResetTimer.forceOvertime();
    resetByTimer();
  }
}
