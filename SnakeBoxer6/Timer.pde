class Timer{
  float time = 0;
  float timeInc;
  float timeMax;
  boolean isRepeatable;
  
  Timer(float increment, float maximum, boolean isRepeating) {
    timeInc = increment;
    timeMax = maximum;
    isRepeatable = isRepeating;
  }
  
  void tick() {
    if (!isOvertime() && !isUnderTime()) {
      time += timeInc;
    } else {
      if (isRepeatable) {
        reset();
      }
    } 
  }
  
  boolean isOvertime() {
    return time >= timeMax;
  }
  
  boolean isUnderTime() {
    return time < 0;
  }
  
  void setTime(float timeValue) {
    time = timeValue;
  }
  
  void reset() {
    setTime(0);
  }
  
  boolean isActive() {
    return time > 0;
  }
  
  void toggleDirection() {
    timeInc *= -1;
    // Manually increment the timer to begin ticking in the new direction
    time += timeInc;
  }
}
