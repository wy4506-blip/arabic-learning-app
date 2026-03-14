import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/alphabet_content_localizer.dart';
import '../l10n/localized_text.dart';
import '../models/alphabet_group.dart';
import '../services/audio_service.dart';
import '../services/review_service.dart';
import '../theme/app_arabic_typography.dart';
import '../theme/app_theme.dart';
import 'alphabet_listen_read_page.dart';
import 'alphabet_write_page.dart';

class AlphabetLetterHomePage extends StatefulWidget {
  final AlphabetLetter letter;

  const AlphabetLetterHomePage({
    super.key,
    required this.letter,
  });

  @override
  State<AlphabetLetterHomePage> createState() => _AlphabetLetterHomePageState();
}

class _AlphabetLetterHomePageState extends State<AlphabetLetterHomePage> {
  static const String _namePlaybackKey = 'letter_name';

  AlphabetLetter get letter => widget.letter;
  String? _playingTarget;

  bool get _isPlayingName => _playingTarget == _namePlaybackKey;

  @override
  void initState() {
    super.initState();
    AudioService.initialize();
    ReviewService.markAlphabetViewed(letter);
  }

  @override
  void dispose() {
    AudioService.stop();
    super.dispose();
  }

  Future<void> _playLetterName() async {
    if (_isPlayingName) {
      await AudioService.stop();
      if (!mounted) return;
      setState(() => _playingTarget = null);
      return;
    }

    setState(() => _playingTarget = _namePlaybackKey);
    try {
      await AudioService.speakLetter(letter.arabic);
    } catch (_) {
      // Audio unavailable (e.g. Windows without TTS) — ignore gracefully.
    }
    if (!mounted) return;
    setState(() => _playingTarget = null);
  }

