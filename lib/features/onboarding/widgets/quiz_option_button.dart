import 'package:flutter/material.dart';

import '../../../theme/app_arabic_typography.dart';
import '../../../theme/app_theme.dart';

class QuizOptionButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool showResult;
  final VoidCallback onTap;

  const QuizOptionButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.showResult,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool highlightCorrect = showResult && isCorrect;
    final bool highlightWrong = showResult && isSelected && !isCorrect;
    final Color background = highlightCorrect
        ? const Color(0xFFE5F4EC)
        : highlightWrong
            ? const Color(0xFFFFEFE9)
            : Theme.of(context).cardColor;
    final Color border = highlightCorrect
        ? const Color(0xFF68A07D)
        : highlightWrong
            ? const Color(0xFFD78767)
            : AppTheme.strokeLight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: showResult ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: border, width: 1.4),
          ),
          child: Center(
            child: ArabicText.body(
              text,
              style: const TextStyle(
                fontSize: 48,
                height: 1,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
