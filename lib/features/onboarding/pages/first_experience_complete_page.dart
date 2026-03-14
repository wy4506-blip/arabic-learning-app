import 'package:flutter/material.dart';

import '../../../app_scope.dart';
import '../../../theme/app_theme.dart';
import '../widgets/completion_summary_card.dart';
import '../widgets/primary_action_button.dart';

class FirstExperienceCompletePage extends StatelessWidget {
  final VoidCallback onContinueLearning;
  final VoidCallback onGoHome;

  const FirstExperienceCompletePage({
    super.key,
    required this.onContinueLearning,
    required this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppTheme.pagePadding,
          child: Column(
            children: [
              const Spacer(),
              CompletionSummaryCard(
                title: strings.t('onboarding.complete_title'),
                subtitle: strings.t('onboarding.complete_subtitle'),
              ),
              const Spacer(),
              PrimaryActionButton(
                text: strings.t('onboarding.complete_primary'),
                onTap: onContinueLearning,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onGoHome,
                child: Text(
                  strings.t('onboarding.complete_secondary'),
                  style: text.labelLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
