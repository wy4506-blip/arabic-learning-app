import 'package:flutter/material.dart';

import '../data/generated_stage_c_preview_lessons.dart';
import '../l10n/localized_text.dart';
import '../models/app_settings.dart';
import '../models/v2_micro_lesson.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'v2_micro_lesson_page.dart';

class V2StageCPreviewPage extends StatelessWidget {
  final AppSettings settings;

  const V2StageCPreviewPage({
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
            zh: 'Stage C Preview',
            en: 'Stage C Preview',
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
                zh: 'Pattern Growth Chapter',
                en: 'Pattern Growth Chapter',
              ),
              subtitle: localizedText(
                context,
                zh:
                    'Review Stage C in order: learn بيت as a real new word, find one page clue, find one quantity clue in a tiny pair, then finish with a tiny Arabic card you can actually handle.',
                en:
                    'Review Stage C in order: learn بيت as a real new word, find one page clue, find one quantity clue in a tiny pair, then finish with a tiny Arabic card you can actually handle.',
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
                      zh: 'Chapter Arc',
                      en: 'Chapter Arc',
                    ),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  ...stageCPreviewDescriptors.map(
                    (descriptor) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Lesson ${descriptor.order}: ${descriptor.chapterBridge}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppSurface(
              child: Text(
                localizedText(
                  context,
                  zh:
                      'By Lesson 12, Stage C should feel like this: I learned one more real word, I found two small clues on the page, and I can already get through a tiny piece of Arabic.',
                  en:
                      'By Lesson 12, Stage C should feel like this: I learned one more real word, I found two small clues on the page, and I can already get through a tiny piece of Arabic.',
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
                      stageCPreviewLessons.length,
                      (index) {
                        final lesson = stageCPreviewLessons[index];
                        final descriptor = stageCPreviewDescriptorForLessonId(
                          lesson.lessonId,
                        );
                        return ActionChip(
                          key: ValueKey<String>(
                            'stage_c_quick_jump_${lesson.lessonId}',
                          ),
                          label: Text(
                            descriptor == null
                                ? 'Lesson ${index + 9}'
                                : 'L${descriptor.order}: ${descriptor.chapterRole}',
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
              stageCPreviewLessons.length,
              (index) {
                final lesson = stageCPreviewLessons[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _StageCPreviewLessonCard(
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

class _StageCPreviewLessonCard extends StatelessWidget {
  final V2MicroLesson lesson;
  final VoidCallback onOpen;

  const _StageCPreviewLessonCard({
    required this.lesson,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final descriptor = stageCPreviewDescriptorForLessonId(lesson.lessonId);
    final lessonNumber = descriptor?.order ?? 0;

    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lessonNumber > 0 ? 'Lesson $lessonNumber' : 'Preview Lesson',
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
          Text(
            descriptor?.learnerVisibleOutcome ?? lesson.outcomeSummary,
            style: theme.textTheme.bodyMedium,
          ),
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
            const SizedBox(height: 8),
            Text(
              localizedText(
                context,
                zh: 'Next unlock: ${descriptor.nextUnlock}',
                en: 'Next unlock: ${descriptor.nextUnlock}',
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
              key: ValueKey<String>('open_stage_c_preview_${lesson.lessonId}'),
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
