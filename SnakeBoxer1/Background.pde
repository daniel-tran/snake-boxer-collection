class Background {
  // 1 background iteration = no repeating background
  int backgroundIterations = 1;
  int backgroundCount = 7;
  // Special backgrounds are those that require additional components than just a sky area.
  // Each special background is only drawn when the index matches a certain number.
  // A negative number indicatse that no special background is being drawn.
  int backgroundSpecialIndex = -1;
  float horizonHeight;
  float horizonWidthInc;
  float skyStripesHeight;
  color[] skyStripes;
  float[] heightFactors;
  color heightFactorsColour;
  color mainColour;
  float[] heightFactorsHills = {1, 0.96, 0.96, 0.92, 0.88, 0.84, 0.84, 0.8,
            0.8, 0.8, 0.8, 0.8, 0.8, 0.84, 0.88, 0.88, 0.92, 0.92,
            0.92, 0.96, 0.96, 1, 1, 1, 1, 1, 1, 0.96, 0.96, 0.92,
            0.88, 0.88, 0.88, 0.88, 0.88, 0.88, 0.88, 0.92, 0.92,
            0.96, 0.96, 0.96, 0.96, 1, 1, 1, 1, 1,
            0.96, 0.96, 0.96, 0.96, 0.92, 0.92, 0.92, 0.88, 0.88,
            0.84, 0.84, 0.8, 0.8, 0.76, 0.76, 0.72, 0.72, 0.68, 0.68,
            0.64, 0.64, 0.64, 0.64, 0.64, 0.64, 0.64, 0.64, 0.64,
            0.68, 0.68, 0.72, 0.72, 0.76, 0.76, 0.8, 0.8, 0.84, 0.84,
            0.88, 0.88, 0.92, 0.92, 0.92, 0.96, 0.96, 0.96, 0.96
           };
  float[] heightFactorsBeach = {0.96, 0.96, 0.96, 0.96, 0.96, 0.96,
            0.92, 0.92, 0.92, 0.92, 0.92, 0.92,
            0.88, 0.88, 0.88, 0.88, 0.88, 0.88,
            0.92, 0.92, 0.92, 0.92, 0.92, 0.92
           };
  float[] heightFactorsSiberia = {0.96, 0.92, 0.88, 0.8, 0.72, 0.68, 0.64, 0.6, 0.56,
            0.52, 0.52, 0.52, 0.56, 0.6, 0.64, 0.68, 0.72, 0.8, 0.88, 0.92, 0.96,
            0.96, 0.96, 0.96, 0.92, 0.92, 0.88, 0.88, 0.84, 0.84, 0.8, 0.8, 0.76,
            0.76, 0.76, 0.76, 0.8, 0.8, 0.84, 0.84, 0.84, 0.84, 0.8, 0.8, 0.76,
            0.72, 0.72, 0.68, 0.64, 0.64, 0.6, 0.56, 0.56, 0.52, 0.48, 0.48, 0.44,
            0.4, 0.4, 0.44, 0.48, 0.48, 0.52, 0.56, 0.56, 0.6, 0.64, 0.64, 0.68,
            0.72, 0.72, 0.76, 0.8, 0.8, 0.84, 0.88, 0.88, 0.92, 0.96, 0.96, 0.96, 0.96
           };
  float[] heightFactorsCity = {0.4, 0.3, 0.3, 0.3,
                           0.7, 0.7, 0.7, 0.75,
                           0.85, 0.85,
                           0.55, 0.55, 0.55, 0.55,
                           0.7,
                           0.3, 0.3, 0.1, 0.3, 0.3,
                           0.8, 0.8,
                           0.85, 0.9,
                           0.75, 0.75, 0.75, 0.75,
                           0.95,
                           0.85, 0.85,
                           0.5, 0.45, 0.45, 0.5,
                           0.8, 0.8,
                           0.6, 0.6, 0.6, 0.6, 0.6, 0.6,
                           0.85, 0.85,
                           0.1, 0.1, 0.1, 0.1,
                           0.75, 0.75, 0.75,
                           0.55, 0.55,
                           0.8, 0.85, 0.85
                         };
  color[] skyStripesHills = {
    color(255, 255, 255),
    color(204, 238, 255),
    color(166, 226, 255),
    color(102, 204, 255),
    color(66, 193, 255),
    color(0, 159, 236)
  };
  color[] skyStripesHillsNoon = {
    color(255, 255, 0),
    color(255, 204, 0),
    color(255, 153, 0),
    color(255, 102, 0),
    color(255, 51, 0),
    color(174, 0, 0)
  };
  color[] skyStripesBeach = {
    color(40, 40, 206),
    color(153, 255, 255)
  };
  color[] skyStripesDesert = {
    color(255, 102, 0),
    color(255, 153, 0),
    color(255, 204, 0),
    color(255, 255, 0),
    color(255, 255, 0)
  };
  color[] skyStripesSiberia = {
    color(86, 139, 246)
  };
  color[] skyStripesCity = {
    color(153, 255, 255)
  };
  
  Background(int backgroundIndex, float horizonHeightValue, float horizonWidthIncValue) {
    horizonHeight = horizonHeightValue;
    horizonWidthInc = horizonWidthIncValue;
    // Supplying a negative number is shorthand for randomising the background
    if (backgroundIndex < 0) {
      randomiseBackground();
    } else {
      selectBackground(backgroundIndex);
    }
  }
  
  void randomiseBackground() {
    int randomBackground = (int)random(backgroundCount);
    selectBackground(randomBackground);
  }
  
  void selectBackground(int backgroundIndex) {
    switch(backgroundIndex) {
      case 0:
        // City
        setMainColour(184, 184, 184, false);
        setHeightFactorsColour(153, 204, 153);
        heightFactors = heightFactorsCity;
        skyStripes = skyStripesCity;
        backgroundIterations = 2;
        break;
      case 1:
        // Fields (daytime)
        setMainColour(3, 61, 12, true);
        heightFactors = heightFactorsHills;
        skyStripes = skyStripesHills;
        backgroundIterations = 1;
        break;
      case 2:
        // Fields (noon)
        setMainColour(3, 48, 10, true);
        heightFactors = heightFactorsHills;
        skyStripes = skyStripesHillsNoon;
        backgroundIterations = 1;
        break;
      case 3:
        // Beach (without trees)
        setMainColour(239, 228, 176, true);
        heightFactors = heightFactorsBeach;
        skyStripes = skyStripesBeach;
        backgroundIterations = 4;
        break;
      case 4:
        // Desert (without trees)
        setMainColour(204, 204, 153, true);
        heightFactors = reverse(heightFactorsHills);
        skyStripes = skyStripesDesert;
        backgroundIterations = 1;
        break;
      case 5:
        // Siberia
        setMainColour(153, 204, 255, false);
        setHeightFactorsColour(200, 227, 253);
        heightFactors = heightFactorsSiberia;
        skyStripes = skyStripesSiberia;
        backgroundIterations = 2;
        break;
      default:
        // Special background (see drawBackgroundSpecial for each mapping)
        backgroundSpecialIndex = backgroundIndex;
        break;
    }
  }
  
  void drawBackgroundSpecial() {
    switch(backgroundSpecialIndex) {
      case 6:
        drawBoxingStadiuim();
        break;
      default:
        break;
    }
  }
  
  void setMainColour(int r, int g, int b, boolean useSameColourForHeightFactors) {
    mainColour = color(r, g, b);
    if (useSameColourForHeightFactors) {
      setHeightFactorsColour(r, g, b);
    }
  }
  
  void setHeightFactorsColour(int r, int g, int b) {
    heightFactorsColour = color(r, g, b);
  }
  
  void drawBackground() {
    if (backgroundSpecialIndex < 0) {
      drawBackgroundRegular();
    } else {
      drawBackgroundSpecial();
    }
  }
  
  void drawBackgroundRegular() {
    rectMode(CORNERS);
    // Draw the main background
    background(mainColour);
    if (skyStripes.length > 0) {
      // Draw the sky as a series of horizontal stripes
      float horizonHeightInc = horizonHeight / skyStripes.length;
      for (int i = 0; i < skyStripes.length; i++) {
        fill(skyStripes[i]);
        // Draw each sky stripe below the last drawn one
        rect(0, 0, width, horizonHeight - (horizonHeightInc * i));
      }
    }
    
    // Initial starting X position of the background element
    float initialX = 0;
    // Width of each pixel column when drawing the background element
    float widthX = horizonWidthInc * 2;
    
    stroke(heightFactorsColour);
    fill(heightFactorsColour);
    // Background willl repeat, by increasing the value of the x coordinate
    // and persisting its modification after the first cycle.
    for (int c = 0; c < backgroundIterations; c++) {
      // Height factor values are effectively a percentage of sky between the
      // pixel column and the top of the screen.
      // Example: 0.1 = Pixel column covers 90% of the sky height
      for (int i = 0; i < heightFactors.length; i++) {
        rect(initialX, horizonHeight * heightFactors[i], initialX + widthX, horizonHeight);
        // Increment the x coordinate after drawing to avoid having an initial empty gap 
        initialX += horizonWidthInc;
      }
    }
    noStroke();
  }
  
  void drawBoxingStadiuim() {
    float localUnitX = width * 0.01;
    float localUnitY = localUnitX;
    float mainStageX = width * 0.3;
    float mainStageY = height * 0.2;
    float mainStageWidth = width * 0.35;
    float mainStageHeight = height * 0.5;
  
    // Background colour outside of the stage area
    background(0);
  
    // Main stage
    fill(204);
    rect(mainStageX, mainStageY, mainStageWidth, mainStageHeight);
    
    fill(255);
    // Horizontal fencing
    float leftmostFenceX = mainStageX - (localUnitX * 2);
    float rightmostFenceX = mainStageX + mainStageWidth + localUnitX;
    rect(leftmostFenceX, mainStageY, localUnitX, mainStageHeight);
    rect(rightmostFenceX, mainStageY, localUnitX, mainStageHeight);
    // Vertical fencing
    float topmostFenceY = mainStageY - (localUnitY * 2); 
    float bottommostFenceY = mainStageY + mainStageHeight + localUnitY;
    rect(mainStageX, topmostFenceY, mainStageWidth, localUnitY);
    rect(mainStageX, bottommostFenceY, mainStageWidth, localUnitY);
         
    // Diagonal fencing
    for (int i = 0; i < 4; i++) {
      // Split increments into separate variables, if we ever want to skew the diagonal fencing
      float incrementX = localUnitX * i;
      float incrementY = localUnitY * i;
      
      // Top left
      rect(leftmostFenceX + incrementX, topmostFenceY + incrementY,
         localUnitX, localUnitY);
      // Top right
      rect(rightmostFenceX - incrementX, topmostFenceY + incrementY,
           localUnitX, localUnitY);
      // Bottom right
      rect(rightmostFenceX - incrementX, bottommostFenceY - incrementY,
           localUnitX, localUnitY);
      // Bottom left
      rect(leftmostFenceX + incrementX, bottommostFenceY - incrementY,
           localUnitX, localUnitY);
    }
  }
}
