class WorldMap {
  float localUnitX;
  float localUnitY;
  float mapWidth;
  float mapHeight;
  boolean hasFightStarted = false;
  
  PImage imgMap = loadImage("map/World.png");
  String locationBeatenFilename = "map/LocationBeaten.png";
  String locationUnbeatenFilename = "map/LocationUnbeaten.png";
  int locationCountWithFinalStage = 7;
  // Use this as an index for the last enemy AND the number of regular enemies
  int locationCountWithoutFinalStage = locationCountWithFinalStage - 1;
  int locationIndex = -1;
  ClickableButton[] locationButtons = new ClickableButton[locationCountWithFinalStage];
  boolean[] locationStatus = new boolean[locationCountWithFinalStage];
  StringList possibleFighterNames = new StringList(
    "BOXER JOE",
    "COBRA JOE",
    "CRAB",
    "ICE BREAKER",
    "SNAKE",
    "STRONG BAD",
    "STRONG MAD"
  );
  Background[] locationBackground = new Background[locationCountWithFinalStage];
  Timer locationReselectionTimer = new Timer(1, 60, false);
  int locationsBeaten = 0;
  
  Timer whiteOutTimer = new Timer(5, 255, false);
  boolean isFadingBack = false;
  boolean isSingleFight = false;
  PImage finalImage;
  String[] finalImageFilenames = {
    "images/congratulations/FinalBoxerJoe.png",
    "images/congratulations/FinalCobraJoe.png",
    "images/congratulations/FinalCrab.png",
    "images/congratulations/FinalIceBreaker.png",
    "images/congratulations/FinalSnake.png",
    "images/congratulations/FinalSnakeFist.png",
    "images/congratulations/FinalStrongBad.png",
    "images/congratulations/FinalStrongMad.png"
  };
  
  WorldMap(float unitX, float unitY, float mapWide, float mapHigh, String playerFighterName) {
    localUnitX = unitX;
    localUnitY = unitY;
    mapWidth = mapWide;
    mapHeight = mapHigh;
    
    setFinalImage(playerFighterName);
    
    float skyHeight = height * 0.15;
    float locationWidth = localUnitX * 5;
    float locationHeight = localUnitY * 5;
    locationButtons[0] = new ClickableButton(mapWidth * 0.15, mapHeight * 0.25, locationWidth, locationHeight);
    locationButtons[0].setButtonImage(locationUnbeatenFilename);
    locationBackground[0] = new Background(0, skyHeight, localUnitX);
    
    locationButtons[1] = new ClickableButton(mapWidth * 0.25, mapHeight * 0.65, locationWidth, locationHeight);
    locationButtons[1].setButtonImage(locationUnbeatenFilename);
    locationBackground[1] = new Background(2, skyHeight, localUnitX);
    
    locationButtons[2] = new ClickableButton(mapWidth * 0.55, mapHeight * 0.15, locationWidth, locationHeight);
    locationButtons[2].setButtonImage(locationUnbeatenFilename);
    locationBackground[2] = new Background(1, skyHeight, localUnitX);
    
    locationButtons[3] = new ClickableButton(mapWidth * 0.5, mapHeight * 0.5, locationWidth, locationHeight);
    locationButtons[3].setButtonImage(locationUnbeatenFilename);
    locationBackground[3] = new Background(4, skyHeight, localUnitX);
    
    locationButtons[4] = new ClickableButton(mapWidth * 0.7, mapHeight * 0.15, locationWidth, locationHeight);
    locationButtons[4].setButtonImage(locationUnbeatenFilename);
    locationBackground[4] = new Background(5, skyHeight, localUnitX);
    
    locationButtons[5] = new ClickableButton(mapWidth * 0.87, mapHeight * 0.75, locationWidth, locationHeight);
    locationButtons[5].setButtonImage(locationUnbeatenFilename);
    locationBackground[5] = new Background(3, skyHeight, localUnitX);
    
    locationButtons[locationCountWithoutFinalStage] = new ClickableButton(mapWidth * 0.35, mapHeight * 0.05, locationWidth, locationHeight);
    locationButtons[locationCountWithoutFinalStage].setButtonImage(locationUnbeatenFilename);
    locationBackground[locationCountWithoutFinalStage] = new Background(6, skyHeight, localUnitX);
    
    // Since the final boss is playable, use a secondary final fighter for when that happens
    String finalFighterName = "SNAKE FIST";
    if (finalFighterName == playerFighterName) {
      finalFighterName = "BOXER JOE";
      // Remove the original instance of the secondary final fighter, so that they're only fought once.
      // Do this before shuffling the order, as the list entry can still be accessed directly.
      possibleFighterNames.remove(0);
    } else {
      // Player cannot fight their own character
      possibleFighterNames.removeValue(playerFighterName);
    }
    
    // Create a list of possible fighters in a randomised order 
    possibleFighterNames.shuffle();
    possibleFighterNames.set(locationCountWithoutFinalStage, finalFighterName);
    // The last location is only selectable once all the other locations are defeated.
    // Ensure this can't be clicked until all others locations are beaten.
    locationStatus[locationCountWithoutFinalStage] = true;
  }
  
