import 'package:flutter/material.dart';
import '../models/alphabet_group.dart';
import '../theme/app_theme.dart';

class AlphabetDetailPage extends StatelessWidget {
  final AlphabetLetter letter;

  const AlphabetDetailPage({
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
                      Text('字母详情', style: text.titleLarge),
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
                      fontSize: 54,
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
                    letter.soundHint,
                    style: text.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _buildAudioPlaceholder(
                    context,
                    title: '播放字母发音',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('听读练习', style: text.titleLarge),
            const SizedBox(height: 6),
            Text(
              '这里完整展示这个字母的 13 个标准读音位。',
              style: text.bodyMedium,
            ),
            const SizedBox(height: 14),
            ...letter.pronunciations.map(
              (item) => _buildPronunciationCard(
                context,
                form: item.form,
                latin: item.latin,
                label: item.label,
                hint: item.hint,
              ),
            ),
            const SizedBox(height: 24),
            Text('示例词', style: text.titleLarge),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 16,
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
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5F0),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: AppTheme.deepAccent,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          letter.example.arabic,
                          style: text.titleLarge?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.volume_up_rounded,
                        color: AppTheme.deepAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    letter.example.latin,
                    style: text.bodyMedium?.copyWith(
                      color: AppTheme.deepAccent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    letter.example.meaning,
                    style: text.titleMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('书写形态', style: text.titleLarge),
            const SizedBox(height: 6),
            Text(
              '阿拉伯字母在词中不同位置会有不同写法。',
              style: text.bodyMedium,
            ),
            const SizedBox(height: 14),
            _buildFormCard(
              context,
              title: '独立形',
              value: letter.forms.isolated,
            ),
            _buildFormCard(
              context,
              title: '词首形',
              value: letter.forms.initial,
            ),
            _buildFormCard(
              context,
              title: '词中形',
              value: letter.forms.medial,
            ),
            _buildFormCard(
              context,
              title: '词尾形',
              value: letter.forms.finalForm,
            ),
            const SizedBox(height: 24),
            Text('连写规则', style: text.titleLarge),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFFE8F5F0),
                    child: Icon(
                      Icons.link_rounded,
                      color: AppTheme.deepAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      letter.connectsAfter
                          ? '这个字母通常可以与后面的字母继续连接。'
                          : '这个字母通常不向后连接，后一个字母会重新起笔。',
                      style: text.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('学习提示', style: text.titleLarge),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFFE8F5F0),
                    child: Icon(
                      Icons.lightbulb_rounded,
                      color: AppTheme.deepAccent,
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
            const SizedBox(height: 24),
            Text('学习动作', style: text.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFFD0D5DD)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text('跟读练习'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.deepAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text('开始书写'),
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

  Widget _buildAudioPlaceholder(
    BuildContext context, {
    required String title,
  }) {
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.82),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.volume_up_rounded,
            color: AppTheme.deepAccent,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: text.labelLarge?.copyWith(
              color: AppTheme.deepAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPronunciationCard(
    BuildContext context, {
    required String form,
    required String latin,
    required String label,
    required String hint,
  }) {
    final text = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5F0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                form,
                style: text.titleLarge?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: text.titleMedium),
                const SizedBox(height: 4),
                Text(
                  latin,
                  style: text.bodyMedium?.copyWith(
                    color: AppTheme.deepAccent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hint,
                  style: text.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.volume_up_rounded,
            color: AppTheme.deepAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(
    BuildContext context, {
    required String title,
    required String value,
  }) {
    final text = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
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
          Expanded(
            child: Text(title, style: text.titleMedium),
          ),
          Text(
            value,
            style: text.titleLarge?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}
