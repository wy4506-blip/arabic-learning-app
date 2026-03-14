import 'dart:async';

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../data/grammar_home_curated_data.dart';
import '../data/grammar_quick_reference_data.dart';
import '../l10n/grammar_text.dart';
import '../l10n/lesson_localizer.dart';
import '../l10n/localized_text.dart';
import '../models/app_settings.dart';
import '../models/grammar_home_models.dart';
import '../models/grammar_models.dart';
import '../models/grammar_quick_reference_models.dart';
import '../models/lesson.dart';
import '../services/grammar_service.dart';
import '../services/grammar_state_service.dart';
import '../services/lesson_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/grammar_home_widgets.dart';
import '../widgets/grammar_quick_reference_card.dart';
import 'grammar_category_page.dart';
import 'grammar_detail_page.dart';

const Duration _grammarHomeLoadTimeout = Duration(seconds: 2);

class GrammarHomePage extends StatefulWidget {
  static const routeName = '/grammar';

  final AppSettings settings;

  const GrammarHomePage({
    super.key,
    required this.settings,
  });

  @override
  State<GrammarHomePage> createState() => _GrammarHomePageState();
}

class _GrammarHomePageState extends State<GrammarHomePage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _featuredSectionKey = GlobalKey();
  final Map<String, GlobalKey> _quickSectionKeys = <String, GlobalKey>{
    for (final section in grammarQuickReferenceSections)
      section.id: GlobalKey(),
  };

  Timer? _scrollSaveTimer;
  List<GrammarCategory> _categories = const <GrammarCategory>[];
  List<GrammarPageContent> _pages = const <GrammarPageContent>[];
  List<Lesson> _lessons = const <Lesson>[];
  List<GrammarRecentVisit> _recentVisits = const <GrammarRecentVisit>[];
  List<String> _favoriteIds = const <String>[];
  ProgressSnapshot _progress = const ProgressSnapshot(
    completedLessons: <String>{},
    startedLessons: <String>{},
    reviewCount: 0,
    streakDays: 0,
  );
  Map<String, bool> _expandedById = <String, bool>{
    for (final section in grammarQuickReferenceSections) section.id: false,
  };
  bool _loading = true;
  bool _showAllFavorites = false;
  String _searchQuery = '';

  bool get _hasSearchQuery => _searchQuery.trim().isNotEmpty;

  Set<String> get _favoriteIdSet => _favoriteIds.toSet();

  Map<String, GrammarCategory> get _categoryById => <String, GrammarCategory>{
        for (final category in _categories) category.id: category,
      };

  Map<String, GrammarPageContent> get _pageById => <String, GrammarPageContent>{
        for (final page in _pages) page.id: page,
      };

  List<GrammarQuickReferenceSection> get _matchingQuickSections {
    final query = normalizeQuickReferenceQuery(_searchQuery);
    return grammarQuickReferenceSections
        .where((section) => section.matchesQuery(query))
        .toList(growable: false);
  }

  List<GrammarPageContent> get _matchingPages {
    final pages = _pages
        .where((page) => page.matchesSearch(_searchQuery))
        .toList(growable: false);
    pages.sort(_comparePages);
    return pages;
  }

  List<GrammarPageContent> get _recentPages {
    return _recentVisits
        .map((visit) => _pageById[visit.pageId])
        .whereType<GrammarPageContent>()
        .toList(growable: false);
  }

  List<GrammarPageContent> get _favoritePages {
    return _favoriteIds
        .map((id) => _pageById[id])
        .whereType<GrammarPageContent>()
        .toList(growable: false);
  }

  List<GrammarPageContent> get _courseRelatedPages {
    final lessonId = _progress.lastLessonId;
    if (lessonId == null || lessonId.isEmpty) {
      return const <GrammarPageContent>[];
    }
    final pages = _pages
        .where((page) => page.relatedLessons.contains(lessonId))
        .toList(growable: false);
    pages.sort(_comparePages);
    return pages.take(4).toList(growable: false);
  }

  bool get _allQuickCardsExpanded => _areSectionsExpanded(
        grammarQuickReferenceSections,
      );

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanged);
    _scrollController.addListener(_handleScrollChanged);
    _loadHomeData();
  }

  @override
  void dispose() {
    _scrollSaveTimer?.cancel();
    if (_scrollController.hasClients) {
      unawaited(
        GrammarStateService.setHomeScrollOffset(_scrollController.offset),
      );
    }
    _searchController
      ..removeListener(_handleSearchChanged)
      ..dispose();
    _scrollController
      ..removeListener(_handleScrollChanged)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadHomeData() async {
    try {
      final results = await Future.wait<dynamic>([
        GrammarService.loadCategories().timeout(
          _grammarHomeLoadTimeout,
          onTimeout: () => const <GrammarCategory>[],
        ),
        GrammarService.loadPages().timeout(
          _grammarHomeLoadTimeout,
          onTimeout: () => const <GrammarPageContent>[],
        ),
        LessonService().loadLessons().timeout(
              _grammarHomeLoadTimeout,
              onTimeout: () => const <Lesson>[],
            ),
        GrammarStateService.getRecentVisits().timeout(
          _grammarHomeLoadTimeout,
          onTimeout: () => const <GrammarRecentVisit>[],
        ),
        GrammarStateService.getFavoriteIds().timeout(
          _grammarHomeLoadTimeout,
          onTimeout: () => const <String>[],
        ),
        GrammarStateService.getExpandStates().timeout(
          _grammarHomeLoadTimeout,
          onTimeout: () => <String, bool>{},
        ),
        ProgressService.getSnapshot().timeout(
          _grammarHomeLoadTimeout,
          onTimeout: () => const ProgressSnapshot(
            completedLessons: <String>{},
            startedLessons: <String>{},
            reviewCount: 0,
            streakDays: 0,
          ),
        ),
        GrammarStateService.getHomeScrollOffset().timeout(
          _grammarHomeLoadTimeout,
          onTimeout: () => 0.0,
        ),
      ]);

      if (!mounted) return;
      final expandedStates = results[5] as Map<String, bool>;
      setState(() {
        _categories = results[0] as List<GrammarCategory>;
        _pages = results[1] as List<GrammarPageContent>;
        _lessons = results[2] as List<Lesson>;
        _recentVisits = results[3] as List<GrammarRecentVisit>;
        _favoriteIds = results[4] as List<String>;
        _progress = results[6] as ProgressSnapshot;
        _expandedById = <String, bool>{
          for (final section in grammarQuickReferenceSections)
            section.id: expandedStates[section.id] ?? false,
        };
        _loading = false;
      });

      _restoreScrollOffset(results[7] as double);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _refreshActivityState() async {
    try {
      final results = await Future.wait<dynamic>([
        GrammarStateService.getRecentVisits().timeout(
          _grammarHomeLoadTimeout,
          onTimeout: () => const <GrammarRecentVisit>[],
        ),
        GrammarStateService.getFavoriteIds().timeout(
          _grammarHomeLoadTimeout,
          onTimeout: () => const <String>[],
        ),
        ProgressService.getSnapshot().timeout(
          _grammarHomeLoadTimeout,
          onTimeout: () => const ProgressSnapshot(
            completedLessons: <String>{},
            startedLessons: <String>{},
            reviewCount: 0,
            streakDays: 0,
          ),
        ),
      ]);

      if (!mounted) return;
      setState(() {
        _recentVisits = results[0] as List<GrammarRecentVisit>;
        _favoriteIds = results[1] as List<String>;
        _progress = results[2] as ProgressSnapshot;
      });
    } catch (_) {
      // Keep the current state visible if the refresh fails.
    }
  }

  void _restoreScrollOffset(double offset) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients || offset <= 0) return;
      final max = _scrollController.position.maxScrollExtent;
      _scrollController.jumpTo(offset.clamp(0.0, max));
    });
  }

  void _handleSearchChanged() {
    final nextQuery = _searchController.text;
    if (nextQuery == _searchQuery) return;
    setState(() => _searchQuery = nextQuery);
  }

  void _handleScrollChanged() {
    if (!_scrollController.hasClients) return;
    _scrollSaveTimer?.cancel();
    _scrollSaveTimer = Timer(const Duration(milliseconds: 250), () {
      if (!_scrollController.hasClients) return;
      unawaited(
        GrammarStateService.setHomeScrollOffset(_scrollController.offset),
      );
    });
  }

  Future<void> _openCategoryById(String categoryId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GrammarCategoryPage(
          categoryId: categoryId,
          settings: widget.settings,
        ),
      ),
    );
    await _refreshActivityState();
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
    await _refreshActivityState();
  }

  Future<void> _toggleFavorite(String pageId) async {
    await GrammarStateService.toggleFavorite(pageId);
    final favoriteIds = await GrammarStateService.getFavoriteIds();
    if (!mounted) return;
    final isFavorite = favoriteIds.contains(pageId);
    setState(() => _favoriteIds = favoriteIds);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite
              ? localizedText(
                  context,
                  zh: '已收藏到语法速查',
                  en: 'Saved to grammar favorites',
                )
              : localizedText(
                  context,
                  zh: '已从收藏移除',
                  en: 'Removed from favorites',
                ),
        ),
      ),
    );
  }

  Future<void> _focusQuickSection(String id) async {
    if (_hasSearchQuery) {
      _searchController.clear();
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }

    if (!(_expandedById[id] ?? false)) {
      await _setSectionExpanded(id, true);
    }

    final sectionContext = _quickSectionKeys[id]?.currentContext;
    if (!mounted || sectionContext == null || !sectionContext.mounted) return;
    await Scrollable.ensureVisible(
      sectionContext,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      alignment: 0.04,
    );
  }

  Future<void> _openShortcut(GrammarHomeShortcut shortcut) async {
    if (shortcut.pageId != null) {
      await _openPage(shortcut.pageId!);
      return;
    }
    if (shortcut.quickSectionId != null) {
      await _focusQuickSection(shortcut.quickSectionId!);
    }
  }

  Future<void> _applyHotSearch(GrammarHomeSearchChip chip) async {
    final query = isEnglishUi(context) ? chip.queryEn : chip.queryZh;
    _searchController.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    await _scrollToTop();
  }

  Future<void> _scrollToTop() async {
    if (!_scrollController.hasClients) return;
    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _scrollToFeaturedSection() async {
    final sectionContext = _featuredSectionKey.currentContext;
    if (sectionContext == null) return;
    await Scrollable.ensureVisible(
      sectionContext,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      alignment: 0.06,
    );
  }

  Future<void> _setSectionExpanded(String id, bool expanded) async {
    if (!mounted) return;
    setState(() => _expandedById[id] = expanded);
    await GrammarStateService.setExpandState(id, expanded);
  }

  void _toggleSection(String id) {
    final next = !(_expandedById[id] ?? false);
    setState(() => _expandedById[id] = next);
    unawaited(GrammarStateService.setExpandState(id, next));
  }

  bool _areSectionsExpanded(List<GrammarQuickReferenceSection> sections) {
    return sections.isNotEmpty &&
        sections.every((section) => _expandedById[section.id] ?? false);
  }

  void _setSectionsExpanded(
    List<GrammarQuickReferenceSection> sections,
    bool expanded,
  ) {
    setState(() {
      for (final section in sections) {
        _expandedById[section.id] = expanded;
        unawaited(GrammarStateService.setExpandState(section.id, expanded));
      }
    });
  }

  int _comparePages(GrammarPageContent a, GrammarPageContent b) {
    final priorityA = _pagePriority(a);
    final priorityB = _pagePriority(b);
    if (priorityA != priorityB) return priorityA.compareTo(priorityB);
    return a.title.compareTo(b.title);
  }

  int _pagePriority(GrammarPageContent page) {
    const featuredOrder = <String, int>{
      'personal_pronouns': 0,
      'negation': 1,
      'question_words': 2,
      'nominal_sentence': 3,
      'prepositions': 4,
      'numbers_basic': 5,
      'present_tense': 6,
      'gender': 7,
    };
    return featuredOrder[page.id] ?? 100;
  }

  GrammarRecentVisit? _recentVisitFor(String pageId) {
    for (final visit in _recentVisits) {
      if (visit.pageId == pageId) return visit;
    }
    return null;
  }

  Lesson? _lessonById(String? lessonId) {
    if (lessonId == null) return null;
    for (final lesson in _lessons) {
      if (lesson.id == lessonId) return lesson;
    }
    return null;
  }

  String _pageSummary(GrammarPageContent page) {
    final meaningLanguage = context.appSettings.meaningLanguage;
    final value = page.subtitle.isNotEmpty ? page.subtitle : page.summary;
    return grammarContentText(value, meaningLanguage);
  }

  String _categoryLabel(GrammarPageContent page) {
    final category = _categoryById[page.category];
    if (category == null) return '';
    return grammarUiText(category.title, context.appSettings.appLanguage);
  }

  String _difficultyLabel(String raw) {
    switch (raw.toLowerCase()) {
      case 'basic':
        return localizedText(context, zh: '基础', en: 'Basic');
      case 'intermediate':
        return localizedText(context, zh: '进阶', en: 'Intermediate');
      default:
        return localizedText(context, zh: '入门', en: 'Starter');
    }
  }

  String _relativeTimeLabel(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inMinutes < 1) {
      return localizedText(context, zh: '刚刚查看', en: 'Viewed just now');
    }
    if (difference.inHours < 1) {
      return localizedText(
        context,
        zh: '${difference.inMinutes} 分钟前查看',
        en: 'Viewed ${difference.inMinutes}m ago',
      );
    }
    if (difference.inDays < 1) {
      return localizedText(
        context,
        zh: '${difference.inHours} 小时前查看',
        en: 'Viewed ${difference.inHours}h ago',
      );
    }
    if (difference.inDays == 1) {
      return localizedText(context, zh: '昨天查看', en: 'Viewed yesterday');
    }
    if (difference.inDays < 7) {
      return localizedText(
        context,
        zh: '${difference.inDays} 天前查看',
        en: 'Viewed ${difference.inDays}d ago',
      );
    }
    final weeks = (difference.inDays / 7).floor();
    return localizedText(
      context,
      zh: '$weeks 周前查看',
      en: 'Viewed ${weeks}w ago',
    );
  }

  List<String> _chipsForPage(
    GrammarPageContent page, {
    bool includeFavorite = false,
  }) {
    final chips = <String>[_difficultyLabel(page.difficulty)];
    final category = _categoryLabel(page);
    if (category.isNotEmpty) {
      chips.add(category);
    }
    if (page.isHighFrequency) {
      chips.add(localizedText(context, zh: '高频', en: 'High Frequency'));
    }
    if (includeFavorite && _favoriteIdSet.contains(page.id)) {
      chips.add(localizedText(context, zh: '已收藏', en: 'Saved'));
    }
    return chips;
  }

  Widget _buildPageCard(
    GrammarPageContent page, {
    String? statusLabel,
    bool includeFavoriteChip = false,
  }) {
    final appLanguage = context.appSettings.appLanguage;
    return GrammarHomeTopicCard(
      title: grammarUiText(page.title, appLanguage),
      subtitle: _pageSummary(page),
      chips: _chipsForPage(
        page,
        includeFavorite: includeFavoriteChip,
      ),
      statusLabel: statusLabel,
      favorite: _favoriteIdSet.contains(page.id),
      onTap: () => _openPage(page.id),
      onLongPress: () => _toggleFavorite(page.id),
      onToggleFavorite: () => _toggleFavorite(page.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadHomeData,
          child: ListView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              _buildHeader(context),
              const SizedBox(height: 18),
              if (_hasSearchQuery)
                _buildSearchResults(context)
              else ...<Widget>[
                _buildShortcutSection(context),
                const SizedBox(height: 18),
                _buildCategorySection(context),
                const SizedBox(height: 18),
                _buildProblemSection(context),
                const SizedBox(height: 18),
                _buildRecentSection(context),
                const SizedBox(height: 18),
                _buildFavoritesSection(context),
                if (_courseRelatedPages.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _buildCourseRelatedSection(context),
                ],
                const SizedBox(height: 18),
                _buildQuickReferenceSection(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _TopBackButton(onTap: () => Navigator.pop(context)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                localizedText(
                  context,
                  zh: '语法速查',
                  en: 'Grammar Quick Reference',
                ),
                style: text.titleLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[
                Color(0xFFF7EAD8),
                Color(0xFFE4F4EC),
                Color(0xFFE8F1FA),
              ],
              stops: <double>[0.0, 0.58, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 26,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizedText(
                  context,
                  zh: '语法速查',
                  en: 'Grammar Quick Reference',
                ),
                style: text.headlineMedium?.copyWith(
                  color: const Color(0xFF24313A),
                  fontWeight: FontWeight.w800,
                  height: 1.08,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                localizedText(
                  context,
                  zh: '快速查看常用阿语基础语法规则',
                  en: 'Quickly review the most common beginner Arabic grammar rules.',
                ),
                style: text.bodyMedium?.copyWith(
                  color: const Color(0xFF4F6775),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                localizedText(
                  context,
                  zh: '按主题、问题或关键词快速查找语法点',
                  en: 'Search by topic, question, or keyword.',
                ),
                style: text.labelLarge?.copyWith(
                  color: const Color(0xFF4B6358),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: localizedText(
                    context,
                    zh: '搜索：否定、介词、数字、名词句、动词句…',
                    en: 'Search: negation, prepositions, numbers, nominal sentences...',
                  ),
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _hasSearchQuery
                      ? IconButton(
                          onPressed: _searchController.clear,
                          icon: const Icon(Icons.close_rounded),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.92),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: grammarHomeSearchChips
                    .map(
                      (chip) => ActionChip(
                        backgroundColor: Colors.white.withOpacity(0.9),
                        side: const BorderSide(color: AppTheme.strokeLight),
                        label: Text(
                          isEnglishUi(context) ? chip.labelEn : chip.labelZh,
                        ),
                        onPressed: () => _applyHotSearch(chip),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    final quickSections = _matchingQuickSections;
    final pages = _matchingPages;
    final total = quickSections.length + pages.length;

    if (total == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            title: localizedText(context, zh: '搜索结果', en: 'Search Results'),
            subtitle: localizedText(
              context,
              zh: '没有找到匹配内容，试试更短的关键词或换一种说法。',
              en: 'No matches found. Try a shorter keyword or another phrase.',
            ),
          ),
          const SizedBox(height: 12),
          GrammarHomeEmptyStateCard(
            title: localizedText(
              context,
              zh: '没有找到对应语法点',
              en: 'No matching grammar topic found',
            ),
            subtitle: localizedText(
              context,
              zh: '可以试试“不是”“我你他”“介词”“1-10”“怎么提问”这类更接近日常问题的关键词。',
              en: 'Try everyday keywords such as “not”, “pronouns”, “prepositions”, “1-10”, or “questions”.',
            ),
            actionLabel: localizedText(
              context,
              zh: '清空搜索',
              en: 'Clear Search',
            ),
            onActionTap: _searchController.clear,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: localizedText(context, zh: '搜索结果', en: 'Search Results'),
          subtitle: localizedText(
            context,
            zh: '共找到 $total 条结果，优先把适合一眼扫懂的内容放在前面。',
            en: '$total results found, with the easiest quick-scan content first.',
          ),
        ),
        if (quickSections.isNotEmpty) ...[
          const SizedBox(height: 14),
          SectionTitle(
            title: localizedText(
              context,
              zh: '一眼速查卡片',
              en: 'Quick-Scan Cards',
            ),
            subtitle: localizedText(
              context,
              zh: '点开即可查看入门说明和短例句。',
              en: 'Tap to expand beginner-friendly notes and short examples.',
            ),
            trailing: TextButton(
              onPressed: () => _setSectionsExpanded(
                quickSections,
                !_areSectionsExpanded(quickSections),
              ),
              child: Text(
                _areSectionsExpanded(quickSections)
                    ? localizedText(context, zh: '全部收起', en: 'Collapse All')
                    : localizedText(context, zh: '全部展开', en: 'Expand All'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...quickSections.map(
            (section) => Padding(
              key: _quickSectionKeys[section.id],
              padding: const EdgeInsets.only(bottom: 14),
              child: GrammarQuickReferenceCard(
                section: section,
                expanded: _expandedById[section.id] ?? false,
                onToggle: () => _toggleSection(section.id),
              ),
            ),
          ),
        ],
        if (pages.isNotEmpty) ...[
          const SizedBox(height: 4),
          SectionTitle(
            title: localizedText(
              context,
              zh: '更完整的语法页',
              en: 'Detailed Grammar Pages',
            ),
            subtitle: localizedText(
              context,
              zh: '适合继续深入看表格、规则和例句。',
              en: 'Open the fuller page when you need tables, rules, and examples.',
            ),
          ),
          const SizedBox(height: 12),
          ...pages.map(
            (page) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildPageCard(page),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildShortcutSection(BuildContext context) {
    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            title: localizedText(context, zh: '高频速查', en: 'Quick Lookup'),
            subtitle: localizedText(
              context,
              zh: '你很多时候只是来补一个洞，这里优先放最常查的入口。',
              en: 'Many visits are just to fill one gap quickly, so the most-used entries come first.',
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: grammarHomeShortcuts
                .map(
                  (shortcut) => GrammarHomeActionChip(
                    label: isEnglishUi(context)
                        ? shortcut.labelEn
                        : shortcut.labelZh,
                    icon: shortcut.icon,
                    onTap: () => _openShortcut(shortcut),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: localizedText(context, zh: '按主题找', en: 'Browse by Theme'),
          subtitle: localizedText(
            context,
            zh: '把大卡片压缩成更快定位的分类入口，适合先按大方向查。',
            en: 'Compact category entry points make browsing much faster.',
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: grammarHomeCategoryShortcuts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.92,
          ),
          itemBuilder: (context, index) {
            final shortcut = grammarHomeCategoryShortcuts[index];
            return GrammarHomeCategoryTile(
              title: isEnglishUi(context) ? shortcut.titleEn : shortcut.titleZh,
              subtitle: isEnglishUi(context)
                  ? shortcut.subtitleEn
                  : shortcut.subtitleZh,
              icon: shortcut.icon,
              tintColor: shortcut.tintColor,
              onTap: () => _openCategoryById(shortcut.categoryId),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProblemSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: localizedText(
            context,
            zh: '你可能想查',
            en: 'You May Want to Check',
          ),
          subtitle: localizedText(
            context,
            zh: '不懂术语也没关系，按问题找更接近真实学习场景。',
            en: 'You do not need grammar terms to find the right answer.',
          ),
        ),
        const SizedBox(height: 12),
        ...grammarHomeProblemShortcuts.map(
          (shortcut) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GrammarHomeProblemTile(
              title: isEnglishUi(context)
                  ? shortcut.questionEn
                  : shortcut.questionZh,
              subtitle: isEnglishUi(context)
                  ? shortcut.subtitleEn
                  : shortcut.subtitleZh,
              onTap: () => _openPage(shortcut.pageId),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSection(BuildContext context) {
    final recentPages = _recentPages;
    if (recentPages.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            title: localizedText(
              context,
              zh: '继续查看',
              en: 'Continue Reading',
            ),
            subtitle: localizedText(
              context,
              zh: '你查过的语法点会留在这里，方便回到上次的位置。',
              en: 'Recently opened grammar topics stay here for quick return visits.',
            ),
          ),
          const SizedBox(height: 12),
          GrammarHomeEmptyStateCard(
            title: localizedText(
              context,
              zh: '还没有最近查看内容',
              en: 'No recent grammar topics yet',
            ),
            subtitle: localizedText(
              context,
              zh: '点开任意语法点后，这里会自动记录，方便你下次接着看。',
              en: 'Open any grammar topic and it will appear here for quick follow-up.',
            ),
            actionLabel: localizedText(
              context,
              zh: '看看高频语法点',
              en: 'See Featured Topics',
            ),
            onActionTap: _scrollToFeaturedSection,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: localizedText(context, zh: '继续查看', en: 'Continue Reading'),
          subtitle: localizedText(
            context,
            zh: '查完以后能自然回到刚才的语法点，减少来回切换成本。',
            en: 'Jump back into the grammar topic you checked last time.',
          ),
        ),
        const SizedBox(height: 12),
        ...recentPages.take(5).map(
              (page) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildPageCard(
                  page,
                  statusLabel: _relativeTimeLabel(
                    _recentVisitFor(page.id)?.visitedAt ?? DateTime.now(),
                  ),
                  includeFavoriteChip: true,
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildFavoritesSection(BuildContext context) {
    final favoritePages = _favoritePages;
    final visibleFavorites = _showAllFavorites
        ? favoritePages
        : favoritePages.take(3).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: localizedText(context, zh: '收藏内容', en: 'Saved Topics'),
          subtitle: localizedText(
            context,
            zh: '遇到想反复回看的语法点，点星标就会留在这里。',
            en: 'Star the grammar topics you expect to revisit often.',
          ),
          trailing: favoritePages.length > 3
              ? TextButton(
                  onPressed: () {
                    setState(() => _showAllFavorites = !_showAllFavorites);
                  },
                  child: Text(
                    _showAllFavorites
                        ? localizedText(context, zh: '收起', en: 'Show Less')
                        : localizedText(context, zh: '查看全部', en: 'View All'),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 12),
        if (favoritePages.isEmpty)
          GrammarHomeEmptyStateCard(
            title: localizedText(
              context,
              zh: '还没有收藏内容',
              en: 'No saved grammar topics yet',
            ),
            subtitle: localizedText(
              context,
              zh: '遇到想反复回看的语法点，点星标收藏到这里。',
              en: 'When a grammar point feels worth revisiting, tap the star and it will stay here.',
            ),
            actionLabel: localizedText(
              context,
              zh: '去看看高频语法点',
              en: 'Explore Featured Topics',
            ),
            onActionTap: _scrollToFeaturedSection,
          )
        else
          ...visibleFavorites.map(
            (page) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildPageCard(
                page,
                statusLabel: localizedText(
                  context,
                  zh: '长按卡片也可以快速取消收藏',
                  en: 'Long-press the card to remove it from saved topics',
                ),
                includeFavoriteChip: true,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCourseRelatedSection(BuildContext context) {
    final lesson = _lessonById(_progress.lastLessonId);
    final lessonTitle = lesson == null
        ? ''
        : LessonLocalizer.title(lesson, context.appSettings.appLanguage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: localizedText(
            context,
            zh: '本课相关语法',
            en: 'Grammar for Your Current Lesson',
          ),
          subtitle: lessonTitle.isEmpty
              ? localizedText(
                  context,
                  zh: '根据你最近的课程学习位置，优先推荐此刻更有帮助的语法点。',
                  en: 'Based on your recent lesson progress, these topics should help right now.',
                )
              : localizedText(
                  context,
                  zh: '基于你最近学习的“$lessonTitle”，优先推荐更相关的语法点。',
                  en: 'Recommended from your recent lesson: $lessonTitle.',
                ),
        ),
        const SizedBox(height: 12),
        ..._courseRelatedPages.map(
          (page) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildPageCard(
              page,
              statusLabel: localizedText(
                context,
                zh: '查完后可直接回到课程继续学习',
                en: 'Review it now, then head back to the lesson.',
              ),
              includeFavoriteChip: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickReferenceSection(BuildContext context) {
    return Column(
      key: _featuredSectionKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: localizedText(
            context,
            zh: '高频语法点',
            en: 'Featured Quick Cards',
          ),
          subtitle: localizedText(
            context,
            zh: '这里保留适合初学者“一眼扫懂”的语法卡片，点开就能看重点、例子和记忆提示。',
            en: 'These quick cards keep the most beginner-friendly explanations visible first.',
          ),
          trailing: TextButton(
            onPressed: () => _setSectionsExpanded(
              grammarQuickReferenceSections,
              !_allQuickCardsExpanded,
            ),
            child: Text(
              _allQuickCardsExpanded
                  ? localizedText(context, zh: '全部收起', en: 'Collapse All')
                  : localizedText(context, zh: '全部展开', en: 'Expand All'),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...grammarQuickReferenceSections.map(
          (section) => Padding(
            key: _quickSectionKeys[section.id],
            padding: const EdgeInsets.only(bottom: 14),
            child: GrammarQuickReferenceCard(
              section: section,
              expanded: _expandedById[section.id] ?? false,
              onToggle: () => _toggleSection(section.id),
            ),
          ),
        ),
      ],
    );
  }
}

class _TopBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _TopBackButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.primaryText,
            size: 20,
          ),
        ),
      ),
    );
  }
}
