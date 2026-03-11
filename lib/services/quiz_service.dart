import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/quiz_question.dart';

class QuizService {
  static Future<Map<String, List<QuizQuestion>>> loadAlphabetQuizData() async {
    final jsonString =
        await rootBundle.loadString('assets/data/alphabet_quiz.json');
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);

    return {
      'recognition': _parseQuestions(jsonData['recognition']),
      'compare': _parseQuestions(jsonData['compare']),
      'sound': _parseQuestions(jsonData['sound']),
      'pronunciation': _parseQuestions(jsonData['pronunciation']),
    };
  }

  static List<QuizQuestion> _parseQuestions(dynamic rawList) {
    return (rawList as List)
        .map((item) => QuizQuestion.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
