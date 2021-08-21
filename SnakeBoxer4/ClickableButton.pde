class ClickableButton {
  float x;
  float y;
  float buttonWidth;
  float buttonHeight;
  
  String buttonText = "";
  float buttonTextSize = 1;
  IntDict buttonTextColour = new IntDict(new Object[][] {
    { "R", 0 },
    { "G", 0 },
    { "B", 0 }
  });
  IntDict buttonColour = new IntDict(new Object[][] {
    { "R", 255 },
    { "G", 255 },
    { "B", 255 }
  });
  PImage buttonImage;
  boolean isUsingImage;
  
  ClickableButton(float buttonX, float buttonY, float buttonWide, float buttonHigh) {
    x = buttonX;
    y = buttonY;
    buttonWidth = buttonWide;
    buttonHeight = buttonHigh;
  }
  
  void drawButton() {
    // Draw button in CENTER mode, as it makes it somewhat easier to plan & position it around the screen
    if (isUsingImage) {
      imageMode(CENTER);
      image(buttonImage, x, y, buttonWidth, buttonHeight);
    } else {
      // Stroke uses the same colour as the text for visual aesthetics
      stroke(buttonTextColour.get("R"), buttonTextColour.get("G"), buttonTextColour.get("B"));
      strokeWeight(6);
      // Draw the actual button
      fill(buttonColour.get("R"), buttonColour.get("G"), buttonColour.get("B"));
      rectMode(CENTER);
      rect(x, y, buttonWidth, buttonHeight);
      noStroke();
    }
    
    // Draw text
    fill(buttonTextColour.get("R"), buttonTextColour.get("G"), buttonTextColour.get("B"));
    textAlign(CENTER, CENTER);
    textSize(buttonTextSize);
    text(buttonText, x, y);
  }
  
  boolean isPressed(float pressX, float pressY) {
    // Logic is based on the premise that the button is drawn in CENTER mode
    return pressX >= x - (buttonWidth * 0.5) &&
           pressX <= x + (buttonWidth * 0.5) &&
           pressY >= y - (buttonHeight * 0.5) &&
           pressY <= y + (buttonHeight * 0.5);
  }
  
  void setButtonText(String text) {
    setButtonText(text, buttonTextSize);
  }
  
  void setButtonText(String text, float textSize) {
    buttonText = text;
    buttonTextSize = textSize;
  }
  
  void setButtonTextColour(int r, int g, int b) {
    buttonTextColour.set("R", r);
    buttonTextColour.set("G", g);
    buttonTextColour.set("B", b);
  }
  
  void setButtonColour(int r, int g, int b) {
    buttonColour.set("R", r);
    buttonColour.set("G", g);
    buttonColour.set("B", b);
  }
  
  void setButtonImage(String pathname) {
    buttonImage = loadImage(pathname);
    isUsingImage = true;
  }
}
