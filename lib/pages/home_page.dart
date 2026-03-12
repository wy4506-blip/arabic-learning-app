import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../models/lesson.dart';
import '../services/lesson_service.dart';
import '../services/progress_service.dart';
import '../services/unlock_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'alphabet_hub_page.dart';
import 'course_list_page.dart';
import 'lesson_detail_page.dart';
import 'review_page.dart';
import 'unlock_page.dart';
import 'vocab_book_page.dart';

class HomePage extends StatefulWidget {
  final AppSettings settings;
  final ValueChanged<int> onOpenTab;

  const HomePage({
    super.key,
    required this.settings,
    required this.onOpenTab,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _unlocked = false;
  bool _loading = true;
  List<Lesson> _lessons = const [];
  ProgressSnapshot _progress = const ProgressSnapshot(
    completedLessons: <String>{},
    startedLessons: <String>{},
    reviewCount: 0,
    streakDays: 0,
  );

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final unlocked = await UnlockService.isUnlocked();
    final lessons = await LessonService().loadLessons();
    final progress = await ProgressService.getSnapshot();
    if (!mounted) return;
    setState(() {
      _unlocked = unlocked;
      _lessons = lessons;
      _progress = progress;
      _loading = false;
    });
  }

  Lesson? get _nextLesson {
    for (final lesson in _lessons) {
      final locked = lesson.isLocked && !_unlocked;
      if (locked) continue;
      if (!_progress.completedLessons.contains(lesson.id)) {
        return lesson;
      }
    }
    return _lessons.isEmpty ? null : _lessons.first;
  }

  Future<void> _openUnlock() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UnlockPage()),
    );
    if (result == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final text = Theme.of(context).textTheme;
    final nextLesson = _nextLesson;
    final learned = _progress.completedLessons.length;
    final toReview = (_progress.startedLessons.length - learned).clamp(0, 999);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: AppTheme.pagePadding,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.strokeLight),
                    ),
                    child: const Icon(Icons.auto_stories_rounded, color: AppTheme.accentMintDark),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('今天从这里开始', style: text.titleLarge),
                        const SizedBox(height: 2),
                        Text('أبا أبا · 阿语入门', style: text.bodyMedium),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _openUnlock,
                    icon: Icon(_unlocked ? Icons.verified_rounded : Icons.lock_outline_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AppSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _MetricTile(label: 'Learned', value: '$learned', onTap: () => widget.onOpenTab(1)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricTile(label: 'To Review', value: '$toReview', onTap: () => widget.onOpenTab(2)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(nextLesson == null ? '继续新课' : '继续课程', style: text.labelMedium?.copyWith(color: AppTheme.accentMintDark)),
                    const SizedBox(height: 8),
                    Text(nextLesson?.titleCn ?? '从字母开始', style: text.headlineMedium),
                    const SizedBox(height: 4),
                    Text(nextLesson?.titleAr ?? 'ابدأ من الحروف', style: const TextStyle(fontSize: 28, height: 1.35, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(nextLesson == null ? '先完成字母与发音，再逐步进入正式课程。' : '首屏聚焦开始学习 → 继续课程 → 复习 → 单词本。', style: text.bodyMedium),
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: () async {
                        if (nextLesson == null) {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AlphabetHubPage()));
                        } else {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => LessonDetailPage(lesson: nextLesson, settings: widget.settings, isUnlocked: _unlocked)));
                          await _load();
                        }
                      },
                      child: Text(nextLesson == null ? '开始字母学习' : '继续学习'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AppSurface(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('特色技能卡', style: text.labelMedium?.copyWith(color: AppTheme.accentMintDark)),
                          const SizedBox(height: 8),
                          Text('字母与发音', style: text.titleLarge),
                          const SizedBox(height: 4),
                          Text('从基础字母、辨析、听读开始，降低新手进入门槛。', style: text.bodyMedium),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () async => Navigator.push(context, MaterialPageRoute(builder: (_) => const AlphabetHubPage())),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF0FBF7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: AppTheme.accentMintDark, size: 30),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SectionTitle(title: '核心入口', subtitle: 'Lessons / Review / Wordbook / Alphabet'),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.15,
                children: [
                  _QuickEntry(icon: Icons.menu_book_rounded, title: 'Lessons', subtitle: '查看课程阶段', onTap: () => widget.onOpenTab(1)),
                  _QuickEntry(icon: Icons.refresh_rounded, title: 'Review', subtitle: '进入今日复习', badge: toReview > 0 ? '$toReview' : null, onTap: () => widget.onOpenTab(2)),
                  _QuickEntry(icon: Icons.bookmark_outline_rounded, title: 'Wordbook', subtitle: '词汇收藏与检索', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VocabBookPage()))),
                  _QuickEntry(icon: Icons.sort_by_alpha_rounded, title: 'Alphabet', subtitle: '字母入门与练习', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AlphabetHubPage()))),
                ],
              ),
              const SizedBox(height: 20),
              if (!_unlocked)
                AppSurface(
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline_rounded, color: AppTheme.accentMintDark),
                      const SizedBox(width: 10),
                      Expanded(child: Text('Lesson 4+ 可作为内容包解锁，不在首页做强打断。', style: text.bodyMedium)),
                      TextButton(onPressed: _openUnlock, child: const Text('解锁')),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _MetricTile({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700, height: 1.0)),
        ],
      ),
    );
  }
}

class _QuickEntry extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;

  const _QuickEntry({required this.icon, required this.title, required this.subtitle, this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      onTap: onTap,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: AppTheme.bgCardSoft, borderRadius: BorderRadius.circular(20)),
                child: Icon(icon, color: AppTheme.accentMintDark),
              ),
              const Spacer(),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          if (badge != null)
            Positioned(
              right: 0,
              top: 0,
              child: Pill(label: badge!, backgroundColor: const Color(0xFFF0FBF7)),
            ),
        ],
      ),
    );
  }
}
