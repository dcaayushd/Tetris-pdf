class GameStats {
  int score = 0;
  int level = 1;
  int linesCleared = 0;
  int combo = 0;
  
  void reset() {
    score = 0;
    level = 1;
    linesCleared = 0;
    combo = 0;
  }
}