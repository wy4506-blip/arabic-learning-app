import 'package:flutter/material.dart';
import '../data/alphabet_quiz_data.dart';
import '../models/quiz_question.dart';
import 'quiz_scaffold.dart';

class AlphabetRecognitionQuizPage extends StatefulWidget {
  const AlphabetRecognitionQuizPage({super.key});

  @override
  State<AlphabetRecognitionQuizPage> createState() =>
      _AlphabetRecognitionQuizPageState();
}

class _AlphabetRecognitionQuizPageState
    extends State<AlphabetRecognitionQuizPage> {
  List<QuizQuestion> _questions = [];
  bool _isLoading = true;

  int _currentIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    await AlphabetQuizData.ensureLoaded();
    if (mounted) {
      setState(() {
        _questions = AlphabetQuizData.recognitionQuestions;
        _isLoading = false;
      });
    }
  }

  void _selectAnswer(String answer) {
    if (_answered || _questions.isEmpty) return;
    final correct = _questions[_currentIndex].correct;

    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      if (answer == correct) _score++;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    final text = Theme.of(context).textTheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('第 1 级完成', style: text.titleLarge),
        content: Text(
          '你本次答对了 $_score / ${_questions.length} 题。',
          style: text.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 0;
                _score = 0;
                _selectedAnswer = null;
                _answered = false;
              });
            },
            child: const Text('再练一次'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('返回'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_questions.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('暂无字母识别练习内容'),
        ),
      );
    }

    final q = _questions[_currentIndex];

    return QuizScaffold(
      levelTitle: '第 1 级：字母识别',
      subtitle: '看字母选名称、看名称选字母',
      currentIndex: _currentIndex,
      total: _questions.length,
      questionTitle: q.title,
      prompt: q.prompt,
      promptType: q.promptType,
      options: q.options,
      correct: q.correct,
      selectedAnswer: _selectedAnswer,
      answered: _answered,
      onSelect: _selectAnswer,
      onNext: _nextQuestion,
    );
  }
}
