import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/lesson_content_localizer.dart';
import '../l10n/lesson_localizer.dart';
import '../l10n/localized_text.dart';
import '../models/lesson.dart';
import '../models/lesson_practice_item.dart';
import '../services/audio_service.dart';
import '../services/lesson_practice_service.dart';
import '../theme/app_arabic_typography.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class LessonQuizResult {
  final int score;
  final int totalQuestions;

  const LessonQuizResult({
    required this.score,
    required this.totalQuestions,
  });

  double get accuracy {
    if (totalQuestions <= 0) {
      return 0;
    }
    return score / totalQuestions;
  }

  bool reachedThreshold(double threshold) => accuracy >= threshold;
}

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
  late final List<LessonPracticeItem> _items;
  late final List<String> _characterBank;

  int _currentIndex = 0;
  String? _selectedAnswer;
  String _typedAnswer = '';
  bool _submitted = false;
  int _score = 0;

  LessonPracticeItem get _currentItem => _items[_currentIndex];

  @override
  void initState() {
    super.initState();
    _items = LessonPracticeService.buildItems(widget.lesson);
    _characterBank = LessonPracticeService.buildCharacterBank(widget.lesson);
    _autoplayCurrentIfNeeded();
  }

  @override
  void dispose() {
    AudioService.stop();
    super.dispose();
  }

  String _lessonText(String value) {
    return LessonContentLocalizer.meaning(
      value,
      context.surfaceMeaningLanguage,
    );
  }

  String _appText({
    required String zh,
    required String en,
  }) {
    return localizedText(context, zh: zh, en: en);
  }

  Future<void> _autoplayCurrentIfNeeded() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _items.isEmpty || !_currentItem.requiresAudio) return;
      await _playCurrentAudio();
    });
  }

  Future<void> _playCurrentAudio() async {
    final audioText = _currentItem.audioText ?? _currentItem.correctAnswer;

    try {
      switch (_currentItem.audioScope) {
        case LessonPracticeAudioScope.alphabet:
          await AudioService.playLearningText(
            LearningAudioRequest.alphabet(
              type: _currentItem.audioType ?? 'word',
              textAr: audioText,
              textPlain: audioText,
              debugLabel: 'lesson_quiz_alphabet_audio',
            ),
          );
          return;
        case LessonPracticeAudioScope.lesson:
          await AudioService.playLearningText(
            LearningAudioRequest.lesson(
              lessonSequence: widget.lesson.sequence,
              type: _currentItem.audioType ?? 'sentence',
              asset: _currentItem.audioAsset,
              textAr: audioText,
              textPlain: audioText,
              debugLabel: 'lesson_quiz_lesson_audio',
            ),
          );
          return;
      }
    } catch (_) {
      // Audio unavailable — ignore gracefully in quiz context.
    }
  }

  void _selectAnswer(String answer) {
    if (_submitted) return;
    setState(() => _selectedAnswer = answer);
  }

  void _appendCharacter(String character) {
    if (_submitted) return;
    setState(() => _typedAnswer += character);
  }

  void _removeCharacter() {
    if (_submitted || _typedAnswer.isEmpty) return;
    setState(
      () => _typedAnswer = _typedAnswer.substring(0, _typedAnswer.length - 1),
    );
  }

  void _clearTypedAnswer() {
    if (_submitted || _typedAnswer.isEmpty) return;
    setState(() => _typedAnswer = '');
  }

  bool get _canSubmit {
    if (_currentItem.requiresWriting) {
      return _typedAnswer.trim().isNotEmpty;
    }
    return _selectedAnswer != null;
  }

  String get _currentAnswer {
    return _currentItem.requiresWriting
        ? _typedAnswer
        : (_selectedAnswer ?? '');
  }

  bool get _isCorrect {
    return _normalize(_currentAnswer) == _normalize(_currentItem.correctAnswer);
  }

  void _submitAnswer() {
    if (!_canSubmit || _submitted) return;

    setState(() {
      _submitted = true;
      if (_isCorrect) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    AudioService.stop();
    if (_currentIndex < _items.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _typedAnswer = '';
        _submitted = false;
      });
      _autoplayCurrentIfNeeded();
    } else {
      _showResultDialog();
    }
  }

  String _normalize(String value) {
    return removeArabicDiacritics(value).replaceAll(RegExp(r'\s+'), '').trim();
  }

  void _showResultDialog() {
    final result = LessonQuizResult(
      score: _score,
      totalQuestions: _items.length,
    );
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(_appText(zh: '练习完成', en: 'Practice Complete')),
        content: Text(
          _appText(
            zh: '本次得分：$_score / ${_items.length}',
            en: 'Score: $_score / ${_items.length}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, result);
            },
            child: Text(_appText(zh: '完成', en: 'Done')),
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

    if (_normalize(option) == _normalize(_currentItem.correctAnswer)) {
      return const Color(0xFFE8F7EC);
    }

    if (_normalize(option) == _normalize(_selectedAnswer ?? '')) {
      return const Color(0xFFFFECEB);
    }

    return const Color(0xFFF2F2F7);
  }

  Color _optionBorder(String option) {
    if (!_submitted) {
      return _selectedAnswer == option ? AppTheme.deepAccent : AppTheme.border;
    }

    if (_normalize(option) == _normalize(_currentItem.correctAnswer)) {
      return const Color(0xFF34C759);
    }

    if (_normalize(option) == _normalize(_selectedAnswer ?? '')) {
      return const Color(0xFFFF6B57);
    }

    return AppTheme.border;
  }

  IconData? _optionIcon(String option) {
    if (!_submitted) return null;

    if (_normalize(option) == _normalize(_currentItem.correctAnswer)) {
      return Icons.check_circle_rounded;
    }

    if (_normalize(option) == _normalize(_selectedAnswer ?? '')) {
      return Icons.cancel_rounded;
    }

    return null;
  }

  Color? _optionIconColor(String option) {
    if (!_submitted) return null;

    if (_normalize(option) == _normalize(_currentItem.correctAnswer)) {
      return const Color(0xFF34C759);
    }

    if (_normalize(option) == _normalize(_selectedAnswer ?? '')) {
      return const Color(0xFFFF6B57);
    }

    return null;
  }

  List<String> get _writeBank {
    final bank = <String>{..._characterBank};
    for (final char in _currentItem.correctAnswer.split('')) {
      if (RegExp(r'[\u0621-\u064A\u066E-\u06D3]').hasMatch(char)) {
        bank.add(char);
      }
    }
    return bank.toList();
  }

  String _displayOption(String option) {
    if (AppArabicTypography.isArabic(option)) {
      return option;
    }
    return _lessonText(option);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final total = _items.length;
    final progress = total == 0 ? 0.0 : (_currentIndex + 1) / total;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          _appText(
            zh: '${LessonLocalizer.title(widget.lesson, context.appSettings.appLanguage)} · 练习',
            en: '${LessonLocalizer.title(widget.lesson, context.appSettings.appLanguage)} · Practice',
          ),
        ),
      ),
      body: total == 0
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  _appText(
                    zh: '当前课程还没有可用练习。',
                    en: 'This lesson does not have practice items yet.',
                  ),
                  style: text.titleMedium,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Pill(label: _lessonText(_currentItem.title)),
                      const Spacer(),
                      Text(
                        _appText(
                          zh: '第 ${_currentIndex + 1} / $total 题',
                          en: 'Question ${_currentIndex + 1} / $total',
                        ),
                        style: text.titleMedium,
                      ),
                    ],
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
                  const SizedBox(height: 18),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _lessonText(_currentItem.prompt),
                          style: text.titleLarge,
                        ),
                        if (_currentItem.helperText != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _lessonText(_currentItem.helperText!),
                            style: text.bodyMedium,
                          ),
                        ],
                        if (_currentItem.requiresAudio) ...[
                          const SizedBox(height: 14),
                          OutlinedButton.icon(
                            onPressed: _playCurrentAudio,
                            icon: const Icon(Icons.volume_up_rounded),
                            label: Text(
                              _appText(zh: '播放音频', en: 'Play Audio'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: _currentItem.requiresWriting
                        ? _WritingPracticePanel(
                            currentInput: _typedAnswer,
                            correctAnswer: _currentItem.correctAnswer,
                            explanation: _currentItem.explanation == null
                                ? null
                                : _lessonText(_currentItem.explanation!),
                            submitted: _submitted,
                            isCorrect: _isCorrect,
                            bank: _writeBank,
                            onAppend: _appendCharacter,
                            onBackspace: _removeCharacter,
                            onClear: _clearTypedAnswer,
                          )
                        : ListView.separated(
                            itemCount: _currentItem.options.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final option = _currentItem.options[index];
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
                                          child: _PracticeText(
                                            _displayOption(option),
                                            style: text.bodyLarge?.copyWith(
                                              color: AppTheme.primaryText,
                                            ),
                                          ),
                                        ),
                                        if (icon != null)
                                          Icon(icon, color: iconColor),
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
                        onPressed: _canSubmit ? _submitAnswer : null,
                        child: Text(
                          _appText(
                            zh: '提交答案',
                            en: 'Submit Answer',
                          ),
                        ),
                      ),
                    ),
                  if (_submitted)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _nextQuestion,
                        child: Text(
                          _currentIndex == total - 1
                              ? _appText(zh: '完成练习', en: 'Finish Practice')
                              : _appText(zh: '下一题', en: 'Next Question'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _WritingPracticePanel extends StatelessWidget {
  final String currentInput;
  final String correctAnswer;
  final String? explanation;
  final bool submitted;
  final bool isCorrect;
  final List<String> bank;
  final ValueChanged<String> onAppend;
  final VoidCallback onBackspace;
  final VoidCallback onClear;

  const _WritingPracticePanel({
    required this.currentInput,
    required this.correctAnswer,
    required this.explanation,
    required this.submitted,
    required this.isCorrect,
    required this.bank,
    required this.onAppend,
    required this.onBackspace,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return ListView(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: submitted
                  ? (isCorrect
                      ? const Color(0xFF34C759)
                      : const Color(0xFFFF6B57))
                  : AppTheme.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizedText(
                  context,
                  zh: '你的答案',
                  en: 'Your Answer',
                ),
                style: text.titleSmall,
              ),
              const SizedBox(height: 8),
              _PracticeText(
                currentInput.isEmpty
                    ? localizedText(
                        context,
                        zh: '点击下方字母开始输入',
                        en: 'Tap a letter below to start typing',
                      )
                    : currentInput,
                style: currentInput.isEmpty
                    ? text.bodyMedium
                    : text.headlineMedium?.copyWith(height: 1.2),
              ),
              if (submitted) ...[
                const SizedBox(height: 14),
                Text(
                  localizedText(
                    context,
                    zh: isCorrect ? '回答正确' : '正确答案',
                    en: isCorrect ? 'Correct Answer' : 'Correct Form',
                  ),
                  style: text.titleSmall?.copyWith(
                    color: isCorrect
                        ? const Color(0xFF25864B)
                        : const Color(0xFFCB4D3E),
                  ),
                ),
                const SizedBox(height: 6),
                ArabicText.word(
                  correctAnswer,
                  style: const TextStyle(
                    fontSize: 28,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (explanation != null) ...[
                  const SizedBox(height: 4),
                  Text(explanation!, style: text.bodyMedium),
                ],
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (!submitted)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onBackspace,
                  icon: const Icon(Icons.backspace_outlined),
                  label: Text(
                    localizedText(
                      context,
                      zh: '退格',
                      en: 'Backspace',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.clear_rounded),
                  label: Text(
                    localizedText(
                      context,
                      zh: '清空',
                      en: 'Clear',
                    ),
                  ),
                ),
              ),
            ],
          ),
        if (!submitted) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: bank
                .map(
                  (character) => InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => onAppend(character),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.strokeLight),
                      ),
                      child: ArabicText.word(
                        character,
                        style: const TextStyle(
                          fontSize: 24,
                          height: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _PracticeText extends StatelessWidget {
  final String value;
  final TextStyle? style;

  const _PracticeText(
    this.value, {
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (AppArabicTypography.isArabic(value)) {
      return ArabicText.word(
        value,
        style: style,
      );
    }

    return Text(value, style: style);
  }
}
