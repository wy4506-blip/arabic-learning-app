import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class FirstExperienceProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String label;

  const FirstExperienceProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: text.labelMedium),
        const SizedBox(height: 10),
        Row(
          children: List.generate(totalSteps, (index) {
            final active = index < currentStep;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 8),
                height: 8,
                decoration: BoxDecoration(
                  color: active
                      ? AppTheme.accentMintDark
                      : const Color(0xFFDCE6E1),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
