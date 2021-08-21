/*
Airplane:
- Drag the airplane up and down to dodge the incoming ducks
*/
class MinigameAirplane extends MinigameManager {
  // Note that setting the enemy count above 5 or 6 can result in an OutOfMemoryError
  // when ending the game on mobile devices.
  MovingEnemy[] ducks = new MovingEnemy[5];
  // Airplane is a moving enemy just for the shifting idle images.
  // Respawn coordinates are negligible, since this is not expected to respawn.
  MovingEnemy airplane = new MovingEnemy(width * 0.15, height * 0.5,
                                         "minigames/Airplane/AirplaneHurt.png",
                                         new String[]{
                                           "minigames/Airplane/AirplaneIdle1.png",
                                           "minigames/Airplane/AirplaneIdle2.png"
                                         },
                                         localUnitX * 44, localUnitY * 44,
                                         new float[]{0}, new float[]{0});

  MinigameAirplane(float localUnitWidth, float localUnitHeight) {
    super(localUnitWidth, localUnitHeight);
    setText("Duck!", 255);
    
    String[] imgDuckMoving = {
      "minigames/Airplane/DuckIdle1.png",
      "minigames/Airplane/DuckIdle2.png",
      "minigames/Airplane/DuckIdle3.png",
      "minigames/Airplane/DuckIdle2.png"
    };
    String imgEmpty = "minigames/Airplane/Empty.png";
    float duckWidth = localUnitX * 6;
    float duckHeight = localUnitY * 6;
    float duckSpawnDistanceX = localUnitX * 18;
    for (int i = 0; i < ducks.length; i++) {
      float duckX = width + (duckSpawnDistanceX * (i + 1));
      float duckY = random(gameSpaceHeight);
      // Ducks don't respawn and can't be defeated
      ducks[i] = new MovingEnemy(duckX, duckY, imgEmpty, imgDuckMoving,
                                 duckWidth, duckHeight, new float[]{0}, new float[]{0});
    }

    // When hurt, disable sprite flashing by massively extending the relevant timer
    airplane.recoveryFlashTimer.timeMax *= 1000;
  }
  
  void drawMinigame() {
    background(51, 153, 0);
    
    // Draw the horizon stripes
    float horizonY = height * 0.1;
    float horizonStripeHeight = localUnitY * 0.5;
    rectMode(CORNERS);
    fill(144, 132, 255);
    rect(0, 0, width, horizonY);
    for (int i = 0; i < 6; i++) {
      switch(i) {
        case 0:
          fill(255, 216, 76);
          break;
        case 1:
          fill(255, 197, 29);
          break;
        case 2:
          fill(255, 152, 44);
          break;
        case 3:
          fill(255, 112, 110);
          break;
        case 4:
          fill(234, 81, 235);
          break;
        case 5:
          fill(190, 96, 255);
          break;
        default:
          break;
      }
      float horizonStripeY = horizonY - (horizonStripeHeight * i);
      rect(0, horizonStripeY, width, horizonStripeY + horizonStripeHeight);
    }
    
    // Draw the  hills that overlay the horizon
    int[] hillRGB = {131, 48, 8};
    fill(hillRGB[0], hillRGB[1], hillRGB[2]);
    stroke(hillRGB[0], hillRGB[1], hillRGB[2]);
    float[] hillHeights = {0.95, 0.95, 0.95, 0.95, 0.85, 0.85, 0.85, 0.85, 0.75, 0.75, 0.75, 0.75,
                           0.65, 0.65, 0.65, 0.65, 0.55, 0.55, 0.55, 0.55, 0.65, 0.65, 0.65, 0.65,
                           0.75, 0.75, 0.75, 0.75, 0.85, 0.85, 0.85, 0.85, 0.95, 0.95, 0.95, 0.95,
                           // Hill 2
                           0.95, 0.95, 0.95, 0.95, 0.85, 0.85, 0.85, 0.85, 0.75, 0.75, 0.75, 0.75,
                           0.65, 0.65, 0.65, 0.65, 0.55, 0.55, 0.55, 0.55, 0.65, 0.65, 0.65, 0.65,
                           0.75, 0.75, 0.75, 0.75, 0.85, 0.85, 0.85, 0.85, 0.95, 0.95, 0.95, 0.95,
                           // Hill 3
                           0.95, 0.95, 0.95, 0.95, 0.85, 0.85, 0.85, 0.85, 0.75, 0.75, 0.75, 0.75,
                           0.65, 0.65, 0.65, 0.65, 0.55, 0.55, 0.55, 0.55, 0.65, 0.65, 0.65, 0.65,
                           0.75, 0.75, 0.75, 0.75, 0.85, 0.85, 0.85, 0.85, 0.95, 0.95, 0.95, 0.95};
    for (int i = 0; i < hillHeights.length; i++) {
      rect(localUnitX * i, horizonY + horizonStripeHeight, localUnitX * (i + 1), horizonY * hillHeights[i]);
    }
    noStroke();

    // Draw ducks before the airplane, as the visual effect for a head-on collision looks more sensible
    drawDucks();
    airplane.drawImage();
    airplane.processAction();
  }

  void drawDucks() {
    float duckStepSize = localUnitX * timerSpeedMultiplier;
    for (int i = 0; i < ducks.length; i++) {
      if (!enableLoseTimer && !isShowingInstructions()) {
        ducks[i].step(duckStepSize);
      }
      ducks[i].drawImage();
      ducks[i].processAction();
      
      // Hit detection is based a specific zone on the image where the airplane is actually drawn
      float airplaneRadiusX = localUnitX * 12;
      float airplaneRadiusY = localUnitY * 6;
      boolean hasStruckAirplane = ducks[i].x <= airplane.x + airplaneRadiusX &&
                                  ducks[i].x >= airplane.x - airplaneRadiusX &&
                                  ducks[i].y <= airplane.y + airplaneRadiusY &&
                                  ducks[i].y >= airplane.y - airplaneRadiusY;
      if (hasStruckAirplane) {
        enableLoseTimer = true;
        airplane.startHurt();
      }
    }
  }
  
  void screenDragged() {
    // Player can drag the airplane as long as the approximate Y coordinate matches the screen press
    float airplaneDragAreaY = airplane.imgHeight * 0.25;
    if (abs(mouseY - airplane.y) <= airplaneDragAreaY && !enableLoseTimer) {
      airplane.y = min(mouseY, gameSpaceHeight);
    }
  }
}
