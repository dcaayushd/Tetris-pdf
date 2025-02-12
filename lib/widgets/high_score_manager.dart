
import 'package:shared_preferences/shared_preferences.dart';

class HighScoreManager {
  static const String _highScoresKey = 'highScores';

  static Future<List<int>> getHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    final scores = prefs.getStringList(_highScoresKey) ?? [];
    return scores.map((e) => int.parse(e)).toList();
  }

  static Future<void> saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final scores = await getHighScores();
    scores.add(score);
    scores.sort((a, b) => b.compareTo(a)); // Sort in descending order
    final topScores = scores.take(5).toList(); // Keep only top 5
    await prefs.setStringList(
      _highScoresKey,
      topScores.map((e) => e.toString()).toList(),
    );
  }
}