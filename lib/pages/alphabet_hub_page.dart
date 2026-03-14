import 'package:flutter/material.dart';

import '../l10n/localized_text.dart';
import '../theme/app_theme.dart';
import 'alabic_pronunciation_quiz_page.dart';
import 'alphabet_compare_quiz_page.dart';
import 'alphabet_page.dart';
import 'alphabet_recognition_quiz_page.dart';
import 'alphabet_sound_quiz_page.dart';

class AlphabetHubPage extends StatelessWidget {
  const AlphabetHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final width = MediaQuery.of(context).size.width;
    final isSmallScreen = width < 360;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            isSmallScreen ? 16 : 20,
            16,
            isSmallScreen ? 16 : 20,
            24,
          ),
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
                        localizedText(
                          context,
                          zh: '字母练习',
                          en: 'Alphabet Practice',
                        ),
                        style: text.titleLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        localizedText(
                          context,
                          zh: '28 个字母学完后，在这里逐级巩固',
                          en: 'Reinforce the 28 letters here, level by level.',
                        ),
                        style: text.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _buildLearnReminderCard(context),
            const SizedBox(height: 24),
            Text(
              localizedText(
                context,
                zh: '练习关卡',
                en: 'Practice Levels',
              ),
              style: text.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              localizedText(
                context,
                zh: '完成学习后，通过练习来巩固记忆。',
                en: 'Use short drills after study to lock the patterns in.',
              ),
              style: text.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildLevelCard(
              context: context,
              icon: Icons.looks_one_rounded,
              iconBg: const Color(0xFFE8F5F0),
              iconColor: AppTheme.deepAccent,
              title: localizedText(
                context,
                zh: '第 1 级：字母识别',
                en: 'Level 1: Letter Recognition',
              ),
              subtitle: localizedText(
                context,
                zh: '看字母选名称、看名称选字母',
                en: 'Match letters and names in both directions.',
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AlphabetRecognitionQuizPage(),
                  ),
                );
              },
            ),
            _buildLevelCard(
              context: context,
              icon: Icons.looks_two_rounded,
              iconBg: const Color(0xFFFFF1E6),
              iconColor: const Color(0xFFF08A24),
              title: localizedText(
                context,
                zh: '第 2 级：字母辨析',
                en: 'Level 2: Letter Contrast',
              ),
              subtitle: localizedText(
                context,
                zh: '区分易混淆字母，如 ب / ت / ث',
                en: 'Separate look-alike letters such as ب / ت / ث.',
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AlphabetCompareQuizPage(),
                  ),
                );
              },
            ),
            _buildLevelCard(
              context: context,
              icon: Icons.looks_3_rounded,
              iconBg: const Color(0xFFE8F3FF),
              iconColor: const Color(0xFF4C7CF0),
              title: localizedText(
                context,
                zh: '第 3 级：基础发音',
                en: 'Level 3: Core Sounds',
              ),
              subtitle: localizedText(
                context,
                zh: '听字母发音，判断基础音值或对应字母',
                en: 'Hear a letter sound, then identify the sound or letter.',
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AlphabetSoundQuizPage(),
                  ),
                );
              },
            ),
            _buildLevelCard(
              context: context,
              icon: Icons.looks_4_rounded,
              iconBg: const Color(0xFFEEEAFE),
              iconColor: const Color(0xFF7D58E6),
              title: localizedText(
                context,
                zh: '第 4 级：13 音位',
                en: 'Level 4: 13 Sound Forms',
              ),
              subtitle: localizedText(
                context,
                zh: '听 13 音位形式，判断转写和读音类别',
                en: 'Hear the 13 sound forms and identify transliteration or type.',
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AlabicPronunciationQuizPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                localizedText(
                  context,
                  zh: '学完分组内容后，按 1 到 4 级顺序刷一遍会更稳。',
                  en: 'After finishing the groups, a full pass from level 1 to 4 works best.',
                ),
                style: text.bodySmall?.copyWith(
                  color: AppTheme.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
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
          child: Icon(icon, color: AppTheme.primaryText, size: 20),
        ),
      ),
    );
  }

  Widget _buildLearnReminderCard(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEAF8F3), Color(0xFFDFF2EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.82),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: AppTheme.deepAccent,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  localizedText(
                    context,
                    zh: '完整学习路径',
                    en: 'Full Learning Path',
                  ),
                  style: text.headlineMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            localizedText(
              context,
              zh: '先完成 7 组字母学习，再回到这里做 4 类练习，识别、发音和 13 音位都会更稳。',
              en: 'Finish the 7 study groups first, then come back for the 4 drill types.',
            ),
            style: text.bodyMedium,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _PathChip(
                label: localizedText(
                  context,
                  zh: '7 个分组',
                  en: '7 Groups',
                ),
                icon: Icons.layers_rounded,
              ),
              _PathChip(
                label: localizedText(
                  context,
                  zh: '28 个字母',
                  en: '28 Letters',
                ),
                icon: Icons.sort_by_alpha_rounded,
              ),
              _PathChip(
                label: localizedText(
                  context,
                  zh: '4 关练习',
                  en: '4 Drill Levels',
                ),
                icon: Icons.rocket_launch_rounded,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.deepAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AlphabetPage(),
                  ),
                );
              },
              child: Text(
                localizedText(
                  context,
                  zh: '去字母入门学习',
                  en: 'Open Alphabet Basics',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard({
    required BuildContext context,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final text = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
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
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: iconColor, size: 25),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: text.titleMedium),
                      const SizedBox(height: 4),
                      Text(subtitle, style: text.bodySmall),
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
}

class _PathChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _PathChip({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.82),
        borderRadius: BorderRadius.circular(18),
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
}
