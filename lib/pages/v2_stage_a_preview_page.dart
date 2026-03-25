import 'package:flutter/material.dart';

import '../data/generated_stage_a_preview_lessons.dart';
import '../l10n/localized_text.dart';
import '../models/app_settings.dart';
import '../models/v2_micro_lesson.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'v2_micro_lesson_page.dart';

class V2StageAPreviewPage extends StatelessWidget {
  final AppSettings settings;

  const V2StageAPreviewPage({
    super.key,
    required this.settings,
  });

  Future<void> _openLesson(
    BuildContext context,
    V2MicroLesson lesson,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => V2MicroLessonPage(
          settings: settings,
          lesson: lesson,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EC),
      appBar: AppBar(
        title: Text(
          localizedText(
            context,
            zh: 'Stage A Preview',
            en: 'Stage A Preview',
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: AppTheme.pagePadding,
          children: [
            SectionTitle(
              title: localizedText(
                context,
                zh: 'First Chapter',
                en: 'First Chapter',
              ),
              subtitle: localizedText(
                context,
                zh:
                    'Preview the revised four-lesson chapter in order: enter Arabic through one real word, win the first true word lesson, see connection inside a real word, then read known words with beginner support and a tiny usage glimpse.',
                en:
                    'Preview the revised four-lesson chapter in order: enter Arabic through one real word, win the first true word lesson, see connection inside a real word, then read known words with beginner support and a tiny usage glimpse.',
              ),
            ),
            const SizedBox(height: 16),
            AppSurface(
              child: Text(
                localizedText(
                  context,
                  zh:
                      'This chapter preview is local only. It does not change the live home recommendation, formal lesson progress, or real review plan.',
                  en:
                      'This chapter preview is local only. It does not change the live home recommendation, formal lesson progress, or real review plan.',
                ),
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),
            AppSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizedText(
                      context,
                      zh: 'Quick Jump',
                      en: 'Quick Jump',
                    ),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List<Widget>.generate(
                      stageAFoundationPreviewLessons.length,
                      (index) {
                        final lesson = stageAFoundationPreviewLessons[index];
                        final descriptor = stageAPreviewDescriptorForLessonId(
                          lesson.lessonId,
                        );
                        return ActionChip(
                          key: ValueKey<String>(
                            'stage_a_quick_jump_${lesson.lessonId}',
                          ),
                          label: Text(
                            descriptor == null
                                ? 'Lesson ${index + 1}'
                                : 'L${index + 1}: ${descriptor.chapterRole}',
                          ),
                          onPressed: () => _openLesson(context, lesson),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...List<Widget>.generate(
              stageAFoundationPreviewLessons.length,
              (index) {
                final lesson = stageAFoundationPreviewLessons[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _StageAPreviewLessonCard(
                    lessonNumber: index + 1,
                    lesson: lesson,
                    onOpen: () => _openLesson(context, lesson),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StageAPreviewLessonCard extends StatelessWidget {
  final int lessonNumber;
  final V2MicroLesson lesson;
  final VoidCallback onOpen;

  const _StageAPreviewLessonCard({
    required this.lessonNumber,
    required this.lesson,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final objectiveSummary = lesson.objectives.isEmpty
        ? ''
        : lesson.objectives.first.summary;
    final descriptor = stageAPreviewDescriptorForLessonId(lesson.lessonId);

    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lesson $lessonNumber',
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppTheme.accentMintDark,
            ),
          ),
          const SizedBox(height: 8),
          if (descriptor != null) ...[
            Text(
              descriptor.chapterRole,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.accentMintDark,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(lesson.title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(lesson.outcomeSummary, style: theme.textTheme.bodyMedium),
          if (objectiveSummary.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              localizedText(
                context,
                zh: 'Core objective: $objectiveSummary',
                en: 'Core objective: $objectiveSummary',
              ),
              style: theme.textTheme.bodySmall,
            ),
          ],
          if (descriptor != null) ...[
            const SizedBox(height: 10),
            Text(
              localizedText(
                context,
                zh: 'Completion evidence: ${descriptor.completionEvidence}',
                en: 'Completion evidence: ${descriptor.completionEvidence}',
              ),
              style: theme.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                label: Text(
                  localizedText(
                    context,
                    zh: '${lesson.estimatedMinutes}-minute preview',
                    en: '${lesson.estimatedMinutes}-minute preview',
                  ),
                ),
              ),
              Chip(
                label: Text(
                  '${lesson.practiceItems.length} '
                  '${localizedText(context, zh: 'practice steps', en: 'practice steps')}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: ValueKey<String>('open_stage_a_preview_${lesson.lessonId}'),
              onPressed: onOpen,
              child: Text(
                localizedText(
                  context,
                  zh: 'Open Preview',
                  en: 'Open Preview',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
