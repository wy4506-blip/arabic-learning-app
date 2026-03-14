import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/grammar_text.dart';
import '../l10n/localized_text.dart';
import '../models/app_settings.dart';
import '../models/grammar_models.dart';
import '../models/lesson.dart';
import '../l10n/lesson_localizer.dart';
import '../services/grammar_service.dart';
import '../services/lesson_service.dart';
import '../services/unlock_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/grammar_widgets.dart';
import 'grammar_detail_page.dart';
import 'lesson_detail_page.dart';

const Duration _grammarCategoryLoadTimeout = Duration(seconds: 2);

class GrammarCategoryPage extends StatefulWidget {
  final String categoryId;
  final AppSettings settings;

  const GrammarCategoryPage({
    super.key,
    required this.categoryId,
    required this.settings,
  });

  @override
  State<GrammarCategoryPage> createState() => _GrammarCategoryPageState();
}

class _GrammarCategoryPageState extends State<GrammarCategoryPage> {
  GrammarCategory? _category;
  List<GrammarPageContent> _pages = const <GrammarPageContent>[];
  List<Lesson> _relatedLessons = const <Lesson>[];
  bool _loading = true;
  bool _unlocked = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final category = await GrammarService.getCategory(widget.categoryId).timeout(
        _grammarCategoryLoadTimeout,
        onTimeout: () => null,
      );
      final pages = await GrammarService.getPagesForCategory(widget.categoryId).timeout(
        _grammarCategoryLoadTimeout,
        onTimeout: () => <GrammarPageContent>[],
      );
      final lessons = await LessonService().loadLessons().timeout(
        _grammarCategoryLoadTimeout,
        onTimeout: () => <Lesson>[],
      );
      final unlocked = await UnlockService.isUnlocked().timeout(
        _grammarCategoryLoadTimeout,
        onTimeout: () => false,
      );
      final lessonIds = pages.expand((page) => page.relatedLessons).toSet();

      if (!mounted) return;
      setState(() {
        _category = category;
        _pages = pages;
        _unlocked = unlocked;
        _relatedLessons = lessons
            .where((lesson) => lessonIds.contains(lesson.id))
            .take(4)
            .toList(growable: false);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _category = null;
        _pages = const <GrammarPageContent>[];
        _relatedLessons = const <Lesson>[];
        _unlocked = false;
        _loading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final category = _category;
    if (category == null) {
      return Scaffold(
        body: Center(
          child: Text(
            localizedText(
              context,
              zh: '未找到分类',
              en: 'Category not found',
            ),
          ),
        ),
      );
    }

    final appLanguage = context.appSettings.appLanguage;
    final meaningLanguage = context.appSettings.meaningLanguage;

    return Scaffold(
      appBar: AppBar(
        title: Text(grammarUiText(category.title, appLanguage)),
      ),
      body: ListView(
        padding: AppTheme.pagePadding,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: category.parsedColor,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  grammarUiText(category.title, appLanguage),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  grammarContentText(category.subtitle, meaningLanguage),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Pill(
                      label: localizedText(
                        context,
                        zh: '${_pages.length} 个核心页面',
                        en: '${_pages.length} core pages',
                      ),
                    ),
                    Pill(
                      label: localizedText(
                        context,
                        zh: '支持离线查看',
                        en: 'Offline Ready',
                      ),
                    ),
                    Pill(
                      label: localizedText(
                        context,
                        zh: '先速查再展开',
                        en: 'Quick Scan First',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GrammarBlockHeader(
            title: localizedText(context, zh: '常查入口', en: 'Quick Links'),
            description: localizedText(
              context,
              zh: '先进入最常用的总表、规则卡和例句页。',
              en: 'Start with the most-used tables, rule cards, and example pages.',
            ),
          ),
          const SizedBox(height: 12),
          ..._pages.map(
            (page) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GrammarQuickLinkCard(
                link: GrammarQuickLink(
                  id: page.id,
                  title: page.title,
                  subtitle: page.summary,
                  route: page.route,
                ),
                onTap: () => _openPage(page.id),
              ),
            ),
          ),
          if (_relatedLessons.isNotEmpty) ...[
            const SizedBox(height: 10),
            GrammarBlockHeader(
              title:
                  localizedText(context, zh: '关联课程', en: 'Related Lessons'),
              description: localizedText(
                context,
                zh: '这些课程和当前分类联系更紧，适合查完后继续练。',
                en: 'These lessons connect closely to this category and work well after a quick review.',
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
