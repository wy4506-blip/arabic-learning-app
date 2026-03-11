import 'package:flutter/material.dart';
import '../models/quiz_question.dart';
import 'quiz_scaffold.dart';

class GenericQuizPage extends StatefulWidget {
  final String levelTitle;
  final String subtitle;
  final String resultTitle;
  final String emptyText;
  final List<QuizQuestion> questions;
  final Future<List<QuizQuestion>>? Function()? questionsLoader;

  const GenericQuizPage({
    super.key,
    required this.levelTitle,
    required this.subtitle,
    required this.resultTitle,
    required this.emptyText,
    required this.questions,
    this.questionsLoader,
  });

  @override
  State<GenericQuizPage> createState() => _GenericQuizPageState();
}

class _GenericQuizPageState extends State<GenericQuizPage> {
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
    List<QuizQuestion> questions;
    
    if (widget.questionsLoader != null) {
      questions = await widget.questionsLoader!() ?? [];
    } else {
      questions = widget.questions;
    }
    
    if (mounted) {
      setState(() {
        _questions = questions;
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
      if (answer == correct) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (widget.questions.isEmpty) return;

    if (_currentIndex + 1 < widget.questions.length) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      _showResultDialog();
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _selectedAnswer = null;
      _answered = false;
    });
  }

  void _showResultDialog() {
    final text = Theme.of(context).textTheme;
    final total = widget.questions.length;
    final rate = total == 0 ? 0 : ((_score / total) * 100).round();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(widget.resultTitle, style: text.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '你本次答对了 $_score / $total 题。',
              style: text.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '正确率：$rate%',
              style: text.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _restartQuiz();
            },
            child: const Text('再练一次'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
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
      return Scaffold(
        body: Center(
          child: Text(widget.emptyText),
        ),
      );
    }

    final q = _questions[_currentIndex];

    return QuizScaffold(
      levelTitle: widget.levelTitle,
      subtitle: widget.subtitle,
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
