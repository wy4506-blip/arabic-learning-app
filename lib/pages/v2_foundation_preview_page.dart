import 'package:flutter/material.dart';

import '../l10n/localized_text.dart';
import '../models/app_settings.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'v2_stage_a_preview_page.dart';
import 'v2_stage_b_preview_page.dart';
import 'v2_stage_c_preview_page.dart';

class V2FoundationPreviewPage extends StatelessWidget {
  final AppSettings settings;

  const V2FoundationPreviewPage({
    super.key,
    required this.settings,
  });

  Future<void> _openStageA(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => V2StageAPreviewPage(settings: settings),
      ),
    );
  }

  Future<void> _openStageB(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => V2StageBPreviewPage(settings: settings),
      ),
    );
  }

  Future<void> _openStageC(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => V2StageCPreviewPage(settings: settings),
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
            zh: 'Foundation Preview',
            en: 'Foundation Preview',
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
                zh: '12-Lesson Free Path',
                en: '12-Lesson Free Path',
              ),
              subtitle: localizedText(
                context,
                zh:
                    'Review the accepted beginner foundation in one place: Stage A lowers fear, Stage B builds a first usable pack, and Stage C adds early clue-awareness and tiny text handling.',
                en:
                    'Review the accepted beginner foundation in one place: Stage A lowers fear, Stage B builds a first usable pack, and Stage C adds early clue-awareness and tiny text handling.',
              ),
            ),
            const SizedBox(height: 16),
            AppSurface(
              child: Text(
                localizedText(
                  context,
                  zh:
                      'This overview is preview-only. It keeps the formal home, review, and lesson recommendation flow unchanged.',
                  en:
                      'This overview is preview-only. It keeps the formal home, review, and lesson recommendation flow unchanged.',
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
                      zh: 'Foundation Arc',
                      en: 'Foundation Arc',
                    ),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    localizedText(
                      context,
                      zh:
                          'Stage A, Lessons 1-4: enter Arabic through real beginner content and supported reading.',
                      en:
                          'Stage A, Lessons 1-4: enter Arabic through real beginner content and supported reading.',
                    ),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizedText(
                      context,
                      zh:
                          'Stage B, Lessons 5-8: grow that base into a first usable Arabic pack.',
                      en:
                          'Stage B, Lessons 5-8: grow that base into a first usable Arabic pack.',
                    ),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizedText(
                      context,
                      zh:
                          'Stage C, Lessons 9-12: keep moving through one more real word, two small clues, and one tiny Arabic card.',
                      en:
                          'Stage C, Lessons 9-12: keep moving through one more real word, two small clues, and one tiny Arabic card.',
                    ),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _FoundationStageCard(
              stageLabel: 'Stage A',
              lessonsLabel: 'Lessons 1-4',
              title: localizedText(
                context,
                zh: 'Arabic Entry Chapter',
                en: 'Arabic Entry Chapter',
              ),
              payoff: localizedText(
                context,
                zh: 'Learner payoff: Arabic is not as scary as it looked.',
                en: 'Learner payoff: Arabic is not as scary as it looked.',
              ),
              summary: localizedText(
                context,
                zh:
                    'Enter Arabic through real words, build the first owned words, and end with supported reading plus a tiny usage glimpse.',
                en:
                    'Enter Arabic through real words, build the first owned words, and end with supported reading plus a tiny usage glimpse.',
              ),
              buttonKey: const ValueKey<String>('foundation_open_stage_a'),
              buttonLabel: localizedText(
                context,
                zh: 'Open Stage A',
                en: 'Open Stage A',
              ),
              onOpen: () => _openStageA(context),
            ),
            const SizedBox(height: 12),
            _FoundationStageCard(
              stageLabel: 'Stage B',
              lessonsLabel: 'Lessons 5-8',
              title: localizedText(
                context,
                zh: 'Usable Arabic Chapter',
                en: 'Usable Arabic Chapter',
              ),
              payoff: localizedText(
                context,
                zh: 'Learner payoff: I can already read and say some Arabic.',
                en: 'Learner payoff: I can already read and say some Arabic.',
              ),
              summary: localizedText(
                context,
                zh:
                    'Add one more real word, build the first tiny line, shift known content toward the ear, then finish with a small usable pack.',
                en:
                    'Add one more real word, build the first tiny line, shift known content toward the ear, then finish with a small usable pack.',
              ),
              buttonKey: const ValueKey<String>('foundation_open_stage_b'),
              buttonLabel: localizedText(
                context,
                zh: 'Open Stage B',
                en: 'Open Stage B',
              ),
              onOpen: () => _openStageB(context),
            ),
            const SizedBox(height: 12),
            _FoundationStageCard(
              stageLabel: 'Stage C',
              lessonsLabel: 'Lessons 9-12',
              title: localizedText(
                context,
                zh: 'Pattern Growth Chapter',
                en: 'Pattern Growth Chapter',
              ),
              payoff: localizedText(
                context,
                zh:
                    'Learner payoff: Arabic gives me clues, and I can already process a tiny card.',
                en:
                    'Learner payoff: Arabic gives me clues, and I can already process a tiny card.',
              ),
              summary: localizedText(
                context,
                zh:
                    'Learn one more real word, discover two small Arabic clues, and finish with one tiny supported card.',
                en:
                    'Learn one more real word, discover two small Arabic clues, and finish with one tiny supported card.',
              ),
              buttonKey: const ValueKey<String>('foundation_open_stage_c'),
              buttonLabel: localizedText(
                context,
                zh: 'Open Stage C',
                en: 'Open Stage C',
              ),
              onOpen: () => _openStageC(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoundationStageCard extends StatelessWidget {
  final String stageLabel;
  final String lessonsLabel;
  final String title;
  final String payoff;
  final String summary;
  final ValueKey<String> buttonKey;
  final String buttonLabel;
  final VoidCallback onOpen;

  const _FoundationStageCard({
    required this.stageLabel,
    required this.lessonsLabel,
    required this.title,
    required this.payoff,
    required this.summary,
    required this.buttonKey,
    required this.buttonLabel,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$stageLabel · $lessonsLabel',
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppTheme.accentMintDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(payoff, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(summary, style: theme.textTheme.bodySmall),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: buttonKey,
              onPressed: onOpen,
              child: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}
