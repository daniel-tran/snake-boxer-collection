class Upgrade {
  int value = 1;
  int valueInc = 1;
  int valueMultiplier = 1;
  int costInitial = 100;
  int costMultiplier = 1;
  int costInc = 0;
  
  Upgrade(int initialValue, int initialValueInc, int initialCost) {
    value = initialValue;
    valueInc = initialValueInc;
    costInitial = initialCost;
  }
  
  int getCost() {
    int cost = (costInitial * costMultiplier) + costInc;
    // Numeric overflow should default to the max value
    if (cost <= 0) {
      return Integer.MAX_VALUE;
    }
    return cost;
  }
  
  int getValue() {
    // Numeric overflow should default to the max value
    if (value < 0) {
      return Integer.MAX_VALUE;
    }
    return value;
  }
  
  boolean isPurchasable(int score) {
    return score >= getCost();
  }
  
  void purchase() {
    value += (valueInc * valueMultiplier);
    int cost = getCost();
    // Avoid numeric overflow by capping the cost at the highest possible value
    if (cost < Integer.MAX_VALUE) {
      costInc = int(cost * 0.5);
      costMultiplier += 1;
    }
  }
}
