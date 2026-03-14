import 'package:flutter/material.dart';

import '../../../theme/app_arabic_typography.dart';
import '../../../theme/app_latin_typography.dart';
import '../../../theme/app_theme.dart';

class WelcomeHeroSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final String note;

  const WelcomeHeroSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFFF8ECDD),
            Color(0xFFE6F4EE),
            Color(0xFFEAF2FA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 26,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              size: 38,
              color: AppTheme.accentMintDark,
            ),
          ),
          const SizedBox(height: 18),
          const ArabicText.display(
            'ابدأ من الحرف الأول',
            style: TextStyle(
              fontSize: 32,
              height: 1.08,
              fontWeight: FontWeight.w400,
              color: Color(0xFF304038),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: text.headlineMedium?.copyWith(fontSize: 30, height: 1.15),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: AppLatinTypography.body(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.55),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Text(
              note,
              style: AppLatinTypography.body(
                context,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
