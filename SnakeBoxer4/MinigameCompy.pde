/*
Compy:
- Type the command shown in the console
- To account for an equal experience on both computers and devices,
  typing simply requires any keyboard press or any touch on the screen.
*/
class MinigameCompy extends MinigameManager {
  String command = "";
  String typing = "";
  String newlinePrefix = "> ";
  int typingIndex = 0;
  
  MinigameCompy(float localUnitWidth, float localUnitHeight) {
    super(localUnitWidth, localUnitHeight);
    setText("Type the command!", 255);
    
    // Randomise the required command for some gameplay variation
    String[] possibleCommands = {
      "strongbad_email.exe",
      "sb_enail.com",
      "cd ..\\..\\ & echo OK!"
    };
    int randomCommand = (int)random(possibleCommands.length);
    command = possibleCommands[randomCommand];
  }
  
  void drawMinigame() {
    float typingX = width * 0.25;
    float typingY = height * 0.25;
    float typingFontSize = localUnitX * 2;
    
    background(0);
    
    fill(255);
    textAlign(LEFT);
    textSize(typingFontSize);
    text(newlinePrefix + command + "\n" + newlinePrefix + typing, typingX, typingY);
  }
  
  void type() {
    if (typingIndex < command.length()) {
      // Type the next character by adding the relevant character onto the typed string
      typing += command.charAt(typingIndex);
      typingIndex++;
    }
    
    // After some typing was done, check if the command has been fully typed out
    if (typing.equals(command) && !hasWon) {
      hasWon = true;
      enableWinTimer = true;
      typing += "\n" + newlinePrefix + "OK!";
    }
  }
  
  void screenPressed() {
    type();
  }
  
  void keyboardPressed() {
    type();
  }
}
