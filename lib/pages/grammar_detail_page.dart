import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/grammar_text.dart';
import '../l10n/localized_text.dart';
import '../models/app_settings.dart';
import '../models/grammar_models.dart';
import '../models/lesson.dart';
import '../l10n/lesson_localizer.dart';
import '../services/audio_service.dart';
import '../services/grammar_service.dart';
import '../services/grammar_state_service.dart';
import '../services/lesson_service.dart';
import '../services/review_service.dart';
import '../services/unlock_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/grammar_widgets.dart';
import 'lesson_detail_page.dart';

const Duration _grammarDetailLoadTimeout = Duration(seconds: 2);

class GrammarDetailPage extends StatefulWidget {
  final String pageId;
  final AppSettings settings;

  const GrammarDetailPage({
    super.key,
    required this.pageId,
    required this.settings,
  });

  @override
  State<GrammarDetailPage> createState() => _GrammarDetailPageState();
}

class _GrammarDetailPageState extends State<GrammarDetailPage> {
  GrammarPageContent? _page;
  GrammarCategory? _category;
  bool _favorite = false;
  bool _loading = true;
  bool _unlocked = false;
  List<Lesson> _relatedLessons = const <Lesson>[];
  final Map<String, bool> _expandedStates = <String, bool>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final page = await GrammarService.getPage(widget.pageId).timeout(
        _grammarDetailLoadTimeout,
        onTimeout: () => null,
      );
      final category = page == null
          ? null
          : await GrammarService.getCategory(page.category).timeout(
              _grammarDetailLoadTimeout,
              onTimeout: () => null,
            );
      final favorite =
          await GrammarStateService.isFavorite(widget.pageId).timeout(
        _grammarDetailLoadTimeout,
        onTimeout: () => false,
      );
      final expandedStates =
          await GrammarStateService.getExpandStates().timeout(
        _grammarDetailLoadTimeout,
        onTimeout: () => <String, bool>{},
      );
      final unlocked = await UnlockService.isUnlocked().timeout(
        _grammarDetailLoadTimeout,
        onTimeout: () => false,
      );
      final lessons = await LessonService().loadLessons().timeout(
            _grammarDetailLoadTimeout,
            onTimeout: () => <Lesson>[],
          );

      await GrammarStateService.recordOpenedPage(widget.pageId).timeout(
        _grammarDetailLoadTimeout,
        onTimeout: () {},
      );
      await ReviewService.markGrammarViewed(widget.pageId).timeout(
        _grammarDetailLoadTimeout,
        onTimeout: () {},
      );

      if (!mounted) return;
      setState(() {
        _page = page;
        _category = category;
        _favorite = favorite;
        _expandedStates
          ..clear()
          ..addAll(expandedStates);
        _unlocked = unlocked;
        _relatedLessons = page == null
            ? const <Lesson>[]
            : lessons
                .where((lesson) => page.relatedLessons.contains(lesson.id))
                .toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _page = null;
        _category = null;
        _favorite = false;
        _expandedStates.clear();
        _unlocked = false;
        _relatedLessons = const <Lesson>[];
        _loading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    await GrammarStateService.toggleFavorite(widget.pageId);
    final nextFavorite = !_favorite;
    await ReviewService.setGrammarFavorited(
      widget.pageId,
      isFavorited: nextFavorite,
    );
    if (!mounted) return;
    setState(() => _favorite = nextFavorite);
  }

  Future<void> _toggleExpanded(String sectionId) async {
    final next = !(_expandedStates[sectionId] ?? false);
    await GrammarStateService.setExpandState(sectionId, next);
    if (!mounted) return;
    setState(() => _expandedStates[sectionId] = next);
  }

  Future<void> _playExample(GrammarExampleData example) async {
    try {
      await AudioService.playLearningText(
        LearningAudioRequest.general(
          scope: 'grammar',
          type: 'sentence',
          asset: example.audioPath,
          textAr: example.arabicWithDiacritics,
          textPlain: example.arabicPlain,
          debugLabel: 'grammar_detail_example',
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.strings.t('lesson.audio_unavailable'))),
      );
    }
  }

