import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/alphabet_content_localizer.dart';
import '../l10n/localized_text.dart';
import '../models/alphabet_group.dart';
import '../services/audio_service.dart';
import '../theme/app_arabic_typography.dart';
import '../theme/app_theme.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeAudio();
  }

  @override
  void dispose() {
    AudioService.stop();
    super.dispose();
  }

  Future<void> _initializeAudio() async {
    await AudioService.initialize();
  }

  Future<void> _playLetter() async {
    setState(() {
      _playingForm = widget.letter.arabic;
    });

    await AudioService.speakLetter(widget.letter.arabic);

    if (mounted) {
      setState(() {
        _playingForm = null;
      });
    }
  }

  Future<void> _playPronunciation(String form) async {
    setState(() {
      _playingForm = form;
    });

    await AudioService.speakPronunciation(form);

    if (mounted) {
      setState(() {
        _playingForm = null;
      });
    }
  }

  Future<void> _playExampleWord() async {
    setState(() {
      _playingForm = widget.letter.example.arabic;
    });

    await AudioService.speakExampleWord(widget.letter.example.arabic);

    if (mounted) {
      setState(() {
        _playingForm = null;
      });
    }
  }

  Future<void> _playAllPronunciations() async {
    if (_isPlayingAll) {
      await AudioService.stop();
      if (mounted) {
        setState(() {
          _isPlayingAll = false;
          _playingForm = null;
        });
      }
      return;
    }

    setState(() {
      _isPlayingAll = true;
    });

    for (final item in widget.letter.pronunciations) {
      if (!mounted || !_isPlayingAll) break;

      setState(() {
        _playingForm = item.form;
      });

      await AudioService.speakPronunciation(item.form);
      await Future.delayed(const Duration(milliseconds: 300));
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

    final steps = <({String form, String label, Future<void> Function() play})>[
      (
        form: widget.letter.arabic,
        label: localizedText(
          context,
          zh: '先跟读字母本体',
          en: 'Repeat the letter itself first',
        ),
        play: _playLetter,
      ),
      for (final item in widget.letter.pronunciations.take(3))
        (
          form: item.form,
          label: localizedText(
            context,
            zh: '跟读 ${item.label}',
            en:
                'Repeat ${AlphabetContentLocalizer.pronunciationLabel(item.label, context.appSettings.appLanguage)}',
          ),
          play: () => _playPronunciation(item.form),
        ),
      (
        form: widget.letter.example.arabic,
        label: localizedText(
          context,
          zh: '最后跟读示例词',
          en: 'Finish by repeating the example word',
        ),
        play: _playExampleWord,
      ),
    ];

    setState(() {
      _isShadowing = true;
      _shadowingLabel = localizedText(
        context,
        zh: '准备开始跟读',
        en: 'Getting ready to shadow',
      );
    });

    for (final step in steps) {
      if (!mounted || !_isShadowing) break;
      setState(() {
        _shadowingLabel = step.label;
        _playingForm = step.form;
      });
      await step.play();
      if (!mounted || !_isShadowing) break;
      await Future.delayed(const Duration(milliseconds: 900));
    }

    if (!mounted) return;
    setState(() {
      _isShadowing = false;
      _shadowingLabel = null;
      _playingForm = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final width = MediaQuery.of(context).size.width;

    final bool isSmallScreen = width < 360;
    final bool isLargeScreen = width >= 520;

    final int crossAxisCount = isLargeScreen
        ? 4
        : isSmallScreen
            ? 2
            : 3;

    final double pagePadding = isSmallScreen ? 14 : 16;
    final double topCardPadding = isSmallScreen ? 14 : 16;
    final double letterFontSize = isSmallScreen ? 38 : 42;
    final double sectionGap = isSmallScreen ? 14 : 16;
    final double topButtonSize = isSmallScreen ? 38 : 40;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(pagePadding, 12, pagePadding, 20),
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
                      Text(
                        localizedText(context, zh: '听读', en: 'Listen'),
                        style: text.titleMedium,
                      ),
                      const SizedBox(height: 1),
                      ArabicText.word(
                        widget.letter.arabicName,
                        style: text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.letter.latinName,
                        style: text.bodySmall?.copyWith(
                          color: AppTheme.deepAccent,
                        ),
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
                  ArabicText.word(
                    widget.letter.arabic,
                    style: text.headlineLarge?.copyWith(
                      fontSize: letterFontSize,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  ArabicText.word(
                    widget.letter.arabicName,
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.letter.latinName,
                    style: text.bodySmall?.copyWith(
                      color: AppTheme.deepAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    localizedText(
                      context,
                      zh: '基础发音：${widget.letter.pronunciation}',
                      en: 'Core sound: ${widget.letter.pronunciation}',
                    ),
                    style: text.bodySmall?.copyWith(
                      color: AppTheme.deepAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.deepAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _playLetter,
                      icon: _playingForm == widget.letter.arabic
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.volume_up_rounded),
                      label: Text(
                        _playingForm == widget.letter.arabic
                            ? localizedText(
                                context,
                                zh: '播放中...',
                                en: 'Playing...',
                              )
                            : localizedText(
                                context,
                                zh: '播放字母发音',
                                en: 'Play Letter Audio',
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildPronunciationMapCompact(
                    context,
                    compact: isSmallScreen,
                  ),
                ],
              ),
            ),
            if (_isShadowing) ...[
              SizedBox(height: sectionGap),
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
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
            SizedBox(height: sectionGap),
            Text(
              localizedText(
                context,
                zh: '13个标准读音',
                en: '13 Standard Sound Forms',
              ),
              style: text.titleMedium,
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.letter.pronunciations.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: isLargeScreen
                    ? 1.0
                    : isSmallScreen
                        ? 0.95
                        : 1.02,
              ),
              itemBuilder: (context, index) {
                final item = widget.letter.pronunciations[index];
                return _buildPronunciationMiniTile(
                  context,
                  compact: isSmallScreen,
                  form: item.form,
                  latin: item.latin,
                  label: item.label,
                );
              },
            ),
            SizedBox(height: sectionGap),
            Text(
              localizedText(context, zh: '示例词', en: 'Example Word'),
              style: text.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: isSmallScreen ? 44 : 48,
                    height: isSmallScreen ? 44 : 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5F0),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: AppTheme.deepAccent,
                      size: isSmallScreen ? 20 : 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ArabicText.word(
                          widget.letter.example.arabic,
                          style: text.titleLarge?.copyWith(
                            fontSize: isSmallScreen ? 20 : 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.letter.example.latin,
                          style: text.bodySmall?.copyWith(
                            color: AppTheme.deepAccent,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AlphabetContentLocalizer.exampleMeaning(
                            widget.letter.example,
                            context.appSettings.meaningLanguage,
                          ),
                          style: text.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: _playExampleWord,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          _playingForm == widget.letter.example.arabic
                              ? Icons.stop_rounded
                              : Icons.volume_up_rounded,
                          color: AppTheme.deepAccent,
                          size: isSmallScreen ? 20 : 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: sectionGap),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 12 : 13,
                      ),
                      side: const BorderSide(color: Color(0xFFD0D5DD)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
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
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.deepAccent,
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 12 : 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _playAllPronunciations,
                    icon: _isPlayingAll
                        ? const Icon(Icons.stop_rounded)
                        : const Icon(Icons.play_arrow_rounded),
                    label: Text(
                      _isPlayingAll
                          ? localizedText(context, zh: '停止', en: 'Stop')
                          : localizedText(
                              context,
                              zh: '播放全部',
                              en: 'Play All',
                            ),
                    ),
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

  Widget _buildPronunciationMapCompact(
    BuildContext context, {
    required bool compact,
  }) {
    final text = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(compact ? 8 : 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.82),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildZone(
                  label: localizedText(context, zh: '双唇', en: 'Lips'),
                  color: const Color(0xFFFFD9C7),
                  compact: compact,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildZone(
                  label: localizedText(context, zh: '舌尖', en: 'Tongue Tip'),
                  color: const Color(0xFFFFF0B8),
                  compact: compact,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildZone(
                  label: localizedText(context, zh: '喉部', en: 'Throat'),
                  color: const Color(0xFFD8F0E6),
                  compact: compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            localizedText(
              context,
              zh: '发音部位示意',
              en: 'Sound Placement Guide',
            ),
            style: text.labelMedium?.copyWith(
              color: AppTheme.deepAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZone({
    required String label,
    required Color color,
    required bool compact,
  }) {
    return Container(
      height: compact ? 34 : 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: compact ? 10 : 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1C1C1E),
          ),
        ),
      ),
    );
  }

  Widget _buildPronunciationMiniTile(
    BuildContext context, {
    required bool compact,
    required String form,
    required String latin,
    required String label,
  }) {
    final text = Theme.of(context).textTheme;
    final isPlaying = _playingForm == form;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _playPronunciation(form),
        child: Container(
          padding: EdgeInsets.all(compact ? 8 : 10),
          decoration: BoxDecoration(
            color: isPlaying ? const Color(0xFFE8F5F0) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isPlaying ? AppTheme.deepAccent : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isPlaying
                    ? const Color(0x202F7D6A)
                    : const Color(0x10000000),
                blurRadius: isPlaying ? 14 : 10,
                offset: Offset(0, isPlaying ? 6 : 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ArabicText.label(
                form,
                style: text.titleLarge?.copyWith(
                  fontSize: compact ? 19 : 22,
                  fontWeight: FontWeight.w700,
                  color: isPlaying ? AppTheme.deepAccent : null,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 3),
              Text(
                latin,
                style: text.bodySmall?.copyWith(
                  color: AppTheme.deepAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: compact ? 11 : 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                AlphabetContentLocalizer.pronunciationLabel(
                  label,
                  context.appSettings.appLanguage,
                ),
                style: text.bodySmall?.copyWith(
                  fontSize: compact ? 10 : 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Icon(
                isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
                color: AppTheme.deepAccent,
                size: compact ? 16 : 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
