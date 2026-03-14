import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/alphabet_content_localizer.dart';
import '../l10n/localized_text.dart';
import '../models/alphabet_group.dart';
import '../services/audio_service.dart';
import '../theme/app_arabic_typography.dart';
import '../theme/app_theme.dart';
import '../widgets/alphabet_pronunciation_card.dart';
import 'alphabet_listen_read_page.dart';
import 'alphabet_write_page.dart';

class AlphabetDetailPage extends StatelessWidget {
  final AlphabetLetter letter;

  const AlphabetDetailPage({
    super.key,
    required this.letter,
  });

  Future<void> _playLetter() async {
    await AudioService.speakLetter(letter.arabic);
  }

  Future<void> _playExampleWord() async {
    await AudioService.speakExampleWord(letter.example.arabic);
  }

  void _showPronunciationSheet(
    BuildContext context,
    AlphabetPronunciationItem item,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PronunciationDetailSheet(
        item: item,
        onPlay: () => AudioService.speakPronunciationItem(item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final meaningLanguage = context.appSettings.meaningLanguage;
    final appLanguage = context.appSettings.appLanguage;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
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
                        localizedText(context, zh: '字母详情', en: 'Letter Detail'),
                        style: text.titleLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${letter.name} · ${letter.pronunciation}',
                        style: text.bodySmall?.copyWith(
                          color: const Color(0xFF667085),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEAF8F3), Color(0xFFDFF2EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ArabicText.word(
                    letter.arabic,
                    style: text.headlineLarge?.copyWith(
                      fontSize: 56,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ArabicText.word(
                    letter.arabicName,
                    style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    letter.latinName,
                    style: text.titleSmall?.copyWith(color: AppTheme.deepAccent),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    localizedText(
                      context,
                      zh: '基础发音：${letter.pronunciation}',
                      en: 'Core sound: ${letter.pronunciation}',
                    ),
                    style: text.bodyMedium?.copyWith(color: AppTheme.deepAccent),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AlphabetContentLocalizer.soundHint(letter, meaningLanguage),
                    style: text.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.deepAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: _playLetter,
                    icon: const Icon(Icons.volume_up_rounded),
                    label: Text(
                      localizedText(context, zh: '播放字母发音', en: 'Play Letter Audio'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.volume_up_rounded,
                    color: const Color(0xFF4C7CF0),
                    background: const Color(0xFFE9F1FF),
                    title: localizedText(context, zh: '听读', en: 'Listen'),
                    subtitle: localizedText(
                      context,
                      zh: '13 项标准发音与播放',
                      en: '13 standard forms with playback',
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AlphabetListenReadPage(letter: letter),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.edit_rounded,
                    color: AppTheme.deepAccent,
                    background: const Color(0xFFE8F5F0),
                    title: localizedText(context, zh: '书写', en: 'Write'),
                    subtitle: localizedText(
                      context,
                      zh: '四种字形与连写规则',
                      en: 'Four forms and connection rules',
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AlphabetWritePage(letter: letter),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              localizedText(context, zh: '13 项标准发音', en: '13 Standard Sound Forms'),
              style: text.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              localizedText(
                context,
                zh: '主界面只保留字形、标准名称和核心读音；点击卡片查看完整说明。',
                en: 'Keep the grid light: form, standard name, and core value. Tap for the full note.',
              ),
              style: text.bodyMedium?.copyWith(color: const Color(0xFF667085)),
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: letter.pronunciations.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.92,
              ),
              itemBuilder: (context, index) {
                final item = letter.pronunciations[index];
                return AlphabetPronunciationCard(
                  arabic: item.form,
                  title: AlphabetContentLocalizer.pronunciationShortTitle(item, appLanguage),
                  value: AlphabetContentLocalizer.pronunciationValue(item, appLanguage),
                  subtitle: AlphabetContentLocalizer.pronunciationShortSubtitle(
                    item,
                    meaningLanguage,
                  ),
                  isPlaying: false,
                  onTap: () => _showPronunciationSheet(context, item),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              localizedText(context, zh: '示例词', en: 'Example Word'),
              style: text.titleLarge,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: _panelDecoration(),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ArabicText.word(
                          letter.example.arabic,
                          style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          letter.example.latin,
                          style: text.bodySmall?.copyWith(color: AppTheme.deepAccent),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AlphabetContentLocalizer.exampleMeaning(
                            letter.example,
                            meaningLanguage,
                          ),
                          style: text.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.deepAccent,
                      side: const BorderSide(color: Color(0xFFD0D5DD)),
                    ),
                    onPressed: _playExampleWord,
                    icon: const Icon(Icons.volume_up_rounded),
                    label: Text(localizedText(context, zh: '播放', en: 'Play')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              localizedText(context, zh: '书写形态', en: 'Writing Forms'),
              style: text.titleLarge,
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.18,
              children: [
                _FormTile(
                  title: localizedText(context, zh: '独立形', en: 'Isolated'),
                  value: letter.forms.isolated,
                ),
                _FormTile(
                  title: localizedText(context, zh: '词首形', en: 'Initial'),
                  value: letter.forms.initial,
                ),
                _FormTile(
                  title: localizedText(context, zh: '词中形', en: 'Medial'),
                  value: letter.forms.medial,
                ),
                _FormTile(
                  title: localizedText(context, zh: '词尾形', en: 'Final'),
                  value: letter.forms.finalForm,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              localizedText(context, zh: '学习提示', en: 'Learning Note'),
              style: text.titleLarge,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: _panelDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_rounded, color: AppTheme.deepAccent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          AlphabetContentLocalizer.tip(letter, meaningLanguage),
                          style: text.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.link_rounded, color: AppTheme.deepAccent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          letter.connectsAfter
                              ? localizedText(
                                  context,
                                  zh: '这个字母通常可以继续向后连写。',
                                  en: 'This letter usually keeps connecting to the next letter.',
                                )
                              : localizedText(
                                  context,
                                  zh: '这个字母通常不向后连写，后一个字母会重新起笔。',
                                  en: 'This letter usually breaks forward connection, so the next letter starts fresh.',
                                ),
                          style: text.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static BoxDecoration _panelDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: const [
        BoxShadow(
          color: Color(0x10000000),
          blurRadius: 16,
          offset: Offset(0, 8),
        ),
      ],
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
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.color,
    required this.background,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE7EAEE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 12),
              Text(title, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: text.bodySmall?.copyWith(color: const Color(0xFF667085)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormTile extends StatelessWidget {
  final String title;
  final String value;

  const _FormTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AlphabetDetailPage._panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: text.bodySmall?.copyWith(color: const Color(0xFF667085))),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: ArabicText.word(
                value,
                style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PronunciationDetailSheet extends StatelessWidget {
  final AlphabetPronunciationItem item;
  final Future<void> Function() onPlay;

  const _PronunciationDetailSheet({
    required this.item,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final appLanguage = context.appSettings.appLanguage;
    final meaningLanguage = context.appSettings.meaningLanguage;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD0D5DD),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            ArabicText.word(
              item.form,
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _DetailRow(
              label: localizedText(context, zh: '中文名称', en: 'Name'),
              value: AlphabetContentLocalizer.pronunciationFullTitle(item, appLanguage),
            ),
            _DetailRow(label: 'Arabic', value: item.form),
            _DetailRow(label: 'Transliteration', value: item.transliteration),
            if (item.ipa.isNotEmpty) _DetailRow(label: 'IPA', value: item.ipa),
            _DetailRow(
              label: localizedText(context, zh: '说明', en: 'Note'),
              value: AlphabetContentLocalizer.pronunciationDetailDescription(
                item,
                meaningLanguage,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.deepAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: onPlay,
                icon: const Icon(Icons.volume_up_rounded),
                label: Text(localizedText(context, zh: '播放示例', en: 'Play Sample')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: text.bodySmall?.copyWith(color: const Color(0xFF667085)),
          ),
          const SizedBox(height: 4),
          Text(value, style: text.titleSmall),
        ],
      ),
    );
  }
}
