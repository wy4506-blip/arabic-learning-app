import 'dart:convert';
import 'dart:io';

import 'package:arabic_learning_app/data/sample_alphabet_data.dart';
import 'package:arabic_learning_app/data/sample_lessons.dart';
import 'package:arabic_learning_app/models/lesson.dart';

const Set<String> _reviewStatuses = <String>{
  'draft',
  'ai_generated',
  'reviewed',
  'approved',
  'published',
  'deprecated',
};

const Set<String> _audioReviewStatuses = <String>{
  'pending',
  'reviewed',
  'approved',
  'rejected',
};

const Set<String> _quizTypes = <String>{
  'multiple_choice',
  'true_false',
  'matching',
  'fill_blank',
  'listen_select',
};

const Set<String> _allowedAudioTypes = <String>{
  'word',
  'sentence',
  'letter',
  'phrase',
  'dialogue',
  'pronunciation',
};

const Set<String> _allowedAudioExtensions = <String>{
  '.mp3',
  '.wav',
  '.m4a',
  '.ogg',
};

const Set<String> _allowedPartOfSpeech = <String>{
  'noun',
  'verb',
  'adjective',
  'pronoun',
  'preposition',
  'particle',
  'phrase',
  'expression',
};

Future<void> main(List<String> args) async {
  final config = _Config.fromArgs(args);
  if (config.showHelp) {
    _printUsage();
    return;
  }

  final result = runContentValidation(
    root: Directory.current,
    strictRelease: config.strictRelease,
    warningThreshold: config.warningThreshold,
    printOutput: true,
  );
  exitCode = result.exitCode;
}

void _printUsage() {
  stdout.writeln('''
Content validator for arabic_learning_app

Usage:
  dart run tool/validate_content.dart [options]

Options:
  --strict-release
  --warning-threshold=N
  --help
''');
}

class _Config {
  final bool strictRelease;
  final int warningThreshold;
  final bool showHelp;

  const _Config({
    required this.strictRelease,
    required this.warningThreshold,
    required this.showHelp,
  });

  static _Config fromArgs(List<String> args) {
    var strictRelease = false;
    var warningThreshold = 0;
    var showHelp = false;

    for (final arg in args) {
      if (arg == '--strict-release') {
        strictRelease = true;
      } else if (arg.startsWith('--warning-threshold=')) {
        warningThreshold =
            int.tryParse(arg.substring('--warning-threshold='.length)) ?? 0;
      } else if (arg == '--help' || arg == '-h') {
        showHelp = true;
      } else {
        stderr.writeln('Unknown argument: $arg');
        showHelp = true;
      }
    }

    return _Config(
      strictRelease: strictRelease,
      warningThreshold: warningThreshold,
      showHelp: showHelp,
    );
  }
}

class ContentValidationResult {
  final int errorCount;
  final int warningCount;
  final int infoCount;
  final int exitCode;
  final List<String> lines;

  const ContentValidationResult({
    required this.errorCount,
    required this.warningCount,
    required this.infoCount,
    required this.exitCode,
    required this.lines,
  });
}

ContentValidationResult runContentValidation({
  Directory? root,
  bool strictRelease = false,
  int warningThreshold = 0,
  bool printOutput = false,
}) {
  final config = _Config(
    strictRelease: strictRelease,
    warningThreshold: warningThreshold,
    showHelp: false,
  );
  final report = _Report(config);
  final validator = _Validator(
    root: root ?? Directory.current,
    config: config,
    report: report,
  );
  validator.run();
  if (printOutput) {
    report.printSummary();
  }
  return report.toResult();
}

enum _Level { error, warning, info }

class _Issue {
  final _Level level;
  final String rule;
  final String target;
  final String message;

  const _Issue(this.level, this.rule, this.target, this.message);
}

class _Report {
  final _Config config;
  final List<_Issue> issues = <_Issue>[];

  _Report(this.config);

  void error(String rule, String target, String message) {
    issues.add(_Issue(_Level.error, rule, target, message));
  }

  void warning(String rule, String target, String message) {
    issues.add(_Issue(_Level.warning, rule, target, message));
  }

  void info(String rule, String target, String message) {
    issues.add(_Issue(_Level.info, rule, target, message));
  }

