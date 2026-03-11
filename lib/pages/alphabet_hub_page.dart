import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'alphabet_page.dart';
import 'alphabet_recognition_quiz_page.dart';
import 'alphabet_compare_quiz_page.dart';
import 'alphabet_sound_quiz_page.dart';
import 'alabic_pronunciation_quiz_page.dart';

class AlphabetHubPage extends StatelessWidget {
  const AlphabetHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final width = MediaQuery.of(context).size.width;
    final bool isSmallScreen = width < 360;

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
                      Text('字母练习', style: text.titleLarge),
                      const SizedBox(height: 2),
                      Text(
                        '学完字母后，来这里逐级挑战',
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
            Text('练习关卡', style: text.titleLarge),
            const SizedBox(height: 6),
            Text(
              '完成学习后，通过练习来巩固记忆。',
              style: text.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildLevelCard(
              context: context,
              icon: Icons.looks_one_rounded,
              iconBg: const Color(0xFFE8F5F0),
              iconColor: AppTheme.deepAccent,
              title: '第 1 级：字母识别',
              subtitle: '看字母选名称、看名称选字母',
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
              title: '第 2 级：字母辨析',
              subtitle: '区分易混淆字母，如 ب / ت / ث',
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
              title: '第 3 级：基础发音',
              subtitle: '把字母和基础音值建立对应关系',
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
              title: '第 4 级：13 音位',
              subtitle: '进入短音、长音、静音、重音和尾音训练',
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
                '💡 提示：学完记得回来挑战所有关卡！',
                style: text.bodySmall?.copyWith(
                  color: AppTheme.secondaryText,
                ),
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
                child: Text('还没学字母？', style: text.headlineMedium),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '先去字母入门学习字母的读写和发音，然后再来挑战这些练习关卡。',
            style: text.bodyMedium,
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
              child: const Text('去字母入门学习'),
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
