import '../models/quiz_question.dart';
import '../services/quiz_service.dart';

class AlphabetQuizData {
  static List<QuizQuestion> recognitionQuestions = [];
  static List<QuizQuestion> compareQuestions = [];
  static List<QuizQuestion> soundQuestions = [];
  static List<QuizQuestion> pronunciationQuestions = [];

  static bool _loaded = false;

  static Future<void> ensureLoaded() async {
    if (_loaded) return;

    final data = await QuizService.loadAlphabetQuizData();
    recognitionQuestions = data['recognition'] ?? [];
    compareQuestions = data['compare'] ?? [];
    soundQuestions = data['sound'] ?? [];
    pronunciationQuestions = data['pronunciation'] ?? [];
    _loaded = true;
  }

  static Future<void> reload() async {
    _loaded = false;
    await ensureLoaded();
  }
}