  int get errorCount => issues.where((item) => item.level == _Level.error).length;
  int get warningCount =>
      issues.where((item) => item.level == _Level.warning).length;
  int get infoCount => issues.where((item) => item.level == _Level.info).length;

  int get exitCode {
    if (errorCount > 0) return 1;
    if (config.strictRelease && warningCount > config.warningThreshold) {
      return 2;
    }
    return 0;
  }

  List<String> buildLines() {
    final lines = <String>[];
    for (final issue in issues) {
      final prefix = switch (issue.level) {
        _Level.error => 'ERROR',
        _Level.warning => 'WARNING',
        _Level.info => 'INFO',
      };
      lines.add('[$prefix] ${issue.rule} ${issue.target}: ${issue.message}');
    }

    lines.add('');
    lines.add('Validation finished.');
    lines.add('Errors: $errorCount');
    lines.add('Warnings: $warningCount');
    lines.add('Info: $infoCount');

    if (exitCode != 0) {
      lines.add('');
      lines.add('Validation failed.');
      lines.add('exitCode = $exitCode');
    }
    return lines;
  }

  ContentValidationResult toResult() {
    return ContentValidationResult(
      errorCount: errorCount,
      warningCount: warningCount,
      infoCount: infoCount,
      exitCode: exitCode,
      lines: buildLines(),
    );
  }

  void printSummary() {
    for (final line in buildLines()) {
      stdout.writeln(line);
    }
  }
}

class _LessonRecord {
  final Lesson lesson;
  final String reviewStatus;

  const _LessonRecord(this.lesson, this.reviewStatus);
}

class _VocabRecord {
  final String id;
  final String? explicitId;
  final String lessonId;
  final LessonWord word;
  final String reviewStatus;
  final String source;

  const _VocabRecord({
    required this.id,
    required this.explicitId,
    required this.lessonId,
    required this.word,
    required this.reviewStatus,
    required this.source,
  });
}

class _SentenceRecord {
  final String id;
  final String lessonId;
  final String vocalized;
  final String plain;
  final String translationZh;
  final String transliteration;
  final String reviewStatus;
  final String ownerType;
  final String source;

  const _SentenceRecord({
    required this.id,
    required this.lessonId,
    required this.vocalized,
    required this.plain,
    required this.translationZh,
    required this.transliteration,
    required this.reviewStatus,
    required this.ownerType,
    required this.source,
  });
}

class _QuizRecord {
  final String id;
  final String lessonId;
  final String type;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String reviewStatus;
  final String source;

  const _QuizRecord({
    required this.id,
    required this.lessonId,
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.reviewStatus,
    required this.source,
  });
}

class _AudioOwner {
  final String ownerType;
  final String ownerId;
  final String vocalized;
  final String plain;
  final Set<String> acceptedVocalized;
  final String reviewStatus;
  final String source;

  const _AudioOwner({
    required this.ownerType,
    required this.ownerId,
    required this.vocalized,
    required this.plain,
    this.acceptedVocalized = const <String>{},
    required this.reviewStatus,
    required this.source,
  });
}

class _Validator {
  final Directory root;
  final _Config config;
  final _Report report;

  final Map<String, _LessonRecord> _lessons = <String, _LessonRecord>{};
  final Map<String, _VocabRecord> _vocabs = <String, _VocabRecord>{};
  final Map<String, _SentenceRecord> _sentences = <String, _SentenceRecord>{};
  final Map<String, _QuizRecord> _quizzes = <String, _QuizRecord>{};
  final Map<String, _AudioOwner> _audioOwners = <String, _AudioOwner>{};
  final Map<String, String> _globalIds = <String, String>{};

  List<dynamic> _grammarCategories = const <dynamic>[];
  List<dynamic> _grammarPages = const <dynamic>[];
  List<dynamic> _audioManifestItems = const <dynamic>[];

  _Validator({
    required this.root,
    required this.config,
    required this.report,
  });

  void run() {
    _loadJsonSources();
    _collectLessons();
    _collectAlphabetAudioOwners();
    _validateLessons();
    _validateVocabs();
    _validateSentences();
    _validateQuizzes();
    _validateAudioManifest();
    _validateGrammar();
    _validateCrossObjectConsistency();
  }

