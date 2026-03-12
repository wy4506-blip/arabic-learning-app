import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../models/lesson.dart';
import '../models/word_item.dart';
import '../services/progress_service.dart';
import '../services/vocab_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'lesson_quiz_page.dart';

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
  final Set<String> _saved = {};
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final snapshot = await ProgressService.getSnapshot();
    if (!mounted) return;
    setState(() => _completed = snapshot.completedLessons.contains(widget.lesson.id));
  }

  String _displayArabic(String text) {
    switch (widget.settings.textMode) {
      case ArabicTextMode.withDiacritics:
        return text;
      case ArabicTextMode.dual:
        final plain = removeArabicDiacritics(text);
        return plain == text ? text : '$text\n$plain';
      case ArabicTextMode.withoutDiacritics:
        return removeArabicDiacritics(text);
    }
  }

  Future<void> _saveWord(LessonWord word) async {
    await VocabService.toggleFavorite(
      WordItem(
        arabic: word.arabic,
        pronunciation: word.transliteration,
        meaning: word.chinese,
      ),
    );
    if (!mounted) return;
    setState(() => _saved.add(word.arabic));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已加入单词本')));
  }

  Future<void> _start() async {
    if (widget.lesson.isLocked && !widget.isUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('当前课时需要解锁后继续')));
      return;
    }
    await ProgressService.markLessonStarted(widget.lesson.id);
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LessonQuizPage(lesson: widget.lesson)),
    );
    if (result == true) {
      await ProgressService.markLessonCompleted(widget.lesson.id);
      if (!mounted) return;
      setState(() => _completed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final locked = lesson.isLocked && !widget.isUnlocked;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(lesson.titleCn)),
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
                    Pill(label: '${lesson.estimatedMinutes} 分钟'),
                    const Spacer(),
                    if (locked) const Icon(Icons.lock_outline_rounded),
                  ],
                ),
                const SizedBox(height: 14),
                Text(lesson.titleCn, style: text.headlineMedium),
                const SizedBox(height: 6),
                Text(_displayArabic(lesson.titleAr), style: const TextStyle(fontSize: 30, height: 1.4, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: lesson.objectives.take(3).map((e) => Pill(label: e)).toList()),
                const SizedBox(height: 18),
                FilledButton(onPressed: _start, child: Text(_completed ? '复习本课' : '开始学习')),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionTitle(title: '模块结构', subtitle: 'Vocabulary / Dialogue / Grammar / Exercise'),
          const SizedBox(height: 12),
          ...[
            _ModuleCard(title: 'Vocabulary', count: lesson.vocabulary.length, subtitle: '优先掌握高频词'),
            _ModuleCard(title: 'Dialogue', count: lesson.dialogues.length, subtitle: '把词放进真实交流'),
            _ModuleCard(title: 'Grammar', count: lesson.grammarTitle.isEmpty ? 0 : 1, subtitle: lesson.grammarTitle.isEmpty ? '待补充' : lesson.grammarTitle),
            _ModuleCard(title: 'Exercise', count: lesson.exercises.length, subtitle: '答题强化记忆'),
          ].map((e) => Padding(padding: const EdgeInsets.only(bottom: 10), child: e)),
          if (lesson.vocabulary.isNotEmpty) ...[
            const SizedBox(height: 10),
            SectionTitle(title: '核心词汇', subtitle: '阿语字号更大，布局克制稳定'),
            const SizedBox(height: 12),
            ...lesson.vocabulary.map((word) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppSurface(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_displayArabic(word.arabic), style: const TextStyle(fontSize: 28, height: 1.45, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(word.chinese, style: text.titleSmall),
                              const SizedBox(height: 4),
                              Text(word.transliteration, style: text.bodyMedium),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _saveWord(word),
                          icon: Icon(_saved.contains(word.arabic) ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
          if (lesson.dialogues.isNotEmpty) ...[
            const SizedBox(height: 10),
            SectionTitle(title: '对话', subtitle: '长文本允许纵向展开，不强行压缩'),
            const SizedBox(height: 12),
            AppSurface(
              child: Column(
                children: lesson.dialogues.map((line) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(radius: 14, backgroundColor: AppTheme.bgCardSoft, child: Text(line.speaker, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary))),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_displayArabic(line.arabic), style: const TextStyle(fontSize: 24, height: 1.45, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(line.transliteration, style: text.bodySmall),
                            const SizedBox(height: 4),
                            Text(line.chinese, style: text.bodyMedium),
                          ],
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ],
          const SizedBox(height: 10),
          SectionTitle(title: '语法点', subtitle: '只讲这一课最关键的一点'),
          const SizedBox(height: 12),
          AppSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lesson.grammarTitle, style: text.titleMedium),
                const SizedBox(height: 8),
                Text(lesson.grammarExplanation, style: text.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String title;
  final int count;
  final String subtitle;

  const _ModuleCard({required this.title, required this.count, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: AppTheme.bgCardSoft, borderRadius: BorderRadius.circular(18)),
            child: const Icon(Icons.grid_view_rounded, color: AppTheme.accentMintDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 3),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Pill(label: '$count'),
        ],
      ),
    );
  }
}
