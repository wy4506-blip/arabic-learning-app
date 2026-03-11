import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AlphabetQuizPage extends StatefulWidget {
  const AlphabetQuizPage({super.key});

  @override
  State<AlphabetQuizPage> createState() => _AlphabetQuizPageState();
}

class _AlphabetQuizPageState extends State<AlphabetQuizPage> {
  final List<Map<String, dynamic>> _questions = [
    {
      'arabic': 'ب',
      'correct': 'Ba',
      'options': ['Ba', 'Ta', 'Jim'],
    },
    {
      'arabic': 'ت',
      'correct': 'Ta',
      'options': ['Tha', 'Ta', 'Ra'],
    },
    {
      'arabic': 'ث',
      'correct': 'Tha',
      'options': ['Ba', 'Tha', 'Kha'],
    },
    {
      'arabic': 'ج',
      'correct': 'Jim',
      'options': ['Jim', 'Ha', 'Dal'],
    },
    {
      'arabic': 'ح',
      'correct': 'Ha',
      'options': ['Kha', 'Ha', 'Zay'],
    },
    {
      'arabic': 'خ',
      'correct': 'Kha',
      'options': ['Jim', 'Kha', 'Ra'],
    },
  ];

  int _currentIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _answered = false;

  void _selectAnswer(String answer) {
    if (_answered) return;

    final correct = _questions[_currentIndex]['correct'] as String;

    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      if (answer == correct) {
        _score++;
      }
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
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text('练习完成', style: text.titleLarge),
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final width = MediaQuery.of(context).size.width;
    final bool isSmallScreen = width < 360;

    final question = _questions[_currentIndex];
    final arabic = question['arabic'] as String;
    final correct = question['correct'] as String;
    final options = question['options'] as List<String>;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            isSmallScreen ? 14 : 16,
            12,
            isSmallScreen ? 14 : 16,
            20,
          ),
          children: [
            Row(
              children: [
                _buildTopButton(
                  size: isSmallScreen ? 38 : 40,
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('字母练习', style: text.titleMedium),
                      const SizedBox(height: 1),
                      Text(
                        '看字母，选择正确名称',
                        style: text.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFEAF8F3),
                    Color(0xFFDFF2EB),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '第 ${_currentIndex + 1} 题 / 共 ${_questions.length} 题',
                    style: text.labelLarge?.copyWith(
                      color: AppTheme.deepAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: (_currentIndex + 1) / _questions.length,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.deepAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '这个字母叫什么？',
                    style: text.titleMedium,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    arabic,
                    style: text.headlineLarge?.copyWith(
                      fontSize: isSmallScreen ? 56 : 64,
                      fontWeight: FontWeight.w700,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            ...options.map(
              (option) => _buildOptionCard(
                context,
                option: option,
                correct: correct,
                onTap: () => _selectAnswer(option),
              ),
            ),
            const SizedBox(height: 16),
            if (_answered)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.deepAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: _nextQuestion,
                  child: Text(
                    _currentIndex == _questions.length - 1 ? '查看结果' : '下一题',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static Widget _buildTopButton({
    required double size,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryText,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String option,
    required String correct,
    required VoidCallback onTap,
  }) {
    final text = Theme.of(context).textTheme;

    final bool isSelected = _selectedAnswer == option;
    final bool isCorrect = option == correct;

    Color bgColor = Colors.white;
    Color borderColor = const Color(0xFFE5E7EB);
    IconData? trailingIcon;

    if (_answered) {
      if (isCorrect) {
        bgColor = const Color(0xFFEAF8F3);
        borderColor = AppTheme.deepAccent;
        trailingIcon = Icons.check_circle_rounded;
      } else if (isSelected) {
        bgColor = const Color(0xFFFFF1F2);
        borderColor = const Color(0xFFE11D48);
        trailingIcon = Icons.cancel_rounded;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    option,
                    style: text.titleMedium,
                  ),
                ),
                if (trailingIcon != null)
                  Icon(
                    trailingIcon,
                    color: isCorrect
                        ? AppTheme.deepAccent
                        : const Color(0xFFE11D48),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
