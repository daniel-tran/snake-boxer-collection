class ClickableButton {
  float x;
  float y;
  float buttonWidth;
  float buttonHeight;
  
  String buttonText = "";
  float buttonTextSize = 1;
  color buttonTextColour = color(0, 0, 0);
  color buttonColour = color(255, 255, 255);
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
      stroke(buttonTextColour);
      strokeWeight(6);
      // Draw the actual button
      fill(buttonColour);
      rectMode(CENTER);
      rect(x, y, buttonWidth, buttonHeight);
      noStroke();
    }
    
    // Draw text
    fill(buttonTextColour);
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
  
  void setButtonTextColour(color colour) {
    buttonTextColour = colour;
  }
  
  void setButtonColour(color colour) {
    buttonColour = colour;
  }
  
  void setButtonColour(int r, int g, int b) {
    buttonColour = color(r, g, b);
  }
  
  void setButtonImage(String pathname) {
    buttonImage = loadImage(pathname);
    isUsingImage = true;
  }
}
