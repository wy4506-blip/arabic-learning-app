import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/lesson_content_localizer.dart';
import '../models/word_item.dart';
import '../services/audio_service.dart';
import '../services/review_service.dart';
import '../services/vocab_service.dart';
import '../theme/app_arabic_typography.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/arabic_text_with_audio.dart';

class VocabBookPage extends StatefulWidget {
  const VocabBookPage({super.key});

  @override
  State<VocabBookPage> createState() => _VocabBookPageState();
}

enum WordFilter { all, recent }

class _VocabBookPageState extends State<VocabBookPage> {
  List<WordItem> _favoriteWords = [];
  bool _isLoading = true;
  final TextEditingController _controller = TextEditingController();
  WordFilter _filter = WordFilter.all;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final words = await VocabService.getFavoriteWords();
    if (!mounted) return;
    setState(() {
      _favoriteWords = words;
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite(WordItem word) async {
    final isFavorite = await VocabService.isFavorite(word.arabic);
    await VocabService.toggleFavorite(word);
    await ReviewService.markWordFavorited(
      word,
      isFavorited: !isFavorite,
    );
    await _loadFavorites();
  }

  String _meaningText(BuildContext context, String value) {
    return LessonContentLocalizer.meaning(
      value,
      context.surfaceMeaningLanguage,
    );
  }

  String _uiText(BuildContext context, String value) {
    return LessonContentLocalizer.ui(
      value,
      context.appSettings.appLanguage,
    );
  }

  List<WordItem> _visible(BuildContext context) {
    final q = _controller.text.trim().toLowerCase();
    Iterable<WordItem> words = _favoriteWords;
    if (_filter == WordFilter.recent) {
      words = words.toList().reversed;
    }
    if (q.isNotEmpty) {
      words = words.where((w) =>
          w.arabic.toLowerCase().contains(q) ||
          w.plainArabic.toLowerCase().contains(q) ||
          removeArabicDiacritics(w.arabic).toLowerCase().contains(q) ||
          w.pronunciation.toLowerCase().contains(q) ||
          w.meaning.toLowerCase().contains(q) ||
          _meaningText(context, w.meaning).toLowerCase().contains(q) ||
          (w.patternNote != null &&
              _meaningText(context, w.patternNote!).toLowerCase().contains(q)));
    }
    return words.toList();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final showTransliteration = context.appSettings.showTransliteration;
    final words = _visible(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.t('wordbook.title'))),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  SectionTitle(
                    title: strings.t('wordbook.title'),
                    subtitle: strings.t('wordbook.subtitle'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      hintText: strings.t('wordbook.search_hint'),
                      prefixIcon: const Icon(Icons.search_rounded),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              const BorderSide(color: AppTheme.strokeLight)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              const BorderSide(color: AppTheme.strokeLight)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ChoiceChip(
                          label: Text(strings.t('common.all')),
                          selected: _filter == WordFilter.all,
                          onSelected: (_) =>
                              setState(() => _filter = WordFilter.all)),
                      const SizedBox(width: 8),
                      ChoiceChip(
                          label: Text(strings.t('common.recent')),
                          selected: _filter == WordFilter.recent,
                          onSelected: (_) =>
                              setState(() => _filter = WordFilter.recent)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_favoriteWords.isEmpty)
                    AppSurface(
                      child: Column(
                        children: [
                          const Icon(Icons.bookmark_border_rounded,
                              size: 40, color: AppTheme.accentMintDark),
                          const SizedBox(height: 10),
                          Text(strings.t('wordbook.empty_title'),
                              style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                    )
                  else if (words.isEmpty)
                    AppSurface(
                      child: Text(strings.t('wordbook.empty_search'),
                          style: Theme.of(context).textTheme.bodyMedium),
                    )
                  else
                    ...words.map((word) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AppSurface(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ArabicTextWithAudio(
                                        textAr: word.arabic,
                                        request: LearningAudioRequest.general(
                                          scope: 'vocab_book',
                                          type: 'word',
                                          textAr: word.arabic,
                                          textPlain: word.plainArabic,
                                          debugLabel: 'vocab_book_word',
                                        ),
                                        variant: ArabicAudioTextVariant.word,
                                        style: const TextStyle(
                                          fontSize: 26,
                                          height: 1.35,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(_meaningText(context, word.meaning),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall),
                                      const SizedBox(height: 4),
                                      if (showTransliteration)
                                        Text(word.pronunciation,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          if (word.partOfSpeech != null &&
                                              word.partOfSpeech!.isNotEmpty)
                                            Pill(
                                              label: _uiText(
                                                context,
                                                word.partOfSpeech!,
                                              ),
                                            ),
                                          if (word.gender != null &&
                                              word.gender!.isNotEmpty)
                                            Pill(
                                              label: _uiText(
                                                context,
                                                word.gender!,
                                              ),
                                            ),
                                          if (word.number != null &&
                                              word.number!.isNotEmpty)
                                            Pill(
                                              label: _uiText(
                                                context,
                                                word.number!,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppTheme.bgCardSoft,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _WordMetaLine(
                                              label:
                                                  strings.t('wordbook.plain'),
                                              value: word.plainArabic,
                                              isArabic: true,
                                            ),
                                            if (word.feminineFormVocalized !=
                                                    null ||
                                                word.feminineFormPlain !=
                                                    null) ...[
                                              const SizedBox(height: 6),
                                              _WordMetaLine(
                                                label: strings.t(
                                                  'wordbook.feminine',
                                                ),
                                                value: _mergeForms(
                                                  word.feminineFormVocalized,
                                                  word.feminineFormPlain,
                                                ),
                                                isArabic: true,
                                              ),
                                            ],
                                            if (word.masculineFormVocalized !=
                                                    null ||
                                                word.masculineFormPlain !=
                                                    null) ...[
                                              const SizedBox(height: 6),
                                              _WordMetaLine(
                                                label: strings.t(
                                                  'wordbook.masculine',
                                                ),
                                                value: _mergeForms(
                                                  word.masculineFormVocalized,
                                                  word.masculineFormPlain,
                                                ),
                                                isArabic: true,
                                              ),
                                            ],
                                            if (word.pluralFormVocalized !=
                                                    null ||
                                                word.pluralFormPlain !=
                                                    null) ...[
                                              const SizedBox(height: 6),
                                              _WordMetaLine(
                                                label: strings.t(
                                                  'wordbook.plural',
                                                ),
                                                value: _mergeForms(
                                                  word.pluralFormVocalized,
                                                  word.pluralFormPlain,
                                                ),
                                                isArabic: true,
                                              ),
                                            ],
                                            const SizedBox(height: 6),
                                            _WordMetaLine(
                                              label:
                                                  strings.t('wordbook.pattern'),
                                              value: word.morphology == null
                                                  ? strings.t('wordbook.unset')
                                                  : _uiText(
                                                      context,
                                                      word.morphology!,
                                                    ),
                                            ),
                                            if (word.patternNote != null &&
                                                word.patternNote!
                                                    .isNotEmpty) ...[
                                              const SizedBox(height: 6),
                                              _WordMetaLine(
                                                label:
                                                    strings.t('wordbook.note'),
                                                value: _meaningText(
                                                  context,
                                                  word.patternNote!,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      if (word.exampleSentenceVocalized !=
                                          null) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                              color: AppTheme.strokeLight,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                strings.t('wordbook.example'),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium
                                                    ?.copyWith(
                                                      color: AppTheme
                                                          .accentMintDark,
                                                    ),
                                              ),
                                              const SizedBox(height: 6),
                                              ArabicTextWithAudio(
                                                textAr: word
                                                    .exampleSentenceVocalized!,
                                                request: LearningAudioRequest
                                                    .general(
                                                  scope: 'vocab_book',
                                                  type: 'sentence',
                                                  textAr: word
                                                      .exampleSentenceVocalized!,
                                                  textPlain: word
                                                          .exampleSentencePlain ??
                                                      word.exampleSentenceVocalized!,
                                                  debugLabel:
                                                      'vocab_book_example_sentence',
                                                ),
                                                variant: ArabicAudioTextVariant
                                                    .sentence,
                                                style: const TextStyle(
                                                  fontSize: 22,
                                                  height: 1.55,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              if (word.exampleSentencePlain !=
                                                  null) ...[
                                                const SizedBox(height: 4),
                                                ArabicText.label(
                                                  word.exampleSentencePlain!,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    height: 1.45,
                                                    color:
                                                        AppTheme.textSecondary,
                                                  ),
                                                ),
                                              ],
                                              if (word.exampleTranslationZh !=
                                                  null) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  _meaningText(
                                                    context,
                                                    word.exampleTranslationZh!,
                                                  ),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                IconButton(
                                    onPressed: () => _toggleFavorite(word),
                                    icon: const Icon(
                                        Icons.bookmark_remove_outlined)),
                              ],
                            ),
                          ),
                        )),
                ],
              ),
      ),
    );
  }
}

class _WordMetaLine extends StatelessWidget {
  final String label;
  final String value;
  final bool isArabic;

  const _WordMetaLine({
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
          width: 44,
          child: Text(
            label,
            style: text.labelMedium?.copyWith(
              color: AppTheme.accentMintDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: isArabic
              ? ArabicText.label(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.45,
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

String _mergeForms(String? vocalized, String? plain) {
  final vocalizedValue = vocalized?.trim() ?? '';
  final plainValue = plain?.trim() ?? '';
  if (vocalizedValue.isEmpty) return plainValue;
  if (plainValue.isEmpty || plainValue == vocalizedValue) {
    return vocalizedValue;
  }
  return '$vocalizedValue\n$plainValue';
}
