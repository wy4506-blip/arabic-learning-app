import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/grammar_text.dart';
import '../l10n/localized_text.dart';
import '../models/grammar_models.dart';
import '../services/audio_service.dart';
import '../theme/app_arabic_typography.dart';
import '../theme/app_theme.dart';
import 'app_widgets.dart';
import 'arabic_text_with_audio.dart';

IconData grammarIconFromName(String name) {
  switch (name) {
    case 'menu_book':
      return Icons.menu_book_rounded;
    case 'spellcheck':
      return Icons.spellcheck_rounded;
    case 'person_outline':
      return Icons.person_outline_rounded;
    case 'badge':
      return Icons.badge_outlined;
    case 'bolt':
      return Icons.bolt_rounded;
    case 'format_align_left':
      return Icons.format_align_left_rounded;
    case 'tune':
      return Icons.tune_rounded;
    default:
      return Icons.auto_stories_rounded;
  }
}

class GrammarCategoryCard extends StatelessWidget {
  final GrammarCategory category;
  final VoidCallback onTap;

  const GrammarCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final uiLanguage = context.appSettings.appLanguage;

    return AppSurface(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: category.parsedColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              grammarIconFromName(category.icon),
              color: AppTheme.accentMintDark,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            grammarUiText(category.title, uiLanguage),
            style: text.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            grammarUiText(category.subtitle, uiLanguage),
            style: text.bodySmall,
          ),
          const SizedBox(height: 12),
          const Align(
            alignment: Alignment.centerRight,
            child: Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class GrammarBlockHeader extends StatelessWidget {
  final String title;
  final String description;
  final String? actionText;
  final VoidCallback? onActionTap;

  const GrammarBlockHeader({
    super.key,
    required this.title,
    required this.description,
    this.actionText,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return SectionTitle(
      title: title,
      subtitle: description,
      trailing: actionText == null || onActionTap == null
          ? null
          : TextButton(
              onPressed: onActionTap,
              child: Text(actionText!),
            ),
    );
  }
}

class GrammarQuickLinkCard extends StatelessWidget {
  final GrammarQuickLink link;
  final VoidCallback onTap;

  const GrammarQuickLinkCard({
    super.key,
    required this.link,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final meaningLanguage = context.appSettings.meaningLanguage;

    return AppSurface(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  grammarContentText(link.title, meaningLanguage),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  grammarContentText(link.subtitle, meaningLanguage),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.textSecondary,
          ),
        ],
      ),
    );
  }
}

class GrammarTableCard extends StatelessWidget {
  final String title;
  final String summary;
  final GrammarTableData table;
  final bool isExpandable;
  final bool expanded;
  final VoidCallback? onToggleExpanded;

