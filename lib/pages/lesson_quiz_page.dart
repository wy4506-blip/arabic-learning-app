import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../theme/app_theme.dart';

class LessonQuizPage extends StatefulWidget {
  final Lesson lesson;

  const LessonQuizPage({
    super.key,
    required this.lesson,
  });

  @override
  State<LessonQuizPage> createState() => _LessonQuizPageState();
}

class _LessonQuizPageState extends State<LessonQuizPage> {
  int _currentIndex = 0;
  String? _selectedAnswer;
  bool _submitted = false;
  int _score = 0;

  LessonExercise get _currentExercise => widget.lesson.exercises[_currentIndex];

  void _selectAnswer(String answer) {
    if (_submitted) return;
    setState(() {
      _selectedAnswer = answer;
    });
  }

  void _submitAnswer() {
    if (_selectedAnswer == null || _submitted) return;

    final isCorrect = _selectedAnswer == _currentExercise.correctAnswer;

    setState(() {
      _submitted = true;
      if (isCorrect) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < widget.lesson.exercises.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _submitted = false;
      });
    } else {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('练习完成'),
        content: Text(
          '你本次得分：$_score / ${widget.lesson.exercises.length}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            child: const Text('完成'),
          ),
        ],
      ),
    );
  }

  Color _optionBackground(String option) {
    if (!_submitted) {
      return _selectedAnswer == option
          ? AppTheme.softAccent
          : const Color(0xFFF2F2F7);
    }

    if (option == _currentExercise.correctAnswer) {
      return const Color(0xFFE8F7EC);
    }

    if (option == _selectedAnswer) {
      return const Color(0xFFFFECEB);
    }

    return const Color(0xFFF2F2F7);
  }

  Color _optionBorder(String option) {
    if (!_submitted) {
      return _selectedAnswer == option ? AppTheme.deepAccent : AppTheme.border;
    }

    if (option == _currentExercise.correctAnswer) {
      return const Color(0xFF34C759);
    }

    if (option == _selectedAnswer) {
      return const Color(0xFFFF6B57);
    }

    return AppTheme.border;
  }

  IconData? _optionIcon(String option) {
    if (!_submitted) return null;

    if (option == _currentExercise.correctAnswer) {
      return Icons.check_circle_rounded;
    }

    if (option == _selectedAnswer) {
      return Icons.cancel_rounded;
    }

    return null;
  }

  Color? _optionIconColor(String option) {
    if (!_submitted) return null;

    if (option == _currentExercise.correctAnswer) {
      return const Color(0xFF34C759);
    }

    if (option == _selectedAnswer) {
      return const Color(0xFFFF6B57);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final total = widget.lesson.exercises.length;
    final progress = total == 0 ? 0.0 : (_currentIndex + 1) / total;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('${widget.lesson.titleCn} · 练习'),
      ),
      body: total == 0
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  '当前课程还没有练习题。',
                  style: text.titleMedium,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '第 ${_currentIndex + 1} / $total 题',
                    style: text.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE9E9EE),
                      color: AppTheme.deepAccent,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppTheme.border,
                        width: 0.6,
                      ),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Text(
                      _currentExercise.question,
                      style: text.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _currentExercise.options.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final option = _currentExercise.options[index];
                        final icon = _optionIcon(option);
                        final iconColor = _optionIconColor(option);

                        return Material(
                          color: _optionBackground(option),
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => _selectAnswer(option),
                            child: Ink(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _optionBorder(option),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: text.bodyLarge?.copyWith(
                                        color: AppTheme.primaryText,
                                      ),
                                    ),
                                  ),
                                  if (icon != null)
                                    Icon(
                                      icon,
                                      color: iconColor,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!_submitted)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed:
                            _selectedAnswer == null ? null : _submitAnswer,
                        child: const Text('提交答案'),
                      ),
                    ),
                  if (_submitted)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _nextQuestion,
                        child: Text(
                          _currentIndex == total - 1 ? '完成练习' : '下一题',
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