  void _loadJsonSources() {
    _grammarCategories = _loadJsonList(
      'assets/grammar/categories.json',
      target: 'grammar.categories',
      nonEmpty: true,
    );
    _grammarPages = _loadJsonList(
      'assets/grammar/pages.json',
      target: 'grammar.pages',
      nonEmpty: true,
    );

    final manifest = _loadJsonObject(
      'assets/data/audio_manifest.json',
      target: 'audio_manifest',
    );
    final items = manifest['items'];
    if (items is! List) {
      report.error('R002', 'audio_manifest.items', 'items 必须是数组。');
    } else if (items.isEmpty) {
      report.error('R003', 'audio_manifest.items', '音频清单不能为空。');
    } else {
      _audioManifestItems = items;
    }
  }

  List<dynamic> _loadJsonList(
    String relativePath, {
    required String target,
    required bool nonEmpty,
  }) {
    final decoded = _loadJson(relativePath, target: target);
    if (decoded is! List) {
      report.error('R002', target, '根节点必须是数组。');
      return const <dynamic>[];
    }
    if (nonEmpty && decoded.isEmpty) {
      report.error('R003', target, '核心内容集合不能为空。');
    }
    return decoded;
  }

  Map<String, dynamic> _loadJsonObject(
    String relativePath, {
    required String target,
  }) {
    final decoded = _loadJson(relativePath, target: target);
    if (decoded is! Map<String, dynamic>) {
      report.error('R002', target, '根节点必须是对象。');
      return <String, dynamic>{};
    }
    return decoded;
  }

  dynamic _loadJson(String relativePath, {required String target}) {
    final file = File('${root.path}${Platform.pathSeparator}$relativePath');
    if (!file.existsSync()) {
      report.error('R001', target, '文件不存在: $relativePath');
      return null;
    }

    try {
      return jsonDecode(file.readAsStringSync());
    } on FormatException catch (error) {
      report.error('R001', target, 'JSON 解析失败: ${error.message}');
    } on FileSystemException catch (error) {
      report.error('R001', target, '文件读取失败: ${error.message}');
    }
    return null;
  }