  const GrammarTableCard({
    super.key,
    required this.title,
    required this.summary,
    required this.table,
    required this.isExpandable,
    required this.expanded,
    this.onToggleExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final meaningLanguage = context.appSettings.meaningLanguage;
    final rows = isExpandable && !expanded && table.rows.length > 5
        ? table.rows.take(5).toList()
        : table.rows;

    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            grammarContentText(title, meaningLanguage),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            grammarContentText(summary, meaningLanguage),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GrammarTableRow(
                  values: table.columns,
                  isHeader: true,
                ),
                ...rows.map(
                  (row) => _GrammarTableRow(values: row),
                ),
              ],
            ),
          ),
          if (isExpandable && table.rows.length > 5) ...[
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: onToggleExpanded,
              icon: Icon(
                expanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
              ),
              label: Text(
                localizedText(
                  context,
                  zh: expanded ? '收起表格' : '展开表格',
                  en: expanded ? 'Hide Table' : 'Show Table',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GrammarTableRow extends StatelessWidget {
  final List<String> values;
  final bool isHeader;

  const _GrammarTableRow({
    required this.values,
    this.isHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final meaningLanguage = context.appSettings.meaningLanguage;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isHeader ? AppTheme.bgCardSoft : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: values
            .map(
              (value) => Container(
                width: 116,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: AppArabicTypography.isArabic(value)
                    ? (isHeader
                        ? ArabicText.label(
                            value,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          )
                        : ArabicTextWithAudio(
                            textAr: value,
                            request: LearningAudioRequest.general(
                              scope: 'grammar',
                              type: 'phrase',
                              textAr: value,
                              textPlain: value,
                              debugLabel: 'grammar_table_cell',
                            ),
                            variant: ArabicAudioTextVariant.label,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                            spacing: 6,
                          ))
                    : Text(
                        grammarContentText(value, meaningLanguage),
                        style: (isHeader ? text.labelLarge : text.bodyMedium)
                            ?.copyWith(color: AppTheme.textPrimary),
                        textAlign: TextAlign.center,
                      ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class GrammarRuleCard extends StatelessWidget {
  final GrammarRuleCardData rule;
  final Future<void> Function()? onPlay;

  const GrammarRuleCard({
    super.key,
    required this.rule,
    this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final meaningLanguage = context.appSettings.meaningLanguage;

    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  grammarContentText(rule.title, meaningLanguage),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (onPlay != null)
                IconButton(
                  onPressed: () async => onPlay!.call(),
                  icon: const Icon(
                    Icons.volume_up_rounded,
                    color: AppTheme.accentMintDark,
                  ),
                ),
            ],
          ),
          if (rule.symbol.isNotEmpty) ...[
            const SizedBox(height: 8),
            ArabicText.grammar(
              rule.symbol,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 8),
          Text(
            grammarContentText(rule.summary, meaningLanguage),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (rule.example != null) ...[
            const SizedBox(height: 12),
            GrammarExampleCard(example: rule.example!),
          ],
        ],
      ),
    );
  }
}

class GrammarCompareCard extends StatelessWidget {
  final GrammarCompareCardData data;

  const GrammarCompareCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final meaningLanguage = context.appSettings.meaningLanguage;

    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _CompareValue(
                  label: grammarContentText(data.leftLabel, meaningLanguage),
                  value: data.leftValue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CompareValue(
                  label: grammarContentText(data.rightLabel, meaningLanguage),
                  value: data.rightValue,
                ),
              ),
            ],
          ),
          if (data.note.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              grammarContentText(data.note, meaningLanguage),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _CompareValue extends StatelessWidget {
  final String label;
  final String value;

  const _CompareValue({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCardSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          if (AppArabicTypography.isArabic(value))
            ArabicTextWithAudio(
              textAr: value,
              request: LearningAudioRequest.general(
                scope: 'grammar',
                type: 'phrase',
                textAr: value,
                textPlain: value,
                debugLabel: 'grammar_compare_value',
              ),
              variant: ArabicAudioTextVariant.word,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
            )
          else
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium,
            ),
        ],
      ),
    );
  }
}

class GrammarExampleCard extends StatelessWidget {
  final GrammarExampleData example;

  const GrammarExampleCard({
    super.key,
    required this.example,
  });

  @override
  Widget build(BuildContext context) {
    final meaningLanguage = context.appSettings.meaningLanguage;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCardSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ArabicTextWithAudio(
            textAr: example.arabicWithDiacritics,
            request: LearningAudioRequest.general(
              scope: 'grammar',
              type: 'sentence',
              asset: example.audioPath,
              textAr: example.arabicWithDiacritics,
              textPlain: example.arabicPlain,
              debugLabel: 'grammar_example_card',
            ),
            variant: ArabicAudioTextVariant.sentence,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
            textAlign: TextAlign.right,
          ),
          if (example.arabicPlain.isNotEmpty &&
              example.arabicPlain != example.arabicWithDiacritics) ...[
            const SizedBox(height: 4),
            ArabicText.label(
              example.arabicPlain,
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.right,
            ),
          ],
          if (example.transliteration.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              example.transliteration,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (example.translation.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              grammarContentText(example.translation, meaningLanguage),
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: AppTheme.textPrimary),
            ),
          ],
          if (example.highlightParts.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: example.highlightParts
                  .map(
                    (item) => Pill(
                      label: grammarContentText(item, meaningLanguage),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class GrammarRelatedLessonCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const GrammarRelatedLessonCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final meaningLanguage = context.appSettings.meaningLanguage;

    return AppSurface(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.bgCardSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: AppTheme.accentMintDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  grammarContentText(subtitle, meaningLanguage),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.textSecondary,
          ),
        ],
      ),
    );
  }
}