  List<_LetterFormExample> get _formExamples => <_LetterFormExample>[
        _LetterFormExample(
          title: '独立',
          value: letter.forms.isolated,
          exampleWord:
              letter.connectsAfter ? letter.arabic : 'ر${letter.arabic}و',
          note: letter.connectsAfter ? '单独书写' : '字中断开示意',
        ),
        _LetterFormExample(
          title: '词首',
          value: letter.forms.initial,
          exampleWord: '${letter.arabic}مر',
          note: '位于词首',
        ),
        _LetterFormExample(
          title: '词中',
          value: letter.forms.medial,
          exampleWord: 'م${letter.arabic}ر',
          note: '位于词中',
        ),
        _LetterFormExample(
          title: '词尾',
          value: letter.forms.finalForm,
          exampleWord: 'مر${letter.arabic}',
          note: '位于词尾',
        ),
      ];

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
                      Text(
                        localizedText(
                          context,
                          zh: '字母学习',
                          en: 'Letter Study',
                        ),
                        style: text.titleLarge,
                      ),
                      const SizedBox(height: 2),
                      ArabicText.word(
                        letter.arabicName,
                        style: text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        letter.latinName,
                        style: text.bodySmall?.copyWith(
                          color: AppTheme.deepAccent,
                        ),
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
                  ArabicText.word(
                    letter.arabic,
                    style: text.headlineLarge?.copyWith(
                      fontSize: 56,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  ArabicText.word(
                    letter.arabicName,
                    style: text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    letter.latinName,
                    style: text.titleSmall?.copyWith(
                      color: AppTheme.deepAccent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    localizedText(
                      context,
                      zh: '基础发音：${letter.pronunciation}',
                      en: 'Core sound: ${letter.pronunciation}',
                    ),
                    style: text.bodyMedium?.copyWith(
                      color: AppTheme.deepAccent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.deepAccent,
                      side: const BorderSide(color: Color(0xFFD0D5DD)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: _playLetterName,
                    icon: Icon(
                      _isPlayingName
                          ? Icons.stop_rounded
                          : Icons.volume_up_rounded,
                    ),
                    label: Text(
                      _isPlayingName
                          ? localizedText(
                              context,
                              zh: '停止名称朗读',
                              en: 'Stop Name Audio',
                            )
                          : localizedText(
                              context,
                              zh: '朗读阿语字母名称',
                              en: 'Hear Arabic Letter Name',
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AlphabetContentLocalizer.hint(
                      letter,
                      context.appSettings.meaningLanguage,
                    ),
                    style: text.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              localizedText(
                context,
                zh: '先抓住这几个重点',
                en: 'Focus on These First',
              ),
              style: text.titleLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildFocusChip(
                  label: localizedText(
                    context,
                    zh: '基础音值 ${letter.phoneme}',
                    en: 'Core Sound ${letter.phoneme}',
                  ),
                  icon: Icons.graphic_eq_rounded,
                ),
                _buildFocusChip(
                  label: localizedText(
                    context,
                    zh: '13 个读音形式',
                    en: '13 Sound Forms',
                  ),
                  icon: Icons.record_voice_over_rounded,
                ),
                _buildFocusChip(
                  label: localizedText(
                    context,
                    zh: '4 种书写形态',
                    en: '4 Writing Forms',
                  ),
                  icon: Icons.draw_rounded,
                ),
                _buildFocusChip(
                  label: localizedText(
                    context,
                    zh: letter.connectsAfter ? '可继续连写' : '后方会断开',
                    en: letter.connectsAfter
                        ? 'Connects Forward'
                        : 'Breaks After It',
                  ),
                  icon: Icons.link_rounded,
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                  Text(
                    localizedText(context, zh: '示例词', en: 'Example Word'),
                    style: text.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ArabicText.word(
                              letter.example.arabic,
                              style: text.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              letter.example.latin,
                              style: text.bodySmall?.copyWith(
                                color: AppTheme.deepAccent,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AlphabetContentLocalizer.exampleMeaning(
                                letter.example,
                                context.appSettings.meaningLanguage,
                              ),
                              style: text.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4FBF8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            AlphabetContentLocalizer.soundHint(
                              letter,
                              context.appSettings.meaningLanguage,
                            ),
                            style: text.bodySmall,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    localizedText(
                      context,
                      zh: '四种常见字形',
                      en: 'Four Common Forms',
                    ),
                    style: text.titleSmall,
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _formExamples.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.18,
                    ),
                    itemBuilder: (context, index) {
                      final item = _formExamples[index];
                      return _buildFormTile(
                        context,
                        title: item.title,
                        value: item.value,
                        exampleWord: item.exampleWord,
                        note: item.note,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              localizedText(
                context,
                zh: '开始学习',
                en: 'Start Learning',
              ),
              style: text.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              localizedText(
                context,
                zh: '把听读和书写拆开练习，会更清楚也更不容易累。',
                en: 'Split listening and writing into two passes. It stays clearer and less tiring.',
              ),
              style: text.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              context: context,
              icon: Icons.volume_up_rounded,
              iconBg: const Color(0xFFE8F3FF),
              iconColor: const Color(0xFF4C7CF0),
              title: localizedText(context, zh: '听读', en: 'Listen'),
              subtitle: localizedText(
                context,
                zh: '学习 13 个读音位、示例词和基础发音',
                en: 'Study the 13 sound forms, example word, and base pronunciation.',
              ),
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
              title: localizedText(context, zh: '书写', en: 'Write'),
              subtitle: localizedText(
                context,
                zh: '学习独立形、词首形、词中形、词尾形与连写规则',
                en: 'Study isolated, initial, medial, final forms, and connection rules.',
              ),
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

  static Widget _buildFocusChip({
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

  Widget _buildFormTile(
    BuildContext context, {
    required String title,
    required String value,
    required String exampleWord,
    required String note,
  }) {
    final text = Theme.of(context).textTheme;
    final localizedTitle = switch (title) {
      '独立' => localizedText(context, zh: '独立', en: 'Isolated'),
      '词首' => localizedText(context, zh: '词首', en: 'Initial'),
      '词中' => localizedText(context, zh: '词中', en: 'Medial'),
      '词尾' => localizedText(context, zh: '词尾', en: 'Final'),
      _ => title,
    };
    final localizedNote = switch (note) {
      '单独书写' => localizedText(context, zh: '单独书写', en: 'Written Alone'),
      '字中断开示意' => localizedText(context, zh: '字中断开示意', en: 'Break Example'),
      '位于词首' => localizedText(context, zh: '位于词首', en: 'At Word Start'),
      '位于词中' => localizedText(context, zh: '位于词中', en: 'Inside a Word'),
      '位于词尾' => localizedText(context, zh: '位于词尾', en: 'At Word End'),
      _ => note,
    };

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            localizedTitle,
            style: text.labelSmall?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          ArabicText.word(
            value,
            style: text.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.deepAccent,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                Text(
                  localizedNote,
                  style: text.labelSmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                _HighlightedArabicWord(
                  word: exampleWord,
                  targetLetter: letter.arabic,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LetterFormExample {
  final String title;
  final String value;
  final String exampleWord;
  final String note;

  const _LetterFormExample({
    required this.title,
    required this.value,
    required this.exampleWord,
    required this.note,
  });
}

class _HighlightedArabicWord extends StatelessWidget {
  final String word;
  final String targetLetter;

  const _HighlightedArabicWord({
    required this.word,
    required this.targetLetter,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = AppArabicTypography.wordStyle(
      color: AppTheme.primaryText,
    ).copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.5,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: word.split('').map((char) {
            final isTarget = char == targetLetter;
            return TextSpan(
              text: char,
              style: baseStyle.copyWith(
                color: isTarget ? AppTheme.deepAccent : AppTheme.primaryText,
                backgroundColor:
                    isTarget ? const Color(0xFFDFF2EB) : Colors.transparent,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
