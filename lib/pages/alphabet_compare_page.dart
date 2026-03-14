import 'package:flutter/material.dart';

import '../l10n/localized_text.dart';
import 'alphabet_compare_quiz_page.dart';

class AlphabetComparePage extends StatelessWidget {
  const AlphabetComparePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: FilledButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AlphabetCompareQuizPage(),
                ),
              );
            },
            child: Text(
              localizedText(
                context,
                zh: '开始字母辨析练习',
                en: 'Start Letter Contrast Drill',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
