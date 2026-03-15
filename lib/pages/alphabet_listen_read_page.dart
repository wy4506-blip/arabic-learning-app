import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/alphabet_content_localizer.dart';
import '../l10n/localized_text.dart';
import '../models/alphabet_group.dart';
import '../services/alphabet_progress_service.dart';
import '../services/audio_service.dart';
import '../services/review_service.dart';
import '../theme/app_arabic_typography.dart';
import '../theme/app_theme.dart';
import '../widgets/alphabet_pronunciation_card.dart';

class AlphabetListenReadPage extends StatefulWidget {
  final AlphabetLetter letter;

  const AlphabetListenReadPage({
    super.key,
    required this.letter,
  });

  @override
  State<AlphabetListenReadPage> createState() => _AlphabetListenReadPageState();
}

class _AlphabetListenReadPageState extends State<AlphabetListenReadPage> {
  String? _playingForm;
  bool _isPlayingAll = false;
  bool _isShadowing = false;
  String? _shadowingLabel;

  void _showAudioUnavailableMessage() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          localizedText(
            context,
            zh: '当前设备暂时没有可用音频，已跳过播放。',
            en: 'Audio is not available on this device right now.',
          ),
        ),
      ),
    );
  }

  Future<void> _completeLetter() async {
    await AlphabetProgressService.markLetterViewed(widget.letter);
    await ReviewService.markAlphabetViewed(widget.letter);
    await AlphabetProgressService.markListenReadCompleted(widget.letter);
    await ReviewService.markAlphabetListenReadCompleted(widget.letter);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  void initState() {
    super.initState();
    AudioService.initialize();
  }

  @override
  void dispose() {
    AudioService.stop();
    super.dispose();
  }

  Future<void> _playLetter() async {
    setState(() => _playingForm = widget.letter.arabic);
    try {
      await AudioService.playLearningText(
        LearningAudioRequest.alphabet(
          type: 'letter',
          textAr: widget.letter.arabic,
          textPlain: widget.letter.arabic,
          debugLabel: 'alphabet_listen_read_letter',
        ),
      );
    } catch (_) {
      _showAudioUnavailableMessage();
    }
    if (mounted) {
      setState(() => _playingForm = null);
    }
  }

  Future<void> _playPronunciation(AlphabetPronunciationItem item) async {
    setState(() => _playingForm = item.form);
    try {
      await AudioService.playLearningText(
        LearningAudioRequest.alphabet(
          type: 'pronunciation',
          textAr: item.audioQueryText,
          textPlain: item.form,
          debugLabel: 'alphabet_listen_read_pronunciation',
        ),
      );
    } catch (_) {
      _showAudioUnavailableMessage();
    }
    if (mounted) {
      setState(() => _playingForm = null);
    }
  }

  Future<void> _playExampleWord() async {
    setState(() => _playingForm = widget.letter.example.arabic);
    try {
      await AudioService.playLearningText(
        LearningAudioRequest.alphabet(
          type: 'word',
          textAr: widget.letter.example.arabic,
          textPlain: widget.letter.example.arabic,
          debugLabel: 'alphabet_listen_read_example_word',
        ),
      );
    } catch (_) {
      _showAudioUnavailableMessage();
    }
    if (mounted) {
      setState(() => _playingForm = null);
    }
  }

  Future<void> _playAllPronunciations() async {
    if (_isPlayingAll) {
      await AudioService.stop();
      if (!mounted) return;
      setState(() {
        _isPlayingAll = false;
        _playingForm = null;
      });
      return;
    }

    setState(() => _isPlayingAll = true);

    for (final item in widget.letter.pronunciations) {
      if (!mounted || !_isPlayingAll) break;
      await _playPronunciation(item);
      await Future.delayed(const Duration(milliseconds: 320));
    }

    if (mounted) {
      setState(() {
        _isPlayingAll = false;
        _playingForm = null;
      });
    }
  }

  Future<void> _startShadowing() async {
    if (_isShadowing) {
      await AudioService.stop();
      if (!mounted) return;
      setState(() {
        _isShadowing = false;
        _shadowingLabel = null;
        _playingForm = null;
      });
      return;
    }

    final steps = <({String label, Future<void> Function() play})>[
      (
        label: localizedText(context,
            zh: '先跟读字母本体', en: 'Repeat the base letter first'),
        play: _playLetter,
      ),
      for (final item in widget.letter.pronunciations.take(4))
        (
          label: localizedText(
            context,
            zh: '跟读 ${item.shortTitle}',
            en: 'Repeat ${AlphabetContentLocalizer.pronunciationShortTitle(item, context.appSettings.appLanguage)}',
          ),
          play: () => _playPronunciation(item),
        ),
      (
        label: localizedText(context,
            zh: '最后跟读示例词', en: 'Finish with the example word'),
        play: _playExampleWord,
      ),
    ];

    setState(() {
      _isShadowing = true;
      _shadowingLabel =
          localizedText(context, zh: '准备开始跟读', en: 'Preparing shadowing');
    });

    for (final step in steps) {
      if (!mounted || !_isShadowing) break;
      setState(() => _shadowingLabel = step.label);
      await step.play();
      if (!mounted || !_isShadowing) break;
      await Future.delayed(const Duration(milliseconds: 900));
    }

    if (mounted) {
      setState(() {
        _isShadowing = false;
        _shadowingLabel = null;
        _playingForm = null;
      });
    }
  }

  void _showPronunciationSheet(AlphabetPronunciationItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PronunciationDetailSheet(
        item: item,
        onPlay: () => _playPronunciation(item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final appLanguage = context.appSettings.appLanguage;
    final meaningLanguage = context.appSettings.meaningLanguage;

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
                      Text(localizedText(context, zh: '听读', en: 'Listen'),
                          style: text.titleLarge),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.letter.name} · ${widget.letter.pronunciation}',
                        style: text.bodySmall
                            ?.copyWith(color: const Color(0xFF667085)),
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
                    widget.letter.arabic,
                    style: text.headlineLarge?.copyWith(
                      fontSize: 52,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  ArabicText.word(
                    widget.letter.arabicName,
                    style:
                        text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    localizedText(
                      context,
                      zh: '基础发音：${widget.letter.pronunciation}',
                      en: 'Core sound: ${widget.letter.pronunciation}',
                    ),
                    style:
                        text.bodyMedium?.copyWith(color: AppTheme.deepAccent),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.deepAccent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: _playLetter,
                          icon: _playingForm == widget.letter.arabic
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Icon(Icons.volume_up_rounded),
                          label: Text(
                            localizedText(context,
                                zh: '播放字母', en: 'Play Letter'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.deepAccent,
                            side: const BorderSide(color: Color(0xFFD0D5DD)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: _playExampleWord,
                          icon: Icon(
                            _playingForm == widget.letter.example.arabic
                                ? Icons.stop_rounded
                                : Icons.volume_up_rounded,
                          ),
                          label: Text(
                            localizedText(
                              context,
                              zh: '示例词',
                              en: 'Example Word',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
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
              child: Text(
                localizedText(
                  context,
                  zh: '首轮先把字母本体和一个示例词听熟就够了。13 项标准发音和跟读放到后面巩固。',
                  en: 'For the first pass, it is enough to hear the base letter and one example word. The 13 sound forms and shadowing can wait.',
                ),
                style: text.bodyMedium,
              ),
            ),
            const SizedBox(height: 20),
            Text(localizedText(context, zh: '示例词', en: 'Example Word'),
                style: text.titleLarge),
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
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ArabicText.word(
                          widget.letter.example.arabic,
                          style: text.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.letter.example.latin,
                          style: text.bodySmall
                              ?.copyWith(color: AppTheme.deepAccent),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AlphabetContentLocalizer.exampleMeaning(
                            widget.letter.example,
                            meaningLanguage,
                          ),
                          style: text.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.deepAccent),
                    onPressed: _playExampleWord,
                    icon: const Icon(Icons.volume_up_rounded),
                    label: Text(localizedText(context, zh: '播放', en: 'Play')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
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
                onPressed: _completeLetter,
                icon: const Icon(Icons.check_circle_rounded),
                label: Text(
                  localizedText(
                    context,
                    zh: '完成这个字母',
                    en: 'Finish This Letter',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              localizedText(
                context,
                zh: '13 项标准发音',
                en: '13 Standard Sound Forms',
              ),
              style: text.labelLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            Container(
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
              child: Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 4,
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                  title: Text(
                    localizedText(
                      context,
                      zh: '进阶发音（可稍后）',
                      en: 'Advanced Pronunciation Later',
                    ),
                    style: text.titleMedium,
                  ),
                  subtitle: Text(
                    localizedText(
                      context,
                      zh: '播放全部、13 项标准发音和跟读模式都保留在这里。',
                      en: 'Play all, the 13 standard sound forms, and shadowing stay here.',
                    ),
                    style: text.bodySmall,
                  ),
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.deepAccent,
                          side: const BorderSide(color: Color(0xFFD0D5DD)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: _playAllPronunciations,
                        icon: Icon(
                          _isPlayingAll
                              ? Icons.stop_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        label: Text(
                          _isPlayingAll
                              ? localizedText(context, zh: '停止', en: 'Stop')
                              : localizedText(
                                  context,
                                  zh: '播放全部发音',
                                  en: 'Play All Sounds',
                                ),
                        ),
                      ),
                    ),
                    if (_isShadowing) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7FAF9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.record_voice_over_rounded,
                              color: AppTheme.deepAccent,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _shadowingLabel ??
                                    localizedText(
                                      context,
                                      zh: '正在跟读',
                                      en: 'Shadowing now',
                                    ),
                                style: text.bodyMedium?.copyWith(
                                  color: AppTheme.deepAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    Text(
                      localizedText(
                        context,
                        zh: '13 项标准发音',
                        en: '13 Standard Sound Forms',
                      ),
                      style: text.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      localizedText(
                        context,
                        zh: '卡片只保留符号、标准名称和核心读音；点击后再看详细解释与播放。',
                        en: 'Cards stay compact. Tap for the detailed note and playback.',
                      ),
                      style: text.bodyMedium?.copyWith(
                        color: const Color(0xFF667085),
                      ),
                    ),
                    const SizedBox(height: 14),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.letter.pronunciations.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.92,
                      ),
                      itemBuilder: (context, index) {
                        final item = widget.letter.pronunciations[index];
                        return AlphabetPronunciationCard(
                          arabic: item.form,
                          title:
                              AlphabetContentLocalizer.pronunciationShortTitle(
                            item,
                            appLanguage,
                          ),
                          value: AlphabetContentLocalizer.pronunciationValue(
                            item,
                            appLanguage,
                          ),
                          subtitle: AlphabetContentLocalizer
                              .pronunciationShortSubtitle(
                            item,
                            meaningLanguage,
                          ),
                          isPlaying: _playingForm == item.form,
                          onTap: () => _showPronunciationSheet(item),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: const BorderSide(color: Color(0xFFD0D5DD)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: _startShadowing,
                      icon: const Icon(Icons.mic_rounded),
                      label: Text(
                        _isShadowing
                            ? localizedText(
                                context,
                                zh: '停止跟读',
                                en: 'Stop Shadowing',
                              )
                            : localizedText(
                                context,
                                zh: '跟读模式',
                                en: 'Shadowing Mode',
                              ),
                      ),
                    ),
                  ],
                ),
              ),
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
          child: Icon(icon, color: AppTheme.primaryText, size: 20),
        ),
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
              value: AlphabetContentLocalizer.pronunciationFullTitle(
                  item, appLanguage),
            ),
            _DetailRow(label: 'Arabic', value: item.form),
            _DetailRow(label: 'Transliteration', value: item.transliteration),
            if (item.ipa.isNotEmpty) _DetailRow(label: 'IPA', value: item.ipa),
            _DetailRow(
              label: localizedText(context, zh: '说明', en: 'Note'),
              value: AlphabetContentLocalizer.pronunciationDetailDescription(
                  item, meaningLanguage),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.deepAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                ),
                onPressed: onPlay,
                icon: const Icon(Icons.volume_up_rounded),
                label:
                    Text(localizedText(context, zh: '播放示例', en: 'Play Sample')),
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
