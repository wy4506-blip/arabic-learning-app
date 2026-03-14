// ignore_for_file: unused_element

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/app_settings.dart';
import '../models/dialogue_line.dart';
import '../models/grammar_models.dart';
import '../models/lesson.dart';
import '../models/review_models.dart';
import '../models/word_item.dart';
import '../l10n/lesson_content_localizer.dart';
import '../l10n/lesson_localizer.dart';
import '../l10n/localized_text.dart';
import '../services/audio_service.dart';
import '../services/arabic_learning_display_service.dart';
import '../services/grammar_service.dart';
import '../services/lesson_practice_service.dart';
import '../services/progress_service.dart';
import '../services/review_service.dart';
import '../services/vocab_service.dart';
import '../theme/app_arabic_typography.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/review/lesson_micro_review_card.dart';
import 'grammar_detail_page.dart';
import 'lesson_quiz_page.dart';
import 'review_session_page.dart';
import 'unlock_page.dart';

class LessonDetailPage extends StatefulWidget {
  final Lesson lesson;
  final AppSettings settings;
  final bool isUnlocked;

  const LessonDetailPage({
    super.key,
    required this.lesson,
    required this.settings,
    required this.isUnlocked,
  });

  @override
  State<LessonDetailPage> createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage> {
  final Set<String> _saved = <String>{};
  final Set<String> _expandedWordSupplement = <String>{};
  List<GrammarPageContent> _relatedGrammarPages = const <GrammarPageContent>[];
  List<ReviewTask> _lessonPreviewTasks = const <ReviewTask>[];
  List<ReviewTask> _lessonWrapUpTasks = const <ReviewTask>[];
  bool _completed = false;
  late bool _unlocked;
  String _expandedSectionId = 'words';

  @override
  void initState() {
    super.initState();
    _unlocked = widget.isUnlocked;
    _load();
  }

  @override
  void dispose() {
    AudioService.stop();
    super.dispose();
  }

  Future<void> _load() async {
    final results = await Future.wait<dynamic>([
      ProgressService.getSnapshot(),
      GrammarService.getPagesForLesson(widget.lesson.id),
      ReviewService.createLessonPreviewSession(widget.settings, widget.lesson),
      ReviewService.createLessonWrapUpSession(widget.settings, widget.lesson),
    ]);
    final snapshot = results[0] as ProgressSnapshot;
    if (!mounted) return;
    setState(() {
      _completed = snapshot.completedLessons.contains(widget.lesson.id);
      _relatedGrammarPages = results[1] as List<GrammarPageContent>;
      _lessonPreviewTasks =
          ((results[2] as ReviewSession?)?.tasks ?? const <ReviewTask>[]);
      _lessonWrapUpTasks =
          ((results[3] as ReviewSession?)?.tasks ?? const <ReviewTask>[]);
    });
  }

  String _displayArabic(String text) {
    return ArabicLearningDisplayService.displayText(
      text: text,
      settings: widget.settings,
      lesson: widget.lesson,
      contentType: ArabicLearningContentType.sentence,
    );
  }

  String _displayWord(String text) {
    return ArabicLearningDisplayService.displayText(
      text: text,
      settings: widget.settings,
      lesson: widget.lesson,
      contentType: ArabicLearningContentType.word,
    );
  }

  String _plainArabic(String text) {
    return ArabicLearningDisplayService.plainText(text);
  }

  String _meaningText(String value) {
    return LessonContentLocalizer.meaning(
      value,
      context.appSettings.meaningLanguage,
    );
  }

  String _wordMorphology(LessonWord word) {
    final value = word.metadata.morphology?.trim();
    if (value != null && value.isNotEmpty) {
      return value;
    }

    switch (word.metadata.partOfSpeech) {
      case 'noun':
        return '名词';
      case 'adjective':
        return '形容词';
      case 'pronoun':
        return '代词';
      case 'verb':
        return '动词';
      case 'particle':
        return '虚词';
      case 'question':
        return '疑问词';
      case 'expression':
        return '固定表达';
      default:
        return word.metadata.partOfSpeech;
    }
  }

  String _wordKey(LessonWord word) {
    final id = word.id?.trim();
    if (id != null && id.isNotEmpty) {
      return id;
    }
    return '${widget.lesson.id}:${_plainArabic(word.arabic)}';
  }

  String? _partOfSpeechLabel(LessonWord word) {
    switch (word.metadata.partOfSpeech) {
      case 'noun':
        return '名词';
      case 'adjective':
        return '形容词';
      case 'pronoun':
        return '代词';
      case 'verb':
        return '动词';
      case 'particle':
        return '虚词';
      case 'question':
        return '疑问词';
      case 'expression':
        return '固定表达';
      default:
        return word.metadata.partOfSpeech.isEmpty
            ? null
            : word.metadata.partOfSpeech;
    }
  }

  String? _genderLabel(String? value) {
    switch (value) {
      case 'masculine':
        return '阳性';
      case 'feminine':
        return '阴性';
      default:
        return value;
    }
  }

  String? _numberLabel(String? value) {
    switch (value) {
      case 'singular':
        return '单数';
      case 'plural':
        return '复数';
      case 'dual':
        return '双数';
      default:
        return value;
    }
  }

  WordItem _buildWordItem(LessonWord word) {
    final example = word.example;
    return WordItem(
      arabic: word.text.vocalized,
      plainArabic: word.text.plain,
      pronunciation: word.transliteration,
      meaning: word.meaning.zh,
      partOfSpeech: _partOfSpeechLabel(word),
      gender: _genderLabel(word.metadata.gender),
      number: _numberLabel(word.metadata.number),
      pluralFormVocalized: word.pluralForm?.vocalized,
      pluralFormPlain: word.pluralForm?.plain,
      feminineFormVocalized: word.feminineForm?.vocalized,
      feminineFormPlain: word.feminineForm?.plain,
      masculineFormVocalized: word.masculineForm?.vocalized,
      masculineFormPlain: word.masculineForm?.plain,
      morphology: _wordMorphology(word),
      patternNote: word.metadata.patternNote,
      exampleSentenceVocalized: example?.text.vocalized,
      exampleSentencePlain: example?.text.plain,
      exampleTranslationZh: example?.meaning.zh,
    );
  }

  Future<void> _saveWord(LessonWord word) async {
    final wasFavorite = await VocabService.isFavorite(word.arabic);
    final wordItem = _buildWordItem(word);
    await VocabService.toggleFavorite(wordItem);
    final isFavorite = !wasFavorite;
    await ReviewService.markWordFavorited(
      wordItem,
      lessonId: widget.lesson.id,
      isFavorited: isFavorite,
    );
    if (!mounted) return;
    setState(() {
      if (isFavorite) {
        _saved.add(word.arabic);
      } else {
        _saved.remove(word.arabic);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          localizedText(
            context,
            zh: isFavorite ? '已加入单词本' : '已从单词本移除',
            en: isFavorite ? 'Saved to Wordbook' : 'Removed from Wordbook',
          ),
        ),
      ),
    );
  }

  Future<bool> _openUnlock() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UnlockPage()),
    );
    if (result == true) {
      if (!mounted) return false;
      setState(() => _unlocked = true);
      return true;
    }
    return false;
  }

  Future<void> _startPractice() async {
    if (widget.lesson.isLocked && !_unlocked) {
      final didUnlock = await _openUnlock();
      if (!didUnlock) return;
    }

    await ReviewService.recordLessonStarted(widget.lesson);
    await ProgressService.markLessonStarted(widget.lesson.id);
    if (!mounted) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LessonQuizPage(lesson: widget.lesson),
      ),
    );
    if (!mounted) return;

    if (result == true) {
      await ReviewService.recordLessonCompleted(widget.lesson);
      await ProgressService.markLessonCompleted(widget.lesson.id);
      if (!mounted) return;
      setState(() => _completed = true);
      await _load();
    }
  }

  Future<void> _openRelatedGrammarPage() async {
    final targetPage =
        _relatedGrammarPages.isEmpty ? null : _relatedGrammarPages.first;
    if (targetPage == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GrammarDetailPage(
          pageId: targetPage.id,
          settings: widget.settings,
        ),
      ),
    );
    await _load();
  }

  Future<void> _openLessonPreviewReview() async {
    final session = await ReviewService.createLessonPreviewSession(
      widget.settings,
      widget.lesson,
    );
    if (!mounted || session == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewSessionPage(session: session),
      ),
    );
    if (result == true) {
      await _load();
    }
  }

  Future<void> _openLessonWrapUpReview() async {
    final session = await ReviewService.createLessonWrapUpSession(
      widget.settings,
      widget.lesson,
    );
    if (!mounted || session == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewSessionPage(session: session),
      ),
    );
    if (result == true) {
      await _load();
    }
  }

  Future<void> _playWordAudio(LessonWord word) async {
    await _runAudioAction(() {
      return AudioService.playLessonAudio(
        asset: word.audioRef.asset,
        lessonSequence: widget.lesson.sequence,
        type: 'word',
        textAr: word.arabic,
        textPlain: word.text.plain,
        fallbackText: word.text.plain,
      );
    });
  }

  Future<void> _playPatternAudio(LessonPattern pattern) async {
    await _runAudioAction(() {
      return AudioService.playLessonAudio(
        asset: pattern.audioRef.asset,
        lessonSequence: widget.lesson.sequence,
        type: 'sentence',
        textAr: pattern.arabic,
        textPlain: pattern.text.plain,
        fallbackText: pattern.text.plain,
      );
    });
  }

  Future<void> _playDialogueAudio(DialogueLine line) async {
    await _runAudioAction(() {
      return AudioService.playLessonAudio(
        asset: line.audioRef.asset,
        lessonSequence: widget.lesson.sequence,
        type: 'sentence',
        textAr: line.arabic,
        textPlain: line.text.plain,
        fallbackText: line.text.plain,
      );
    });
  }

  Future<void> _runAudioAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.strings.t('lesson.audio_unavailable'))),
      );
    }
  }

  List<String> _availableSectionIds(Lesson lesson) {
    final ids = <String>[];
    if (lesson.vocabulary.isNotEmpty) ids.add('words');
    if (lesson.patterns.isNotEmpty) ids.add('patterns');
    if (lesson.dialogues.isNotEmpty) ids.add('dialogues');
    if (lesson.grammarTitle.isNotEmpty ||
        lesson.grammarExplanation.isNotEmpty) {
      ids.add('grammar');
    }
    ids.addAll(['practice', 'summary']);
    return ids;
  }

  void _openSection(String sectionId) {
    if (_expandedSectionId == sectionId) return;
    setState(() => _expandedSectionId = sectionId);
  }

  Future<void> _showWordFocusSheet(LessonWord word) async {
    await _showArabicFocusSheet(
      title: localizedText(
        context,
        zh: '单词聚焦',
        en: 'Word Focus',
      ),
      arabic: _displayWord(word.arabic),
      secondaryArabic: word.text.plain,
      transliteration: word.transliteration,
      chinese: _meaningText(word.meaning.zh),
      onPlay: () => _playWordAudio(word),
      extra: _WordFocusSupplement(
        partOfSpeech: _partOfSpeechLabel(word),
        gender: _genderLabel(word.metadata.gender),
        wordNumber: _numberLabel(word.metadata.number),
        patternNote: word.metadata.patternNote,
        exampleSentenceVocalized: word.example?.text.vocalized,
        exampleSentencePlain: word.example?.text.plain,
        exampleTranslationZh: word.example?.meaning.zh,
      ),
    );
  }

  Future<void> _showPatternFocusSheet(LessonPattern pattern) async {
    await _showArabicFocusSheet(
      title: localizedText(
        context,
        zh: '句型聚焦',
        en: 'Pattern Focus',
      ),
      arabic: _displayArabic(pattern.arabic),
      transliteration: pattern.transliteration,
      chinese: _meaningText(pattern.meaning.zh),
      onPlay: () => _playPatternAudio(pattern),
    );
  }

  Future<void> _showDialogueFocusSheet(DialogueLine line) async {
    await _showArabicFocusSheet(
      title: localizedText(
        context,
        zh: '对话聚焦',
        en: 'Dialogue Focus',
      ),
      arabic: _displayArabic(line.arabic),
      transliteration: line.transliteration,
      chinese: _meaningText(line.meaning.zh),
      onPlay: () => _playDialogueAudio(line),
      topBadge: line.speaker,
    );
  }

  Future<void> _showArabicFocusSheet({
    required String title,
    required String arabic,
    required String transliteration,
    required String chinese,
    required Future<void> Function() onPlay,
    String? secondaryArabic,
    String? topBadge,
    Widget? extra,
  }) async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'close_focus_card',
      barrierColor: Colors.black.withValues(alpha: 0.42),
      pageBuilder: (context, _, __) {
        return SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: _ArabicFocusDialog(
                title: title,
                arabic: arabic,
                secondaryArabic: secondaryArabic,
                transliteration: transliteration,
                chinese: chinese,
                topBadge: topBadge,
                onPlay: onPlay,
                extra: extra,
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final showTransliteration = context.appSettings.showTransliteration;
    final lesson = widget.lesson;
    final locked = lesson.isLocked && !_unlocked;
    final practiceCount = LessonPracticeService.countFor(lesson);
    final text = Theme.of(context).textTheme;
    final availableSectionIds = _availableSectionIds(lesson);
    final activeSectionId = availableSectionIds.contains(_expandedSectionId)
        ? _expandedSectionId
        : availableSectionIds.first;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          LessonLocalizer.title(lesson, context.appSettings.appLanguage),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          AppSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Pill(label: lesson.id),
                    const SizedBox(width: 8),
                    Pill(
                      label: localizedText(
                        context,
                        zh: '${lesson.estimatedMinutes} 分钟',
                        en: '${lesson.estimatedMinutes} min',
                      ),
                    ),
                    const Spacer(),
                    if (locked) const Icon(Icons.lock_outline_rounded),
                  ],
                ),
                const SizedBox(height: 14),
                _LessonTitleBar(
                  title: LessonLocalizer.title(
                    lesson,
                    context.appSettings.appLanguage,
                  ),
                  arabicTitle: _displayArabic(lesson.titleAr),
                ),
                const SizedBox(height: 12),
                if (locked)
                  _LockedLessonGate(onUnlock: _openUnlock)
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: lesson.objectives
                        .take(3)
                        .map((item) => Pill(label: _meaningText(item)))
                        .toList(),
                  ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _startPractice,
                  icon: const Icon(Icons.school_rounded),
                  label: Text(
                    locked
                        ? strings.t('lesson.unlock_continue')
                        : _completed
                            ? strings.t('lesson.retry_practice')
                            : strings.t('lesson.study_then_practice'),
                  ),
                ),
              ],
            ),
          ),
          if (!locked && !_completed && _lessonPreviewTasks.isNotEmpty) ...[
            const SizedBox(height: 16),
            LessonMicroReviewCard(
              title: localizedText(
                context,
                zh: '课前回顾',
                en: 'Before This Lesson',
              ),
              subtitle: localizedText(
                context,
                zh: '先回顾两三个最近学过的点，再开始这节会更轻松。',
                en: 'Refresh a couple of recent points before starting this lesson.',
              ),
              tasks: _lessonPreviewTasks.take(3).toList(growable: false),
              actionLabel: localizedText(
                context,
                zh: '先回顾一下',
                en: 'Quick Review First',
              ),
              onActionTap: _openLessonPreviewReview,
            ),
          ],
          if (!locked) ...[
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (lesson.vocabulary.isNotEmpty)
                  _LessonSectionChip(
                    label: strings.t('lesson.words'),
                    countLabel: '${lesson.vocabulary.length}',
                    selected: activeSectionId == 'words',
                    onTap: () => _openSection('words'),
                  ),
                if (lesson.patterns.isNotEmpty)
                  _LessonSectionChip(
                    label: strings.t('lesson.patterns'),
                    countLabel: '${lesson.patterns.length}',
                    selected: activeSectionId == 'patterns',
                    onTap: () => _openSection('patterns'),
                  ),
                if (lesson.dialogues.isNotEmpty)
                  _LessonSectionChip(
                    label: strings.t('lesson.dialogues'),
                    countLabel: '${lesson.dialogues.length}',
                    selected: activeSectionId == 'dialogues',
                    onTap: () => _openSection('dialogues'),
                  ),
                if (lesson.grammarTitle.isNotEmpty ||
                    lesson.grammarExplanation.isNotEmpty)
                  _LessonSectionChip(
                    label: strings.t('lesson.grammar'),
                    selected: activeSectionId == 'grammar',
                    onTap: () => _openSection('grammar'),
                  ),
                _LessonSectionChip(
                  label: strings.t('lesson.practice'),
                  countLabel: '$practiceCount',
                  selected: activeSectionId == 'practice',
                  onTap: () => _openSection('practice'),
                ),
                _LessonSectionChip(
                  label: strings.t('lesson.summary'),
                  selected: activeSectionId == 'summary',
                  onTap: () => _openSection('summary'),
                ),
              ],
            ),
            if (lesson.vocabulary.isNotEmpty && activeSectionId == 'words') ...[
              const SizedBox(height: 14),
              SectionTitle(
                title: strings.t('lesson.core_words'),
                subtitle: strings.t('lesson.core_words_subtitle'),
              ),
              const SizedBox(height: 12),
              ...lesson.vocabulary.map(
                (word) {
                  final wordKey = _wordKey(word);
                  final expanded = _expandedWordSupplement.contains(wordKey);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppSurface(
                      onTap: () => _showWordFocusSheet(word),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ArabicText.word(
                                  _displayWord(word.arabic),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    height: 1.45,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ArabicText.label(
                                  word.text.plain,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    height: 1.45,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                if (showTransliteration) ...[
                                  Text(word.transliteration,
                                      style: text.bodyMedium),
                                  const SizedBox(height: 4),
                                ],
                                Text(
                                  _meaningText(word.meaning.zh),
                                  style: text.titleSmall,
                                ),
                                const SizedBox(height: 10),
                                _WordDetailPanel(
                                  vocalizedArabic: word.text.vocalized,
                                  plainArabic: word.text.plain,
                                  partOfSpeech: _partOfSpeechLabel(word),
                                  gender: _genderLabel(word.metadata.gender),
                                  wordNumber:
                                      _numberLabel(word.metadata.number),
                                  pluralVocalized: word.pluralForm?.vocalized,
                                  pluralPlain: word.pluralForm?.plain,
                                  feminineVocalized:
                                      word.feminineForm?.vocalized,
                                  femininePlain: word.feminineForm?.plain,
                                  masculineVocalized:
                                      word.masculineForm?.vocalized,
                                  masculinePlain: word.masculineForm?.plain,
                                  patternNote: word.metadata.patternNote,
                                  exampleSentenceVocalized:
                                      word.example?.text.vocalized,
                                  exampleSentencePlain:
                                      word.example?.text.plain,
                                  exampleTranslationZh:
                                      word.example?.meaning.zh,
                                  expanded: expanded,
                                  onToggleExpanded: () {
                                    setState(() {
                                      if (expanded) {
                                        _expandedWordSupplement.remove(wordKey);
                                      } else {
                                        _expandedWordSupplement.add(wordKey);
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              _AudioActionButton(
                                onTap: () => _playWordAudio(word),
                              ),
                              const SizedBox(height: 6),
                              IconButton(
                                onPressed: () => _saveWord(word),
                                icon: Icon(
                                  _saved.contains(word.arabic)
                                      ? Icons.bookmark_rounded
                                      : Icons.bookmark_border_rounded,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
            if (lesson.patterns.isNotEmpty &&
                activeSectionId == 'patterns') ...[
              const SizedBox(height: 10),
              SectionTitle(
                title: strings.t('lesson.core_patterns'),
                subtitle: strings.t('lesson.core_patterns_subtitle'),
              ),
              const SizedBox(height: 12),
              ...lesson.patterns.map(
                (pattern) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppSurface(
                    onTap: () => _showPatternFocusSheet(pattern),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ArabicText.sentence(
                                _displayArabic(pattern.arabic),
                                style: const TextStyle(
                                  fontSize: 24,
                                  height: 1.55,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (showTransliteration) ...[
                                Text(
                                  pattern.transliteration,
                                  style: text.bodySmall,
                                ),
                                const SizedBox(height: 4),
                              ],
                              Text(
                                _meaningText(pattern.meaning.zh),
                                style: text.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        _AudioActionButton(
                          onTap: () => _playPatternAudio(pattern),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            if (lesson.dialogues.isNotEmpty &&
                activeSectionId == 'dialogues') ...[
              const SizedBox(height: 10),
              SectionTitle(
                title: strings.t('lesson.core_dialogues'),
                subtitle: strings.t('lesson.core_dialogues_subtitle'),
              ),
              const SizedBox(height: 12),
              AppSurface(
                child: Column(
                  children: lesson.dialogues
                      .map(
                        (line) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => _showDialogueFocusSheet(line),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppTheme.bgCardSoft,
                                  child: Text(
                                    line.speaker,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ArabicText.sentence(
                                        _displayArabic(line.arabic),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          height: 1.45,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      if (showTransliteration) ...[
                                        Text(
                                          line.transliteration,
                                          style: text.bodySmall,
                                        ),
                                        const SizedBox(height: 4),
                                      ],
                                      Text(
                                        _meaningText(line.meaning.zh),
                                        style: text.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                _AudioActionButton(
                                  onTap: () => _playDialogueAudio(line),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
            if ((lesson.grammarTitle.isNotEmpty ||
                    lesson.grammarExplanation.isNotEmpty) &&
                activeSectionId == 'grammar') ...[
              const SizedBox(height: 10),
              SectionTitle(
                title: strings.t('lesson.grammar_point'),
                subtitle: strings.t('lesson.grammar_point_subtitle'),
              ),
              const SizedBox(height: 12),
              AppSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LessonLocalizer.grammarTitle(
                        lesson,
                        context.appSettings.meaningLanguage,
                      ),
                      style: text.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      LessonLocalizer.grammarExplanation(
                        lesson,
                        context.appSettings.meaningLanguage,
                      ),
                      style: text.bodyMedium,
                    ),
                    if (_relatedGrammarPages.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _openRelatedGrammarPage,
                          icon: const Icon(Icons.rule_rounded),
                          label: Text(
                            localizedText(
                              context,
                              zh: '打开相关语法，查完可直接返回这节课',
                              en: 'Open the related grammar and return here after',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (activeSectionId == 'practice') ...[
              const SizedBox(height: 10),
              SectionTitle(
                title: strings.t('lesson.practice_title'),
                subtitle: practiceCount == 0
                    ? strings.t('lesson.practice_empty_subtitle')
                    : strings.t(
                        'lesson.practice_subtitle',
                        params: <String, String>{'count': '$practiceCount'},
                      ),
              ),
              const SizedBox(height: 12),
              AppSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.bgCardSoft,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.edit_note_rounded,
                            color: AppTheme.accentMintDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(strings.t('lesson.practice_card_title'),
                                  style: text.titleSmall),
                              const SizedBox(height: 4),
                              Text(
                                practiceCount == 0
                                    ? strings.t('lesson.practice_card_empty')
                                    : strings.t('lesson.practice_card_ready'),
                                style: text.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Pill(
                          label: practiceCount == 0
                              ? strings.t('lesson.practice_count_empty')
                              : strings.t(
                                  'lesson.practice_count_ready',
                                  params: <String, String>{
                                    'count': '$practiceCount',
                                  },
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: practiceCount == 0 ? null : _startPractice,
                        child: Text(
                          _completed
                              ? strings.t('lesson.practice_restart')
                              : strings.t('lesson.practice_start'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (activeSectionId == 'summary') ...[
              const SizedBox(height: 10),
              SectionTitle(
                title: strings.t('lesson.summary_title'),
                subtitle: strings.t('lesson.summary_subtitle'),
              ),
              const SizedBox(height: 12),
              _LessonSummaryCard(
                lesson: lesson,
                practiceCount: practiceCount,
              ),
              if (_completed && _lessonWrapUpTasks.isNotEmpty) ...[
                const SizedBox(height: 12),
                LessonMicroReviewCard(
                  title: localizedText(
                    context,
                    zh: '课后巩固',
                    en: 'After-Lesson Reinforcement',
                  ),
                  subtitle: localizedText(
                    context,
                    zh: '刚学完这节，顺手再过一遍重点，更容易留下来。',
                    en: 'This lesson is still fresh, so a short follow-up pass will stick better.',
                  ),
                  tasks: _lessonWrapUpTasks.take(3).toList(growable: false),
                  actionLabel: localizedText(
                    context,
                    zh: '顺手巩固一下',
                    en: 'Reinforce It Now',
                  ),
                  onActionTap: _openLessonWrapUpReview,
                ),
              ],
            ],
          ],
        ],
      ),
    );
  }
}

class _LessonSectionChip extends StatelessWidget {
  final String label;
  final String? countLabel;
  final bool selected;
  final VoidCallback onTap;

  const _LessonSectionChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.countLabel,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : AppTheme.accentMintDark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppTheme.accentMintDark : AppTheme.bgCardSoft,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: foreground,
                    ),
              ),
              if (countLabel != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withValues(alpha: 0.18)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    countLabel!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: foreground,
                        ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonSummaryCard extends StatelessWidget {
  final Lesson lesson;
  final int practiceCount;

  const _LessonSummaryCard({
    required this.lesson,
    required this.practiceCount,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final meaningLanguage = context.appSettings.meaningLanguage;

    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Pill(
                label: localizedText(
                  context,
                  zh: '${lesson.vocabulary.length} 个词',
                  en: '${lesson.vocabulary.length} words',
                ),
              ),
              Pill(
                label: localizedText(
                  context,
                  zh: '${lesson.patterns.length} 个句型',
                  en: '${lesson.patterns.length} patterns',
                ),
              ),
              Pill(
                label: localizedText(
                  context,
                  zh: '$practiceCount 道练习',
                  en: '$practiceCount exercises',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...lesson.objectives.take(3).map(
                (objective) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(top: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCardSoft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: AppTheme.accentMintDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          LessonContentLocalizer.meaning(
                            objective,
                            meaningLanguage,
                          ),
                          style: text.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 2),
          Text(
            localizedText(
              context,
              zh: '建议把核心句型和对话再跟读一遍，然后完成本课练习，再进入下一节。',
              en: 'Review the key patterns and dialogue once more, finish the practice, then move to the next lesson.',
            ),
            style: text.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _WordDetailPanel extends StatelessWidget {
  final String vocalizedArabic;
  final String plainArabic;
  final String? partOfSpeech;
  final String? gender;
  final String? wordNumber;
  final String? pluralVocalized;
  final String? pluralPlain;
  final String? feminineVocalized;
  final String? femininePlain;
  final String? masculineVocalized;
  final String? masculinePlain;
  final String? patternNote;
  final String? exampleSentenceVocalized;
  final String? exampleSentencePlain;
  final String? exampleTranslationZh;
  final bool expanded;
  final VoidCallback onToggleExpanded;

  const _WordDetailPanel({
    required this.vocalizedArabic,
    required this.plainArabic,
    required this.partOfSpeech,
    required this.gender,
    required this.wordNumber,
    required this.pluralVocalized,
    required this.pluralPlain,
    required this.feminineVocalized,
    required this.femininePlain,
    required this.masculineVocalized,
    required this.masculinePlain,
    required this.patternNote,
    required this.exampleSentenceVocalized,
    required this.exampleSentencePlain,
    required this.exampleTranslationZh,
    required this.expanded,
    required this.onToggleExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final meaningLanguage = context.appSettings.meaningLanguage;
    final appLanguage = context.appSettings.appLanguage;
    final tags = <String>[
      if (partOfSpeech != null && partOfSpeech!.isNotEmpty)
        LessonContentLocalizer.ui(partOfSpeech!, appLanguage),
      if (gender != null && gender!.isNotEmpty)
        LessonContentLocalizer.ui(gender!, appLanguage),
      if (wordNumber != null && wordNumber!.isNotEmpty)
        LessonContentLocalizer.ui(wordNumber!, appLanguage),
    ];
    final hasSupplement = (patternNote?.isNotEmpty ?? false) ||
        (exampleSentenceVocalized?.isNotEmpty ?? false) ||
        (exampleTranslationZh?.isNotEmpty ?? false);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgCardSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tags.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags
                  .map(
                    (tag) => Pill(
                      label: tag,
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.accentMintDark,
                    ),
                  )
                  .toList(),
            ),
          if (tags.isNotEmpty) const SizedBox(height: 10),
          _WordDetailRow(
            label: localizedText(context, zh: '带音符', en: 'Vocalized'),
            value: vocalizedArabic,
            isArabic: true,
          ),
          const SizedBox(height: 8),
          _WordDetailRow(
            label: localizedText(context, zh: '去音符', en: 'Plain'),
            value: plainArabic,
            isArabic: true,
          ),
          if ((feminineVocalized?.isNotEmpty ?? false) ||
              (femininePlain?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 8),
            _WordDetailRow(
              label: localizedText(context, zh: '阴性形式', en: 'Feminine'),
              value: _mergeForm(feminineVocalized, femininePlain),
              isArabic: true,
            ),
          ],
          if ((masculineVocalized?.isNotEmpty ?? false) ||
              (masculinePlain?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 8),
            _WordDetailRow(
              label: localizedText(context, zh: '阳性形式', en: 'Masculine'),
              value: _mergeForm(masculineVocalized, masculinePlain),
              isArabic: true,
            ),
          ],
          if ((pluralVocalized?.isNotEmpty ?? false) ||
              (pluralPlain?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 8),
            _WordDetailRow(
              label: localizedText(context, zh: '复数形式', en: 'Plural'),
              value: _mergeForm(pluralVocalized, pluralPlain),
              isArabic: true,
            ),
          ],
          if (hasSupplement) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onToggleExpanded,
                icon: Icon(
                  expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                ),
                label: Text(
                  localizedText(
                    context,
                    zh: expanded ? '收起学习补充' : '展开学习补充',
                    en: expanded ? 'Hide Extra Notes' : 'Show Extra Notes',
                  ),
                ),
              ),
            ),
          ],
          if (expanded && hasSupplement) ...[
            if (patternNote?.isNotEmpty ?? false) ...[
              const SizedBox(height: 4),
              Text(
                localizedText(context, zh: '规律提示', en: 'Pattern Note'),
                style: text.titleSmall,
              ),
              const SizedBox(height: 6),
              Text(
                LessonContentLocalizer.meaning(patternNote!, meaningLanguage),
                style: text.bodySmall,
              ),
            ],
            if (exampleSentenceVocalized?.isNotEmpty ?? false) ...[
              const SizedBox(height: 12),
              Text(
                localizedText(context, zh: '例句', en: 'Example'),
                style: text.titleSmall,
              ),
              const SizedBox(height: 6),
              ArabicText.sentence(
                exampleSentenceVocalized!,
                style: const TextStyle(
                  fontSize: 22,
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (exampleSentencePlain?.isNotEmpty ?? false) ...[
                const SizedBox(height: 4),
                ArabicText.label(
                  exampleSentencePlain!,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.45,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
              if (exampleTranslationZh?.isNotEmpty ?? false) ...[
                const SizedBox(height: 4),
                Text(
                  LessonContentLocalizer.meaning(
                    exampleTranslationZh!,
                    meaningLanguage,
                  ),
                  style: text.bodySmall,
                ),
              ],
            ],
          ],
        ],
      ),
    );
  }

  String _mergeForm(String? vocalized, String? plain) {
    final vocalizedValue = vocalized?.trim() ?? '';
    final plainValue = plain?.trim() ?? '';
    if (vocalizedValue.isEmpty) return plainValue;
    if (plainValue.isEmpty || plainValue == vocalizedValue) {
      return vocalizedValue;
    }
    return '$vocalizedValue\n$plainValue';
  }
}

class _WordDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isArabic;

  const _WordDetailRow({
    required this.label,
    required this.value,
    this.isArabic = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 62,
          child: Text(
            label,
            style: text.labelMedium?.copyWith(
              color: AppTheme.accentMintDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: isArabic
              ? ArabicText.label(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 1.5,
                    color: AppTheme.textPrimary,
                  ),
                )
              : Text(
                  value,
                  style: text.bodySmall?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
        ),
      ],
    );
  }
}

class _LessonTitleBar extends StatelessWidget {
  final String title;
  final String arabicTitle;

  const _LessonTitleBar({
    required this.title,
    required this.arabicTitle,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final inline = width >= 390;
    final text = Theme.of(context).textTheme;
    final chineseStyle = text.headlineMedium?.copyWith(
      color: const Color(0xFF24313A),
      height: 1.08,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.2,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18, inline ? 14 : 16, 18, 16),
      decoration: BoxDecoration(
        color: AppTheme.bgCardSoft,
        borderRadius: BorderRadius.circular(22),
      ),
      child: inline
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 6,
                  child: Text(
                    title,
                    style: chineseStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 5,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ArabicText.display(
                      arabicTitle,
                      style: const TextStyle(
                        fontSize: 32,
                        height: 1.04,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF2A3C34),
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: chineseStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: ArabicText.display(
                    arabicTitle,
                    style: const TextStyle(
                      fontSize: 32,
                      height: 1.04,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF2A3C34),
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
    );
  }
}

class _LockedLessonGate extends StatelessWidget {
  final Future<bool> Function() onUnlock;

  const _LockedLessonGate({
    required this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9E7E1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.lock_open_rounded,
              color: AppTheme.deepAccent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.strings.t('lesson.locked_title'),
                    style: text.titleSmall),
                const SizedBox(height: 2),
                Text(
                  context.strings.t('lesson.locked_subtitle'),
                  style: text.bodySmall,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              await onUnlock();
            },
            child: Text(context.strings.t('lesson.go_unlock')),
          ),
        ],
      ),
    );
  }
}

class _AudioActionButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AudioActionButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: context.strings.t('common.play_audio'),
      onPressed: onTap,
      icon: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppTheme.bgCardSoft,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          Icons.volume_up_rounded,
          size: 20,
          color: AppTheme.accentMintDark,
        ),
      ),
    );
  }
}

class _ArabicFocusDialog extends StatelessWidget {
  final String title;
  final String arabic;
  final String? secondaryArabic;
  final String transliteration;
  final String chinese;
  final String? topBadge;
  final Future<void> Function() onPlay;
  final Widget? extra;

  const _ArabicFocusDialog({
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.chinese,
    required this.onPlay,
    this.secondaryArabic,
    this.topBadge,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final plainArabic = secondaryArabic?.trim() ?? '';
    final width = MediaQuery.of(context).size.width;
    final arabicSize = width >= 420 ? 54.0 : 46.0;

    return Material(
      color: Colors.transparent,
      child: Semantics(
        label: title,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 620,
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(32),
            boxShadow: AppTheme.softShadow,
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (topBadge != null && topBadge!.isNotEmpty) ...[
                      Center(child: Pill(label: topBadge!)),
                      const SizedBox(height: 16),
                    ],
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCardSoft,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ArabicText.sentence(
                            arabic,
                            style: TextStyle(
                              fontSize: arabicSize,
                              height: 1.5,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (plainArabic.isNotEmpty &&
                              plainArabic != arabic) ...[
                            const SizedBox(height: 12),
                            ArabicText.label(
                              plainArabic,
                              style: const TextStyle(
                                fontSize: 28,
                                height: 1.45,
                                color: AppTheme.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          if (context.appSettings.showTransliteration &&
                              transliteration.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              transliteration,
                              style: text.bodyLarge?.copyWith(
                                color: AppTheme.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          if (chinese.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              chinese,
                              style: text.titleSmall?.copyWith(
                                color: AppTheme.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () async {
                          await onPlay();
                        },
                        icon: const Icon(Icons.volume_up_rounded),
                        label: Text(context.strings.t('common.play_audio')),
                      ),
                    ),
                    if (extra != null) ...[
                      const SizedBox(height: 16),
                      extra!,
                    ],
                  ],
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WordFocusSupplement extends StatelessWidget {
  final String? partOfSpeech;
  final String? gender;
  final String? wordNumber;
  final String? patternNote;
  final String? exampleSentenceVocalized;
  final String? exampleSentencePlain;
  final String? exampleTranslationZh;

  const _WordFocusSupplement({
    required this.partOfSpeech,
    required this.gender,
    required this.wordNumber,
    required this.patternNote,
    required this.exampleSentenceVocalized,
    required this.exampleSentencePlain,
    required this.exampleTranslationZh,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final meaningLanguage = context.appSettings.meaningLanguage;
    final appLanguage = context.appSettings.appLanguage;
    final tags = <String>[
      if (partOfSpeech != null && partOfSpeech!.isNotEmpty)
        LessonContentLocalizer.ui(partOfSpeech!, appLanguage),
      if (gender != null && gender!.isNotEmpty)
        LessonContentLocalizer.ui(gender!, appLanguage),
      if (wordNumber != null && wordNumber!.isNotEmpty)
        LessonContentLocalizer.ui(wordNumber!, appLanguage),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCardSoft,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tags.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags
                  .map(
                    (tag) => Pill(
                      label: tag,
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.accentMintDark,
                    ),
                  )
                  .toList(),
            ),
          if (patternNote != null && patternNote!.isNotEmpty) ...[
            if (tags.isNotEmpty) const SizedBox(height: 14),
            Text(
              localizedText(context, zh: '学习提示', en: 'Learning Note'),
              style: text.titleSmall,
            ),
            const SizedBox(height: 6),
            Text(
              LessonContentLocalizer.meaning(patternNote!, meaningLanguage),
              style: text.bodyMedium?.copyWith(color: AppTheme.textPrimary),
            ),
          ],
          if (exampleSentenceVocalized != null &&
              exampleSentenceVocalized!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              localizedText(context, zh: '例句', en: 'Example'),
              style: text.titleSmall,
            ),
            const SizedBox(height: 6),
            ArabicText.sentence(
              exampleSentenceVocalized!,
              style: const TextStyle(
                fontSize: 24,
                height: 1.55,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.right,
            ),
            if (exampleSentencePlain != null &&
                exampleSentencePlain!.isNotEmpty &&
                exampleSentencePlain != exampleSentenceVocalized) ...[
              const SizedBox(height: 4),
              ArabicText.label(
                exampleSentencePlain!,
                style: const TextStyle(
                  fontSize: 20,
                  height: 1.45,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.right,
              ),
            ],
            if (exampleTranslationZh != null &&
                exampleTranslationZh!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                LessonContentLocalizer.meaning(
                  exampleTranslationZh!,
                  meaningLanguage,
                ),
                style: text.bodyMedium?.copyWith(color: AppTheme.textPrimary),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
