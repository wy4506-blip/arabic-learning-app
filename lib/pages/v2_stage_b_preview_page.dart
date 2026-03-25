import 'package:flutter/material.dart';

import '../data/generated_stage_b_preview_lessons.dart';
import '../l10n/localized_text.dart';
import '../models/app_settings.dart';
import '../models/v2_micro_lesson.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'v2_micro_lesson_page.dart';

class V2StageBPreviewPage extends StatelessWidget {
  final AppSettings settings;

  const V2StageBPreviewPage({
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
            zh: 'Stage B Preview',
            en: 'Stage B Preview',
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
                zh: 'Usable Arabic Chapter',
                en: 'Usable Arabic Chapter',
              ),
              subtitle: localizedText(
                context,
                zh:
                    'Review Stage B in order: add قلم as one more real word, build your first tiny Arabic line, hear known content more directly, then finish with a first usable Arabic pack.',
                en:
                    'Review Stage B in order: add قلم as one more real word, build your first tiny Arabic line, hear known content more directly, then finish with a first usable Arabic pack.',
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
                  ...stageBPreviewDescriptors.map(
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
                      'By Lesson 8, Stage B should feel like this: I learned one more real word, I can already build a tiny Arabic line, I can hear familiar content more directly, and I now have a small usable pack.',
                  en:
                      'By Lesson 8, Stage B should feel like this: I learned one more real word, I can already build a tiny Arabic line, I can hear familiar content more directly, and I now have a small usable pack.',
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
                      stageBPreviewLessons.length,
                      (index) {
                        final lesson = stageBPreviewLessons[index];
                        final descriptor = stageBPreviewDescriptorForLessonId(
                          lesson.lessonId,
                        );
                        return ActionChip(
                          key: ValueKey<String>(
                            'stage_b_quick_jump_${lesson.lessonId}',
                          ),
                          label: Text(
                            descriptor == null
                                ? 'Lesson ${index + 5}'
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
              stageBPreviewLessons.length,
              (index) {
                final lesson = stageBPreviewLessons[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _StageBPreviewLessonCard(
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

class _StageBPreviewLessonCard extends StatelessWidget {
  final V2MicroLesson lesson;
  final VoidCallback onOpen;

  const _StageBPreviewLessonCard({
    required this.lesson,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final descriptor = stageBPreviewDescriptorForLessonId(lesson.lessonId);
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
              key: ValueKey<String>('open_stage_b_preview_${lesson.lessonId}'),
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