  void _collectLessons() {
    final orderToLesson = <int, String>{};

    for (final lesson in sampleLessons) {
      final target = 'lesson:${lesson.id.isEmpty ? '<missing>' : lesson.id}';
      _registerGlobalId(
        id: lesson.id,
        owner: target,
        rule: 'R005',
        duplicateMessage: 'lesson id 重复。',
      );

      _lessons[lesson.id] = _LessonRecord(lesson, 'published');

      if (orderToLesson.containsKey(lesson.sequence)) {
        report.error(
          'R103',
          target,
          'lesson.order 重复，和 ${orderToLesson[lesson.sequence]} 冲突。',
        );
      } else {
        orderToLesson[lesson.sequence] = lesson.id;
      }

      final seenPlainWords = <String, String>{};

      for (var index = 0; index < lesson.vocabulary.length; index++) {
        final word = lesson.vocabulary[index];
        final id = word.id ?? '${lesson.id}_word_${index + 1}';
        final source = '$target/vocab#$index';
        final record = _VocabRecord(
          id: id,
          explicitId: word.id,
          lessonId: lesson.id,
          word: word,
          reviewStatus: 'published',
          source: source,
        );
        _vocabs[id] = record;
        _registerGlobalId(
          id: id,
          owner: source,
          rule: 'R005',
          duplicateMessage: 'vocab id 重复。',
        );

        final normalizedPlain = _normalizeArabicText(word.plainArabic);
        if (normalizedPlain.isNotEmpty) {
          final previous = seenPlainWords[normalizedPlain];
          if (previous != null) {
            report.warning(
              'R210',
              source,
              '同一 lesson 内重复出现去音符词形，已与 $previous 重复。',
            );
          } else {
            seenPlainWords[normalizedPlain] = id;
          }
        }

        _audioOwners[id] = _AudioOwner(
          ownerType: 'vocab',
          ownerId: id,
          vocalized: word.arabic,
          plain: word.plainArabic,
          reviewStatus: 'published',
          source: source,
        );
      }

      for (var index = 0; index < lesson.patterns.length; index++) {
        final pattern = lesson.patterns[index];
        final id = '${lesson.id}_pattern_${index + 1}';
        final source = '$target/pattern#$index';
        final record = _SentenceRecord(
          id: id,
          lessonId: lesson.id,
          vocalized: pattern.arabic,
          plain: _stripArabicDiacritics(pattern.arabic),
          translationZh: pattern.chinese,
          transliteration: pattern.transliteration,
          reviewStatus: 'published',
          ownerType: 'pattern',
          source: source,
        );
        _sentences[id] = record;
        _registerGlobalId(
          id: id,
          owner: source,
          rule: 'R005',
          duplicateMessage: 'sentence id 重复。',
        );
        _audioOwners[id] = _AudioOwner(
          ownerType: 'sentence',
          ownerId: id,
          vocalized: record.vocalized,
          plain: record.plain,
          reviewStatus: record.reviewStatus,
          source: source,
        );
      }

      for (var index = 0; index < lesson.dialogues.length; index++) {
        final dialogue = lesson.dialogues[index];
        final id = '${lesson.id}_dialogue_${index + 1}';
        final source = '$target/dialogue#$index';
        final record = _SentenceRecord(
          id: id,
          lessonId: lesson.id,
          vocalized: dialogue.arabic,
          plain: _stripArabicDiacritics(dialogue.arabic),
          translationZh: dialogue.chinese,
          transliteration: dialogue.transliteration,
          reviewStatus: 'published',
          ownerType: 'dialogue',
          source: source,
        );
        _sentences[id] = record;
        _registerGlobalId(
          id: id,
          owner: source,
          rule: 'R005',
          duplicateMessage: 'sentence id 重复。',
        );
        _audioOwners[id] = _AudioOwner(
          ownerType: 'dialogue',
          ownerId: id,
          vocalized: record.vocalized,
          plain: record.plain,
          reviewStatus: record.reviewStatus,
          source: source,
        );
      }

      for (var index = 0; index < lesson.exercises.length; index++) {
        final quiz = lesson.exercises[index];
        final id = '${lesson.id}_quiz_${index + 1}';
        final source = '$target/quiz#$index';
        final record = _QuizRecord(
          id: id,
          lessonId: lesson.id,
          type: 'multiple_choice',
          question: quiz.question,
          options: quiz.options,
          correctAnswer: quiz.correctAnswer,
          reviewStatus: 'published',
          source: source,
        );
        _quizzes[id] = record;
        _registerGlobalId(
          id: id,
          owner: source,
          rule: 'R005',
          duplicateMessage: 'quiz id 重复。',
        );
      }
    }
  }

