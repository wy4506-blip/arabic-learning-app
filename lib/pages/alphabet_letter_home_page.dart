import 'package:flutter/material.dart';
import '../models/alphabet_group.dart';
import '../theme/app_theme.dart';
import 'alphabet_listen_read_page.dart';
import 'alphabet_write_page.dart';

class AlphabetLetterHomePage extends StatelessWidget {
  final AlphabetLetter letter;

  const AlphabetLetterHomePage({
    super.key,
    required this.letter,
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
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('字母学习', style: text.titleLarge),
                      const SizedBox(height: 2),
                      Text(
                        '${letter.name} · ${letter.pronunciation}',
                        style: text.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFEAF8F3),
                    Color(0xFFDFF2EB),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 22,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    letter.arabic,
                    style: text.headlineLarge?.copyWith(
                      fontSize: 56,
                      fontWeight: FontWeight.w700,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 10),
                  Text(letter.name, style: text.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    '基础发音：${letter.pronunciation}',
                    style: text.bodyMedium?.copyWith(
                      color: AppTheme.deepAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    letter.hint,
                    style: text.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('开始学习', style: text.titleLarge),
            const SizedBox(height: 6),
            Text(
              '把听读和书写拆开练习，会更清楚也更不容易累。',
              style: text.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              context: context,
              icon: Icons.volume_up_rounded,
              iconBg: const Color(0xFFE8F3FF),
              iconColor: const Color(0xFF4C7CF0),
              title: '听读',
              subtitle: '学习 13 个读音位、示例词和基础发音',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AlphabetListenReadPage(letter: letter),
                  ),
                );
              },
            ),
            _buildActionCard(
              context: context,
              icon: Icons.edit_rounded,
              iconBg: const Color(0xFFE8F5F0),
              iconColor: AppTheme.deepAccent,
              title: '书写',
              subtitle: '学习独立形、词首形、词中形、词尾形与连写规则',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AlphabetWritePage(letter: letter),
                  ),
                );
              },
            ),
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
          child: Icon(
            icon,
            color: AppTheme.primaryText,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
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
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
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
