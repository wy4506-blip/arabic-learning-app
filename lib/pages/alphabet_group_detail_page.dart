import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/alphabet_content_localizer.dart';
import '../l10n/localized_text.dart';
import '../models/alphabet_group.dart';
import '../theme/app_arabic_typography.dart';
import '../theme/app_theme.dart';
import 'alphabet_letter_home_page.dart';

class AlphabetGroupDetailPage extends StatelessWidget {
  final AlphabetGroup group;

  const AlphabetGroupDetailPage({
    super.key,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: [
                _buildTopButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AlphabetContentLocalizer.groupTitle(
                          group,
                          context.appSettings.appLanguage,
                        ),
                        style: text.titleLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AlphabetContentLocalizer.groupSubtitle(
                          group,
                          context.appSettings.meaningLanguage,
                        ),
                        style: text.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFEAF8F3),
                    Color(0xFFDFF2EB),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 22,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.82),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      color: AppTheme.deepAccent,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizedText(
                            context,
                            zh: '这一组共 ${group.letters.length} 个字母',
                            en: '${group.letters.length} letters in this group',
                          ),
                          style: text.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          localizedText(
                            context,
                            zh: '先点进单个字母主页，再选择听读或书写。',
                            en: 'Open a single letter first, then choose listening or writing.',
                          ),
                          style: text.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildGuideChip(
                  label: localizedText(
                    context,
                    zh: '先认字形',
                    en: 'See the Shape',
                  ),
                  icon: Icons.visibility_rounded,
                ),
                _buildGuideChip(
                  label: localizedText(
                    context,
                    zh: '再听发音',
                    en: 'Hear the Sound',
                  ),
                  icon: Icons.hearing_rounded,
                ),
                _buildGuideChip(
                  label: localizedText(
                    context,
                    zh: '最后练书写',
                    en: 'Finish with Writing',
                  ),
                  icon: Icons.edit_rounded,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: group.letters
                    .map(
                      (letter) => Container(
                        width: 64,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4FBF8),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: ArabicText.word(
                            letter.arabic,
                            style: text.titleLarge?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              localizedText(
                context,
                zh: '本组字母',
                en: 'Letters in This Group',
              ),
              style: text.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              localizedText(
                context,
                zh: '每次先学少量内容，更适合初学者。',
                en: 'Small batches work better for beginners.',
              ),
              style: text.bodyMedium,
            ),
            const SizedBox(height: 16),
            ...group.letters.map(
              (letter) => _buildLetterCard(context, letter),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildGuideChip({
    required String label,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.deepAccent),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildTopButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryText,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildLetterCard(BuildContext context, AlphabetLetter letter) {
    final text = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AlphabetLetterHomePage(letter: letter),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5F0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: ArabicText.word(
                      letter.arabic,
                      style: text.titleLarge?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ArabicText.word(
                        letter.arabicName,
                        style: text.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        letter.latinName,
                        style: text.labelLarge?.copyWith(
                          color: AppTheme.deepAccent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AlphabetContentLocalizer.hint(
                          letter,
                          context.appSettings.meaningLanguage,
                        ),
                        style: text.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildMetaTag(
                            context,
                            localizedText(
                              context,
                              zh: '基础音值 ${letter.phoneme}',
                              en: 'Core Sound ${letter.phoneme}',
                            ),
                          ),
                          _buildMetaTag(
                            context,
                            localizedText(
                              context,
                              zh: '示例 ${letter.example.arabic}',
                              en: 'Example ${letter.example.arabic}',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF98A2B3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaTag(BuildContext context, String label) {
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: text.labelMedium?.copyWith(
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}
