import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/alphabet_content_localizer.dart';
import '../l10n/localized_text.dart';
import '../models/alphabet_group.dart';
import '../services/alphabet_progress_service.dart';
import '../services/review_service.dart';
import '../theme/app_arabic_typography.dart';
import '../theme/app_theme.dart';

class AlphabetWritePage extends StatefulWidget {
  final AlphabetLetter letter;

  const AlphabetWritePage({
    super.key,
    required this.letter,
  });

  @override
  State<AlphabetWritePage> createState() => _AlphabetWritePageState();
}

class _AlphabetWritePageState extends State<AlphabetWritePage> {
  bool _showObservation = false;
  int _practiceStep = -1;

  Future<void> _completeWriting() async {
    await AlphabetProgressService.markWriteCompleted(widget.letter);
    await ReviewService.markAlphabetWriteCompleted(widget.letter);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  List<_PracticeStep> get _practiceSteps => <_PracticeStep>[
        _PracticeStep(
          title: '先写独立形',
          detail: '先把 ${widget.letter.forms.isolated} 单独写 3 次，记住主体轮廓。',
        ),
        _PracticeStep(
          title: '再看连接形',
          detail:
              '依次写 ${widget.letter.forms.initial}、${widget.letter.forms.medial}、${widget.letter.forms.finalForm}，观察连笔变化。',
        ),
        _PracticeStep(
          title: '最后写示例词',
          detail:
              '临摹 ${widget.letter.example.arabic}，同时读出 ${widget.letter.example.latin}。',
        ),
        _PracticeStep(
          title: '完成自检',
          detail: widget.letter.connectsAfter
              ? '确认这个字母通常可以继续向后连写。'
              : '确认这个字母通常不向后连写，后一个字母要重新起笔。',
        ),
      ];

  void _toggleObservation() {
    setState(() {
      _showObservation = !_showObservation;
    });
  }

  void _advancePractice() {
    setState(() {
      if (_practiceStep + 1 < _practiceSteps.length) {
        _practiceStep++;
      } else {
        _practiceStep = -1;
      }
      _showObservation = true;
    });
  }

  String _practiceDetail(BuildContext context, _PracticeStep step) {
    switch (step.title) {
      case '先写独立形':
        return localizedText(
          context,
          zh: step.detail,
          en: 'Write ${widget.letter.forms.isolated} on its own three times and memorize the main outline.',
        );
      case '再看连接形':
        return localizedText(
          context,
          zh: step.detail,
          en: 'Write ${widget.letter.forms.initial}, ${widget.letter.forms.medial}, and ${widget.letter.forms.finalForm} in order and compare how the connection changes.',
        );
      case '最后写示例词':
        return localizedText(
          context,
          zh: step.detail,
          en: 'Trace ${widget.letter.example.arabic} and say ${widget.letter.example.latin} aloud at the same time.',
        );
      case '完成自检':
        return localizedText(
          context,
          zh: step.detail,
          en: widget.letter.connectsAfter
              ? 'Confirm that this letter usually keeps connecting to the next one.'
              : 'Confirm that this letter usually breaks before the next one, so the following letter starts fresh.',
        );
      default:
        return step.detail;
    }
  }

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
          padding: EdgeInsets.fromLTRB(pagePadding, 12, pagePadding, 20),
          children: [
            Row(
              children: [
                _buildTopButton(
                  size: topButtonSize,
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizedText(
                          context,
                          zh: '书写巩固',
                          en: 'Writing Practice',
                        ),
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
                  colors: [Color(0xFFEAF8F3), Color(0xFFDFF2EB)],
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
                  const SizedBox(height: 6),
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
                  const SizedBox(height: 4),
                  Text(
                    AlphabetContentLocalizer.hint(
                      widget.letter,
                      context.appSettings.meaningLanguage,
                    ),
                    style: text.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: sectionGap),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizedText(
                            context,
                            zh: '这一步放到后面巩固即可',
                            en: 'This Step Can Wait',
                          ),
                          style: text.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          localizedText(
                            context,
                            zh: '首轮先看独立形和断连提醒就够了。完整四形、临摹和自检都保留在后面。',
                            en: 'For the first pass, just look at the isolated form and the connection rule. The full set of forms, tracing, and self-check stay below.',
                          ),
                          style: text.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: sectionGap),
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FCFA),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD8ECE4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizedText(
                      context,
                      zh: '首轮先看独立形',
                      en: 'Start with the Isolated Form',
                    ),
                    style: text.titleSmall,
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: ArabicText.word(
                      widget.letter.forms.isolated,
                      style: text.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.deepAccent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.letter.connectsAfter
                        ? localizedText(
                            context,
                            zh: '这个字母通常可以继续向后连接。首轮先知道“它通常不断开”就够了。',
                            en: 'This letter usually connects forward. For the first pass, it is enough to know that it usually keeps flowing.',
                          )
                        : localizedText(
                            context,
                            zh: '这个字母通常不向后连接。首轮先知道“它后面会重新起笔”就够了。',
                            en: 'This letter usually does not connect forward. For the first pass, it is enough to know that the next letter starts fresh.',
                          ),
                    style: text.bodyMedium,
                  ),
                ],
              ),
            ),
            SizedBox(height: sectionGap),
            SizedBox(
              width: double.infinity,
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
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.schedule_rounded),
                label: Text(
                  localizedText(
                    context,
                    zh: '稍后再练，先回去继续认字母',
                    en: 'Practice This Later',
                  ),
                ),
              ),
            ),
            SizedBox(height: sectionGap),
            Text(
              localizedText(
                context,
                zh: '书写形态',
                en: 'Writing Forms',
              ),
              style: text.labelLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: sectionGap),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 14 : 16,
                    vertical: 4,
                  ),
                  childrenPadding: EdgeInsets.fromLTRB(
                    isSmallScreen ? 14 : 16,
                    0,
                    isSmallScreen ? 14 : 16,
                    16,
                  ),
                  title: Text(
                    localizedText(
                      context,
                      zh: '完整书写巩固（可稍后）',
                      en: 'Full Writing Practice Later',
                    ),
                    style: text.titleMedium,
                  ),
                  subtitle: Text(
                    localizedText(
                      context,
                      zh: '四种字形、连写规则、临摹步骤和自检都保留在这里。',
                      en: 'The full forms, connection rule, tracing steps, and self-check stay here.',
                    ),
                    style: text.bodySmall,
                  ),
                  children: [
                    Text(
                      localizedText(
                        context,
                        zh: '书写形态',
                        en: 'Writing Forms',
                      ),
                      style: text.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      localizedText(
                        context,
                        zh: '阿拉伯字母在不同位置会变化。先认形，再动笔，书写会稳得多。',
                        en: 'Arabic letters change by position. Learn the shapes first, then start writing.',
                      ),
                      style: text.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    _buildFormsGrid(
                      context,
                      isSmallScreen: isSmallScreen,
                      isLargeScreen: isLargeScreen,
                    ),
                    if (_showObservation) ...[
                      SizedBox(height: sectionGap),
                      _ObservationCard(
                        letter: widget.letter,
                        currentStep: _practiceStep,
                      ),
                    ],
                    SizedBox(height: sectionGap),
                    Text(
                      localizedText(
                        context,
                        zh: '连写规则',
                        en: 'Connection Rule',
                      ),
                      style: text.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7FAF9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.letter.connectsAfter
                            ? localizedText(
                                context,
                                zh: '这个字母通常可以继续向后连接。写在词中时，重点观察它和后一个字母之间的过渡。',
                                en: 'This letter usually connects forward. When it appears inside a word, focus on the transition into the next letter.',
                              )
                            : localizedText(
                                context,
                                zh: '这个字母通常不向后连接。它后面的字母需要重新起笔，这是阅读和书写都要特别注意的断点。',
                                en: 'This letter usually does not connect forward. The next letter starts fresh, which matters in both reading and writing.',
                              ),
                        style: text.bodyMedium,
                      ),
                    ),
                    SizedBox(height: sectionGap),
                    Text(
                      localizedText(
                        context,
                        zh: '分步临摹',
                        en: 'Step-by-Step Tracing',
                      ),
                      style: text.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7FAF9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          for (var index = 0;
                              index < _practiceSteps.length;
                              index++)
                            _PracticeStepTile(
                              step: _practiceSteps[index],
                              active: _practiceStep == index,
                              completed: _practiceStep > index,
                            ),
                        ],
                      ),
                    ),
                    if (_practiceStep >= 0) ...[
                      SizedBox(height: sectionGap),
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7FCFA),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFD8ECE4),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.edit_note_rounded,
                              color: AppTheme.deepAccent,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _practiceDetail(
                                  context,
                                  _practiceSteps[_practiceStep],
                                ),
                                style: text.bodyMedium,
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
                        zh: '学习提示',
                        en: 'Learning Note',
                      ),
                      style: text.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7FAF9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        AlphabetContentLocalizer.tip(
                          widget.letter,
                          context.appSettings.meaningLanguage,
                        ),
                        style: text.bodyMedium,
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
                            onPressed: _toggleObservation,
                            child: Text(
                              _showObservation
                                  ? localizedText(
                                      context,
                                      zh: '收起观察',
                                      en: 'Hide Notes',
                                    )
                                  : localizedText(
                                      context,
                                      zh: '观察结构',
                                      en: 'Observe Shape',
                                    ),
                            ),
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
                            onPressed: _advancePractice,
                            child: Text(
                              _practiceStep + 1 < _practiceSteps.length
                                  ? (_practiceStep < 0
                                      ? localizedText(
                                          context,
                                          zh: '开始临摹',
                                          en: 'Start Tracing',
                                        )
                                      : localizedText(
                                          context,
                                          zh: '下一步',
                                          en: 'Next',
                                        ))
                                  : localizedText(
                                      context,
                                      zh: '重新开始',
                                      en: 'Restart',
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sectionGap),
                    SizedBox(
                      width: double.infinity,
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
                        onPressed: _completeWriting,
                        icon: const Icon(Icons.check_circle_rounded),
                        label: Text(
                          localizedText(
                            context,
                            zh: '完成书写巩固',
                            en: 'Finish Writing Practice',
                          ),
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
    final forms = <Map<String, String>>[
      <String, String>{'title': '独立形', 'value': widget.letter.forms.isolated},
      <String, String>{'title': '词首形', 'value': widget.letter.forms.initial},
      <String, String>{'title': '词中形', 'value': widget.letter.forms.medial},
      <String, String>{
        'title': '词尾形',
        'value': widget.letter.forms.finalForm,
      },
    ];

    final crossAxisCount = isLargeScreen ? 4 : 2;
    final ratio = isSmallScreen ? 1.2 : 1.35;

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
            switch (title) {
              '独立形' => localizedText(context, zh: '独立形', en: 'Isolated'),
              '词首形' => localizedText(context, zh: '词首形', en: 'Initial'),
              '词中形' => localizedText(context, zh: '词中形', en: 'Medial'),
              '词尾形' => localizedText(context, zh: '词尾形', en: 'Final'),
              _ => title,
            },
            style: text.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ArabicText.word(
            value,
            style: text.titleLarge?.copyWith(
              fontSize: compact ? 24 : 28,
              fontWeight: FontWeight.w700,
              color: AppTheme.deepAccent,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ObservationCard extends StatelessWidget {
  final AlphabetLetter letter;
  final int currentStep;

  const _ObservationCard({
    required this.letter,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final localizedRows = <String>[
      localizedText(
        context,
        zh: '先认独立形：${letter.forms.isolated}',
        en: 'Start with the isolated form: ${letter.forms.isolated}',
      ),
      localizedText(
        context,
        zh: '再看连接形：${letter.forms.initial} / ${letter.forms.medial} / ${letter.forms.finalForm}',
        en: 'Then compare the connecting forms: ${letter.forms.initial} / ${letter.forms.medial} / ${letter.forms.finalForm}',
      ),
      localizedText(
        context,
        zh: '最后观察示例词：${letter.example.arabic}',
        en: 'Finally, observe the example word: ${letter.example.arabic}',
      ),
    ];

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizedText(
              context,
              zh: '观察重点',
              en: 'What to Observe',
            ),
            style: text.titleMedium,
          ),
          const SizedBox(height: 10),
          for (var index = 0; index < localizedRows.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: currentStep == index
                          ? const Color(0xFFE8F5F0)
                          : AppTheme.bgCardSoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: text.labelMedium?.copyWith(
                        color: AppTheme.deepAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      localizedRows[index],
                      style: text.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PracticeStepTile extends StatelessWidget {
  final _PracticeStep step;
  final bool active;
  final bool completed;

  const _PracticeStepTile({
    required this.step,
    required this.active,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final localizedTitle = switch (step.title) {
      '先写独立形' =>
        localizedText(context, zh: '先写独立形', en: 'Write the Isolated Form'),
      '再看连接形' =>
        localizedText(context, zh: '再看连接形', en: 'Study the Connecting Forms'),
      '最后写示例词' =>
        localizedText(context, zh: '最后写示例词', en: 'Write the Example Word'),
      '完成自检' =>
        localizedText(context, zh: '完成自检', en: 'Finish with a Self-check'),
      _ => step.title,
    };

    final Color bg = active ? const Color(0xFFF3FBF8) : Colors.transparent;
    final Color border = active ? const Color(0xFFD8ECE4) : Colors.transparent;
    final IconData icon = completed
        ? Icons.check_circle_rounded
        : active
            ? Icons.radio_button_checked_rounded
            : Icons.radio_button_unchecked_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: completed || active
                ? AppTheme.deepAccent
                : AppTheme.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              localizedTitle,
              style: text.bodyMedium?.copyWith(
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PracticeStep {
  final String title;
  final String detail;

  const _PracticeStep({
    required this.title,
    required this.detail,
  });
}
