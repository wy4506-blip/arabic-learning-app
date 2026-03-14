import 'package:flutter/material.dart';

import '../l10n/localized_text.dart';
import '../models/quiz_question.dart';
import '../services/audio_service.dart';
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

  @override
  void dispose() {
    AudioService.stop();
    super.dispose();
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
      _autoplayCurrentPromptIfNeeded();
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
    if (_questions.isEmpty) return;

    AudioService.stop();

    if (_currentIndex + 1 < _questions.length) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
      _autoplayCurrentPromptIfNeeded();
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
    _autoplayCurrentPromptIfNeeded();
  }

  QuizQuestion get _currentQuestion => _questions[_currentIndex];

  bool _isAudioPrompt(QuizQuestion question) {
    return question.promptType == 'letter_audio' ||
        question.promptType == 'pronunciation_audio';
  }

  Future<void> _playPromptAudio() async {
    if (_questions.isEmpty) return;

    final question = _currentQuestion;
    switch (question.promptType) {
      case 'letter_audio':
        await AudioService.speakLetter(question.prompt);
        return;
      case 'pronunciation_audio':
        await AudioService.speakPronunciation(question.prompt);
        return;
      default:
        return;
    }
  }

  void _autoplayCurrentPromptIfNeeded() {
    if (_questions.isEmpty || !_isAudioPrompt(_currentQuestion)) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _questions.isEmpty) return;
      if (!_isAudioPrompt(_currentQuestion)) return;
      await _playPromptAudio();
    });
  }

  void _showResultDialog() {
    AudioService.stop();
    final text = Theme.of(context).textTheme;
    final total = _questions.length;
    final rate = total == 0 ? 0 : ((_score / total) * 100).round();

    showDialog<void>(
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
              localizedText(
                context,
                zh: '本次答对 $_score / $total 题',
                en: 'You answered $_score / $total correctly',
              ),
              style: text.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              localizedText(
                context,
                zh: '正确率：$rate%',
                en: 'Accuracy: $rate%',
              ),
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
            child: Text(
              localizedText(
                context,
                zh: '再练一次',
                en: 'Retry',
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: Text(
              localizedText(
                context,
                zh: '返回',
                en: 'Back',
              ),
            ),
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
      onPlayPromptAudio: _isAudioPrompt(q) ? _playPromptAudio : null,
    );
  }
}
