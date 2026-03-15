import 'package:flutter/material.dart';

import '../l10n/localized_text.dart';
import '../services/audio_service.dart';
import '../theme/app_arabic_typography.dart';
import '../theme/app_theme.dart';
import '../widgets/arabic_text_with_audio.dart';

class QuizScaffold extends StatelessWidget {
  final String levelTitle;
  final String subtitle;
  final int currentIndex;
  final int total;
  final String questionTitle;
  final String prompt;
  final String promptType;
  final List<String> options;
  final String correct;
  final String? selectedAnswer;
  final bool answered;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;
  final VoidCallback? onPlayPromptAudio;

  const QuizScaffold({
    super.key,
    required this.levelTitle,
    required this.subtitle,
    required this.currentIndex,
    required this.total,
    required this.questionTitle,
    required this.prompt,
    required this.promptType,
    required this.options,
    required this.correct,
    required this.selectedAnswer,
    required this.answered,
    required this.onSelect,
    required this.onNext,
    this.onPlayPromptAudio,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final isSmallScreen = width < 360;
    final progress = total <= 0 ? 0 : (currentIndex + 1) / total;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            isSmallScreen ? 14 : 16,
            12,
            isSmallScreen ? 14 : 16,
            media.padding.bottom + 24,
          ),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopButton(
                  size: isSmallScreen ? 38 : 40,
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          levelTitle,
                          style: text.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: text.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
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
                  Text(
                    total > 0
                        ? localizedText(
                            context,
                            zh: '第 ${currentIndex + 1} 题 / 共 $total 题',
                            en: 'Question ${currentIndex + 1} of $total',
                          )
                        : localizedText(
                            context,
                            zh: '暂无题目',
                            en: 'No Questions',
                          ),
                    style: text.labelLarge?.copyWith(
                      color: AppTheme.deepAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0).toDouble(),
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.deepAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 18 : 22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    questionTitle,
                    style: text.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  _buildPrompt(context, text, isSmallScreen),
                ],
              ),
            ),
            const SizedBox(height: 18),
            ...options.map(
              (option) => _buildOptionCard(
                context,
                option: option,
                correct: correct,
                onTap: answered ? () {} : () => onSelect(option),
              ),
            ),
            const SizedBox(height: 8),
            if (!answered)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.touch_app_rounded,
                      size: 18,
                      color: AppTheme.deepAccent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        localizedText(
                          context,
                          zh: '请先选择一个答案，再查看结果。',
                          en: 'Choose one answer first, then check the result.',
                        ),
                        style: text.bodySmall?.copyWith(
                          color: const Color(0xFF667085),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            if (answered)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.deepAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: onNext,
                  child: Text(
                    currentIndex == total - 1
                        ? localizedText(
                            context,
                            zh: '查看结果',
                            en: 'View Result',
                          )
                        : localizedText(
                            context,
                            zh: '下一题',
                            en: 'Next Question',
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrompt(
    BuildContext context,
    TextTheme text,
    bool isSmallScreen,
  ) {
    if (promptType == 'letter_audio' || promptType == 'pronunciation_audio') {
      final helper = promptType == 'letter_audio'
          ? localizedText(
              context,
              zh: '点击播放字母发音，再选择答案。',
              en: 'Play the letter sound, then choose the answer.',
            )
          : localizedText(
              context,
              zh: '点击播放读音形式，再选择答案。',
              en: 'Play the sound form, then choose the answer.',
            );

      return Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: onPlayPromptAudio,
            child: Ink(
              width: isSmallScreen ? 76 : 84,
              height: isSmallScreen ? 76 : 84,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF8F3),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.volume_up_rounded,
                color: AppTheme.deepAccent,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            helper,
            style: text.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (promptType == 'arabic') {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: isSmallScreen ? 260 : 320,
          child: ArabicTextWithAudio(
            textAr: prompt,
            request: LearningAudioRequest.general(
              scope: 'quiz',
              type: 'word',
              textAr: prompt,
              textPlain: prompt,
              debugLabel: 'quiz_prompt_arabic',
            ),
            variant: ArabicAudioTextVariant.word,
            style: text.headlineLarge?.copyWith(
              fontSize: isSmallScreen ? 52 : 60,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Text(
      prompt,
      style: text.headlineSmall?.copyWith(
        fontSize: isSmallScreen ? 28 : 32,
        fontWeight: FontWeight.w700,
        color: AppTheme.deepAccent,
      ),
      textAlign: TextAlign.center,
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
          child: Icon(icon, color: AppTheme.primaryText, size: 18),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String option,
    required String correct,
    required VoidCallback onTap,
  }) {
    final text = Theme.of(context).textTheme;

    final isSelected = selectedAnswer == option;
    final isCorrect = option == correct;

    var bgColor = Colors.white;
    var borderColor = const Color(0xFFE5E7EB);
    var textColor = AppTheme.primaryText;
    IconData? trailingIcon;

    if (answered) {
      if (isCorrect) {
        bgColor = const Color(0xFFEAF8F3);
        borderColor = AppTheme.deepAccent;
        textColor = AppTheme.deepAccent;
        trailingIcon = Icons.check_circle_rounded;
      } else if (isSelected) {
        bgColor = const Color(0xFFFFF1F2);
        borderColor = const Color(0xFFE11D48);
        textColor = const Color(0xFFBE123C);
        trailingIcon = Icons.cancel_rounded;
      }
    } else if (isSelected) {
      bgColor = const Color(0xFFF5FAF8);
      borderColor = AppTheme.deepAccent;
      textColor = AppTheme.deepAccent;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1.2),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: AppArabicTypography.isArabic(option)
                      ? ArabicTextWithAudio(
                          textAr: option,
                          request: LearningAudioRequest.general(
                            scope: 'quiz',
                            type: 'word',
                            textAr: option,
                            textPlain: option,
                            debugLabel: 'quiz_option_arabic',
                          ),
                          variant: ArabicAudioTextVariant.word,
                          style: text.titleMedium?.copyWith(color: textColor),
                          spacing: 8,
                        )
                      : Text(
                          option,
                          style: text.titleMedium?.copyWith(color: textColor),
                        ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: 12),
                  Icon(
                    trailingIcon,
                    color: isCorrect
                        ? AppTheme.deepAccent
                        : const Color(0xFFE11D48),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