  Future<void> _openPage(String pageId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GrammarDetailPage(
          pageId: pageId,
          settings: widget.settings,
        ),
      ),
    );
    await _load();
  }

  Future<void> _openLesson(Lesson lesson) async {
    final locked = lesson.isLocked && !_unlocked;
    if (locked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.strings.t('lesson.locked_snackbar'))),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LessonDetailPage(
          lesson: lesson,
          settings: widget.settings,
          isUnlocked: _unlocked,
        ),
      ),
    );
  }

  List<Widget> _buildSectionWidgets(GrammarPageContent page) {
    final widgets = <Widget>[];
    final meaningLanguage = context.appSettings.meaningLanguage;

    for (final section in page.sections) {
      if (section.type != 'table_card') {
        widgets.add(
          GrammarBlockHeader(
            title: grammarContentText(section.title, meaningLanguage),
            description: grammarContentText(
              section.description,
              meaningLanguage,
            ),
          ),
        );
        widgets.add(const SizedBox(height: 12));
      }

      switch (section.type) {
        case 'quick_links':
          widgets.addAll(
            section.quickLinks.map(
              (link) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GrammarQuickLinkCard(
                  link: link,
                  onTap: () => _openPage(link.id),
                ),
              ),
            ),
          );
          break;
        case 'table_card':
          widgets.add(
            GrammarTableCard(
              title: section.title,
              summary: section.description,
              table: section.table!,
              isExpandable: section.isExpandable,
              expanded: _expandedStates[section.id] ?? false,
              onToggleExpanded: section.isExpandable
                  ? () => _toggleExpanded(section.id)
                  : null,
            ),
          );
          break;
        case 'rule_group':
          widgets.addAll(
            section.rules.map(
              (rule) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GrammarRuleCard(
                  rule: rule,
                  onPlay: rule.example == null
                      ? null
                      : () => _playExample(rule.example!),
                ),
              ),
            ),
          );
          break;
        case 'compare_group':
          widgets.addAll(
            section.compares.map(
              (compare) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GrammarCompareCard(data: compare),
              ),
            ),
          );
          break;
        case 'example_group':
          widgets.addAll(
            section.examples.map(
              (example) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GrammarExampleCard(
                  example: example,
                ),
              ),
            ),
          );
          break;
        case 'note_card':
          widgets.add(
            AppSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (section.description.isNotEmpty) ...[
                    Text(
                      grammarContentText(section.description, meaningLanguage),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    if (section.bullets.isNotEmpty) const SizedBox(height: 12),
                  ],
                  if (section.bullets.isNotEmpty)
                    ...section.bullets.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Icon(
                                Icons.circle,
                                size: 8,
                                color: AppTheme.accentMintDark,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                grammarContentText(item, meaningLanguage),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppTheme.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
          break;
      }

      widgets.add(const SizedBox(height: 18));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final page = _page;
    if (page == null) {
      return Scaffold(
        body: Center(
          child: Text(
            localizedText(
              context,
              zh: '未找到语法内容',
              en: 'Grammar content not found',
            ),
          ),
        ),
      );
    }

    final appLanguage = context.appSettings.appLanguage;
    final meaningLanguage = context.appSettings.meaningLanguage;

    return Scaffold(
      appBar: AppBar(
        title: Text(grammarUiText(page.title, appLanguage)),
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              _favorite
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: AppTheme.pagePadding,
        children: [
          AppSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_category != null) ...[
                  Pill(
                    label: grammarUiText(_category!.title, appLanguage),
                    backgroundColor: _category!.parsedColor,
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  grammarUiText(page.title, appLanguage),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  grammarContentText(page.summary, meaningLanguage),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (page.tags.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: page.tags
                        .map(
                          (tag) => Pill(
                            label: grammarContentText(tag, meaningLanguage),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          ..._buildSectionWidgets(page),
          if (_relatedLessons.isNotEmpty) ...[
            GrammarBlockHeader(
              title: localizedText(context, zh: '关联课程', en: 'Related Lessons'),
              description: localizedText(
                context,
                zh: '看完语法后，可以回到这些课程继续练。',
                en: 'After reading the grammar point, go back to these lessons to practice it in context.',
              ),
            ),
            const SizedBox(height: 12),
            ..._relatedLessons.map(
              (lesson) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GrammarRelatedLessonCard(
                  title: LessonLocalizer.title(
                    lesson,
                    context.appSettings.appLanguage,
                  ),
                  subtitle: LessonLocalizer.grammarTitle(
                    lesson,
                    context.appSettings.meaningLanguage,
                  ),
                  onTap: () => _openLesson(lesson),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