  void _collectAlphabetAudioOwners() {
    var letterIndex = 1;
    var pronunciationIndex = 1;
    var exampleWordIndex = 1;

    for (final group in sampleAlphabetGroups) {
      for (final letter in group.letters) {
        final pronunciationByKey = <String, dynamic>{
          for (final pronunciation in letter.pronunciations)
            pronunciation.key: pronunciation,
        };
        final legacyPronunciationTexts = <String>[
          pronunciationByKey['fatha']?.audioQueryText ?? '',
          pronunciationByKey['kasra']?.audioQueryText ?? '',
          pronunciationByKey['damma']?.audioQueryText ?? '',
          pronunciationByKey['long_a']?.audioQueryText ?? '',
          pronunciationByKey['long_i']?.audioQueryText ?? '',
          pronunciationByKey['long_u']?.audioQueryText ?? '',
          pronunciationByKey['sukun']?.audioQueryText ?? '',
          _legacyShaddaForm(letter.arabic, 'a'),
          _legacyShaddaForm(letter.arabic, 'i'),
          _legacyShaddaForm(letter.arabic, 'u'),
          pronunciationByKey['tanwin_an']?.audioQueryText ?? '',
          pronunciationByKey['tanwin_in']?.audioQueryText ?? '',
          pronunciationByKey['tanwin_un']?.audioQueryText ?? '',
        ];

        final letterId = 'alphabet_letter_$letterIndex';
        _audioOwners[letterId] = _AudioOwner(
          ownerType: 'letter',
          ownerId: letterId,
          vocalized: letter.arabic,
          plain: letter.arabic,
          reviewStatus: 'published',
          source: 'alphabet/group_${group.id}/letter_$letterIndex',
        );
        letterIndex++;

        for (var pronunciationOffset = 0;
            pronunciationOffset < letter.pronunciations.length;
            pronunciationOffset++) {
          final pronunciation = letter.pronunciations[pronunciationOffset];
          final pronunciationId = 'alphabet_pronunciation_$pronunciationIndex';
          final acceptedVocalized = <String>{
            pronunciation.form,
            pronunciation.audioQueryText,
          };
          if (pronunciationOffset < legacyPronunciationTexts.length) {
            final legacyText = legacyPronunciationTexts[pronunciationOffset];
            if (legacyText.isNotEmpty) {
              acceptedVocalized.add(legacyText);
            }
          }
          _audioOwners[pronunciationId] = _AudioOwner(
            ownerType: 'pronunciation',
            ownerId: pronunciationId,
            vocalized: pronunciation.form,
            plain: _stripArabicDiacritics(pronunciation.form),
            acceptedVocalized: acceptedVocalized,
            reviewStatus: 'published',
            source: 'alphabet/group_${group.id}/pronunciation_$pronunciationIndex',
          );
          pronunciationIndex++;
        }

        final exampleId = 'alphabet_example_word_$exampleWordIndex';
        _audioOwners[exampleId] = _AudioOwner(
          ownerType: 'word',
          ownerId: exampleId,
          vocalized: letter.example.arabic,
          plain: _stripArabicDiacritics(letter.example.arabic),
          reviewStatus: 'published',
          source: 'alphabet/group_${group.id}/example_$exampleWordIndex',
        );
        exampleWordIndex++;
      }
    }
  }

  void _registerGlobalId({
    required String id,
    required String owner,
    required String rule,
    required String duplicateMessage,
  }) {
    if (id.trim().isEmpty) {
      report.error('R004', owner, '对象缺少非空 id。');
      return;
    }

    final previous = _globalIds[id];
    if (previous != null) {
      report.error(rule, owner, '$duplicateMessage 已与 $previous 重复。');
      return;
    }
    _globalIds[id] = owner;
  }

  void _validateLessons() {
    for (final entry in _lessons.entries) {
      final lesson = entry.value.lesson;
      final target = 'lesson:${lesson.id}';

      if (lesson.id.trim().isEmpty ||
          lesson.titleCn.trim().isEmpty ||
          lesson.titleAr.trim().isEmpty) {
        report.error('R101', target, 'lesson 缺少必填字段 id/title。');
      }

      if (lesson.sequence <= 0) {
        report.error('R102', target, 'lesson.order 必须是正整数。');
      }

      if (lesson.vocabulary.isEmpty &&
          lesson.patterns.isEmpty &&
          lesson.dialogues.isEmpty) {
        report.error('R104', target, '正式 lesson 不允许没有任何教学内容。');
      }

      final sentenceCount = _sentences.values
          .where((item) => item.lessonId == lesson.id)
          .length;
      final quizCount =
          _quizzes.values.where((item) => item.lessonId == lesson.id).length;

      if (lesson.vocabulary.length < 3 || sentenceCount < 1 || quizCount < 1) {
        report.warning(
          'R703',
          target,
          '正式 lesson 建议至少具备 vocab>=3、sentence>=1、quiz>=1。',
        );
      }
    }
  }

