import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../models/lesson.dart';
import '../services/lesson_service.dart';
import '../services/progress_service.dart';
import '../services/unlock_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'lesson_detail_page.dart';

class CourseListPage extends StatefulWidget {
  final AppSettings settings;

  const CourseListPage({super.key, required this.settings});

  @override
  State<CourseListPage> createState() => _CourseListPageState();
}

enum LessonFilter { all, notStarted, inProgress, completed }

class _CourseListPageState extends State<CourseListPage> {
  bool _loading = true;
  bool _unlocked = false;
  List<Lesson> _lessons = const [];
  ProgressSnapshot _progress = const ProgressSnapshot(
    completedLessons: <String>{},
    startedLessons: <String>{},
    reviewCount: 0,
    streakDays: 0,
  );
  LessonFilter _filter = LessonFilter.all;
  final Map<String, bool> _expanded = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final lessons = await LessonService().loadLessons();
    final unlocked = await UnlockService.isUnlocked();
    final progress = await ProgressService.getSnapshot();
    if (!mounted) return;
    setState(() {
      _lessons = lessons;
      _unlocked = unlocked;
      _progress = progress;
      for (final unit in lessons.map((e) => e.unitId).toSet()) {
        _expanded.putIfAbsent(unit, () => unit == 'U1');
      }
      _loading = false;
    });
  }

  String _unitTitle(String unitId) {
    switch (unitId) {
      case 'U1':
        return '字母与发音';
      case 'U2':
        return '基础交流';
      case 'U3':
        return '生活场景';
      case 'U4':
        return '表达扩展';
      default:
        return unitId;
    }
  }

  List<Lesson> _filtered(List<Lesson> input) {
    return input.where((lesson) {
      switch (_filter) {
        case LessonFilter.all:
          return true;
        case LessonFilter.notStarted:
          return !_progress.startedLessons.contains(lesson.id);
        case LessonFilter.inProgress:
          return _progress.startedLessons.contains(lesson.id) &&
              !_progress.completedLessons.contains(lesson.id);
        case LessonFilter.completed:
          return _progress.completedLessons.contains(lesson.id);
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final grouped = <String, List<Lesson>>{};
    for (final lesson in _lessons) {
      grouped.putIfAbsent(lesson.unitId, () => []).add(lesson);
    }
    final completed = _progress.completedLessons.length;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: AppTheme.pagePadding,
          children: [
            SectionTitle(title: 'Lessons', subtitle: '明确当前阶段、下一步学什么、哪些已解锁'),
            const SizedBox(height: 16),
            AppSurface(
              child: Row(
                children: [
                  Expanded(child: Text('已完成 $completed / ${_lessons.length} 课时', style: Theme.of(context).textTheme.titleMedium)),
                  SizedBox(
                    width: 90,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        minHeight: 8,
                        value: _lessons.isEmpty ? 0 : completed / _lessons.length,
                        backgroundColor: AppTheme.bgCardSoft,
                        color: AppTheme.accentMintDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: LessonFilter.values.map((filter) {
                  final selected = _filter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_labelForFilter(filter)),
                      selected: selected,
                      onSelected: (_) => setState(() => _filter = filter),
                      selectedColor: const Color(0xFFF0FBF7),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppTheme.strokeLight)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            ...grouped.entries.map((entry) {
              final lessons = _filtered(entry.value);
              if (lessons.isEmpty) return const SizedBox.shrink();
              final expanded = _expanded[entry.key] ?? false;
              final unitCompleted = entry.value.where((e) => _progress.completedLessons.contains(e.id)).length;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  children: [
                    AppSurface(
                      onTap: () => setState(() => _expanded[entry.key] = !expanded),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Unit ${entry.key.replaceAll('U', '')} · ${_unitTitle(entry.key)}', style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 4),
                                Text('$unitCompleted / ${entry.value.length} 已完成', style: Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ),
                          Transform.rotate(
                            angle: expanded ? 1.57 : 0,
                            child: const Icon(Icons.chevron_right_rounded),
                          ),
                        ],
                      ),
                    ),
                    if (expanded) ...[
                      const SizedBox(height: 10),
                      ...lessons.map((lesson) {
                        final locked = lesson.isLocked && !_unlocked;
                        final done = _progress.completedLessons.contains(lesson.id);
                        final started = _progress.startedLessons.contains(lesson.id);
                        final status = done ? 'done' : started ? 'in-progress' : locked ? 'locked' : 'free';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AppSurface(
                            onTap: () async {
                              await Navigator.push(context, MaterialPageRoute(builder: (_) => LessonDetailPage(lesson: lesson, settings: widget.settings, isUnlocked: _unlocked)));
                              await _load();
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(color: AppTheme.bgCardSoft, borderRadius: BorderRadius.circular(18)),
                                  child: Text(lesson.id.replaceAll(entry.key, ''), style: Theme.of(context).textTheme.titleSmall),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(lesson.titleCn, style: Theme.of(context).textTheme.titleSmall),
                                      const SizedBox(height: 4),
                                      Text(lesson.titleAr, style: const TextStyle(fontSize: 20, height: 1.35, fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 4),
                                      Text('${lesson.estimatedMinutes} 分钟', style: Theme.of(context).textTheme.bodySmall),
                                    ],
                                  ),
                                ),
                                Pill(label: status, icon: locked ? Icons.lock_outline_rounded : done ? Icons.check_rounded : Icons.play_arrow_rounded),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _labelForFilter(LessonFilter filter) {
    switch (filter) {
      case LessonFilter.all:
        return '全部';
      case LessonFilter.notStarted:
        return '未学';
      case LessonFilter.inProgress:
        return '学习中';
      case LessonFilter.completed:
        return '已完成';
    }
  }
}
