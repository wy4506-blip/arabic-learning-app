import 'package:flutter/material.dart';

import '../../../app_scope.dart';
import '../../../theme/app_theme.dart';
import '../widgets/primary_action_button.dart';
import '../widgets/welcome_hero_section.dart';

class WelcomePage extends StatelessWidget {
  final VoidCallback onStartLearning;
  final VoidCallback onGoHome;

  const WelcomePage({
    super.key,
    required this.onStartLearning,
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
              WelcomeHeroSection(
                title: strings.t('onboarding.welcome_title'),
                subtitle: strings.t('onboarding.welcome_subtitle'),
                note: strings.t('onboarding.welcome_note'),
              ),
              const Spacer(),
              PrimaryActionButton(
                text: strings.t('onboarding.welcome_primary'),
                onTap: onStartLearning,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onGoHome,
                child: Text(
                  strings.t('onboarding.welcome_secondary'),
                  style: text.labelLarge?.copyWith(
                    color: const Color(0xFF6B7280),
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
