/*
Rank up behaviour:
- Upon reaching a specific score, players can "rank up", resulting in all upgrade values
  being scaled up by some factor and the current points set to 0.
- Players cannot rank up if their score falls below the specific score after reaching it,
  and players cannot rank up once they have reached the final rank.
- Ranks cannot be skipped, although sequential rank ups are possible with sufficient points.
*/
class DialogBoxRankUp extends DialogBox {
  IntDict ranks = new IntDict(new Object[][] {
    { "Junior Diplomat", 0 },
    { "Diplomat", 100 },
    { "Ambassador", 2000 },
    { "Minister", 50000 },
    { "President", 1000000 },
    { "Uber Pope", 100000000 }
  });
  int rankNextIndex = 1;
  int rankCurrent = 0;
  
  DialogBoxRankUp(float initialX, float initialY, float initialWidth, float initialHeight,
                  float buttonWidth, float buttonHeight, boolean enableChoice) {
    super(initialX, initialY, initialWidth, initialHeight, buttonWidth, buttonHeight, enableChoice);
    
    setRankUpText();
  }
  
  void setRankUpText() {
    setText("Promotion!", "You can now be promoted to:\n\n" +
                          getNextRank() + "\n\n" +
                          "Do you accept?\n" +
                          "WARNING: Your diplomacy\nwill be cleared!");
  }
  
  String getCurrentRank() {
    return ranks.key(rankCurrent);
  }
  
  String getNextRank() {
    // After reaching the final rank, cap the promotion rank at that point
    return ranks.key(min(rankNextIndex, ranks.size() - 1));
  }
  
  boolean isAbleToRankUp(int score) {
    return score >= ranks.get(getNextRank()) && rankNextIndex < ranks.size();
  }
  
  void rankUp() {
    rankNextIndex++;
    rankCurrent++;
    setRankUpText();
  }
}
