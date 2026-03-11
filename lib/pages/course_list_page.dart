import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../services/lesson_service.dart';
import '../theme/app_theme.dart';
import 'lesson_detail_page.dart';

class CourseListPage extends StatefulWidget {
  final bool isUnlocked;

  const CourseListPage({
    super.key,
    required this.isUnlocked,
  });

  @override
  State<CourseListPage> createState() => _CourseListPageState();
}

class _CourseListPageState extends State<CourseListPage> {
  late Future<Map<String, List<Lesson>>> _futureLessons;

  @override
  void initState() {
    super.initState();
    _futureLessons = LessonService().loadLessonsGroupedByUnit();
  }

  String _unitTitle(String unitId) {
    switch (unitId) {
      case 'U1':
        return 'Unit 1 · 字母与发音';
      case 'U2':
        return 'Unit 2 · 基础交流';
      case 'U3':
        return 'Unit 3 · 生活场景';
      case 'U4':
        return 'Unit 4 · 表达扩展';
      default:
        return unitId;
    }
  }

  bool _canOpenLesson(Lesson lesson) {
    if (widget.isUnlocked) return true;
    const freeLessonIds = {'U1L1', 'U1L2', 'U2L7'};
    return freeLessonIds.contains(lesson.id);
  }

  String _categoryLabel(String category) {
    switch (category) {
      case 'alphabet':
        return '字母';
      case 'dialogue':
        return '对话';
      case 'grammar':
        return '语法';
      case 'review':
        return '复习';
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('全部课程'),
      ),
      body: FutureBuilder<Map<String, List<Lesson>>>(
        future: _futureLessons,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('课程加载失败：${snapshot.error}'),
              ),
            );
          }

          final grouped = snapshot.data ?? {};
          final unitIds = grouped.keys.toList()..sort();

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            itemCount: unitIds.length,
            itemBuilder: (context, index) {
              final unitId = unitIds[index];
              final lessons = grouped[unitId] ?? [];

              return Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _unitTitle(unitId),
                      style: text.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '循序渐进地完成这一单元内容。',
                      style: text.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    ...lessons.map((lesson) {
                      final canOpen = _canOpenLesson(lesson);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: canOpen
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            LessonDetailPage(lesson: lesson),
                                      ),
                                    );
                                  }
                                : () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('该课程需要解锁后学习'),
                                      ),
                                    );
                                  },
                            child: Ink(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: AppTheme.border,
                                  width: 0.6,
                                ),
                                boxShadow: AppTheme.softShadow,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: canOpen
                                          ? AppTheme.softAccent
                                          : const Color(0xFFF0F1F4),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Icon(
                                      canOpen
                                          ? Icons.play_arrow_rounded
                                          : Icons.lock_outline_rounded,
                                      color: canOpen
                                          ? AppTheme.deepAccent
                                          : AppTheme.tertiaryText,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lesson.titleCn,
                                          style: text.titleMedium,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          lesson.titleAr,
                                          textDirection: TextDirection.rtl,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.primaryText,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            _InfoPill(
                                              label: _categoryLabel(
                                                  lesson.category),
                                            ),
                                            _InfoPill(
                                              label: '难度 ${lesson.difficulty}',
                                            ),
                                            _InfoPill(
                                              label:
                                                  '${lesson.estimatedMinutes} 分钟',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    canOpen
                                        ? Icons.chevron_right_rounded
                                        : Icons.lock_rounded,
                                    color: canOpen
                                        ? AppTheme.tertiaryText
                                        : AppTheme.secondaryText,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;

  const _InfoPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppTheme.secondaryText,
        ),
      ),
    );
  }
}
