import 'dart:convert';

import 'package:flutter/services.dart';

import '../data/sample_alphabet_data.dart';
import '../models/quiz_question.dart';

class QuizService {
  static Future<Map<String, List<QuizQuestion>>> loadAlphabetQuizData() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/alphabet_quiz.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);

      final data = {
        'recognition': _parseQuestions(jsonData['recognition']),
        'compare': _parseQuestions(jsonData['compare']),
        'sound': _parseQuestions(jsonData['sound']),
        'pronunciation': _parseQuestions(jsonData['pronunciation']),
      };

      final hasAnyQuestions = data.values.any((items) => items.isNotEmpty);
      if (hasAnyQuestions) {
        return data;
      }
    } catch (_) {
      // Fall back to generated quiz data when local JSON is absent or invalid.
    }

    return buildSampleAlphabetQuizData();
  }

  static List<QuizQuestion> _parseQuestions(dynamic rawList) {
    return (rawList as List)
        .map((item) => QuizQuestion.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
