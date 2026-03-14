import 'package:flutter/material.dart';

import '../../../theme/app_latin_typography.dart';
import '../../../theme/app_theme.dart';

class CompletionSummaryCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const CompletionSummaryCard({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFE5F4EC), Color(0xFFF6ECDF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.82),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 36,
              color: AppTheme.accentMintDark,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: text.headlineMedium?.copyWith(fontSize: 28),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: AppLatinTypography.body(context),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