  void _validateVocabs() {
    final plainToVocalized = <String, Set<String>>{};

    for (final record in _vocabs.values) {
      final word = record.word;
      final target = 'vocab:${record.id}';

      if (!_lessons.containsKey(record.lessonId)) {
        report.error('R202', target, 'lesson_id=${record.lessonId} 不存在。');
      }

      if (record.id.trim().isEmpty ||
          word.arabic.trim().isEmpty ||
          word.plainArabic.trim().isEmpty ||
          word.chinese.trim().isEmpty) {
        report.error('R201', target, 'vocab 缺少必填字段。');
      }

      if (!_containsArabic(word.arabic)) {
        report.error('R203', target, 'surface_vocalized 必须包含阿语字符。');
      }

      if (!_containsArabic(word.plainArabic)) {
        report.error('R204', target, 'surface_unvocalized 必须包含阿语字符。');
      }

      if (_containsLatinInArabicField(word.arabic) ||
          _containsLatinInArabicField(word.plainArabic) ||
          _containsIllegalWhitespace(word.arabic) ||
          _containsIllegalWhitespace(word.plainArabic)) {
        report.error('R212', target, '阿语字段包含异常字符或重复空白。');
      }

      final stripped = _normalizeArabicText(_stripArabicDiacritics(word.arabic));
      final plain = _normalizeArabicText(word.plainArabic);
      if (stripped != plain) {
        report.error(
          'R205',
          target,
          'surface_vocalized 去音符后不等于 surface_unvocalized。',
        );
      }

      if (word.chinese.trim().isEmpty) {
        report.error('R207', target, 'meaning_zh 不能为空。');
      }

      if (word.wordType.trim().isNotEmpty &&
          !_allowedPartOfSpeech.contains(word.wordType.trim())) {
        report.warning(
          'R208',
          target,
          'part_of_speech=${word.wordType} 不在推荐枚举内。',
        );
      }

      final normalizedPlain = _normalizeArabicText(word.plainArabic);
      final normalizedVocalized = _normalizeArabicText(word.arabic);
      if (normalizedPlain.isNotEmpty) {
        plainToVocalized
            .putIfAbsent(normalizedPlain, () => <String>{})
            .add(normalizedVocalized);
      }
    }

    for (final entry in plainToVocalized.entries) {
      if (entry.value.length > 1) {
        report.warning(
          'R211',
          'vocab:${entry.key}',
          '同一个去音符词形对应多个带音符写法，请人工复核。',
        );
      }
    }
  }

  void _validateSentences() {
    for (final record in _sentences.values) {
      final target = 'sentence:${record.id}';

      if (!_lessons.containsKey(record.lessonId)) {
        report.error('R302', target, 'lesson_id=${record.lessonId} 不存在。');
      }

      if (record.id.trim().isEmpty ||
          record.vocalized.trim().isEmpty ||
          record.plain.trim().isEmpty ||
          record.translationZh.trim().isEmpty) {
        report.error('R301', target, 'sentence 缺少必填字段。');
      }

      if (!_containsArabic(record.vocalized)) {
        report.error('R303', target, 'text_vocalized 必须包含阿语字符。');
      }

      if (!_containsArabic(record.plain)) {
        report.error('R304', target, 'text_unvocalized 必须包含阿语字符。');
      }

      if (_containsLatinInArabicField(record.vocalized) ||
          _containsLatinInArabicField(record.plain) ||
          _containsIllegalWhitespace(record.vocalized) ||
          _containsIllegalWhitespace(record.plain)) {
        report.error('R212', target, '阿语句子字段包含异常字符或重复空白。');
      }

      final stripped =
          _normalizeArabicText(_stripArabicDiacritics(record.vocalized));
      final plain = _normalizeArabicText(record.plain);
      if (stripped != plain) {
        report.error(
          'R305',
          target,
          'text_vocalized 去音符后与 text_unvocalized 不一致。',
        );
      }

      if (record.translationZh.trim().isEmpty) {
        report.error('R307', target, 'translation_zh 不能为空。');
      }

      final tokenCount = _countArabicTokens(record.plain);
      final lesson = _lessons[record.lessonId]?.lesson;
      if (lesson != null && lesson.sequence <= 3 && tokenCount > 8) {
        report.warning(
          'R310',
          target,
          '初学阶段句子长度偏长，建议控制在 8 个 token 以内。',
        );
      }
    }
  }

