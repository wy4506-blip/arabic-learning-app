import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../models/review_models.dart';
import '../../services/audio_service.dart';
import '../../theme/app_theme.dart';
import '../app_widgets.dart';
import '../arabic_text_with_audio.dart';

class ReviewTaskSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<ReviewTask> tasks;
  final String emptyTitle;
  final String emptySubtitle;
  final void Function(ReviewTask task)? onTaskTap;

  const ReviewTaskSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.tasks,
    required this.emptyTitle,
    required this.emptySubtitle,
    this.onTaskTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: title, subtitle: subtitle),
        const SizedBox(height: 12),
        if (tasks.isEmpty)
          AppSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(emptyTitle, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 6),
                Text(emptySubtitle,
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          )
        else
          ...tasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ReviewTaskPreviewCard(
                task: task,
                onTap: onTaskTap == null ? null : () => onTaskTap!(task),
              ),
            ),
          ),
      ],
    );
  }
}

class ReviewTaskPreviewCard extends StatelessWidget {
  final ReviewTask task;
  final VoidCallback? onTap;

  const ReviewTaskPreviewCard({
    super.key,
    required this.task,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasArabic =
        task.arabicText != null && task.arabicText!.trim().isNotEmpty;

    return AppSurface(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Pill(label: _typeLabel(context, task.type)),
                    if (task.lessonId != null && task.lessonId!.isNotEmpty)
                      Pill(label: task.lessonId!),
                  ],
                ),
                const SizedBox(height: 12),
                if (hasArabic) ...[
                  ArabicTextWithAudio(
                    textAr: task.arabicText!,
                    request: LearningAudioRequest.general(
                      scope: 'review',
                      type: _audioTypeForTask(task.type),
                      textAr: task.arabicText!,
                      textPlain: task.audioQueryText ?? task.arabicText!,
                      debugLabel: 'review_preview_card',
                    ),
                    variant: ArabicAudioTextVariant.word,
                    style: const TextStyle(
                      fontSize: 26,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(task.title, style: Theme.of(context).textTheme.titleSmall),
                if (task.transliteration != null &&
                    task.transliteration!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.transliteration!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (task.subtitle.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    task.subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                if (task.helperText != null &&
                    task.helperText!.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.bgCardSoft,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      task.helperText!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 10),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSecondary,
            ),
          ],
        ],
      ),
    );
  }

  String _typeLabel(BuildContext context, ReviewContentType type) {
    final english =
        AppSettingsScope.maybeOf(context)?.settings.appLanguage.name == 'en';

    switch (type) {
      case ReviewContentType.word:
        return english ? 'Word' : '单词';
      case ReviewContentType.pronunciation:
        return english ? 'Pronunciation' : '发音';
      case ReviewContentType.pair:
        return english ? 'Sound Contrast' : '辨音';
      case ReviewContentType.sentence:
        return english ? 'Sentence' : '句子';
      case ReviewContentType.grammar:
        return english ? 'Grammar' : '语法';
      case ReviewContentType.alphabet:
        return english ? 'Letter' : '字母';
    }
  }

  String _audioTypeForTask(ReviewContentType type) {
    switch (type) {
      case ReviewContentType.alphabet:
        return 'letter';
      case ReviewContentType.pronunciation:
        return 'pronunciation';
      case ReviewContentType.word:
        return 'word';
      case ReviewContentType.pair:
      case ReviewContentType.sentence:
      case ReviewContentType.grammar:
        return 'sentence';
    }
  }
}
