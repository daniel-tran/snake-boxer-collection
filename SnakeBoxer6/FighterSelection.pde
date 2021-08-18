class FighterSelection {
  float localUnitX;
  float localUnitY;
  
  int fighterMugshotCount = 8;
  ClickableButton[] fighterMugshots = new ClickableButton[fighterMugshotCount];
  PImage imgFighterSelected;
  PImage imgFighterSelectedEmpty;
  String blurbSelected;
  float[] imgFighterSelectedPosition = new float[2];
  PImage[] imgFighterSelectedShowcase = new PImage[fighterMugshotCount];
  ClickableButton startButton;
  int modeSelectionIndex = 0;
  int modeCount = 2;
  String[] modeNames = {
    "1P MODE",
    "VS MODE"
  };
  ClickableButton modeButton;
  
  String[] fighterSelectedPresetNames = {
    "BOXER JOE",
    "COBRA JOE",
    "CRAB",
    "ICE BREAKER",
    "SNAKE",
    "SNAKE FIST",
    "STRONG BAD",
    "STRONG MAD"
  };
  String[] fighterSelectedPresetBlurb = {
    fighterSelectedPresetNames[0] + ":\nFASTER MOVEMENT SPEED\nMEANS A FASTER WIN!",
    fighterSelectedPresetNames[1] + ":\nCHARGE BY BLOCKING\nFOR A DEADLY FLAME ATTACK!",
    fighterSelectedPresetNames[2] + ":\nYOUR SHELL REDUCES\nDAMAGE TAKEN FROM OPPONENTS!",
    fighterSelectedPresetNames[3] + ":\nCHARGE UP A WATER ATTACK!\nIT POWERS UP WHEN YOU LAND HITS!",
    fighterSelectedPresetNames[4] + ":\nBOOSTS STATS WHEN YOU\nLOSE A LIFE!",
    fighterSelectedPresetNames[5] + ":\nCHARGE UP A FANG ATTACK!\nIT POWERS UP WITH LESS HP!",
    fighterSelectedPresetNames[6] + ":\nENJOY BOOSTED STATS\nUNTIL YOU LOSE A LIFE!",
    fighterSelectedPresetNames[7] + ":\nIMPROVED PUNCH RANGE\nDUE TO YOUR HULKING MASS!"
  };
  
  // Players count includes selectable CPU fighters
  int playersCount = 1;
  int playerSelectionIndex = 0;
  PImage[] imgPlayerSelection = {
    loadImage("CharacterFrameSelection1P.png"),
    loadImage("CharacterFrameSelection2P.png")
  };
  // Preset these variables to account for the most number of selectable fighters.
  // Default values are ignored, as these are set when calling reset()
  float[][] imgPlayerSelectionPosition = {
    {-width, 0},
    {-width, 0}
  };
  int[] playerSelectionValue = {-1, -1};
  
  FighterSelection(float unitX, float unitY) {
    localUnitX = unitX;
    localUnitY = unitY;
    
    float incrementX = localUnitX * 16;
    float incrementY = localUnitY * 16;
    
    String[] fighterMugshotsFilenames = {
      "images/mugshots/MugshotBoxerJoe.png",
      "images/mugshots/MugshotCobraJoe.png",
      "images/mugshots/MugshotCrab.png",
      "images/mugshots/MugshotIceBreaker.png",
      "images/mugshots/MugshotSnake.png",
      "images/mugshots/MugshotSnakeFist.png",
      "images/mugshots/MugshotStrongBad.png",
      "images/mugshots/MugshotStrongMad.png"
    };
    
    for (int i = 0; i < fighterMugshotCount; i++) {
      float mugshotX = incrementX * (i + 1.5);
      float mugshotY = incrementY * 0.5;
      if (i >= 4) {
        mugshotX = incrementX * (i - 2.5);
        mugshotY = incrementY * 1.5;
      }
      
      fighterMugshots[i] = new ClickableButton(mugshotX, mugshotY, incrementX, incrementY);
      fighterMugshots[i].setButtonImage(fighterMugshotsFilenames[i]);
    }
    
    imgFighterSelectedEmpty = loadImage("Empty.png");
    imgFighterSelectedPosition[0] = width * 0.2;
    imgFighterSelectedPosition[1] = height * 0.75;
    
    imgFighterSelectedShowcase[0] = loadImage("characters/BoxerJoe/BoxerJoe_Idle.png");
    imgFighterSelectedShowcase[1] = loadImage("characters/CobraJoe/CobraJoe_Idle.png");
    imgFighterSelectedShowcase[2] = loadImage("characters/Crab/Crab_Idle.png");
    imgFighterSelectedShowcase[3] = loadImage("characters/IceBreaker/IceBreaker_Idle.png");
    imgFighterSelectedShowcase[4] = loadImage("characters/Snake/Snake_Idle.png");
    imgFighterSelectedShowcase[5] = loadImage("characters/SnakeFist/SnakeFist_Idle.png");
    imgFighterSelectedShowcase[6] = loadImage("characters/StrongBad/StrongBad_Idle.png");
    imgFighterSelectedShowcase[7] = loadImage("characters/StrongMad/StrongMad_Idle.png");
    
    startButton = new ClickableButton(width * 0.7, height * 0.9, localUnitX * 22, localUnitY * 7);
    startButton.setButtonText("FIGHT!", localUnitX * 3);
    startButton.setButtonColour(0, 255, 0);
    // Reuse some details from the start button for visual consistency
    modeButton = new ClickableButton(width * 0.45, startButton.y, startButton.buttonWidth, startButton.buttonHeight);
    modeButton.setButtonText(modeNames[modeSelectionIndex], localUnitX * 3);
    
    // Set default fighter selection
    reset();
  }
  
  void reset() {
    // Set the default fighter selection for all players
    int[] defaultPlayerSelectionIndexes = {0, 4};
    for (int i = 0; i < defaultPlayerSelectionIndexes.length; i++) {
      int playerSelectionIndex = defaultPlayerSelectionIndexes[i];
      playerSelectionValue[i] = playerSelectionIndex;
      imgPlayerSelectionPosition[i][0] = fighterMugshots[playerSelectionIndex].x;
      imgPlayerSelectionPosition[i][1] = fighterMugshots[playerSelectionIndex].y;
    }
    // Set current fighter's mugshot 
    imgFighterSelected = imgFighterSelectedShowcase[0];
    blurbSelected = fighterSelectedPresetBlurb[0];
  }
  
  void drawFighterSelection() {
    background(49, 52, 74);
  
    // Draw selected fighter blurb
    if (getCurrentFighterIndex() >= 0) {    
      textSize(localUnitX * 2);
      fill(255);
      textAlign(LEFT);
      text(blurbSelected, imgFighterSelectedPosition[0] + (localUnitX * 12), imgFighterSelectedPosition[1] - (localUnitY * 4));
    }
    
    // Draw selection mugshots
    for (int i = 0; i < fighterMugshotCount; i++) {
      fighterMugshots[i].drawButton();
    }
    
    // Draw selected fighter sprite, using the same dimensions as the mugshots for consistency
    imageMode(CENTER);
    float mugshotWidth = fighterMugshots[0].buttonWidth;
    float mugshotHeight = fighterMugshots[0].buttonHeight;
    image(imgFighterSelected, imgFighterSelectedPosition[0], imgFighterSelectedPosition[1], mugshotWidth * 2, mugshotHeight * 2);
    
    // Draw selection markers for all players
    for (int i = 0; i < playersCount; i++) {
      image(imgPlayerSelection[i], imgPlayerSelectionPosition[i][0], imgPlayerSelectionPosition[i][1],
            mugshotWidth, mugshotHeight);
    }
    
    // Draw FIGHT! button and text
    startButton.drawButton();
    
    // Draw mode button
    if (isSelected1PMode()) {
      modeButton.setButtonColour(255, 245, 136);
    } else if (isSelectedVSMode()) {
      modeButton.setButtonColour(221, 169, 255);
    }
    modeButton.drawButton();
  }
  
  void updateFighterSelection() {
    for (int i = 0; i < fighterMugshotCount; i++) {
      if (fighterMugshots[i].isPressed(mouseX, mouseY)) {
        imgFighterSelected = imgFighterSelectedShowcase[i];
        blurbSelected = fighterSelectedPresetBlurb[i];
        
        playerSelectionValue[playerSelectionIndex] = i;
        // Set the player selection marker to the pressed mugshot
        imgPlayerSelectionPosition[playerSelectionIndex][0] = fighterMugshots[i].x;
        imgPlayerSelectionPosition[playerSelectionIndex][1] = fighterMugshots[i].y;
        // Player has made a selection, so the next player can now select a fighter
        playerSelectionIndex = (playerSelectionIndex + 1) % playersCount;
        break;
      }
    }
  }
  
  boolean hasPressedStart(float pressX, float pressY) {
    return startButton.isPressed(pressX, pressY);
  }
  
  void updateModeSelection(float pressX, float pressY) {
    if (modeButton.isPressed(pressX, pressY)) {
      modeSelectionIndex = (modeSelectionIndex + 1) % modeCount;
      modeButton.setButtonText(modeNames[modeSelectionIndex]);
      
      // Adjust player count based on the mode
      if (isSelectedVSMode()) {
        playersCount = 2;
      } else if (isSelected1PMode()) {
        playersCount = 1;
        // Switch fighter selection back to player 1
        playerSelectionIndex = 0;
      }
    }
  }
  
  boolean isSelected1PMode() {
    return modeSelectionIndex == 0;
  }
  
  boolean isSelectedVSMode() {
    return modeSelectionIndex == 1;
  }
  
  boolean hasSelectedFighter() {
    return getCurrentFighterIndex() >= 0;
  }
  
  String getPresetName() {
    // Gets the fighter name used by the currently selected player
    return fighterSelectedPresetNames[getCurrentFighterIndex()];
  }
  
  int getCurrentFighterIndex() {
    // Gets the fighter index being used by the currently selected player
    return playerSelectionValue[playerSelectionIndex];
  }
  
  String getPresetNameOfPlayer(int playerIndex) {
    // Gets the preset fighter name of the player
    return fighterSelectedPresetNames[playerSelectionValue[playerIndex]];
  }
}
