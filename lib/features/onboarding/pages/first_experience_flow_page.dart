import 'package:flutter/material.dart';

import '../../../app_scope.dart';
import '../../../services/audio_service.dart';
import '../../../theme/app_latin_typography.dart';
import '../../../theme/app_theme.dart';
import '../models/first_experience_content.dart';
import '../widgets/arabic_letter_card.dart';
import '../widgets/example_sound_card.dart';
import '../widgets/first_experience_progress.dart';
import '../widgets/primary_action_button.dart';
import '../widgets/quiz_option_button.dart';

class FirstExperienceFlowPage extends StatefulWidget {
  final FirstExperienceContent content;
  final int initialStep;
  final ValueChanged<int> onStepChanged;
  final VoidCallback onCompleted;
  final VoidCallback? onGoHome;

  const FirstExperienceFlowPage({
    super.key,
    required this.content,
    required this.initialStep,
    required this.onStepChanged,
    required this.onCompleted,
    this.onGoHome,
  });

  @override
  State<FirstExperienceFlowPage> createState() =>
      _FirstExperienceFlowPageState();
}

class _FirstExperienceFlowPageState extends State<FirstExperienceFlowPage> {
  static const int _totalSteps = 3;

  late int _currentStep;
  String? _selectedOption;

  bool get _showResult => _selectedOption != null;
  bool get _isCorrect => _selectedOption == widget.content.correctOption;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep.clamp(1, _totalSteps);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onStepChanged(_currentStep);
    });
  }

  void _goToStep(int step) {
    setState(() {
      _currentStep = step;
      if (step != 3) {
        _selectedOption = null;
      }
    });
    widget.onStepChanged(step);
  }

  Future<void> _playLetter() async {
    await AudioService.speakLetter(widget.content.letterArabic);
  }

  Future<void> _playExample() async {
    await AudioService.speakPronunciation(
      widget.content.exampleArabicWithDiacritics,
    );
  }

  Widget _buildHeader(BuildContext context) {
    final strings = context.strings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_currentStep > 1 || widget.onGoHome != null)
          Row(
            children: [
              if (_currentStep > 1)
                IconButton(
                  onPressed: () => _goToStep(_currentStep - 1),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                )
              else
                const SizedBox(width: 48),
              const Spacer(),
              if (widget.onGoHome != null)
                TextButton(
                  onPressed: widget.onGoHome,
                  child: Text(strings.t('onboarding.welcome_secondary')),
                ),
            ],
          ),
        FirstExperienceProgress(
          currentStep: _currentStep,
          totalSteps: _totalSteps,
          label: strings.t(
            'onboarding.step_progress',
            params: <String, String>{
              'current': '$_currentStep',
              'total': '$_totalSteps',
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStepOne(BuildContext context) {
    final strings = context.strings;
    final content = widget.content;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.t('onboarding.step1_label'),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 10),
        Text(
          content.titleFor(context.appSettings.appLanguage),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          content.subtitleFor(context.appSettings.appLanguage),
          style: AppLatinTypography.body(context),
        ),
        const SizedBox(height: 24),
        ArabicLetterCard(
          arabic: content.letterArabic,
          name: content.letterName,
          transliteration: content.transliteration,
          badge: strings.t('onboarding.first_letter_badge'),
          description: strings.t('onboarding.step1_card_note'),
          playLabel: strings.t('common.play_audio'),
          onPlayAudio: _playLetter,
        ),
        const Spacer(),
        PrimaryActionButton(
          text: strings.t('onboarding.got_it'),
          onTap: () => _goToStep(2),
        ),
      ],
    );
  }

  Widget _buildStepTwo(BuildContext context) {
    final strings = context.strings;
    final content = widget.content;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.t('onboarding.step2_label'),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 10),
        Text(
          strings.t('onboarding.step2_title'),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          strings.t('onboarding.step2_subtitle'),
          style: AppLatinTypography.body(context),
        ),
        const SizedBox(height: 24),
        ExampleSoundCard(
          arabic: content.exampleArabic,
          arabicWithDiacritics: content.exampleArabicWithDiacritics,
          transliteration: content.exampleTransliteration,
          note: strings.t('onboarding.example_note'),
          onPlayAudio: _playExample,
        ),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _playExample,
                child: Text(strings.t('onboarding.play_again')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryActionButton(
                text: strings.t('onboarding.continue'),
                onTap: () => _goToStep(3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepThree(BuildContext context) {
    final strings = context.strings;
    final content = widget.content;
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.t('onboarding.step3_label'),
          style: text.labelLarge,
        ),
        const SizedBox(height: 10),
        Text(
          strings.t('onboarding.step3_title'),
          style: text.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          strings.t('onboarding.quiz_title'),
          style: AppLatinTypography.body(context),
        ),
        const SizedBox(height: 24),
        Row(
          children: content.quizOptions.map((option) {
            final index = content.quizOptions.indexOf(option);
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 0 : 8,
                  right: index == content.quizOptions.length - 1 ? 0 : 8,
                ),
                child: QuizOptionButton(
                  text: option,
                  isSelected: _selectedOption == option,
                  isCorrect: option == content.correctOption,
                  showResult: _showResult,
                  onTap: () {
                    setState(() => _selectedOption = option);
                  },
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: !_showResult
              ? const SizedBox(height: 88)
              : Container(
                  key: ValueKey<String>(_selectedOption!),
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isCorrect
                        ? const Color(0xFFEAF6EF)
                        : const Color(0xFFFFF3EC),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isCorrect
                            ? strings.t('onboarding.quiz_correct')
                            : strings.t('onboarding.quiz_incorrect'),
                        style: text.titleSmall?.copyWith(
                          color: _isCorrect
                              ? AppTheme.accentMintDark
                              : const Color(0xFFB56D45),
                        ),
                      ),
                      if (!_isCorrect) ...[
                        const SizedBox(height: 8),
                        Text(
                          strings.t(
                            'onboarding.quiz_answer',
                            params: <String, String>{
                              'answer': content.correctOption,
                            },
                          ),
                          style: AppLatinTypography.body(context),
                        ),
                      ],
                    ],
                  ),
                ),
        ),
        const Spacer(),
        PrimaryActionButton(
          text: strings.t('onboarding.finish_step'),
          onTap: _showResult ? widget.onCompleted : null,
          isEnabled: _showResult,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppTheme.pagePadding,
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: KeyedSubtree(
                    key: ValueKey<int>(_currentStep),
                    child: _currentStep == 1
                        ? _buildStepOne(context)
                        : _currentStep == 2
                            ? _buildStepTwo(context)
                            : _buildStepThree(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
