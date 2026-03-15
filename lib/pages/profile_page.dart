import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_scope.dart';
import '../l10n/app_strings.dart';
import '../l10n/lesson_localizer.dart';
import '../models/app_settings.dart';
import '../models/lesson.dart';
import '../services/lesson_service.dart';
import '../services/progress_service.dart';
import '../services/unlock_service.dart';
import '../theme/app_theme.dart';
import '../view_models/learning_path_view_models.dart' as vm;
import '../widgets/app_widgets.dart';
import 'course_list_page.dart';
import 'feedback_board_page.dart';
import 'lesson_detail_page.dart';
import 'review_page.dart';
import 'static_info_page.dart';
import 'unlock_page.dart';

const Duration _profileLoadTimeout = Duration(seconds: 2);

class ProfilePage extends StatefulWidget {
  final AppSettings settings;
  final ValueChanged<AppSettings> onSettingsChanged;

  const ProfilePage({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _LearningOverviewData {
  final IconData icon;
  final String title;
  final String suggestion;
  final List<String> stats;
  final String actionText;
  final vm.ProfileLearningActionType actionType;
  final Lesson? lesson;

  const _LearningOverviewData({
    required this.icon,
    required this.title,
    required this.suggestion,
    required this.stats,
    required this.actionText,
    required this.actionType,
    this.lesson,
  });
}

class _CurrentPlanData {
  final String? badge;
  final String title;
  final String description;
  final String footnote;
  final String? actionText;
  final bool unlocked;

  const _CurrentPlanData({
    this.badge,
    required this.title,
    required this.description,
    required this.footnote,
    required this.unlocked,
    this.actionText,
  });
}

class _ProfilePageState extends State<ProfilePage> {
  static const String _developerMailbox = '13823724506@163.com';
  static final bool _isFlutterTest =
      const bool.fromEnvironment('FLUTTER_TEST', defaultValue: false) ||
          Platform.environment.containsKey('FLUTTER_TEST');

  bool _loading = true;
  bool _unlocked = false;
  List<Lesson> _lessons = const <Lesson>[];
  ProgressSnapshot _progress = const ProgressSnapshot(
    completedLessons: <String>{},
    startedLessons: <String>{},
    reviewCount: 0,
    streakDays: 0,
  );
  String _appVersion = '--';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final snapshot = await ProgressService.getSnapshot().timeout(
        _profileLoadTimeout,
        onTimeout: () => const ProgressSnapshot(
          completedLessons: <String>{},
          startedLessons: <String>{},
          reviewCount: 0,
          streakDays: 0,
        ),
      );
      final unlocked = await UnlockService.isUnlocked().timeout(
        _profileLoadTimeout,
        onTimeout: () => false,
      );
      final lessons = await LessonService().loadLessons().timeout(
            _profileLoadTimeout,
            onTimeout: () => <Lesson>[],
          );
      String appVersion = '--';

      if (!_isFlutterTest) {
        try {
          final info = await PackageInfo.fromPlatform();
          appVersion = '${info.version}+${info.buildNumber}';
        } catch (_) {
          appVersion = '--';
        }
      }

      if (!mounted) return;
      setState(() {
        _progress = snapshot;
        _unlocked = unlocked;
        _lessons = lessons;
        _appVersion = appVersion;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _progress = const ProgressSnapshot(
          completedLessons: <String>{},
          startedLessons: <String>{},
          reviewCount: 0,
          streakDays: 0,
        );
        _unlocked = false;
        _lessons = const <Lesson>[];
        _appVersion = '--';
        _loading = false;
      });
    }
  }

  Future<void> _openUnlockPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UnlockPage()),
    );
    if (result == true) {
      await _load();
    }
  }

  Future<void> _restorePurchase() async {
    if (_unlocked) {
      _showSnackBar(context.strings.t('profile.restore_purchase_current'));
      return;
    }
    await _openUnlockPage();
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _parseTimeOfDay(widget.settings.reminderTime),
      helpText: context.strings.t('settings.choice_reminder_time'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.accentMintDark,
                ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked == null) return;
    widget.onSettingsChanged(
      widget.settings.copyWith(reminderTime: _formatTimeOfDay(picked)),
    );
  }

  TimeOfDay _parseTimeOfDay(String raw) {
    final parts = raw.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 20 : 20;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return TimeOfDay(
      hour: hour.clamp(0, 23),
      minute: minute.clamp(0, 59),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _openFeedbackBoard(String category) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FeedbackBoardPage(
          initialCategory: category,
          onSubmit: _sendFeedback,
        ),
      ),
    );
  }

  Future<void> _sendFeedback(String category, String message) async {
    final strings = context.strings;
    final categoryLabel = strings.t(category);
    final feedbackBody = _buildFeedbackBody(category, message);
    await _launchMail(
      subject: '[Ababa Arabic] $categoryLabel',
      body: feedbackBody,
      successMessage: strings.t('feedback.mail_opened'),
      fallbackMessage: strings.t('feedback.mail_copied'),
    );
  }

  Future<void> _contactSupport() async {
    final strings = context.strings;
    final body = '''
${strings.t('profile.contact_support_body')}

----
${_buildAppContextSummary()}
''';
    await _launchMail(
      subject: '[Ababa Arabic] ${strings.t('profile.contact_support')}',
      body: body,
      successMessage: strings.t('profile.contact_support_opened'),
      fallbackMessage: strings.t('profile.contact_support_copied'),
    );
  }

  Future<void> _launchMail({
    required String subject,
    required String body,
    required String successMessage,
    required String fallbackMessage,
  }) async {
    final uri = Uri(
      scheme: 'mailto',
      path: _developerMailbox,
      queryParameters: <String, String>{
        'subject': subject,
        'body': body,
      },
    );

    bool launched = false;
    try {
      launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      launched = false;
    }

    if (!mounted) return;

    if (launched) {
      _showSnackBar(successMessage);
      return;
    }

    await Clipboard.setData(ClipboardData(text: body));
    if (!mounted) return;
    _showSnackBar(fallbackMessage);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _buildFeedbackBody(String category, String message) {
    final strings = context.strings;

    return '''
${strings.t('feedback.category')}: ${strings.t(category)}

${strings.t('feedback.message')}:
$message

----
${_buildAppContextSummary()}
''';
  }

  String _buildAppContextSummary() {
    final strings = context.strings;
    final snapshot = vm.LearningPathViewModels.buildSnapshot(
      lessons: _lessons,
      progress: _progress,
      unlocked: _unlocked,
    );
    final plan = vm.LearningPathViewModels.buildCurrentPlan(
      strings: strings,
      snapshot: snapshot,
    );

    return '''
${strings.t('profile.interface_language')}: ${_interfaceLanguageLabel(widget.settings.appLanguage)}
${strings.t('profile.meaning_language')}: ${_meaningLanguageLabel(widget.settings.meaningLanguage)}
${strings.t('profile.text_mode')}: ${_textModeLabel(widget.settings.textMode)}
${strings.t('profile.show_transliteration')}: ${widget.settings.showTransliteration ? strings.t('common.on') : strings.t('common.off')}
${strings.t('profile.arabic_font_size')}: ${_fontScaleLabel(widget.settings.arabicFontScale)}
${strings.t('profile.theme_mode')}: ${_themeLabel(widget.settings.themePreference)}
${strings.t('profile.reminder')}: ${widget.settings.reminderEnabled ? strings.t('profile.reminder_on_short', params: <String, String>{
                'time': widget.settings.reminderTime
              }) : strings.t('profile.reminder_off_short')}
${strings.t('profile.plan_card_title')}: ${plan.title}
${strings.t('profile.about_version')}: $_appVersion
''';
  }

  _LearningOverviewData _materializeLearningOverviewData({
    required vm.LearningPathSnapshot snapshot,
    required vm.LearningOverviewViewModel viewModel,
  }) {
    return _LearningOverviewData(
      icon: snapshot.streakDays > 0
          ? Icons.local_fire_department_rounded
          : Icons.auto_stories_rounded,
      title: viewModel.title,
      suggestion: viewModel.suggestion,
      stats: viewModel.stats,
      actionText: viewModel.actionText,
      actionType: viewModel.actionType,
      lesson: viewModel.lesson,
    );
  }

  _CurrentPlanData _materializeCurrentPlanData(
    vm.CurrentPlanViewModel viewModel,
  ) {
    return _CurrentPlanData(
      badge: viewModel.badge.isEmpty ? null : viewModel.badge,
      title: viewModel.title,
      description: viewModel.description,
      footnote: viewModel.footnote,
      unlocked: viewModel.unlocked,
      actionText: viewModel.actionText,
    );
  }

  Future<void> _openLearningOverviewAction(_LearningOverviewData data) async {
    switch (data.actionType) {
      case vm.ProfileLearningActionType.startReview:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReviewPage()),
        );
        break;
      case vm.ProfileLearningActionType.reviewLessons:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CourseListPage(settings: widget.settings),
          ),
        );
        break;
      case vm.ProfileLearningActionType.startLearning:
      case vm.ProfileLearningActionType.continueLearning:
        final lesson = data.lesson;
        if (lesson != null) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LessonDetailPage(
                lesson: lesson,
                settings: widget.settings,
                isUnlocked: _unlocked,
              ),
            ),
          );
        } else {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CourseListPage(settings: widget.settings),
            ),
          );
        }
        break;
    }

    if (mounted) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final strings = context.strings;
    final snapshot = vm.LearningPathViewModels.buildSnapshot(
      lessons: _lessons,
      progress: _progress,
      unlocked: _unlocked,
    );
    final overview = _materializeLearningOverviewData(
      snapshot: snapshot,
      viewModel: vm.LearningPathViewModels.buildProfileOverview(
        language: widget.settings.appLanguage,
        strings: strings,
        snapshot: snapshot,
      ),
    );
    final plan = _materializeCurrentPlanData(
      vm.LearningPathViewModels.buildCurrentPlan(
        strings: strings,
        snapshot: snapshot,
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: AppTheme.pagePadding,
          children: [
            SectionTitle(
              title: strings.t('profile.title'),
              subtitle: strings.t('profile.page_intro'),
            ),
            const SizedBox(height: 16),
            _SettingsSection(
              title: strings.t('profile.section_course_access'),
              children: <Widget>[
                _CurrentPlanCard(
                  data: plan,
                  onActionTap: plan.unlocked ? null : _openUnlockPage,
                ),
                if (!_unlocked)
                  _SettingsValueItem(
                    title: strings.t('profile.content_pack_title'),
                    value: strings.t('profile.content_pack_trial_value'),
                    subtitle: strings.t('profile.content_pack_trial_subtitle'),
                  ),
                _SettingsValueItem(
                  title: strings.t('profile.unlock_full_title'),
                  value: strings.t('profile.unlock_full_value'),
                  subtitle: strings.t('profile.unlock_full_subtitle'),
                  onTap: _openUnlockPage,
                ),
                _SettingsNavItem(
                  title: strings.t('profile.restore_purchase'),
                  subtitle: strings.t('profile.restore_purchase_subtitle'),
                  onTap: _restorePurchase,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SettingsSection(
              title: strings.t('profile.section_learning_state'),
              children: [
                _LearningOverviewCard(
                  data: overview,
                  onActionTap: () => _openLearningOverviewAction(overview),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SettingsSection(
              title: strings.t('profile.section_learning_preferences'),
              children: [
                _SettingsValueItem(
                  title: strings.t('profile.interface_language'),
                  subtitle: strings.t('profile.interface_language_subtitle'),
                  value: _interfaceLanguageLabel(widget.settings.appLanguage),
                  onTap: () => _showInterfaceLanguageSheet(context),
                ),
                _SettingsValueItem(
                  title: strings.t('profile.meaning_language'),
                  subtitle: strings.t('profile.meaning_language_subtitle'),
                  value: _meaningLanguageLabel(widget.settings.meaningLanguage),
                  onTap: () => _showMeaningLanguageSheet(context),
                ),
                _SettingsValueItem(
                  title: strings.t('profile.text_mode'),
                  value: _textModeLabel(widget.settings.textMode),
                  subtitle: strings.t('profile.text_mode_subtitle'),
                  onTap: () => _showTextModeSheet(context),
                ),
                _SettingsSwitchItem(
                  title: strings.t('profile.show_transliteration'),
                  subtitle: strings.t('profile.show_transliteration_subtitle'),
                  value: widget.settings.showTransliteration,
                  onChanged: (value) => widget.onSettingsChanged(
                    widget.settings.copyWith(showTransliteration: value),
                  ),
                ),
                _SettingsValueItem(
                  title: strings.t('profile.voice_preference'),
                  value: _voicePreferenceLabel(widget.settings.voicePreference),
                  subtitle: strings.t('profile.voice_preference_subtitle'),
                  onTap: () => _showVoicePreferenceSheet(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SettingsSection(
              title: strings.t('profile.section_appearance_reminder'),
              children: [
                _SettingsValueItem(
                  title: strings.t('profile.theme_mode'),
                  value: _themeLabel(widget.settings.themePreference),
                  subtitle: strings.t('profile.theme_mode_subtitle'),
                  onTap: () => _showThemeSheet(context),
                ),
                _SettingsSwitchItem(
                  title: strings.t('profile.reminder'),
                  subtitle: widget.settings.reminderEnabled
                      ? strings.t(
                          'profile.reminder_on_subtitle',
                          params: <String, String>{
                            'time': widget.settings.reminderTime,
                          },
                        )
                      : strings.t('profile.reminder_off_subtitle'),
                  value: widget.settings.reminderEnabled,
                  onChanged: (value) => widget.onSettingsChanged(
                    widget.settings.copyWith(reminderEnabled: value),
                  ),
                ),
                if (widget.settings.reminderEnabled)
                  _SettingsValueItem(
                    title: strings.t('profile.reminder_time'),
                    value: widget.settings.reminderTime,
                    subtitle: strings.t('profile.reminder_time_subtitle'),
                    onTap: _pickReminderTime,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _SettingsSection(
              title: strings.t('profile.section_help_feedback'),
              children: [
                _SettingsNavItem(
                  title: strings.t('profile.submit_suggestion'),
                  subtitle: strings.t('profile.submit_suggestion_subtitle'),
                  onTap: () =>
                      _openFeedbackBoard('feedback.category_suggestion'),
                ),
                _SettingsNavItem(
                  title: strings.t('profile.report_issue'),
                  subtitle: strings.t('profile.report_issue_subtitle'),
                  onTap: () => _openFeedbackBoard('feedback.category_bug'),
                ),
                _SettingsNavItem(
                  title: strings.t('profile.contact_support'),
                  subtitle: strings.t('profile.contact_support_subtitle'),
                  onTap: _contactSupport,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SettingsSection(
              title: strings.t('profile.section_about_info'),
              children: [
                _SettingsNavItem(
                  title: strings.t('profile.developer_note'),
                  subtitle: strings.t('profile.developer_note_subtitle'),
                  onTap: _openDeveloperNotePage,
                ),
                _SettingsValueItem(
                  title: strings.t('profile.about_version'),
                  value: _appVersion == '--'
                      ? strings.t('profile.about_version_unavailable_value')
                      : _appVersion,
                  subtitle: strings.t('profile.about_version_subtitle'),
                ),
                _SettingsNavItem(
                  title: strings.t('profile.about_privacy'),
                  subtitle: strings.t('profile.about_privacy_subtitle'),
                  onTap: _openPrivacyPage,
                ),
                _SettingsNavItem(
                  title: strings.t('profile.about_terms'),
                  subtitle: strings.t('profile.about_terms_subtitle'),
                  onTap: _openTermsPage,
                ),
              ],
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  _LearningOverviewData _buildLearningOverviewData(AppStrings strings) {
    final completedCount = _completedLessonCount;
    final nextLesson = _resolveContinuationLesson();
    final currentUnit = nextLesson?.unitId;

    final title = completedCount == 0
        ? strings.t('profile.overview_title_new')
        : completedCount >= _lessons.length
            ? strings.t('profile.overview_title_completed')
            : strings.t(
                'profile.overview_title_unit',
                params: <String, String>{
                  'unit': _unitTitle(currentUnit),
                },
              );

    String suggestion;
    if (!_unlocked &&
        _freeLessonCount > 0 &&
        _freeCompletedCount >= _freeLessonCount) {
      suggestion = strings.t('profile.overview_suggestion_unlock');
    } else if (_progress.reviewCount > 0) {
      suggestion = strings.t(
        'profile.overview_suggestion_review',
        params: <String, String>{'count': '${_progress.reviewCount}'},
      );
    } else if (nextLesson != null) {
      suggestion = strings.t(
        completedCount == 0
            ? 'profile.overview_suggestion_first_lesson'
            : 'profile.overview_suggestion_continue',
        params: <String, String>{
          'lesson':
              LessonLocalizer.title(nextLesson, widget.settings.appLanguage),
        },
      );
    } else {
      suggestion = strings.t('profile.overview_suggestion_keep_going');
    }

    final streakText = _progress.streakDays == 0
        ? strings.t('profile.overview_streak_start')
        : strings.t(
            'profile.overview_streak_days',
            params: <String, String>{'days': '${_progress.streakDays}'},
          );

    final stageText = !_unlocked
        ? (_freeCompletedCount >= _freeLessonCount && _freeLessonCount > 0
            ? strings.t('profile.overview_stage_trial_done')
            : strings.t('profile.overview_stage_trial'))
        : currentUnit != null
            ? strings.t(
                'profile.overview_stage_unit',
                params: <String, String>{'unit': _unitTitle(currentUnit)},
              )
            : strings.t('profile.overview_stage_full');

    final stats = <String>[
      strings.t(
        'profile.overview_completed',
        params: <String, String>{
          'completed': '$completedCount',
          'total': '${_lessons.length}',
        },
      ),
      stageText,
      streakText,
      if (_progress.reviewCount > 0)
        strings.t(
          'profile.overview_review',
          params: <String, String>{'count': '${_progress.reviewCount}'},
        ),
    ];

    return _LearningOverviewData(
      icon: _progress.streakDays > 0
          ? Icons.local_fire_department_rounded
          : Icons.auto_stories_rounded,
      title: title,
      suggestion: suggestion,
      stats: stats,
      actionText: strings.t('profile.overview_action_continue_learning'),
      actionType: vm.ProfileLearningActionType.continueLearning,
      lesson: _resolveContinuationLesson(),
    );
  }

  // ignore: unused_element
  _CurrentPlanData _buildCurrentPlanData(AppStrings strings) {
    if (_unlocked || !_hasLockedLessons) {
      final remaining =
          (_lessons.length - _completedLessonCount).clamp(0, _lessons.length);
      return _CurrentPlanData(
        badge: strings.t('profile.plan_full_badge'),
        title: strings.t('profile.plan_full_title'),
        description: strings.t('profile.plan_full_description'),
        footnote: strings.t(
          'profile.plan_full_footnote',
          params: <String, String>{'remaining': '$remaining'},
        ),
        unlocked: true,
      );
    }

    return _CurrentPlanData(
      badge: strings.t('profile.plan_trial_badge'),
      title: strings.t('profile.plan_trial_title'),
      description: strings.t(
        'profile.plan_trial_description',
        params: <String, String>{
          'free': '$_freeLessonCount',
        },
      ),
      footnote: strings.t(
        'profile.plan_trial_footnote',
        params: <String, String>{
          'completed': '$_freeCompletedCount',
          'total': '$_freeLessonCount',
        },
      ),
      unlocked: false,
      actionText: strings.t('profile.plan_unlock_action'),
    );
  }

  // ignore: unused_element
  int get _completedLessonCount {
    final lessonIds = _lessons.map((lesson) => lesson.id).toSet();
    return _progress.completedLessons.intersection(lessonIds).length;
  }

  // ignore: unused_element
  bool get _hasLockedLessons {
    return _lessons.any((lesson) => lesson.isLocked);
  }

  int get _freeLessonCount {
    return _lessons.where((lesson) => !lesson.isLocked).length;
  }

  int get _freeCompletedCount {
    return _lessons
        .where(
          (lesson) =>
              !lesson.isLocked &&
              _progress.completedLessons.contains(lesson.id),
        )
        .length;
  }

  // ignore: unused_element
  Lesson? _resolveContinuationLesson() {
    if (_lessons.isEmpty) return null;

    Lesson? byLastLesson;
    if (_progress.lastLessonId != null) {
      byLastLesson = _firstWhereOrNull(
        _lessons,
        (lesson) =>
            lesson.id == _progress.lastLessonId &&
            _progress.startedLessons.contains(lesson.id) &&
            !_progress.completedLessons.contains(lesson.id),
      );
    }

    final startedInProgress = _firstWhereOrNull(
      _lessons,
      (lesson) =>
          _progress.startedLessons.contains(lesson.id) &&
          !_progress.completedLessons.contains(lesson.id),
    );

    final nextAccessible = _firstWhereOrNull(
      _lessons,
      (lesson) =>
          !_progress.completedLessons.contains(lesson.id) &&
          (!lesson.isLocked || _unlocked),
    );

    return byLastLesson ?? startedInProgress ?? nextAccessible;
  }

  // ignore: unused_element
  String _unitTitle(String? unitId) {
    final strings = context.strings;
    switch (unitId) {
      case 'U1':
        return strings.t('profile.unit_1');
      case 'U2':
        return strings.t('profile.unit_2');
      case 'U3':
        return strings.t('profile.unit_3');
      case 'U4':
        return strings.t('profile.unit_4');
      default:
        return strings.t('profile.unit_default');
    }
  }

  void _openPrivacyPage() {
    final strings = context.strings;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StaticInfoPage(
          title: strings.t('profile.about_privacy'),
          paragraphs: <String>[
            strings.t('profile.privacy_body_1'),
            strings.t('profile.privacy_body_2'),
            strings.t('profile.privacy_body_3'),
          ],
        ),
      ),
    );
  }

  void _openDeveloperNotePage() {
    final strings = context.strings;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StaticInfoPage(
          title: strings.t('profile.developer_note'),
          paragraphs: <String>[
            strings.t('profile.developer_note_body_1'),
            strings.t('profile.developer_note_body_2'),
          ],
        ),
      ),
    );
  }

  void _openTermsPage() {
    final strings = context.strings;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StaticInfoPage(
          title: strings.t('profile.about_terms'),
          paragraphs: <String>[
            strings.t('profile.terms_body_1'),
            strings.t('profile.terms_body_2'),
            strings.t('profile.terms_body_3'),
          ],
        ),
      ),
    );
  }

  void _showTextModeSheet(BuildContext context) {
    const textModeOptions = <ArabicTextMode>[
      ArabicTextMode.withDiacritics,
      ArabicTextMode.smart,
      ArabicTextMode.dual,
      ArabicTextMode.withoutDiacritics,
    ];

    showModalBottomSheet<void>(
      context: context,
      builder: (_) => _OptionsSheet<ArabicTextMode>(
        title: context.strings.t('profile.text_mode'),
        current: widget.settings.textMode,
        options: textModeOptions,
        labelBuilder: _textModeLabel,
        subtitleBuilder: _textModeDescription,
        onSelected: (value) =>
            widget.onSettingsChanged(widget.settings.copyWith(textMode: value)),
      ),
    );
  }

  void _showThemeSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => _OptionsSheet<AppThemePreference>(
        title: context.strings.t('profile.theme_mode'),
        current: widget.settings.themePreference,
        options: AppThemePreference.values,
        labelBuilder: _themeLabel,
        onSelected: (value) => widget.onSettingsChanged(
          widget.settings.copyWith(themePreference: value),
        ),
      ),
    );
  }

  void _showInterfaceLanguageSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => _OptionsSheet<AppLanguage>(
        title: context.strings.t('profile.interface_language'),
        current: widget.settings.appLanguage,
        options: AppLanguage.values,
        labelBuilder: _interfaceLanguageLabel,
        onSelected: (value) => widget.onSettingsChanged(
          widget.settings.copyWith(appLanguage: value),
        ),
      ),
    );
  }

  void _showMeaningLanguageSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => _OptionsSheet<ContentLanguage>(
        title: context.strings.t('profile.meaning_language'),
        current: widget.settings.meaningLanguage,
        options: ContentLanguage.values,
        labelBuilder: _meaningLanguageLabel,
        onSelected: (value) => widget.onSettingsChanged(
          widget.settings.copyWith(meaningLanguage: value),
        ),
      ),
    );
  }

  void _showVoicePreferenceSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => _OptionsSheet<AudioVoicePreference>(
        title: context.strings.t('profile.voice_preference'),
        current: widget.settings.voicePreference,
        options: AudioVoicePreference.values,
        labelBuilder: _voicePreferenceLabel,
        subtitleBuilder: _voicePreferenceDescription,
        onSelected: (value) => widget.onSettingsChanged(
          widget.settings.copyWith(voicePreference: value),
        ),
      ),
    );
  }

  String _textModeLabel(ArabicTextMode mode) {
    final strings = context.strings;
    switch (mode) {
      case ArabicTextMode.withDiacritics:
        return strings.t('profile.text_mode_beginner');
      case ArabicTextMode.smart:
        return strings.t('profile.text_mode_adaptive');
      case ArabicTextMode.dual:
        return strings.t('profile.text_mode_dual');
      case ArabicTextMode.withoutDiacritics:
        return strings.t('profile.text_mode_reading');
    }
  }

  String _textModeDescription(ArabicTextMode mode) {
    final strings = context.strings;
    switch (mode) {
      case ArabicTextMode.withDiacritics:
        return strings.t('profile.text_mode_beginner_desc');
      case ArabicTextMode.smart:
        return strings.t('profile.text_mode_adaptive_desc');
      case ArabicTextMode.dual:
        return strings.t('profile.text_mode_dual_desc');
      case ArabicTextMode.withoutDiacritics:
        return strings.t('profile.text_mode_reading_desc');
    }
  }

  String _themeLabel(AppThemePreference pref) {
    final strings = context.strings;
    switch (pref) {
      case AppThemePreference.system:
        return strings.t('settings.theme_system');
      case AppThemePreference.light:
        return strings.t('settings.theme_light');
      case AppThemePreference.dark:
        return strings.t('settings.theme_dark');
    }
  }

  String _interfaceLanguageLabel(AppLanguage language) {
    final strings = context.strings;
    switch (language) {
      case AppLanguage.zh:
        return strings.t('settings.language_zh');
      case AppLanguage.en:
        return strings.t('settings.language_en');
    }
  }

  String _meaningLanguageLabel(ContentLanguage language) {
    final strings = context.strings;
    switch (language) {
      case ContentLanguage.zh:
        return strings.t('settings.language_zh');
      case ContentLanguage.en:
        return strings.t('settings.language_en');
    }
  }

  String _fontScaleLabel(ArabicFontScale scale) {
    final strings = context.strings;
    switch (scale) {
      case ArabicFontScale.standard:
        return strings.t('settings.font_standard');
      case ArabicFontScale.large:
        return strings.t('settings.font_large');
    }
  }

  String _voicePreferenceLabel(AudioVoicePreference pref) {
    final strings = context.strings;
    switch (pref) {
      case AudioVoicePreference.ai:
        return strings.t('settings.voice_ai');
      case AudioVoicePreference.human:
        return strings.t('settings.voice_human');
    }
  }

  String _voicePreferenceDescription(AudioVoicePreference pref) {
    final strings = context.strings;
    switch (pref) {
      case AudioVoicePreference.ai:
        return strings.t('settings.voice_ai_desc');
      case AudioVoicePreference.human:
        return strings.t('settings.voice_human_desc');
    }
  }
}

class _LearningOverviewCard extends StatelessWidget {
  final _LearningOverviewData data;
  final VoidCallback onActionTap;

  const _LearningOverviewCard({
    required this.data,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppTheme.softAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  data.icon,
                  color: AppTheme.accentMintDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  data.title,
                  style: text.titleLarge?.copyWith(height: 1.25),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.bgCardSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              data.suggestion,
              style: text.bodyLarge?.copyWith(color: AppTheme.textPrimary),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: data.stats
                .map((item) => _OverviewStatChip(label: item))
                .toList(),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onActionTap,
              child: Text(data.actionText),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewStatChip extends StatelessWidget {
  final String label;

  const _OverviewStatChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppTheme.bgCardSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppTheme.accentMintDark,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _CurrentPlanCard extends StatelessWidget {
  final _CurrentPlanData data;
  final VoidCallback? onActionTap;

  const _CurrentPlanCard({
    required this.data,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.strings.t('profile.plan_card_title'),
                  style: text.titleMedium,
                ),
              ),
              if (data.badge != null)
                Pill(
                  label: data.badge!,
                  backgroundColor: data.unlocked
                      ? AppTheme.softAccent
                      : AppTheme.bgCardSoft,
                  foregroundColor: AppTheme.accentMintDark,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(data.title, style: text.titleLarge),
          const SizedBox(height: 8),
          Text(data.description, style: text.bodyMedium),
          if (data.footnote.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(data.footnote, style: text.bodySmall),
          ],
          if (data.actionText != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onActionTap,
                child: Text(data.actionText!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsNavItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsNavItem({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}

class _SettingsSwitchItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchItem({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () => onChanged(!value),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}

class _SettingsValueItem extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final VoidCallback? onTap;

  const _SettingsValueItem({
    required this.title,
    required this.value,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.accentMintDark,
                ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded),
          ],
        ],
      ),
    );
  }
}

class _OptionsSheet<T> extends StatelessWidget {
  final String title;
  final T current;
  final List<T> options;
  final String Function(T) labelBuilder;
  final String Function(T)? subtitleBuilder;
  final ValueChanged<T> onSelected;

  const _OptionsSheet({
    required this.title,
    required this.current,
    required this.options,
    required this.labelBuilder,
    required this.onSelected,
    this.subtitleBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...options.map(
              (option) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(labelBuilder(option)),
                subtitle: subtitleBuilder == null
                    ? null
                    : Text(subtitleBuilder!(option)),
                trailing: current == option
                    ? const Icon(
                        Icons.check_rounded,
                        color: AppTheme.accentMintDark,
                      )
                    : null,
                onTap: () {
                  onSelected(option);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

T? _firstWhereOrNull<T>(
  Iterable<T> values,
  bool Function(T value) test,
) {
  for (final value in values) {
    if (test(value)) {
      return value;
    }
  }
  return null;
}
