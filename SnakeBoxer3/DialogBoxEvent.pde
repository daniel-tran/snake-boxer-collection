class DialogBoxEvent extends DialogBox {
  int eventCountdown;
  int diplomacyImpactOK;
  int diplomacyImpactYes;
  int diplomacyImpactNo;
  
  DialogBoxEvent(float initialX, float initialY, float initialWidth, float initialHeight,
                  float buttonWidth, float buttonHeight, boolean enableChoice) {
    super(initialX, initialY, initialWidth, initialHeight, buttonWidth, buttonHeight, enableChoice);
    setEventCountdown();
  }
  
  void setEventCountdown() {
    eventCountdown = (int)random(50, 100);
  }
  
  void incrementEventCountdown(int score) {
    // Events cannot occur with negative points. It would be the equivalent of being a terrible
    // diplomat which nobody wants to associate with due to a bad reputation.
    if (!isTimeForEvent() && score >= 0) {
      eventCountdown--;
      
      // Event is generated based on the current points at that instance.
      // This is to prevent players from spending all their points in upgrades before entering
      // the event to minimise negative impact.
      if (isTimeForEvent()) {
        generateEvent(score);
      }
    }
  }
  
  boolean isTimeForEvent() {
    return eventCountdown <= 0;
  }
  
  String getRandomRegion() {
    return getRandomRegion("");
  }
  
  String getRandomRegion(String excludeRegion) {
    StringList regions = new StringList(new String[]{
      "Bleak House",
      "Strong Badia",
      "Country",
      "Marzistar",
      "Homezipan",
      "Pompomerania",
      "Sticktenstein",
      "Poopslovakia",
      "Conncessionstan",
      "Coachnya",
      "Frontzeatserland",
      "Hatchbackistan",
      "Snapshakland",
      "Tirerea"
    });
    regions.removeValue(excludeRegion);
    return regions.get((int)random(0, regions.size()));
  }
  
  String getEffectMessage(int value) {
    String message = "You ";
    if (value >= 0) {
      message += "gained";
    } else {
      message += "lost";
    }
    
    return message + " " + nfc(abs(value)) + "\ndiplomacy!";
  }
  
  void generateEvent(int score) {
    float chance = random(1);
    
    if (chance > 0.5) {
      generateEventOK(score);
    } else {
      generateEventYesNo(score);
    }
  }
  
  void generateEventOK(int score) {
    // Option indexes range from 0 to the number specified - 1
    int option = (int)random(4);
    String region = getRandomRegion();
    
    allowChoice = false;
    switch(option) {
      case 1:
        diplomacyImpactOK = (int)random(1, score);
        setText("World Congress update!", getRandomRegion() + " liked your\nproposal to the last\nWorld Congress meeting.\n\n" +
                getEffectMessage(diplomacyImpactOK));
        break;
      case 2:
        diplomacyImpactOK = -(int)random(1, score);
        setText("World Congress update!", getRandomRegion() + " opposed your\nproposal to the last\nWorld Congress meeting.\n\n" +
                getEffectMessage(diplomacyImpactOK));
        break;
      case 3:
        diplomacyImpactOK = (int)random(1, score * 0.5);
        setText("Foreign aid update!", region + "'s economy\nis now improving\nthanks to your foreign\naid program!\n\n" +
                getEffectMessage(diplomacyImpactOK));
        break;
      default:
        // This would be synonymous with option index 0
        diplomacyImpactOK = 0;
        setText("Humanitarian aid update!", "Refugees from the\nHomsar Reservation\nare seeking immigration\ninto " + region + ".");
    }
  }
  
  void generateEventYesNo(int score) {
    // Option indexes range from 0 to the number specified - 1
    int option = (int)random(4);
    String region = getRandomRegion();
    
    allowChoice = true;
    switch(option) {
      case 1:
        diplomacyImpactYes = (int)random(-score, score);
        diplomacyImpactNo = 0;
        setText("Espionage!", "Send spies into\n" + getRandomRegion() + "?\nIf they are caught, your\ndiplomacy will decrease!");
        break;
      case 2:
        diplomacyImpactYes = (int)random(-score, score * 2);
        diplomacyImpactNo = (int)random(0, score);
        setText("Request for military support!",
                region + " is\nengaged in active combat\nwith " + getRandomRegion(region) + "!\n" +
                "Will you provide support\nfor " + region + "?");
        break;
      case 3:
        diplomacyImpactYes = (int)random(0, score * 2);
        diplomacyImpactNo = (int)random(0, score);
        setText("Open the borders!", "Open the border for\n" + region + " to\nimprove international\nrelations?");
        break;
      default:
        // This would be synonymous with option index 0
        diplomacyImpactYes = -(int)random(0, score);
        diplomacyImpactNo = -(int)random(0, score * 0.25);
        String action = new String[]{
          "technology theft",
          "various war crimes",
          "aggressive trade embargoes"
        }[(int)random(3)];
        setText("Denounced!", region + " has\ndenounced you for\n" + action + "!\nRetaliate?");
    }
  }
  
  int getPointsOK() {
    return diplomacyImpactOK;
  }
  
  int getPointsYes() {
    return diplomacyImpactYes;
  }
  
  int getPointsNo() {
    return diplomacyImpactNo;
  }
}
