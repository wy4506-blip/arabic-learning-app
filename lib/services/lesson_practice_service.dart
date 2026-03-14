import 'dart:math';

import '../models/lesson.dart';
import '../models/lesson_content_parts.dart';
import '../models/lesson_practice_item.dart';
import '../widgets/app_widgets.dart';

class LessonPracticeService {
  LessonPracticeService._();

  static List<LessonPracticeItem> buildItems(Lesson lesson) {
    final random = Random(lesson.id.hashCode);
    final baseItems = lesson.exercises
        .map(
          (exercise) => LessonPracticeItem(
            type: LessonPracticeType.choice,
            title: '理解选择',
            prompt: exercise.question,
            options: exercise.options,
            correctAnswer: exercise.correctAnswer,
          ),
        )
        .toList();

    final extraItems = <LessonPracticeItem>[];
    final letters = lesson.letters
        .map((item) => removeArabicDiacritics(item).trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();

    if (letters.isNotEmpty) {
      final targetLetter = letters[random.nextInt(letters.length)];
      extraItems.add(
        LessonPracticeItem(
          type: LessonPracticeType.audioChoice,
          title: '听音辨字',
          prompt: '听音后选择对应字母',
          options: _pickOptions(
            correct: targetLetter,
            pool: letters,
            random: random,
            maxCount: 4,
          ),
          correctAnswer: targetLetter,
          audioText: targetLetter,
          audioType: 'letter',
          audioScope: LessonPracticeAudioScope.alphabet,
          helperText: '可重复播放，先听清再选。',
        ),
      );
      extraItems.add(
        LessonPracticeItem(
          type: LessonPracticeType.audioWrite,
          title: '听写字母',
          prompt: '根据声音写出听到的字母',
          options: const <String>[],
          correctAnswer: targetLetter,
          audioText: targetLetter,
          audioType: 'letter',
          audioScope: LessonPracticeAudioScope.alphabet,
          helperText: '用下方字母板完成输入。',
        ),
      );
    }

    final words = lesson.vocabulary
        .where((word) => word.arabic.trim().isNotEmpty)
        .toList();
    final patterns = lesson.patterns
        .where(
          (pattern) =>
              pattern.text.preferred.trim().isNotEmpty &&
              pattern.meaning.primary.trim().isNotEmpty,
        )
        .toList();

    if (patterns.length > 1) {
      final targetPattern = patterns[random.nextInt(patterns.length)];
      final meaningPool = patterns
          .map((pattern) => pattern.meaning.primary.trim())
          .where((item) => item.isNotEmpty)
          .toSet()
          .toList();

      extraItems.add(
        LessonPracticeItem(
          type: LessonPracticeType.audioChoice,
          title: '听音选义',
          prompt: '听音后选择最接近的中文意思',
          options: _pickOptions(
            correct: targetPattern.meaning.primary.trim(),
            pool: meaningPool,
            random: random,
            maxCount: 4,
          ),
          correctAnswer: targetPattern.meaning.primary.trim(),
          audioAsset: targetPattern.audioRef.asset,
          audioText: targetPattern.text.plain.trim(),
          audioType: 'sentence',
          helperText: '先听完整句子，再判断它对应的中文意思。',
        ),
      );
    }

    if (words.isNotEmpty) {
      final targetWord = words[random.nextInt(words.length)];
      final wordPool = words
          .map((word) => word.text.plain.trim())
          .where((item) => item.isNotEmpty)
          .toSet()
          .toList();
      final normalizedTarget = targetWord.text.plain.trim();

      extraItems.add(
        LessonPracticeItem(
          type: LessonPracticeType.audioChoice,
          title: '听音辨词',
          prompt: '听音后选择对应单词',
          options: _pickOptions(
            correct: normalizedTarget,
            pool: wordPool,
            random: random,
            maxCount: 4,
          ),
          correctAnswer: normalizedTarget,
          audioAsset: targetWord.audioRef.asset,
          audioText: normalizedTarget,
          audioType: 'word',
          helperText: '本题考察声音和词形的对应。',
          explanation: targetWord.meaning.primary,
        ),
      );
      extraItems.add(
        LessonPracticeItem(
          type: LessonPracticeType.audioWrite,
          title: '听写单词',
          prompt: '根据声音写出听到的单词',
          options: const <String>[],
          correctAnswer: normalizedTarget,
          audioAsset: targetWord.audioRef.asset,
          audioText: normalizedTarget,
          audioType: 'word',
          helperText: '先听，再用字母板拼出完整单词。',
          explanation: targetWord.meaning.primary,
        ),
      );
    }

    extraItems.addAll(_buildMorphologyItems(words, random));

    return _interleave(baseItems, extraItems);
  }

  static List<String> buildCharacterBank(Lesson lesson) {
    final characters = <String>{};
    final sources = <String>[
      ...lesson.letters,
      ...lesson.vocabulary.map((word) => word.arabic),
      ...lesson.patterns.map((pattern) => pattern.arabic),
      ...lesson.dialogues.map((line) => line.arabic),
    ];

    for (final source in sources) {
      for (final char in removeArabicDiacritics(source).characters) {
        if (_isArabicLetter(char)) {
          characters.add(char);
        }
      }
    }

    return characters.toList();
  }

  static int countFor(Lesson lesson) {
    return buildItems(lesson).length;
  }

  static List<String> _pickOptions({
    required String correct,
    required List<String> pool,
    required Random random,
    required int maxCount,
  }) {
    final options = <String>[correct];
    final others = pool.where((item) => item != correct).toSet().toList();
    others.shuffle(random);
    options.addAll(others.take(maxCount - 1));
    options.shuffle(random);
    return options;
  }

  static List<LessonPracticeItem> _buildMorphologyItems(
    List<LessonWord> words,
    Random random,
  ) {
    final items = <LessonPracticeItem>[];
    final optionPool = _buildMorphologyOptionPool(words);

    final genderWords = words
        .where(
          (word) =>
              _preferredText(word.feminineForm) != null ||
              _preferredText(word.masculineForm) != null,
        )
        .toList();
    if (genderWords.isNotEmpty) {
      final target = genderWords[random.nextInt(genderWords.length)];
      final feminine = _preferredText(target.feminineForm);
      final masculine = _preferredText(target.masculineForm);
      final askForFeminine = feminine != null;
      final correct = feminine ?? masculine;
      if (correct == null) {
        return items;
      }
      final prompt = askForFeminine
          ? '“${target.arabic}” 的阴性对应形式是？'
          : '“${target.arabic}” 的阳性对应形式是？';

      items.add(
        LessonPracticeItem(
          type: LessonPracticeType.choice,
          title: '词形配对',
          prompt: prompt,
          options: _pickOptions(
            correct: correct,
            pool: optionPool,
            random: random,
            maxCount: 4,
          ),
          correctAnswer: correct,
          helperText: '先判断词的性，再选择对应词形。',
        ),
      );
    }

    final pluralWords = words
        .where(
          (word) => _preferredText(word.pluralForm) != null,
        )
        .toList();
    if (pluralWords.isNotEmpty) {
      final target = pluralWords[random.nextInt(pluralWords.length)];
      final correct = _preferredText(target.pluralForm)!;

      items.add(
        LessonPracticeItem(
          type: LessonPracticeType.choice,
          title: '单复数配对',
          prompt: '“${target.arabic}” 的复数形式是？',
          options: _pickOptions(
            correct: correct,
            pool: optionPool,
            random: random,
            maxCount: 4,
          ),
          correctAnswer: correct,
          helperText: '高频可数词建议把单数和复数一起记。',
        ),
      );
    }

    final exampleWords = words
        .where(
          (word) =>
              (word.example?.text.hasValue ?? false) &&
              word.text.preferred.trim().isNotEmpty,
        )
        .toList();
    if (exampleWords.isNotEmpty) {
      final target = exampleWords[random.nextInt(exampleWords.length)];
      final sentence = _blankedExampleSentence(target);
      final familyPool = <String>{
        target.text.preferred,
        if (_preferredText(target.feminineForm) != null)
          _preferredText(target.feminineForm)!,
        if (_preferredText(target.masculineForm) != null)
          _preferredText(target.masculineForm)!,
        if (_preferredText(target.pluralForm) != null)
          _preferredText(target.pluralForm)!,
        ...optionPool,
      }.toList();
      final helperLines = <String>[
        if (sentence.isNotEmpty) sentence,
        if (target.example?.meaning.primary.trim().isNotEmpty ?? false)
          target.example!.meaning.primary,
      ];

      items.add(
        LessonPracticeItem(
          type: LessonPracticeType.choice,
          title: '例句选形',
          prompt: '根据例句选择正确词形',
          options: _pickOptions(
            correct: target.text.preferred,
            pool: familyPool,
            random: random,
            maxCount: 4,
          ),
          correctAnswer: target.text.preferred,
          helperText: helperLines.join('\n'),
        ),
      );
    }

    return items;
  }

  static List<String> _buildMorphologyOptionPool(List<LessonWord> words) {
    return words
        .expand(
          (word) => <String>[
            word.text.preferred,
            word.text.plain,
            if (_preferredText(word.feminineForm) != null)
              _preferredText(word.feminineForm)!,
            if (_preferredText(word.masculineForm) != null)
              _preferredText(word.masculineForm)!,
            if (_preferredText(word.pluralForm) != null)
              _preferredText(word.pluralForm)!,
          ],
        )
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
  }

  static String? _preferredText(LessonArabicText? text) {
    final value = text?.preferred.trim();
    return value == null || value.isEmpty ? null : value;
  }

  static String _blankedExampleSentence(LessonWord word) {
    final sentence = word.example?.text.preferred.trim() ?? '';
    if (sentence.isEmpty) return '';
    if (sentence.contains(word.text.preferred)) {
      return sentence.replaceFirst(word.text.preferred, '____');
    }
    if (word.text.plain.isNotEmpty && sentence.contains(word.text.plain)) {
      return sentence.replaceFirst(word.text.plain, '____');
    }
    return sentence;
  }

  static List<LessonPracticeItem> _interleave(
    List<LessonPracticeItem> baseItems,
    List<LessonPracticeItem> extraItems,
  ) {
    if (extraItems.isEmpty) return baseItems;
    if (baseItems.isEmpty) return extraItems;

    final mixed = <LessonPracticeItem>[];
    var extraIndex = 0;

    for (final item in baseItems) {
      mixed.add(item);
      if (extraIndex < extraItems.length) {
        mixed.add(extraItems[extraIndex]);
        extraIndex++;
      }
    }

    mixed.addAll(extraItems.skip(extraIndex));
    return mixed;
  }

  static bool _isArabicLetter(String char) {
    return RegExp(r'[\u0621-\u064A\u066E-\u06D3]').hasMatch(char);
  }
}

extension on String {
  Iterable<String> get characters sync* {
    for (var index = 0; index < length; index++) {
      yield this[index];
    }
  }
}
