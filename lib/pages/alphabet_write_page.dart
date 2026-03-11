import 'package:flutter/material.dart';
import '../models/alphabet_group.dart';
import '../theme/app_theme.dart';

class AlphabetWritePage extends StatelessWidget {
  final AlphabetLetter letter;

  const AlphabetWritePage({
    super.key,
    required this.letter,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final width = MediaQuery.of(context).size.width;

    final bool isSmallScreen = width < 360;
    final bool isLargeScreen = width >= 520;

    final double pagePadding = isSmallScreen ? 14 : 16;
    final double topCardPadding = isSmallScreen ? 14 : 18;
    final double sectionGap = isSmallScreen ? 14 : 16;
    final double topButtonSize = isSmallScreen ? 38 : 40;
    final double letterFontSize = isSmallScreen ? 42 : 48;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            pagePadding,
            12,
            pagePadding,
            20,
          ),
          children: [
            Row(
              children: [
                _buildTopButton(
                  size: topButtonSize,
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('书写', style: text.titleMedium),
                      const SizedBox(height: 1),
                      Text(
                        '${letter.name} · ${letter.pronunciation}',
                        style: text.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: sectionGap),
            Container(
              padding: EdgeInsets.all(topCardPadding),
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
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    letter.arabic,
                    style: text.headlineLarge?.copyWith(
                      fontSize: letterFontSize,
                      fontWeight: FontWeight.w700,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 6),
                  Text(letter.name, style: text.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    letter.hint,
                    style: text.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: sectionGap),
            Text('书写形态', style: text.titleMedium),
            const SizedBox(height: 6),
            Text(
              '阿拉伯字母在不同位置会变化，这是阅读和书写的关键。',
              style: text.bodyMedium,
            ),
            const SizedBox(height: 12),
            _buildFormsGrid(
              context,
              isSmallScreen: isSmallScreen,
              isLargeScreen: isLargeScreen,
            ),
            SizedBox(height: sectionGap),
            Text('连写规则', style: text.titleMedium),
            const SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: isSmallScreen ? 18 : 20,
                    backgroundColor: const Color(0xFFE8F5F0),
                    child: Icon(
                      Icons.link_rounded,
                      color: AppTheme.deepAccent,
                      size: isSmallScreen ? 18 : 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      letter.connectsAfter
                          ? '这个字母通常可以与后面的字母继续连接。写单词时要注意保持笔画连贯。'
                          : '这个字母通常不向后连接，后一个字母需要重新起笔。阅读和书写时这一点非常关键。',
                      style: text.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: sectionGap),
            Text('学习提示', style: text.titleMedium),
            const SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: isSmallScreen ? 18 : 20,
                    backgroundColor: const Color(0xFFE8F5F0),
                    child: Icon(
                      Icons.lightbulb_rounded,
                      color: AppTheme.deepAccent,
                      size: isSmallScreen ? 18 : 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      letter.tip,
                      style: text.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: sectionGap),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 12 : 13,
                      ),
                      side: const BorderSide(color: Color(0xFFD0D5DD)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text('观察形态'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.deepAccent,
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 12 : 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text('开始临摹'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildTopButton({
    required double size,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryText,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildFormsGrid(
    BuildContext context, {
    required bool isSmallScreen,
    required bool isLargeScreen,
  }) {
    final forms = [
      {'title': '独立形', 'value': letter.forms.isolated},
      {'title': '词首形', 'value': letter.forms.initial},
      {'title': '词中形', 'value': letter.forms.medial},
      {'title': '词尾形', 'value': letter.forms.finalForm},
    ];

    final int crossAxisCount = isLargeScreen ? 4 : 2;
    final double ratio = isSmallScreen ? 1.2 : 1.35;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: forms.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: ratio,
      ),
      itemBuilder: (context, index) {
        final item = forms[index];
        return _buildFormTile(
          context,
          compact: isSmallScreen,
          title: item['title']!,
          value: item['value']!,
        );
      },
    );
  }

  Widget _buildFormTile(
    BuildContext context, {
    required bool compact,
    required String title,
    required String value,
  }) {
    final text = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: text.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: text.titleLarge?.copyWith(
              fontSize: compact ? 24 : 28,
              fontWeight: FontWeight.w700,
              color: AppTheme.deepAccent,
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
