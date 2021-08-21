/*
Videlectrix:
- Press on the runner to make him trip
- The runner's speed can vary between different plays, and increases with difficulty
*/
class MinigameVidelectrix extends MinigameManager {
  float runnerSpeed = random(localUnitX * 0.25, localUnitX);
  MovingEnemy runner = new MovingEnemy(width * 1.25, height * 0.5,
                                 "minigames/Videlectrix/RunnerFall1.png",
                                 new String[]{
                                   "minigames/Videlectrix/Runner1.png",
                                   "minigames/Videlectrix/Runner2.png",
                                   "minigames/Videlectrix/Runner3.png",
                                   "minigames/Videlectrix/Runner4.png",
                                   "minigames/Videlectrix/Runner5.png"
                                 },
                                 localUnitX * 11, localUnitY * 11,
                                 new float[]{0}, new float[]{0});
  PImage[] runnerFallImages = new PImage[]{
    loadImage("minigames/Videlectrix/RunnerFall1.png"),
    loadImage("minigames/Videlectrix/RunnerFall2.png"),
    loadImage("minigames/Videlectrix/RunnerFall3.png")
  };
  PImage runnerFallImageFinal = loadImage("minigames/Videlectrix/RunnerFall4.png");
  boolean isRunnerFalling = false;
  Timer runnerFallTimer = new Timer(1, 30, false);
  PImage videlectrixLogo = loadImage("minigames/Videlectrix/VidelectrixLogo.png");
  
  MinigameVidelectrix(float localUnitWidth, float localUnitHeight) {
    super(localUnitWidth, localUnitHeight);
    setText("Make him trip!", 255);
  }
  
  void drawMinigame() {
    float runnerSpeedFall = localUnitX * 0.1;
    
    background(0);
    
    if (hasWon) {
      drawLogo();
      
      runnerFallTimer.tick();
      if (!runnerFallTimer.isOvertime()) {
        // Runner is sliding across the floor after tripping
        runner.step(runnerSpeedFall);
        
        if (runner.imgDrawn == runnerFallImages[runnerFallImages.length - 1] && runner.imgMoving.length > 1) {
          // Force the runner to use the last falling image after they've hit the floor
          runner.imgMoving = new PImage[]{runner.imgDrawn};
        }
      } else if (runner.imgDrawn != runnerFallImageFinal) {
        // Runner has stopped sliding on the floor and can use their final image
        runner.imgMoving = new PImage[]{runnerFallImageFinal};
      }
    } else if (!isShowingInstructions()) {
      float runnerStepSize = runnerSpeed * timerSpeedMultiplier;
      runner.step(runnerStepSize);
      runner.processAction();
    }
    runner.drawImage();
  }
  
  void drawLogo() {
    float videlectrixLogoX = width * 0.5;
    float videlectrixLogoY = height * 0.25;
    float videlectrixLogoWidth = width * 0.5;
    float videlectrixLogoHeight = height * 0.25;

    image(videlectrixLogo, videlectrixLogoX, videlectrixLogoY, videlectrixLogoWidth, videlectrixLogoHeight);
  }
  
  void screenPressed() {
    float runnerWidthOffset = runner.imgWidth * 0.25;
    float runnerHeightOffset = runner.imgHeight * 0.25;
    boolean runnerWasPressed = mouseX >= runner.x - runnerWidthOffset &&
                               mouseX <= runner.x + runnerWidthOffset &&
                               mouseY >= runner.y - runnerHeightOffset &&
                               mouseY <= runner.y + runnerHeightOffset;
    if (!hasWon && runnerWasPressed) {
      isRunnerFalling = true;
      runner.imgMoving = runnerFallImages;
      hasWon = true;
    }
  }
}