  void _validateQuizzes() {
    for (final record in _quizzes.values) {
      final target = 'quiz:${record.id}';

      if (!_lessons.containsKey(record.lessonId)) {
        report.error('R402', target, 'lesson_id=${record.lessonId} 不存在。');
      }

      if (record.id.trim().isEmpty ||
          record.question.trim().isEmpty ||
          record.options.isEmpty ||
          record.correctAnswer.trim().isEmpty) {
        report.error('R401', target, 'quiz 缺少必填字段。');
      }

      if (!_quizTypes.contains(record.type)) {
        report.error('R403', target, '题型 ${record.type} 不在支持列表内。');
      }

      if (record.options.length < 2) {
        report.error('R404', target, '选择题至少需要 2 个选项。');
      }

      final uniqueOptions = <String>{};
      for (final option in record.options) {
        if (option.trim().isEmpty) {
          report.error('R405', target, 'option.text 不能为空。');
        }
        if (!uniqueOptions.add(option.trim())) {
          report.warning('R408', target, '存在重复选项文本: $option');
        }
      }

      if (!record.options.contains(record.correctAnswer)) {
        report.error('R407', target, 'correct_option_id 对应答案不在 options 中。');
      }

      final duplicateCorrectCount = record.options
          .where((option) => option.trim() == record.correctAnswer.trim())
          .length;
      if (duplicateCorrectCount > 1) {
        report.error('R412', target, '正确答案在选项中出现了多个完全相同的等价值。');
      }
    }
  }

  void _validateAudioManifest() {
    final seenIds = <String>{};

    for (final item in _audioManifestItems) {
      if (item is! Map<String, dynamic>) {
        report.error('R501', 'audio_manifest', 'audio item 必须是对象。');
        continue;
      }

      final id = (item['id'] ?? '').toString();
      final type = (item['type'] ?? '').toString();
      final sourceId = (item['sourceId'] ?? '').toString();
      final textAr = (item['textAr'] ?? '').toString();
      final assetPath = (item['assetPath'] ?? '').toString();
      final target = 'audio:$id';
      final audioReviewStatus = (item['audio_review_status'] ?? '').toString();

      if (id.isEmpty || type.isEmpty || sourceId.isEmpty || textAr.isEmpty) {
        report.error('R501', target, 'audio item 缺少必填字段。');
      }

      if (!seenIds.add(id)) {
        report.error('R005', target, 'audio id 重复。');
      }

      if (!_allowedAudioTypes.contains(type)) {
        report.error('R502', target, 'owner/type=$type 不在允许范围内。');
      }

      if (audioReviewStatus.isNotEmpty &&
          !_audioReviewStatuses.contains(audioReviewStatus)) {
        report.error(
          'R505',
          target,
          'audio_review_status=$audioReviewStatus 不在允许枚举内。',
        );
      }

      final owner = _audioOwners[sourceId];
      if (owner == null) {
        report.error('R503', target, 'sourceId=$sourceId 找不到对应内容。');
      } else {
        final normalizedText = _normalizeArabicText(textAr);
        final acceptedForms = <String>{owner.vocalized, ...owner.acceptedVocalized}
            .map(_normalizeArabicText)
            .where((value) => value.isNotEmpty)
            .toSet();

        if (!acceptedForms.contains(normalizedText)) {
        report.error('R504', target, '音频文本与 owner 展示文本不一致。');
        }
      }

      if (assetPath.trim().isEmpty) {
        report.error('R507', target, 'assetPath 不能为空。');
      } else if (!_allowedAudioExtensions.any(assetPath.endsWith)) {
        report.error('R507', target, '音频扩展名不在允许列表内。');
      } else {
        final assetFile =
            File('${root.path}${Platform.pathSeparator}${assetPath.replaceAll('/', Platform.pathSeparator)}');
        if (!assetFile.existsSync()) {
          report.warning('R507', target, '音频文件不存在: $assetPath');
        }
      }
    }
  }

  String _legacyShaddaForm(String letter, String vowel) {
    if (letter == 'ا') {
      return switch (vowel) {
        'a' => 'أَّ',
        'i' => 'إِّ',
        'u' => 'أُّ',
        _ => 'أَّ',
      };
    }

    return switch (vowel) {
      'a' => '${letter}َّ',
      'i' => '${letter}ِّ',
      'u' => '${letter}ُّ',
      _ => '${letter}َّ',
    };
  }