  AIFighter getLocationFighter(int locationIndex) {
    float locationFighterX = width * 0.425;
    float locationFighterY = height * 0.45;
    float locationFighterWidth = localUnitX * 22;
    float locationFighterHeight = localUnitY * 22;
    AIFighter fighter = new AIFighter(locationFighterX, locationFighterY, locationFighterWidth, locationFighterHeight, possibleFighterNames.get(locationIndex));
    fighter.isStalled = true;
    // Opponent gets certain settings adjusted if in 1P or VS mode
    if (isSingleFight) {
      fighter.setLives(3);
    } else {
      fighter.setLives(1);
    }
    return fighter;
  }
  
  // Use this constructor for VS Mode
  WorldMap(float unitX, float unitY, float mapWide, float mapHigh, String player1FighterName, String player2FighterName) {
    this(unitX, unitY, mapWide, mapHigh, player1FighterName);
    
    // Use the same fighter for all the locations
    for (int i = 0; i < locationCountWithFinalStage; i++) {
      possibleFighterNames.set(i, player2FighterName);
    }
    
    // Final level background is selectable
    locationStatus[locationCountWithoutFinalStage] = false;
    
    isSingleFight = true;
  }
  
  void drawMap() {    
    imageMode(CORNER);
    image(imgMap, 0, 0, mapWidth, mapHeight);
    
    for (int i = 0; i < locationCountWithFinalStage; i++) {      
      // Draw location's that aren't the final battle, and only draw the final location if in VS mode
      // OR player has passed enough locations to unlock it.
      if ((i < locationCountWithoutFinalStage) || 
          (i == locationCountWithoutFinalStage && (locationsBeaten == locationCountWithoutFinalStage || isSingleFight))) {
        locationButtons[i].drawButton();
      }
    }
  }
  
  void drawWhiteOut() {
    if (isFadingBack && !isSingleFight) {
      // Draw fade back image before the rectangle to re-use its alpha value
      imageMode(CORNER);
      image(finalImage, 0, 0, width, height);
    }
    
    // By default, the white out timer must manually be incremented before it is active
    if (whiteOutTimer.isActive()) {     
      rectMode(CORNER);
      fill(255, whiteOutTimer.time);
      rect(0, 0, width, height);
      
      whiteOutTimer.tick();
      if (whiteOutTimer.isOvertime()) {
        whiteOutTimer.toggleDirection();
        isFadingBack = true;
      }
    }
  }
  
  int getLocation(float pressX, float pressY) {
    // Returns the location index that the press is closest to.
    // A negative number indicates that no location was pressed.
    for (int i = 0; i < locationCountWithFinalStage; i++) {
      // Ensure a finished location cannot be reselected
      if (locationButtons[i].isPressed(pressX, pressY) && !locationStatus[i]) {
        return i;
      }
    }
    return -1;
  }
  
  int getLocationCount() {
    return locationCountWithoutFinalStage;
  }
  
  void updateFightStatus(boolean isEnemyDefeated) {
    if (locationIndex >= 0 && isEnemyDefeated) {
      
      if (!isSingleFight) {
        // 1P mode should return to the world map after defeating an enemy.
        // So, start the timer to select a new location.
        locationReselectionTimer.tick();
      } else {
        // VS mode should return back to the fighter selection, since it is a single match fight
        isFadingBack = true;
      }
      
      if (locationReselectionTimer.isOvertime()) {
        locationButtons[locationIndex].setButtonImage(locationBeatenFilename);
        locationStatus[locationIndex] = true;
        locationsBeaten++;
        
        if (locationsBeaten <= locationCountWithoutFinalStage) {
          locationReselectionTimer.reset();
          locationIndex = -1;
        } else {
          whiteOutTimer.tick();
        }
        
        // Unlocks the last location
        if (locationsBeaten == locationCountWithoutFinalStage) {
          locationStatus[locationCountWithoutFinalStage] = false;
        }
      }
    }
  }
  
  void setFinalImage(String playerFighterName) {
    String filename = "Empty.png";
    if (playerFighterName == "BOXER JOE") {
      filename = finalImageFilenames[0];
    } else if (playerFighterName == "COBRA JOE") {
      filename = finalImageFilenames[1];
    } else if (playerFighterName == "CRAB") {
      filename = finalImageFilenames[2];
    } else if (playerFighterName == "ICE BREAKER") {
      filename = finalImageFilenames[3];
    } else if (playerFighterName == "SNAKE") {
      filename = finalImageFilenames[4];
    } else if (playerFighterName == "SNAKE FIST") {
      filename = finalImageFilenames[5];
    } else if (playerFighterName == "STRONG BAD") {
      filename = finalImageFilenames[6];
    } else if (playerFighterName == "STRONG MAD") {
      filename = finalImageFilenames[6];
    }
    finalImage = loadImage(filename);
  }
}
