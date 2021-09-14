class DialogBoxUpgrade extends DialogBox {
  ClickableButton multiplierUpgradeButton;
  ClickableButton powerUpgradeButton;
  ClickableButton idleUpgradeButton;
  
  // Score is stored in this class, as opposed to the global scope, since there are
  // functions in this class that modify the score.
  // Also, the main scope only really uses the score for display purposes.
  //
  // Note that the only reason that the points are represented as an "int" is so that
  // the nfc() function can be applied to it, and numbers close to the max. value
  // still fit in the screen width without having to reduce the font size.
  int points = 0;
  Upgrade multiplierUpgrade = new Upgrade(1, 1, 300);
  Upgrade powerUpgrade = new Upgrade(1, 2, 50);
  Upgrade idleUpgrade = new Upgrade(0, 5, 100);
  Timer idleTimer = new Timer(1, 90, true);
  Timer pointsColourTimer = new Timer(1, 20, false);
  color pointsColour;
  
  DialogBoxUpgrade(float initialX, float initialY, float initialWidth, float initialHeight,
                   float buttonWidth, float buttonHeight, boolean enableChoice) {
    super(initialX, initialY, initialWidth, initialHeight, buttonWidth, buttonHeight, enableChoice);
    
    float upgradeButtonX = x + (dialogBoxWidth * 0.35);
    float upgradeButtonY = y - (dialogBoxHeight * 0.2);
    float upgradeButtonYInc = dialogBoxHeight * 0.18;
    powerUpgradeButton = new ClickableButton(upgradeButtonX, upgradeButtonY, buttonWidth, buttonHeight);
    powerUpgradeButton.setButtonText("GET!", dialogBoxTextSize);
    
    multiplierUpgradeButton = new ClickableButton(upgradeButtonX, upgradeButtonY + upgradeButtonYInc, buttonWidth, buttonHeight);
    multiplierUpgradeButton.setButtonText("GET!", dialogBoxTextSize);
    
    idleUpgradeButton = new ClickableButton(upgradeButtonX, upgradeButtonY + (upgradeButtonYInc * 2), buttonWidth, buttonHeight);
    idleUpgradeButton.setButtonText("GET!", dialogBoxTextSize);
    
    setPointsColourDefault();
  }
  
  void resetPoints() {
    points = 0;
  }
  
  int getPoints() {
    return points;
  }
  
  void incrementPoints() {
    // Used to add value according to a basic screen press.
    // Colour timer is reset to minimise the "flashing" of the points value when pressing the screen multiple times.
    pointsColourTimer.reset();
    incrementPoints(powerUpgrade.getValue() * multiplierUpgrade.getValue());
  }
  
  void incrementPoints(int value) {
    // Used to add arbitrary value to the current points
    boolean isPositivePoints = points >= 0;
    points += value;
    
    // Prevent numeric overflow by capping the points at a certain limit
    if (isPositivePoints && points < 0) {
      points = Integer.MAX_VALUE;
    }
    setPointsColour(value);
  }
  
  color getPointsColour() {
    return pointsColour;
  }
  
  void setPointsColourDefault() {
    setPointsColour(0);
  }
  
  void setPointsColour(int value) {
    // Set the font colour based on the type of score increment
    if (value > 0) {
      pointsColour = color(0, 255, 0);
      pointsColourTimer.tick();
    } else if (value < 0) {
      pointsColour = color(255, 0, 0);
      pointsColourTimer.tick();
    } else {
      pointsColour = color(0, 0, 0);
    }
  }
  
  void setTextSize(float textSize) {
    super.setTextSize(textSize);
    // These buttons aren't included in the base class 
    multiplierUpgradeButton.buttonTextSize = textSize;
    powerUpgradeButton.buttonTextSize = textSize;
    idleUpgradeButton.buttonTextSize = textSize;
  }
  
  void drawDialogBox() {
    super.drawDialogBox();
    
    if (isActive) {
      // Draw blurbs of upgrade options
      fill(0);
      textAlign(LEFT);
      textSize(dialogBoxTextSize);
      text("Diplomacy: " + nfc(points) + "\n\n" +
           "Defence Pact: x" + nfc(powerUpgrade.getValue()) + "\n" +
           "Upgrade: " + nfc(powerUpgrade.getCost()) + "\n\n" +
           "Peace Treaty: x" + nfc(multiplierUpgrade.getValue()) + "\n" +
           "Upgrade: " + nfc(multiplierUpgrade.getCost()) + "\n\n" +
           "Trade Policy: x"+ nfc(idleUpgrade.getValue()) +"\n" +
           "Upgrade: " + nfc(idleUpgrade.getCost()),
           x - (dialogBoxWidth * 0.45), y - (dialogBoxHeight * 0.3));

      // Draw buttons for each upgrade option
      if (powerUpgrade.isPurchasable(points)) {
        powerUpgradeButton.drawButton();
      }
      if (multiplierUpgrade.isPurchasable(points)) {
        multiplierUpgradeButton.drawButton();
      }
      if (idleUpgrade.isPurchasable(points)) {
        idleUpgradeButton.drawButton();
      }
    }
  }
  
  void registerButtonPress(float pressX, float pressY) {
    super.registerButtonPress(pressX, pressY);
    
    // Register the buttons that are not included in the base class
    if (isActive) {
      if (powerUpgradeButton.isPressed(pressX, pressY) && powerUpgrade.isPurchasable(points)) {
        points -= powerUpgrade.getCost();
        powerUpgrade.purchase();
      } else if (multiplierUpgradeButton.isPressed(pressX, pressY) && multiplierUpgrade.isPurchasable(points)) {
        points -= multiplierUpgrade.getCost();
        multiplierUpgrade.purchase();
      } else if (idleUpgradeButton.isPressed(pressX, pressY) && idleUpgrade.isPurchasable(points)) {
        points -= idleUpgrade.getCost();
        idleUpgrade.purchase();
      }
    }
  }
  
  void processIdleTimer() {
    // Viewing the upgrade menu pauses the idle timer, which in a sense, adds some consequence
    // to players spending too much time on the menu (if they have upgraded their idle value,
    // the more potential points are being lost).
    if (!isActive) {
      idleTimer.tick();
      if (idleTimer.isOvertime()) {
        incrementPoints(idleUpgrade.getValue() * multiplierUpgrade.getValue());
      }
    }
  }
  
  void processPointsColourTimer() {
    // Score font colour reverts back to the default colour eventually.
    if (pointsColourTimer.isActive()) {
      pointsColourTimer.tick();
      if (pointsColourTimer.isOvertime()) {
        pointsColourTimer.reset();
        setPointsColourDefault();
      }
    }
  }
  
  void rankUp() {
    int scale = 2;
    powerUpgrade.value *= scale;
    multiplierUpgrade.value *= scale;
    idleUpgrade.value *= scale;
  }
}
