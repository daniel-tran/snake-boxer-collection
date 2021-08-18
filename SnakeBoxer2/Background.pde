class Background {
  // 1 background iteration = no repeating background
  int backgroundIterations = 1;
  int backgroundCount = 6;
  float horizonHeight;
  float horizonWidthInc;
  float skyStripesHeight;
  int[][] skyStripes;
  float[] heightFactors;
  IntDict heightFactorsColour;
  IntDict mainColour;
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
  int[][] skyStripesHills = {
    {255, 255, 255},
    {204, 238, 255},
    {166, 226, 255},
    {102, 204, 255},
    {66, 193, 255},
    {0, 159, 236}
  };
  int[][] skyStripesHillsNoon = {
    {255, 255, 0},
    {255, 204, 0},
    {255, 153, 0},
    {255, 102, 0},
    {255, 51, 0},
    {174, 0, 0}
  };
  int[][] skyStripesBeach = {
    {40, 40, 206},
    {153, 255, 255}
  };
  int[][] skyStripesDesert = {
    {255, 102, 0},
    {255, 153, 0},
    {255, 204, 0},
    {255, 255, 0},
    {255, 255, 0}
  };
  int[][] skyStripesSiberia = {
    {86, 139, 246}
  };
  int[][] skyStripesCity = {
    {153, 255, 255}
  };
  
  Background(int backgroundIndex, float horizonHeightValue, float horizonWidthIncValue) {
    horizonHeight = horizonHeightValue;
    horizonWidthInc = horizonWidthIncValue;
    mainColour = new IntDict();
    heightFactorsColour = new IntDict();
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
        skyStripes = new int[0][0];
        heightFactors = new float[0];
        backgroundIterations = 0;
        break;
    }
  }
  
  void setMainColour(int R, int G, int B, boolean useSameColourForHeightFactors) {
    mainColour.set("R", R);
    mainColour.set("G", G);
    mainColour.set("B", B);
    if (useSameColourForHeightFactors) {
      setHeightFactorsColour(R, G, B);
    }
  }
  
  void setHeightFactorsColour(int R, int G, int B) {
    heightFactorsColour.set("R", R);
    heightFactorsColour.set("G", G);
    heightFactorsColour.set("B", B);
  }
  
  void drawBackground() {
    rectMode(CORNERS);
    // Draw the main background
    background(mainColour.get("R"), mainColour.get("G"), mainColour.get("B"));
    if (skyStripes.length > 0) {
      // Draw the sky as a series of horizontal stripes
      float horizonHeightInc = horizonHeight / skyStripes.length;
      for (int i = 0; i < skyStripes.length; i++) {
        fill(skyStripes[i][0], skyStripes[i][1], skyStripes[i][2]);
        // Draw each sky stripe below the last drawn one
        rect(0, 0, width, horizonHeight - (horizonHeightInc * i));
      }
    }
    
    // Initial starting X position of the background element
    float initialX = 0;
    // Width of each pixel column when drawing the background element
    float widthX = horizonWidthInc * 2;
    
    stroke(heightFactorsColour.get("R"), heightFactorsColour.get("G"), heightFactorsColour.get("B"));
    fill(heightFactorsColour.get("R"), heightFactorsColour.get("G"), heightFactorsColour.get("B"));
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
}
