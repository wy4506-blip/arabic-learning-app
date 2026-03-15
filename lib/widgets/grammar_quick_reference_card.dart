import 'package:flutter/material.dart';

import '../l10n/localized_text.dart';
import '../models/grammar_quick_reference_models.dart';
import '../services/audio_service.dart';
import '../theme/app_arabic_typography.dart';
import '../theme/app_theme.dart';
import 'app_widgets.dart';
import 'arabic_text_with_audio.dart';

class GrammarQuickReferenceCard extends StatelessWidget {
  final GrammarQuickReferenceSection section;
  final bool expanded;
  final VoidCallback onToggle;

  const GrammarQuickReferenceCard({
    super.key,
    required this.section,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final title = localizedText(
      context,
      zh: section.titleZh,
      en: section.titleEn,
    );
    final summary = localizedText(
      context,
      zh: section.summaryZh,
      en: section.summaryEn,
    );
    final tags = _localizedTags(context);
    final visibleExamples = expanded
        ? section.examples
        : section.examples.take(1).toList(growable: false);
    final bullets = _localizedBullets(context);
    final cardColor = Theme.of(context).cardColor;
    final blendedAccent =
        Color.lerp(cardColor, section.accentSurfaceColor, 0.88)!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  cardColor,
                  expanded
                      ? blendedAccent
                      : Color.lerp(cardColor, blendedAccent, 0.45)!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: expanded
                    ? section.accentColor.withOpacity(0.24)
                    : AppTheme.strokeLight,
              ),
              boxShadow: AppTheme.softShadow,
            ),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: section.accentSurfaceColor,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          section.icon,
                          color: section.accentColor,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: text.titleMedium),
                            const SizedBox(height: 6),
                            _ArabicHeadline(
                              label: section.arabicTerm,
                              preview: section.arabicPreview,
                              accentColor: section.accentColor,
                              surfaceColor: section.accentSurfaceColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 220),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: section.accentColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(summary, style: text.bodyMedium),
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tags
                          .map(
                            (tag) => Pill(
                              label: tag,
                              backgroundColor: section.accentSurfaceColor,
                              foregroundColor: section.accentColor,
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ],
                  const SizedBox(height: 14),
                  ...visibleExamples.map(
                    (example) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GrammarQuickReferenceExamplePanel(
                        example: example,
                        accentColor: section.accentColor,
                        accentSurfaceColor: section.accentSurfaceColor,
                        showNote: expanded,
                      ),
                    ),
                  ),
                  if (expanded && bullets.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.72),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.strokeLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizedText(
                              context,
                              zh: '快速记忆点',
                              en: 'Quick Notes',
                            ),
                            style: text.titleSmall?.copyWith(
                              color: section.accentColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...bullets.map(
                            (bullet) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(top: 6),
                                    decoration: BoxDecoration(
                                      color: section.accentColor,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      bullet,
                                      style: text.bodySmall?.copyWith(
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 2),
                  TextButton.icon(
                    onPressed: onToggle,
                    style: TextButton.styleFrom(
                      foregroundColor: section.accentColor,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: Icon(
                      expanded
                          ? Icons.unfold_less_rounded
                          : Icons.unfold_more_rounded,
                    ),
                    label: Text(
                      expanded
                          ? localizedText(
                              context,
                              zh: '收起说明',
                              en: 'Collapse',
                            )
                          : localizedText(
                              context,
                              zh: '展开查看更多',
                              en: 'Expand for More',
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<String> _localizedBullets(BuildContext context) {
    final isEnglish = isEnglishUi(context);
    return isEnglish ? section.detailBulletsEn : section.detailBulletsZh;
  }

  List<String> _localizedTags(BuildContext context) {
    final isEnglish = isEnglishUi(context);
    return isEnglish ? section.tagsEn : section.tagsZh;
  }
}

class GrammarQuickReferenceExamplePanel extends StatelessWidget {
  final GrammarQuickReferenceExample example;
  final Color accentColor;
  final Color accentSurfaceColor;
  final bool showNote;

  const GrammarQuickReferenceExamplePanel({
    super.key,
    required this.example,
    required this.accentColor,
    required this.accentSurfaceColor,
    required this.showNote,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final translation = localizedText(
      context,
      zh: example.translationZh,
      en: example.translationEn,
    );
    final note = showNote
        ? localizedText(
            context,
            zh: example.noteZh ?? '',
            en: example.noteEn ?? '',
          )
        : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.76),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.strokeLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizedText(context, zh: '例句', en: 'Example'),
            style: text.labelLarge?.copyWith(color: accentColor),
          ),
          const SizedBox(height: 8),
          ArabicTextWithAudio(
            textAr: example.arabic,
            request: LearningAudioRequest.general(
              scope: 'grammar',
              type: 'sentence',
              textAr: example.arabic,
              textPlain: example.arabic,
              debugLabel: 'grammar_quick_reference_example',
            ),
            variant: ArabicAudioTextVariant.sentence,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w600,
              height: 1.45,
              color: AppTheme.primaryText,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 6),
          Text(
            example.transliteration,
            style: text.bodySmall?.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            translation,
            style: text.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          if (note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: accentSurfaceColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                note,
                style: text.bodySmall?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ArabicHeadline extends StatelessWidget {
  final String label;
  final String preview;
  final Color accentColor;
  final Color surfaceColor;

  const _ArabicHeadline({
    required this.label,
    required this.preview,
    required this.accentColor,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ArabicText.grammar(
            label,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              height: 1.3,
              color: accentColor,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 6),
          ArabicText.label(
            preview,
            style: const TextStyle(
              fontSize: 18,
              height: 1.4,
              color: AppTheme.primaryText,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}
