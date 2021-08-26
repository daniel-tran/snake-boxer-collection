class DialogBox {
  float x;
  float y;
  float dialogBoxWidth;
  float dialogBoxHeight;
  color dialogBoxColour = color(255, 255, 255);
  String dialogBoxText = "System report:\nEverything is fine. Nothing\n is ruined.";
  String headerText = "This is real.";
  ClickableButton okButton;
  ClickableButton yesButton;
  ClickableButton noButton;
  float dialogBoxTextSize = 1;
  boolean allowChoice;
  boolean isActive = false;
  
  DialogBox(float initialX, float initialY, float initialWidth, float initialHeight,
            float buttonWidth, float buttonHeight, boolean enableChoice) {
    x = initialX;
    y = initialY;
    dialogBoxWidth = initialWidth;
    dialogBoxHeight = initialHeight;
    allowChoice = enableChoice;
    
    float buttonY = y + (initialHeight * 0.35);
    float buttonXChoiceOffset = initialWidth * 0.25;
    okButton = new ClickableButton(x, buttonY, buttonWidth, buttonHeight);
    okButton.setButtonColour(dialogBoxColour);
    okButton.setButtonText("OK");
    
    yesButton = new ClickableButton(x - buttonXChoiceOffset, buttonY, buttonWidth, buttonHeight);
    yesButton.setButtonColour(dialogBoxColour);
    yesButton.setButtonText("YES");
    
    noButton = new ClickableButton(x + buttonXChoiceOffset, buttonY, buttonWidth, buttonHeight);
    noButton.setButtonColour(dialogBoxColour);
    noButton.setButtonText("NO");
  }
  
  void setText(String heading, String bodyText) {
    headerText = heading;
    dialogBoxText = bodyText;
  }
  
  void setDialogTextSize(float textSize) {
    dialogBoxTextSize = textSize;
  }
  
  void setTextSize(float textSize) {
    setDialogTextSize(textSize);
    okButton.buttonTextSize = textSize;
    yesButton.buttonTextSize = textSize;
    noButton.buttonTextSize = textSize;
  }
  
  void setDialogBoxColour(int r, int g, int b) {
    dialogBoxColour = color(r, g, b);
  }
  
  void registerButtonPress(float pressX, float pressY) {
    // Hides the dialog box after pressing a button
    if (hasPressedOK(pressX, pressY) || hasPressedYes(pressX, pressY) || hasPressedNo(pressX, pressY)) {
      isActive = false;
    }
  }
  
  void show() {
    isActive = true;
  }
  
  boolean isActive() {
    return isActive;
  }
  
  boolean hasPressedOK(float pressX, float pressY) {
    return isActive && !allowChoice && okButton.isPressed(pressX, pressY);
  }
  
  boolean hasPressedYes(float pressX, float pressY) {
    return isActive && allowChoice && yesButton.isPressed(pressX, pressY);
  }
  
  boolean hasPressedNo(float pressX, float pressY) {
    return isActive && allowChoice && noButton.isPressed(pressX, pressY);
  }
  
  void drawDialogBox() {
    // No point in drawing anything if inactive.
    if (!isActive) {
      return;
    }
    
    // Draw main dialog box
    stroke(0);
    fill(dialogBoxColour);
    rectMode(CENTER);
    rect(x, y, dialogBoxWidth, dialogBoxHeight);
    noStroke();
    
    // Draw main dialog box text
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(dialogBoxTextSize);
    text(dialogBoxText, x, y);
    
    // Draw top bar
    stroke(0);
    fill(1, 51, 205);
    rectMode(CENTER);
    rect(x, y * 0.19, dialogBoxWidth, dialogBoxHeight * 0.1);
    
    // Draw top bar text
    fill(255);
    textAlign(LEFT, CENTER);
    textSize(dialogBoxTextSize);
    text(headerText, x * 0.15, y * 0.19);
    noStroke();
    
    if (allowChoice) {
      yesButton.drawButton();
      noButton.drawButton();
    } else {
      okButton.drawButton();
    }
  }
}