  void _validateGrammar() {
    final categoryIds = <String>{};

    for (final item in _grammarCategories) {
      if (item is! Map<String, dynamic>) {
        report.error('R601', 'grammar.category', 'grammar category 必须是对象。');
        continue;
      }

      final id = (item['id'] ?? '').toString();
      final title = (item['title'] ?? '').toString();
      final route = (item['route'] ?? '').toString();
      final subtitle = (item['subtitle'] ?? '').toString();
      final target = 'grammar.category:$id';
      final reviewStatus = (item['review_status'] ?? '').toString().trim();

      if (id.isEmpty || title.isEmpty || route.isEmpty || subtitle.isEmpty) {
        report.error('R601', target, 'grammar category 缺少必填字段。');
      }

      if (!categoryIds.add(id)) {
        report.error('R005', target, 'grammar category id 重复。');
      }

      if (reviewStatus.isEmpty) {
        report.warning(
          'R006',
          target,
          '当前 grammar category 缺少 review_status，后续建议补齐治理字段。',
        );
      } else if (!_reviewStatuses.contains(reviewStatus)) {
        report.error(
          'R006',
          target,
          'review_status=$reviewStatus 不在允许枚举内。',
        );
      }
    }

    final pageIds = <String>{};
    for (final item in _grammarPages) {
      if (item is! Map<String, dynamic>) {
        report.error('R601', 'grammar.page', 'grammar page 必须是对象。');
        continue;
      }

      final id = (item['id'] ?? '').toString();
      final title = (item['title'] ?? '').toString();
      final route = (item['route'] ?? '').toString();
      final category = (item['category'] ?? '').toString();
      final summary = (item['summary'] ?? '').toString();
      final target = 'grammar.page:$id';
      final reviewStatus = (item['review_status'] ?? '').toString().trim();

      if (id.isEmpty ||
          title.isEmpty ||
          route.isEmpty ||
          category.isEmpty ||
          summary.isEmpty) {
        report.error('R601', target, 'grammar page 缺少必填字段。');
      }

      if (!pageIds.add(id)) {
        report.error('R005', target, 'grammar page id 重复。');
      }

      if (!categoryIds.contains(category)) {
        report.error('R602', target, 'category=$category 不存在。');
      }

      final relatedLessons = item['relatedLessons'];
      if (relatedLessons is List) {
        for (final lessonId in relatedLessons) {
          final lessonIdText = lessonId.toString();
          if (!_lessons.containsKey(lessonIdText)) {
            report.error(
              'R602',
              target,
              'relatedLessons 引用了不存在的 lesson: $lessonIdText',
            );
          }
        }
      }

      if (reviewStatus.isEmpty) {
        report.warning(
          'R006',
          target,
          '当前 grammar page 缺少 review_status，后续建议补齐治理字段。',
        );
      } else if (!_reviewStatuses.contains(reviewStatus)) {
        report.error(
          'R006',
          target,
          'review_status=$reviewStatus 不在允许枚举内。',
        );
      }
    }
  }

  void _validateCrossObjectConsistency() {
    for (final audio in _audioManifestItems) {
      if (audio is! Map<String, dynamic>) {
        continue;
      }
      final sourceId = (audio['sourceId'] ?? '').toString();
      final owner = _audioOwners[sourceId];
      if (owner == null) {
        continue;
      }
      if (_isFormalStatus(owner.reviewStatus) &&
          !_isFormalStatus('published')) {
        report.error(
          'R701',
          'audio:${audio['id']}',
          '正式内容不允许引用非正式状态的音频。',
        );
      }
    }
  }
}

bool _containsArabic(String input) {
  return RegExp(r'[\u0600-\u06FF]').hasMatch(input);
}

bool _containsLatinInArabicField(String input) {
  return RegExp(r'[A-Za-z]').hasMatch(input);
}

bool _containsIllegalWhitespace(String input) {
  return input.contains(RegExp(r'\s{2,}')) ||
      input.contains('\u200B') ||
      input.contains('\u200C') ||
      input.contains('\u200D');
}

String _normalizeArabicText(String input) {
  final stripped = _stripArabicDiacritics(input)
      .replaceAll(RegExp(r'[،؛؟,.!]+'), ' ')
      .replaceAll('ـ', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return stripped;
}

String _stripArabicDiacritics(String input) {
  return input
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
      .replaceAll('ٱ', 'ا')
      .trim();
}

int _countArabicTokens(String input) {
  final normalized = _normalizeArabicText(input);
  if (normalized.isEmpty) {
    return 0;
  }
  return normalized.split(' ').where((item) => item.isNotEmpty).length;
}

bool _isFormalStatus(String status) {
  return status == 'approved' || status == 'published';
}
