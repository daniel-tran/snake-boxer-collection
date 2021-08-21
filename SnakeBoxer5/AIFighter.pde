class AIFighter extends Fighter {
  int directionYUp = 1;
  int directionYStationary = 0;
  int directionYDown = -1;
  int directionY = directionYDown; // 1 = up,  0 = stationary, -1 = down
  Timer directionYSwitchTimer = new Timer(1, 30, true);
  Timer actionTimer = new Timer(1, 30, true);
  float chanceChangeDirection = 0.5;
  
  AIFighter(float initialX, float initialY, String filenameIdle, String filenameBlock,
            String filenameHurt, String[] filenamesAttackNormal,
            float spriteWidth, float spriteHeight) {
    super(initialX, initialY, filenameIdle, filenameBlock,
          filenameHurt, filenamesAttackNormal, spriteWidth, spriteHeight);
  }
  
  AIFighter(float initialX, float initialY, float spriteWidth, float spriteHeight, String presetName) {
    super(initialX, initialY, spriteWidth, spriteHeight, presetName);
  }
  
  void resetToIdle() {
    super.resetToIdle();
    // Resume movement by selecting a random direction to go in
    float directionChance = random(0, 1);
    if (directionChance >= 0.5) {
      directionY = directionYUp; 
    } else {
      directionY = directionYDown;
    }
  }
  
  void startBlock() {
    if (isPlayable()) {
      super.startBlock();
      stopMovementTemporarily();
    }
  }
  
  void startAttack() {
    if (isPlayable()) {
      super.startAttack();
      stopMovementTemporarily();
    }
  }
  
  void startHurt(int damage) {
    super.startHurt(damage);
    // Ensure enemy goes through the entire hurt animation before the next action
    // Remove the condition to enable constant blocking on non-stop attacks
    if (isUsingHurtImage()){
      stopMovementTemporarily();
      actionTimer.reset();
    }
  }
  
  void stopMovementTemporarily() {
    // Enemy should not be able to move when doing certain actions
    directionY = directionYStationary;
    directionYSwitchTimer.setTime(-directionYSwitchTimer.timeMax);
  }
  
  void defaultDirectionSwitch(float playerMinX, float playerMaxX,
                             float playerMinY, float playerMaxY) {
    // Force a direction change when at the stage boundaries
    // Blocking should keep the direction as stationary
    if (directionY != directionYStationary) {
      if (y == playerMinY) {
        directionY = directionYDown;
      } else if (y == playerMaxY) {
        directionY = directionYUp;
      }
    }
    
    directionYSwitchTimer.tick();
    if (directionYSwitchTimer.isOvertime()) {
      directionYSwitchTimer.setTime((int)random(-20, 1));
      
      // Enemy might change direction, or continue in the same direction
      float chanceToChangeDirection = random(0, 1);
      if (chanceToChangeDirection >= chanceChangeDirection) {
        if (directionY == directionYDown) {
          directionY = directionYUp;
        } else if (directionY == directionYUp) {
          directionY = directionYDown;
        }
      }
    }
  }
  
  void decideAction() {    
    actionTimer.tick();
    // An action should only be made when the fighter is actually
    // available to make a next move.
    if (actionTimer.isOvertime() && isPlayable() && !isUsingHurtImage()) {
      float chance = random(0, 1);
      float chanceBlock = 0.4;
      float chanceAttack = 0.75;
      float chanceAttackSpecial = random(0.5);
      
      // First priority is the special attack, since it requires a charge-up.
      // Use return to ensure the special attack and charge-up are
      // mutually exclusive to the regular actions.
      if (chance >= chanceAttackSpecial && isChargedForSpecialAttack()) {
        startSpecialAttack();
        return;
      } else if (useSpecialAttack && isUsingBlockImage()) {
        // Continue blocking to delay the special attack
        startBlock();
        return;
      }
      
      // Condition sequence indicates action preferencce
      if (chance >= chanceAttack) {
        startAttack();
      } else if (chance >= chanceBlock) {
        startBlock();
      } else {
        resetToIdle();
      }
    }
  }
  
  void levelUp() {
    speedYMultiplier += 0.1;
    attack1Multiplier += 0.1;
    damageMultiplier *= 0.9;
  }
  
}
