import '../models/app_settings.dart';

class AppStrings {
  final AppLanguage language;

  const AppStrings(this.language);

  String t(String key, {Map<String, String> params = const {}}) {
    final values = _strings[key];
    var template =
        values?[language.name] ?? values?['en'] ?? values?['zh'] ?? key;

    for (final entry in params.entries) {
      template = template.replaceAll('{${entry.key}}', entry.value);
    }

    return template;
  }
}

const Map<String, Map<String, String>> _strings = <String, Map<String, String>>{
  'app.name': <String, String>{
    'zh': '阿巴阿巴',
    'en': 'Ababa Arabic',
  },
  'nav.home': <String, String>{
    'zh': '首页',
    'en': 'Home',
  },
  'nav.lessons': <String, String>{
    'zh': '课程',
    'en': 'Lessons',
  },
  'nav.review': <String, String>{
    'zh': '复习',
    'en': 'Review',
  },
  'nav.profile': <String, String>{
    'zh': '我的',
    'en': 'Profile',
  },
  'common.loading': <String, String>{
    'zh': '加载中...',
    'en': 'Loading...',
  },
  'common.all': <String, String>{
    'zh': '全部',
    'en': 'All',
  },
  'common.recent': <String, String>{
    'zh': '最近加入',
    'en': 'Recent',
  },
  'common.search': <String, String>{
    'zh': '搜索',
    'en': 'Search',
  },
  'common.play_audio': <String, String>{
    'zh': '播放发音',
    'en': 'Play Audio',
  },
  'common.done': <String, String>{
    'zh': '完成',
    'en': 'Done',
  },
  'common.on': <String, String>{
    'zh': '开启',
    'en': 'On',
  },
  'common.off': <String, String>{
    'zh': '关闭',
    'en': 'Off',
  },
  'common.cancel': <String, String>{
    'zh': '取消',
    'en': 'Cancel',
  },
  'common.send': <String, String>{
    'zh': '发送',
    'en': 'Send',
  },
  'home.today_start': <String, String>{
    'zh': '继续今天的学习',
    'en': 'Continue Today\'s Learning',
  },
  'home.today_subtitle': <String, String>{
    'zh': '先完成当前最重要的一步，再沿学习路径进入下一步。',
    'en':
        'Finish the most important next step first, then keep moving along the learning path.',
  },
  'home.quick_actions': <String, String>{
    'zh': '常用入口',
    'en': 'Quick Actions',
  },
  'home.quick_actions_subtitle': <String, String>{
    'zh': '只保留最核心的 4 个动作，首页聚焦分发与反馈',
    'en':
        'Four high-value entry points to keep the home page tight and useful.',
  },
  'home.lessons': <String, String>{
    'zh': '课程',
    'en': 'Lessons',
  },
  'home.review': <String, String>{
    'zh': '复习',
    'en': 'Review',
  },
  'home.alphabet': <String, String>{
    'zh': '字母',
    'en': 'Alphabet',
  },
  'home.wordbook': <String, String>{
    'zh': '单词本',
    'en': 'Wordbook',
  },
  'home.grammar': <String, String>{
    'zh': '语法速查',
    'en': 'Grammar Quick Reference',
  },
  'home.lessons_done_subtitle': <String, String>{
    'zh': '全部课程已学习',
    'en': 'All lessons completed',
  },
  'home.lessons_remaining_subtitle': <String, String>{
    'zh': '还剩 {count} 节待推进',
    'en': '{count} lessons left',
  },
  'home.review_ready_subtitle': <String, String>{
    'zh': '今天先继续新课',
    'en': 'Focus on new lessons today',
  },
  'home.review_pending_subtitle': <String, String>{
    'zh': '待回顾 {count} 项',
    'en': '{count} items to review',
  },
  'home.alphabet_subtitle': <String, String>{
    'zh': '听读、书写、练习闭环',
    'en': 'Listen, write, and drill letters in one flow.',
  },
  'home.wordbook_subtitle': <String, String>{
    'zh': '随学随收，随时检索',
    'en': 'Save while learning and search anytime.',
  },
  'home.learned': <String, String>{
    'zh': '已学',
    'en': 'Learned',
  },
  'home.to_review': <String, String>{
    'zh': '待复习',
    'en': 'To Review',
  },
  'home.streak': <String, String>{
    'zh': '连续',
    'en': 'Streak',
  },
  'home.today_path': <String, String>{
    'zh': '今日主线',
    'en': 'Today\'s Focus',
  },
  'home.default_lesson_title': <String, String>{
    'zh': '先学字母，再进入课程',
    'en': 'Learn the Alphabet First',
  },
  'home.default_lesson_note': <String, String>{
    'zh': '先建立字母识读与基础发音，再进入完整 16 节课程。',
    'en':
        'Build letter recognition and pronunciation first, then move into the 16-lesson course.',
  },
  'home.next_open_note': <String, String>{
    'zh': '{minutes} 分钟 · 下一步建议优先完成这一课。',
    'en': '{minutes} min · This is the best next lesson to take.',
  },
  'home.next_locked_note': <String, String>{
    'zh': '{minutes} 分钟 · 当前阶段完成后，可查看会员说明并继续后续路径。',
    'en':
        '{minutes} min · After this stage, view membership info and continue into the next path.',
  },
  'home.start_alphabet': <String, String>{
    'zh': '开始字母学习',
    'en': 'Start Alphabet',
  },
  'home.continue_learning': <String, String>{
    'zh': '继续学习',
    'en': 'Continue',
  },
  'home.view_alphabet_path': <String, String>{
    'zh': '查看字母路径',
    'en': 'Open Alphabet Path',
  },
  'home.view_lessons': <String, String>{
    'zh': '查看课程列表',
    'en': 'View Lessons',
  },
  'home.free_lessons': <String, String>{
    'zh': '当前开放起步阶段',
    'en': 'Starter Stage Open',
  },
  'home.streak_today_start': <String, String>{
    'zh': '今日开始',
    'en': 'Start today',
  },
  'home.streak_days_value': <String, String>{
    'zh': '{days} 天',
    'en': '{days} days',
  },
  'home.unlock_note': <String, String>{
    'zh': '会员用于提升学习效率与后续阶段衔接，不再单独打断主线。',
    'en':
        'Membership improves continuity and efficiency instead of interrupting the main path.',
  },
  'course.title': <String, String>{
    'zh': '课程',
    'en': 'Lessons',
  },
  'course.subtitle': <String, String>{
    'zh': '按当前进度继续，也可以随时回看已学内容。',
    'en':
        'Continue from your current progress, or revisit what you already learned.',
  },
  'course.completed_summary': <String, String>{
    'zh': '已完成 {completed} / {total} 课时',
    'en': 'Completed {completed} / {total} lessons',
  },
  'course.filter_all': <String, String>{
    'zh': '全部课程',
    'en': 'All Lessons',
  },
  'course.filter_not_started': <String, String>{
    'zh': '未开始',
    'en': 'Not Started',
  },
  'course.filter_in_progress': <String, String>{
    'zh': '学习中',
    'en': 'In Progress',
  },
  'course.filter_completed': <String, String>{
    'zh': '已完成',
    'en': 'Completed',
  },
  'course.status_locked': <String, String>{
    'zh': '需解锁',
    'en': 'Locked',
  },
  'course.status_done': <String, String>{
    'zh': '已完成',
    'en': 'Done',
  },
  'course.status_started': <String, String>{
    'zh': '进行中',
    'en': 'In Progress',
  },
  'course.status_ready': <String, String>{
    'zh': '可学习',
    'en': 'Ready',
  },
  'review.title': <String, String>{
    'zh': '复习',
    'en': 'Review',
  },
  'review.subtitle': <String, String>{
    'zh': '清晰答题、降低压力，优先复习已收藏内容',
    'en': 'Keep review lightweight and focused by starting with saved words.',
  },
  'review.empty_title': <String, String>{
    'zh': '当前没有待复习内容',
    'en': 'Nothing to Review Yet',
  },
  'review.empty_subtitle': <String, String>{
    'zh': '先去课程详情页或单词本收藏几个重点词。',
    'en': 'Save a few key words from lessons or the wordbook first.',
  },
  'review.today': <String, String>{
    'zh': '今日复习',
    'en': 'Today\'s Review',
  },
  'review.tip_title': <String, String>{
    'zh': '复习提示',
    'en': 'Review Tip',
  },
  'review.tip_body': <String, String>{
    'zh': '一次只服务一个决策：看 → 想 → 记 → 下一步。',
    'en': 'One decision at a time: see it, think, recall, move on.',
  },
  'review.later': <String, String>{
    'zh': '稍后复习',
    'en': 'Later',
  },
  'review.remembered': <String, String>{
    'zh': '我记住了',
    'en': 'I Remember It',
  },
  'wordbook.title': <String, String>{
    'zh': '单词本',
    'en': 'Wordbook',
  },
  'wordbook.subtitle': <String, String>{
    'zh': '重点是检索、复习与掌握状态，而不是堆列表',
    'en':
        'Built for search, review, and retention instead of a long dump list.',
  },
  'wordbook.search_hint': <String, String>{
    'zh': '搜索阿语 / 中文 / 英文 / 音译',
    'en': 'Search Arabic / Chinese / English / transliteration',
  },
  'wordbook.empty_title': <String, String>{
    'zh': '学习中可随时加入单词本',
    'en': 'Save words to your wordbook anytime while learning.',
  },
  'wordbook.empty_search': <String, String>{
    'zh': '没有搜索到结果，试试切换带音符/去音符的检索方式。',
    'en': 'No result found. Try searching with or without diacritics.',
  },
  'wordbook.plain': <String, String>{
    'zh': '去音符',
    'en': 'Plain',
  },
  'wordbook.feminine': <String, String>{
    'zh': '阴性',
    'en': 'Feminine',
  },
  'wordbook.masculine': <String, String>{
    'zh': '阳性',
    'en': 'Masculine',
  },
  'wordbook.plural': <String, String>{
    'zh': '复数',
    'en': 'Plural',
  },
  'wordbook.pattern': <String, String>{
    'zh': '词形',
    'en': 'Morphology',
  },
  'wordbook.note': <String, String>{
    'zh': '提示',
    'en': 'Note',
  },
  'wordbook.example': <String, String>{
    'zh': '例句',
    'en': 'Example',
  },
  'wordbook.unset': <String, String>{
    'zh': '未标注',
    'en': 'Not Set',
  },
  'profile.title': <String, String>{
    'zh': '我的',
    'en': 'Profile',
  },
  'profile.subtitle_locked': <String, String>{
    'zh': '学习体验、提醒、购买、反馈与支持',
    'en': 'Experience, reminders, purchase, feedback, and support',
  },
  'profile.subtitle_unlocked': <String, String>{
    'zh': '学习体验、提醒、反馈与支持',
    'en': 'Experience, reminders, feedback, and support',
  },
  'profile.learning': <String, String>{
    'zh': '学习中',
    'en': 'Learning',
  },
  'profile.streak_days': <String, String>{
    'zh': '连续学习 {days} 天',
    'en': '{days}-day streak',
  },
  'profile.group_experience': <String, String>{
    'zh': '学习体验',
    'en': 'Learning Experience',
  },
  'profile.group_language': <String, String>{
    'zh': '语言与显示',
    'en': 'Language & Display',
  },
  'profile.group_reminder': <String, String>{
    'zh': '提醒',
    'en': 'Reminder',
  },
  'profile.group_content_locked': <String, String>{
    'zh': '内容与购买',
    'en': 'Content & Purchase',
  },
  'profile.group_content_unlocked': <String, String>{
    'zh': '当前课程',
    'en': 'Current Course',
  },
  'profile.group_feedback': <String, String>{
    'zh': '反馈与支持',
    'en': 'Feedback & Support',
  },
  'profile.interface_language': <String, String>{
    'zh': '界面语言',
    'en': 'Interface Language',
  },
  'profile.interface_language_subtitle': <String, String>{
    'zh': '设置应用界面的显示语言。',
    'en': 'Set the display language of the app interface.',
  },
  'profile.meaning_language': <String, String>{
    'zh': '释义语言',
    'en': 'Meaning Language',
  },
  'profile.meaning_language_subtitle': <String, String>{
    'zh': '设置单词和句子的解释语言。',
    'en': 'Set the explanation language for words and sentences.',
  },
  'profile.text_mode': <String, String>{
    'zh': '文本显示模式',
    'en': 'Text Display Mode',
  },
  'profile.show_transliteration': <String, String>{
    'zh': '显示转写',
    'en': 'Show Transliteration',
  },
  'profile.arabic_font_size': <String, String>{
    'zh': '阿文字号',
    'en': 'Arabic Text Size',
  },
  'profile.theme_mode': <String, String>{
    'zh': '外观模式',
    'en': 'Appearance',
  },
  'profile.reminder': <String, String>{
    'zh': '学习提醒',
    'en': 'Learning Reminder',
  },
  'profile.reminder_time': <String, String>{
    'zh': '提醒时间',
    'en': 'Reminder Time',
  },
  'profile.course_range': <String, String>{
    'zh': '课程范围',
    'en': 'Course Access',
  },
  'profile.current_pack': <String, String>{
    'zh': '当前内容包',
    'en': 'Current Pack',
  },
  'profile.restore_purchase': <String, String>{
    'zh': '恢复会员权益',
    'en': 'Restore Membership',
  },
  'profile.restore_purchase_value': <String, String>{
    'zh': '保留入口',
    'en': 'Keep Entry',
  },
  'profile.feedback_board': <String, String>{
    'zh': '反馈',
    'en': 'Feedback',
  },
  'profile.feedback_value': <String, String>{
    'zh': '改进建议 / Bug 反馈',
    'en': 'Suggestions / Bug Report',
  },
  'profile.reminder_off': <String, String>{
    'zh': '已关闭，可先选择提醒时间',
    'en': 'Off. You can still preselect a time.',
  },
  'profile.reminder_on': <String, String>{
    'zh': '已开启，每天 {time}',
    'en': 'On, daily at {time}',
  },
  'profile.full_course': <String, String>{
    'zh': '{count} 节完整课程',
    'en': '{count} full lessons',
  },
  'profile.free_pack': <String, String>{
    'zh': '前 3 节免费',
    'en': 'First 3 lessons free',
  },
  'profile.page_intro': <String, String>{
    'zh': '管理学习状态、偏好设置与支持信息。',
    'en': 'Manage learning status, preferences, and support.',
  },
  'profile.section_learning_state': <String, String>{
    'zh': '学习状态',
    'en': 'Learning Status',
  },
  'profile.section_learning_preferences': <String, String>{
    'zh': '学习偏好',
    'en': 'Learning Preferences',
  },
  'profile.section_language_text': <String, String>{
    'zh': '语言与文本',
    'en': 'Language & Text',
  },
  'profile.section_appearance_reminder': <String, String>{
    'zh': '外观与提醒',
    'en': 'Appearance & Reminder',
  },
  'profile.section_course_access': <String, String>{
    'zh': '会员与权益',
    'en': 'Membership',
  },
  'profile.section_content_purchase': <String, String>{
    'zh': '内容与购买',
    'en': 'Content & Purchase',
  },
  'profile.section_developer_support': <String, String>{
    'zh': '帮助与反馈',
    'en': 'Help & Feedback',
  },
  'profile.section_help_feedback': <String, String>{
    'zh': '帮助与反馈',
    'en': 'Help & Feedback',
  },
  'profile.section_about_info': <String, String>{
    'zh': '关于与说明',
    'en': 'About & Policies',
  },
  'profile.section_about': <String, String>{
    'zh': '关于',
    'en': 'About',
  },
  'profile.overview_title_new': <String, String>{
    'zh': '开始你的阿语学习',
    'en': 'Start Your Arabic Learning',
  },
  'profile.overview_title_start_learning': <String, String>{
    'zh': '开始你的阿语学习',
    'en': 'Start Your Arabic Learning',
  },
  'profile.overview_title_continue_learning': <String, String>{
    'zh': '继续你的学习',
    'en': 'Continue Your Learning',
  },
  'profile.overview_title_review_first': <String, String>{
    'zh': '先完成今天的复习',
    'en': 'Finish Today\'s Review First',
  },
  'profile.overview_title_completed': <String, String>{
    'zh': '已完成全部课程',
    'en': 'All Lessons Completed',
  },
  'profile.overview_title_unit': <String, String>{
    'zh': '正在学习 {unit}',
    'en': 'Learning {unit}',
  },
  'profile.overview_suggestion_first_lesson': <String, String>{
    'zh': '先完成第 1 节，建立稳定节奏。',
    'en': 'Finish lesson 1 first and build a steady rhythm.',
  },
  'profile.overview_suggestion_start_learning': <String, String>{
    'zh': '先从字母和发音开始，再进入第一课。',
    'en': 'Start with letters and sounds, then move into lesson 1.',
  },
  'profile.overview_suggestion_continue_learning': <String, String>{
    'zh': '继续当前节奏，比加快更重要。',
    'en': 'Keeping your rhythm matters more than moving faster.',
  },
  'profile.overview_suggestion_review_first': <String, String>{
    'zh': '先把今天该看的内容过一遍，再学新内容会更稳。',
    'en': 'Review today\'s due items first, then continue with new learning.',
  },
  'profile.overview_suggestion_completed': <String, String>{
    'zh': '主线课程已完成，现在更适合按需回看和复习。',
    'en': 'The core course is complete. Revisit and review as needed now.',
  },
  'profile.overview_suggestion_continue': <String, String>{
    'zh': '继续上一节内容：{lesson}',
    'en': 'Continue your last lesson: {lesson}',
  },
  'profile.overview_suggestion_review': <String, String>{
    'zh': '先回顾 {count} 项重点，再继续往下学。',
    'en': 'Review {count} key items first, then keep learning.',
  },
  'profile.overview_suggestion_unlock': <String, String>{
    'zh': '当前阶段已完成，先巩固已学内容，再决定是否查看会员说明。',
    'en':
        'This stage is complete. Reinforce what you learned first, then decide whether to review membership details.',
  },
  'profile.overview_suggestion_keep_going': <String, String>{
    'zh': '保持当前节奏，适时回看已学内容。',
    'en': 'Keep your current rhythm and revisit learned content when needed.',
  },
  'profile.overview_first_step_progress': <String, String>{
    'zh': '已完成 0/1 节',
    'en': '0/1 lessons completed',
  },
  'profile.overview_stage_beginner': <String, String>{
    'zh': '入门阶段',
    'en': 'Beginner Stage',
  },
  'profile.overview_lesson_in_progress': <String, String>{
    'zh': '第 {lesson} 课学习中',
    'en': 'Lesson {lesson} In Progress',
  },
  'profile.overview_lesson_not_finished': <String, String>{
    'zh': '本课未完成',
    'en': 'Current Lesson Not Finished',
  },
  'profile.overview_action_start_learning': <String, String>{
    'zh': '开始学习',
    'en': 'Start Learning',
  },
  'profile.overview_action_continue_learning': <String, String>{
    'zh': '继续学习',
    'en': 'Continue Learning',
  },
  'profile.overview_action_review': <String, String>{
    'zh': '去复习',
    'en': 'Go Review',
  },
  'profile.overview_action_review_lessons': <String, String>{
    'zh': '回看课程',
    'en': 'Review Lessons',
  },
  'profile.overview_completed': <String, String>{
    'zh': '已完成 {completed}/{total} 节',
    'en': '{completed}/{total} lessons completed',
  },
  'profile.overview_stage_trial': <String, String>{
    'zh': '当前阶段：体验中',
    'en': 'Stage: Trial',
  },
  'profile.overview_stage_trial_done': <String, String>{
    'zh': '当前阶段：体验已完成',
    'en': 'Stage: Trial Complete',
  },
  'profile.overview_stage_unit': <String, String>{
    'zh': '当前阶段：{unit}',
    'en': 'Stage: {unit}',
  },
  'profile.overview_stage_full': <String, String>{
    'zh': '当前阶段：完整版',
    'en': 'Stage: Full Access',
  },
  'profile.overview_streak_start': <String, String>{
    'zh': '从今天开始累计连续学习',
    'en': 'Start building your streak today',
  },
  'profile.overview_streak_days': <String, String>{
    'zh': '连续学习 {days} 天',
    'en': '{days}-day streak',
  },
  'profile.overview_review': <String, String>{
    'zh': '待复习 {count} 项',
    'en': '{count} items to review',
  },
  'profile.plan_card_title': <String, String>{
    'zh': '当前状态',
    'en': 'Current Status',
  },
  'profile.plan_trial_badge': <String, String>{
    'zh': '基础版',
    'en': 'Core',
  },
  'profile.plan_trial_title': <String, String>{
    'zh': '当前为基础学习路径',
    'en': 'You Are on the Core Learning Path',
  },
  'profile.plan_trial_description': <String, String>{
    'zh': '当前主线可继续学习。会员主要用于提升效率，并在后续阶段开放时提供更顺滑的衔接。',
    'en':
        'Your main learning path remains available. Membership mainly improves efficiency and later-stage continuity.',
  },
  'profile.plan_trial_footnote': <String, String>{
    'zh': '当前已完成 {completed}/{total} 个起步阶段课时',
    'en': '{completed}/{total} starter-stage lessons completed',
  },
  'profile.plan_unlock_action': <String, String>{
    'zh': '查看会员说明',
    'en': 'View Membership Info',
  },
  'profile.plan_full_badge': <String, String>{
    'zh': '会员',
    'en': 'Member',
  },
  'profile.plan_full_title': <String, String>{
    'zh': '当前已启用会员',
    'en': 'Membership Is Active',
  },
  'profile.plan_full_description': <String, String>{
    'zh': '会员已启用，后续阶段开放时会获得更顺滑的衔接。',
    'en':
        'Membership is active and will support smoother continuity as later stages open.',
  },
  'profile.plan_full_footnote': <String, String>{
    'zh': '当前仍有 {remaining} 节可继续推进的课程内容',
    'en': '{remaining} lessons are currently available to continue',
  },
  'profile.text_mode_subtitle': <String, String>{
    'zh': '选择更适合当前阶段的阿文显示方式。',
    'en': 'Choose the Arabic display style that best fits your current stage.',
  },
  'profile.show_transliteration_subtitle': <String, String>{
    'zh': '显示拼读辅助，适合初学阶段。',
    'en': 'Show pronunciation support for the early learning stage.',
  },
  'profile.font_size_subtitle': <String, String>{
    'zh': '调整阿文内容的显示大小。',
    'en': 'Adjust the display size of Arabic content.',
  },
  'profile.voice_preference': <String, String>{
    'zh': '配音偏好',
    'en': 'Voice Preference',
  },
  'profile.voice_preference_subtitle': <String, String>{
    'zh': '选择更适合你的发音播放方式。',
    'en': 'Choose the pronunciation playback style that suits you better.',
  },
  'profile.theme_mode_subtitle': <String, String>{
    'zh': '设置应用整体外观风格。',
    'en': 'Set the overall appearance style of the app.',
  },
  'profile.reminder_off_subtitle': <String, String>{
    'zh': '按设定时间提醒你学习。',
    'en': 'Get reminded to study at the set time.',
  },
  'profile.reminder_on_subtitle': <String, String>{
    'zh': '已开启，每天 {time} 提醒你学习。',
    'en': 'On. You will be reminded to study each day at {time}.',
  },
  'profile.reminder_time_subtitle': <String, String>{
    'zh': '选择每天接收学习提醒的时间。',
    'en': 'Pick the time for your daily reminder.',
  },
  'profile.reminder_on_short': <String, String>{
    'zh': '每天 {time}',
    'en': 'Daily at {time}',
  },
  'profile.reminder_off_short': <String, String>{
    'zh': '未开启',
    'en': 'Off',
  },
  'profile.content_pack_title': <String, String>{
    'zh': '会员状态',
    'en': 'Membership Status',
  },
  'profile.content_pack_trial_value': <String, String>{
    'zh': '基础学习路径',
    'en': 'Core Learning Path',
  },
  'profile.content_pack_full_value': <String, String>{
    'zh': '完整版',
    'en': 'Full',
  },
  'profile.content_pack_trial_subtitle': <String, String>{
    'zh': '当前主线仍可继续，会员不再打断学习路径。',
    'en':
        'Your current path remains available, and membership no longer interrupts the learning flow.',
  },
  'profile.content_pack_full_subtitle': <String, String>{
    'zh': '会员已启用，后续阶段开放时会更顺滑接续。',
    'en':
        'Membership is active and will support smoother continuation as later stages open.',
  },
  'profile.unlock_full_title': <String, String>{
    'zh': '会员说明',
    'en': 'Membership Info',
  },
  'profile.unlock_full_value': <String, String>{
    'zh': '查看',
    'en': 'View',
  },
  'profile.unlock_full_subtitle': <String, String>{
    'zh': '了解会员如何提升学习效率，而不打断当前主线。',
    'en':
        'See how membership improves efficiency without blocking the current path.',
  },
  'profile.unlocked_value': <String, String>{
    'zh': '已解锁',
    'en': 'Unlocked',
  },
  'profile.unlocked_subtitle': <String, String>{
    'zh': '全部课程权益已可用。',
    'en': 'Full lesson access is already available.',
  },
  'profile.restore_purchase_subtitle': <String, String>{
    'zh': '在新设备上恢复已经开通的会员状态。',
    'en': 'Restore your existing membership state on a new device.',
  },
  'profile.restore_purchase_current': <String, String>{
    'zh': '当前会员已启用，无需重复恢复。',
    'en': 'Membership is already active. No restore is needed.',
  },
  'profile.submit_suggestion': <String, String>{
    'zh': '提建议',
    'en': 'Suggestions',
  },
  'profile.submit_suggestion_subtitle': <String, String>{
    'zh': '提交想法，帮助我们继续打磨产品。',
    'en': 'Share ideas that can help improve the product.',
  },
  'profile.report_issue': <String, String>{
    'zh': '问题反馈',
    'en': 'Report an Issue',
  },
  'profile.report_issue_subtitle': <String, String>{
    'zh': '反馈音频、显示或使用中的问题。',
    'en': 'Report audio, display, or general usage issues.',
  },
  'profile.contact_support': <String, String>{
    'zh': '联系支持',
    'en': 'Contact Support',
  },
  'profile.contact_support_subtitle': <String, String>{
    'zh': '遇到问题时，可以直接联系我们。',
    'en': 'Contact us directly when you need help.',
  },
  'profile.developer_note': <String, String>{
    'zh': '开发者说明',
    'en': 'Developer Note',
  },
  'profile.developer_note_subtitle': <String, String>{
    'zh': '关于这款产品为什么开始的一点说明。',
    'en': 'A short note on why this product began.',
  },
  'profile.developer_note_body_1': <String, String>{
    'zh': '这款 App 的起点很简单：把阿拉伯语入门做得更轻一些，让第一次接触这门语言的人也能继续学下去。',
    'en':
        'This app started from a simple goal: make beginner Arabic lighter, so first-time learners can keep going.',
  },
  'profile.developer_note_body_2': <String, String>{
    'zh': '如果你愿意继续用它学习，也愿意告诉我们哪些地方还不够顺，这款产品就会继续改进。',
    'en':
        'If you keep learning with it and tell us where the experience still feels rough, the product can keep improving.',
  },
  'profile.contact_support_body': <String, String>{
    'zh': '请描述你遇到的问题、出现页面以及复现步骤，我们会据此继续排查。',
    'en':
        'Describe the issue, where it happened, and how to reproduce it so we can investigate further.',
  },
  'profile.contact_support_opened': <String, String>{
    'zh': '已打开邮件应用。',
    'en': 'Your mail app has been opened.',
  },
  'profile.contact_support_copied': <String, String>{
    'zh': '当前无法直接发信，已复制支持内容到剪贴板。',
    'en':
        'Could not open mail directly. The support content was copied instead.',
  },
  'profile.about_version': <String, String>{
    'zh': '当前版本',
    'en': 'Current Version',
  },
  'profile.about_version_subtitle': <String, String>{
    'zh': '查看当前安装版本。',
    'en': 'View the currently installed version.',
  },
  'profile.about_version_unavailable_value': <String, String>{
    'zh': '版本信息暂不可用',
    'en': 'Version unavailable',
  },
  'profile.about_privacy': <String, String>{
    'zh': '隐私说明',
    'en': 'Privacy Notice',
  },
  'profile.about_privacy_subtitle': <String, String>{
    'zh': '查看隐私说明。',
    'en': 'Read the privacy notice.',
  },
  'profile.about_terms': <String, String>{
    'zh': '使用条款',
    'en': 'Terms of Use',
  },
  'profile.about_terms_subtitle': <String, String>{
    'zh': '查看使用说明。',
    'en': 'Read the terms of use.',
  },
  'profile.privacy_body_1': <String, String>{
    'zh': '首发版本主要在本地保存学习进度、设置项和解锁状态，用于恢复你的学习状态。',
    'en':
        'The first release mainly stores learning progress, settings, and unlock status locally so your study state can be restored.',
  },
  'profile.privacy_body_2': <String, String>{
    'zh': '当你发送建议或问题时，内容会通过系统邮件应用发送给开发者，用于产品改进和问题排查。',
    'en':
        'When you send suggestions or issue reports, the content is passed to your system mail app so the developer can review it.',
  },
  'profile.privacy_body_3': <String, String>{
    'zh': '如果后续增加在线账号、支付或云同步能力，隐私说明会同步更新并在应用内展示。',
    'en':
        'If future versions add online accounts, payments, or cloud sync, this notice will be updated in the app.',
  },
  'profile.terms_body_1': <String, String>{
    'zh': '本应用用于阿拉伯语入门学习与复习，帮助建立基础识读、词汇和句型能力。',
    'en':
        'This app is designed for beginner Arabic learning and review, helping you build basic reading, vocabulary, and sentence-pattern skills.',
  },
  'profile.terms_body_2': <String, String>{
    'zh': '首发版本中的购买、恢复购买和部分反馈流程仍为轻量实现，后续会继续完善。',
    'en':
        'Some purchase, restore, and support flows in the first release are still lightweight implementations and will continue to improve.',
  },
  'profile.terms_body_3': <String, String>{
    'zh': '如果发现内容错误、音频问题或界面异常，欢迎通过应用内反馈入口联系开发者。',
    'en':
        'If you encounter content errors, audio problems, or interface issues, please contact the developer through the in-app feedback entry.',
  },
  'profile.unit_1': <String, String>{
    'zh': 'Unit 1 · 入门表达',
    'en': 'Unit 1 · Core Expressions',
  },
  'profile.unit_2': <String, String>{
    'zh': 'Unit 2 · 人物与身份',
    'en': 'Unit 2 · People & Identity',
  },
  'profile.unit_3': <String, String>{
    'zh': 'Unit 3 · 时间与生活',
    'en': 'Unit 3 · Time & Daily Life',
  },
  'profile.unit_4': <String, String>{
    'zh': 'Unit 4 · 场景表达',
    'en': 'Unit 4 · Real-life Scenes',
  },
  'profile.unit_default': <String, String>{
    'zh': '当前学习阶段',
    'en': 'Current Learning Stage',
  },
  'profile.text_mode_beginner': <String, String>{
    'zh': '新手模式',
    'en': 'Beginner Mode',
  },
  'profile.text_mode_beginner_desc': <String, String>{
    'zh': '优先显示带音符文本，更适合初学阶段。',
    'en': 'Prioritize vocalized Arabic for early-stage learning.',
  },
  'profile.text_mode_adaptive': <String, String>{
    'zh': '智能模式',
    'en': 'Adaptive Mode',
  },
  'profile.text_mode_adaptive_desc': <String, String>{
    'zh': '根据学习阶段逐步减少注音，保持自然过渡。',
    'en': 'Reduce diacritics gradually as learning progresses.',
  },
  'profile.text_mode_dual': <String, String>{
    'zh': '对照模式',
    'en': 'Dual Mode',
  },
  'profile.text_mode_dual_desc': <String, String>{
    'zh': '同时显示带音符和去音符文本，便于对照。',
    'en': 'Show vocalized and plain text together for comparison.',
  },
  'profile.text_mode_reading': <String, String>{
    'zh': '原文模式',
    'en': 'Reading Mode',
  },
  'profile.text_mode_reading_desc': <String, String>{
    'zh': '更接近真实阿语文本，适合后期阅读。',
    'en': 'Closer to native-style Arabic text for later reading stages.',
  },
  'settings.language_zh': <String, String>{
    'zh': '中文',
    'en': 'Chinese',
  },
  'settings.language_en': <String, String>{
    'zh': 'English',
    'en': 'English',
  },
  'settings.font_standard': <String, String>{
    'zh': '标准',
    'en': 'Standard',
  },
  'settings.font_large': <String, String>{
    'zh': '大',
    'en': 'Large',
  },
  'settings.voice_ai': <String, String>{
    'zh': 'AI 配音',
    'en': 'AI Voice',
  },
  'settings.voice_human': <String, String>{
    'zh': '真人优先',
    'en': 'Prefer Human',
  },
  'settings.voice_ai_desc': <String, String>{
    'zh': '使用 AI 合成语音朗读，覆盖所有内容。',
    'en': 'AI-synthesized voice, covers all content.',
  },
  'settings.voice_human_desc': <String, String>{
    'zh': '优先使用真人录音，未覆盖部分自动回退到 AI。',
    'en': 'Prefer human recordings and fall back to AI where needed.',
  },
  'settings.theme_system': <String, String>{
    'zh': '跟随系统',
    'en': 'Follow System',
  },
  'settings.theme_light': <String, String>{
    'zh': '浅色模式',
    'en': 'Light Mode',
  },
  'settings.theme_dark': <String, String>{
    'zh': '深色模式',
    'en': 'Dark Mode',
  },
  'settings.text_mode_smart': <String, String>{
    'zh': '智能注音',
    'en': 'Smart',
  },
  'settings.text_mode_with': <String, String>{
    'zh': '带音符',
    'en': 'With Diacritics',
  },
  'settings.text_mode_dual': <String, String>{
    'zh': '双显示',
    'en': 'Dual Display',
  },
  'settings.text_mode_without': <String, String>{
    'zh': '去音符',
    'en': 'Without Diacritics',
  },
  'settings.choice_reminder_time': <String, String>{
    'zh': '选择提醒时间',
    'en': 'Select Reminder Time',
  },
  'feedback.title': <String, String>{
    'zh': '反馈',
    'en': 'Feedback',
  },
  'feedback.hero_title': <String, String>{
    'zh': '告诉我们哪里需要改进',
    'en': 'Tell us what needs attention',
  },
  'feedback.hero_subtitle': <String, String>{
    'zh': '可以提交建议、问题反馈，或指出任何让你觉得不顺的地方。',
    'en':
        'Share suggestions, report issues, or point out anything that feels unclear or rough.',
  },
  'feedback.category': <String, String>{
    'zh': '反馈类型',
    'en': 'Category',
  },
  'feedback.message': <String, String>{
    'zh': '留言内容',
    'en': 'Message',
  },
  'feedback.hint': <String, String>{
    'zh': '例如：第 4 课标题不够准确；复习页返回后状态丢失；希望增加慢速播放。',
    'en':
        'Example: Lesson 4 title feels off; review state resets after returning; please add slower playback.',
  },
  'feedback.submit': <String, String>{
    'zh': '发送反馈',
    'en': 'Send Feedback',
  },
  'feedback.mail_opened': <String, String>{
    'zh': '已打开邮件应用，发送后开发者即可收到。',
    'en': 'Mail app opened. Send the message there to reach the developer.',
  },
  'feedback.mail_copied': <String, String>{
    'zh': '未找到邮件应用，反馈内容已复制，可稍后粘贴发送。',
    'en': 'No mail app found. The message was copied so you can send it later.',
  },
  'feedback.submitting': <String, String>{
    'zh': '发送中...',
    'en': 'Sending...',
  },
  'feedback.empty_error': <String, String>{
    'zh': '请先写下你的建议或遇到的问题。',
    'en': 'Add a short message first.',
  },
  'feedback.category_suggestion': <String, String>{
    'zh': '改进建议',
    'en': 'Suggestion',
  },
  'feedback.category_bug': <String, String>{
    'zh': 'Bug 反馈',
    'en': 'Bug',
  },
  'feedback.category_experience': <String, String>{
    'zh': '体验问题',
    'en': 'Experience Issue',
  },
  'unlock.title': <String, String>{
    'zh': '会员说明',
    'en': 'Membership Info',
  },
  'unlock.subtitle': <String, String>{
    'zh': '会员用于提升学习效率与后续阶段衔接，不再阻断当前主线。',
    'en':
        'Membership improves learning efficiency and future stage continuity without blocking your current path.',
  },
  'unlock.plan': <String, String>{
    'zh': '当前仍可继续基础学习路径；会员作为效率提升与后续衔接说明保留。',
    'en':
        'The core learning path remains available. Membership stays as an efficiency upgrade and future-stage continuity option.',
  },
  'unlock.benefits': <String, String>{
    'zh': '会员可带来',
    'en': 'Membership Can Help With',
  },
  'unlock.benefit_lessons': <String, String>{
    'zh': '16 节完整课程开放',
    'en': 'Access to all 16 lessons',
  },
  'unlock.benefit_no_lock': <String, String>{
    'zh': '减少主路径切换与额外判断',
    'en': 'Reduce extra switching and decision overhead',
  },
  'unlock.benefit_home': <String, String>{
    'zh': '首页与学习路径提示更聚焦',
    'en': 'Keep home and path guidance more focused',
  },
  'unlock.benefit_path': <String, String>{
    'zh': '后续阶段开放时更顺滑接入学习路径',
    'en': 'Connect into later stages more smoothly as they open',
  },
  'unlock.action': <String, String>{
    'zh': '立即解锁（模拟）',
    'en': 'Unlock Now (Mock)',
  },
  'unlock.footer': <String, String>{
    'zh': '当前仍是本地模拟开通流程；这页现在是说明页，不再承担主链路拦截。',
    'en':
        'This is still a local mock activation flow. The page now serves as an information page rather than a main-path blocker.',
  },
  'unlock.hero_title': <String, String>{
    'zh': '会员让学习路径更顺滑',
    'en': 'Membership Makes the Learning Path Smoother',
  },
  'unlock.hero_subtitle_trial': <String, String>{
    'zh': '当前主线仍可继续。会员会在后续阶段接入时，帮助你更顺滑地承接剩余 {remaining} 节内容。',
    'en':
        'Your current main path remains available. Membership helps you continue more smoothly into the remaining {remaining} lessons as later stages connect in.',
  },
  'unlock.hero_subtitle_completed': <String, String>{
    'zh': '你已完成当前起步阶段。会员可在后续学习路径接入时，帮助你更顺滑地继续剩余 {remaining} 节内容。',
    'en':
        'You finished the current starter stage. Membership can help you continue more smoothly into the remaining {remaining} lessons as the later path connects in.',
  },
  'unlock.hero_subtitle_unlocked': <String, String>{
    'zh': '当前会员已启用，后续阶段开放时会自动衔接到学习路径中。',
    'en':
        'Membership is already active and will connect automatically as later stages open.',
  },
  'unlock.price': <String, String>{
    'zh': '¥10',
    'en': 'CNY 10',
  },
  'unlock.price_tag': <String, String>{
    'zh': '本地模拟开通',
    'en': 'Local Mock Activation',
  },
  'unlock.trust_subscription': <String, String>{
    'zh': '无订阅',
    'en': 'No Subscription',
  },
  'unlock.trust_ads': <String, String>{
    'zh': '无广告干扰',
    'en': 'No Ad Interruptions',
  },
  'unlock.trust_lifetime': <String, String>{
    'zh': '当前版本永久可用',
    'en': 'Permanent Access to This Release',
  },
  'unlock.benefit_all_lessons': <String, String>{
    'zh': '后续 {count} 节系统课程接入后可更顺滑继续',
    'en':
        'Continue more smoothly as the remaining {count} structured lessons connect in',
  },
  'unlock.benefit_learning_flow': <String, String>{
    'zh': '学习路径提示更集中，减少被购买页打断',
    'en':
        'Keep the learning path more focused with less interruption from purchase screens',
  },
  'unlock.benefit_content_full': <String, String>{
    'zh': '后续扩展内容开放时自动纳入同一路径',
    'en':
        'Bring later expansion content into the same path as it becomes available',
  },
  'unlock.benefit_review_full': <String, String>{
    'zh': '复习与巩固信号在后续阶段更完整',
    'en': 'Support fuller review and reinforcement signals in later stages',
  },
  'unlock.notes_title': <String, String>{
    'zh': '当前说明',
    'en': 'Current Notes',
  },
  'unlock.note_one_time': <String, String>{
    'zh': '当前仍是一次性本地模拟开通，不是订阅流程',
    'en':
        'This is still a one-time local mock activation rather than a subscription flow.',
  },
  'unlock.note_restore': <String, String>{
    'zh': '保留恢复入口，便于后续接正式购买逻辑',
    'en':
        'A restore entry remains in place for future real purchase integration.',
  },
  'unlock.note_current_release': <String, String>{
    'zh': '当前版本后续 {remaining} 节课程接入时，会优先沿当前学习路径衔接',
    'en':
        'As the remaining {remaining} lessons connect into the current release, they will follow the same learning path first.',
  },
  'unlock.note_future': <String, String>{
    'zh': '未来如新增独立专题阶段，会单独说明，不混入当前骨架收尾范围',
    'en':
        'If standalone future stages are added later, they will be described separately rather than mixed into the current skeleton scope.',
  },
  'unlock.secondary_action': <String, String>{
    'zh': '先继续当前学习',
    'en': 'Continue Current Learning First',
  },
  'unlock.primary_action': <String, String>{
    'zh': '开通会员（模拟）',
    'en': 'Enable Membership (Mock)',
  },
  'unlock.action_processing': <String, String>{
    'zh': '正在解锁...',
    'en': 'Unlocking...',
  },
  'unlock.action_unlocked': <String, String>{
    'zh': '会员已启用',
    'en': 'Membership Active',
  },
  'unlock.success': <String, String>{
    'zh': '会员已启用',
    'en': 'Membership enabled',
  },
  'unlock.failure': <String, String>{
    'zh': '会员开通失败，请稍后再试',
    'en': 'Membership activation failed. Please try again shortly.',
  },
  'grammar.home_title': <String, String>{
    'zh': '语法速查',
    'en': 'Grammar Quick Reference',
  },
  'grammar.home_subtitle': <String, String>{
    'zh': '快速查看基础语法、整表和常用句型',
    'en': 'Quickly review core grammar, summary tables, and common patterns.',
  },
  'grammar.recent': <String, String>{
    'zh': '最近查看',
    'en': 'Recently Viewed',
  },
  'grammar.recent_empty': <String, String>{
    'zh': '还没有最近查看内容，先打开一个语法页吧。',
    'en': 'Nothing here yet. Open a grammar page first.',
  },
  'grammar.favorites': <String, String>{
    'zh': '收藏内容',
    'en': 'Favorites',
  },
  'grammar.favorites_empty': <String, String>{
    'zh': '当前还没有收藏内容。',
    'en': 'No favorite grammar pages yet.',
  },
  'grammar.related_lessons': <String, String>{
    'zh': '课程关联推荐',
    'en': 'Related Lessons',
  },
  'grammar.related_lessons_subtitle': <String, String>{
    'zh': '这些课程和语法速查内容联系紧，适合来回切换看。',
    'en': 'These lessons connect closely to what you are reviewing here.',
  },
  'lesson.locked_snackbar': <String, String>{
    'zh': '该课程需先解锁',
    'en': 'This lesson is locked.',
  },
  'lesson.audio_unavailable': <String, String>{
    'zh': '当前发音暂时不可用',
    'en': 'Audio is not available right now.',
  },
  'lesson.locked_title': <String, String>{
    'zh': '前 3 节免费',
    'en': 'First 3 Lessons Free',
  },
  'lesson.locked_subtitle': <String, String>{
    'zh': '当前课时属于后续内容，解锁后自动展开完整词汇、对话与练习。',
    'en':
        'This lesson belongs to later content. Unlocking will open words, dialogue, and practice seamlessly.',
  },
  'lesson.go_unlock': <String, String>{
    'zh': '去解锁',
    'en': 'Unlock',
  },
  'lesson.words': <String, String>{
    'zh': '词汇',
    'en': 'Words',
  },
  'lesson.patterns': <String, String>{
    'zh': '句型',
    'en': 'Patterns',
  },
  'lesson.dialogues': <String, String>{
    'zh': '对话',
    'en': 'Dialogue',
  },
  'lesson.grammar': <String, String>{
    'zh': '语法',
    'en': 'Grammar',
  },
  'lesson.practice': <String, String>{
    'zh': '练习',
    'en': 'Practice',
  },
  'lesson.summary': <String, String>{
    'zh': '小结',
    'en': 'Summary',
  },
  'lesson.study_then_practice': <String, String>{
    'zh': '学完后做练习',
    'en': 'Practice After Learning',
  },
  'lesson.retry_practice': <String, String>{
    'zh': '再做一遍练习',
    'en': 'Retry Practice',
  },
  'lesson.unlock_continue': <String, String>{
    'zh': '解锁后继续',
    'en': 'Unlock to Continue',
  },
  'lesson.core_words': <String, String>{
    'zh': '核心词汇',
    'en': 'Core Words',
  },
  'lesson.core_words_subtitle': <String, String>{
    'zh': '单词先看、先听、再收藏，形成第一轮记忆',
    'en': 'See, hear, and save words to build the first memory pass.',
  },
  'lesson.core_patterns': <String, String>{
    'zh': '核心句型',
    'en': 'Core Patterns',
  },
  'lesson.core_patterns_subtitle': <String, String>{
    'zh': '把本课高频表达连起来读，练到能直接套用',
    'en': 'Read the high-frequency patterns together until they feel reusable.',
  },
  'lesson.core_dialogues': <String, String>{
    'zh': '核心对话',
    'en': 'Core Dialogue',
  },
  'lesson.core_dialogues_subtitle': <String, String>{
    'zh': '每句都能点读，先听语感，再看对应中文',
    'en': 'Tap each line, hear the rhythm first, then check the translation.',
  },
  'lesson.grammar_point': <String, String>{
    'zh': '语法点',
    'en': 'Grammar Point',
  },
  'lesson.grammar_point_subtitle': <String, String>{
    'zh': '只讲这一课最关键的一点，避免信息过载',
    'en': 'Only the most important grammar point of this lesson.',
  },
  'lesson.practice_title': <String, String>{
    'zh': '边学边练',
    'en': 'Practice in Context',
  },
  'lesson.practice_empty_subtitle': <String, String>{
    'zh': '当前课程暂时还没有练习题',
    'en': 'This lesson does not have practice items yet.',
  },
  'lesson.practice_subtitle': <String, String>{
    'zh': '本课共 {count} 道混合练习，建议学完马上做',
    'en': '{count} mixed exercises are ready for this lesson.',
  },
  'lesson.practice_card_title': <String, String>{
    'zh': '本课练习',
    'en': 'Lesson Practice',
  },
  'lesson.practice_card_empty': <String, String>{
    'zh': '课程内容已就绪，后续可继续补充对应练习。',
    'en': 'Lesson content is ready. Matching exercises can be added later.',
  },
  'lesson.practice_card_ready': <String, String>{
    'zh': '包含理解、听辨与听写，做完会直接记录课程完成状态。',
    'en':
        'Includes comprehension, listening, and dictation. Completion updates lesson progress directly.',
  },
  'lesson.practice_count_empty': <String, String>{
    'zh': '暂无题目',
    'en': 'No Items',
  },
  'lesson.practice_count_ready': <String, String>{
    'zh': '{count} 题',
    'en': '{count} Items',
  },
  'lesson.practice_start': <String, String>{
    'zh': '开始本课练习',
    'en': 'Start Practice',
  },
  'lesson.practice_restart': <String, String>{
    'zh': '重新进入练习',
    'en': 'Reopen Practice',
  },
  'lesson.summary_title': <String, String>{
    'zh': '课末小结',
    'en': 'Lesson Summary',
  },
  'lesson.summary_subtitle': <String, String>{
    'zh': '把这课最值得带走的内容再压一遍，形成完成感',
    'en':
        'Compress the most important takeaways one more time before leaving the lesson.',
  },
  'onboarding.welcome_title': <String, String>{
    'zh': '从第一个字母开始，轻松进入阿拉伯语',
    'en': 'Start Arabic gently, from your first letter',
  },
  'onboarding.welcome_subtitle': <String, String>{
    'zh': '先学一点，再慢慢展开。',
    'en': 'Learn a little first, then grow step by step.',
  },
  'onboarding.welcome_note': <String, String>{
    'zh': '不用先做复杂设置。先看一个字母、听一个声音、完成一次很轻的练习。',
    'en':
        'No setup first. See one letter, hear one sound, and finish one tiny exercise.',
  },
  'onboarding.welcome_primary': <String, String>{
    'zh': '开始学习',
    'en': 'Start Learning',
  },
  'onboarding.welcome_secondary': <String, String>{
    'zh': '先看看首页',
    'en': 'Go to Home',
  },
  'onboarding.step_progress': <String, String>{
    'zh': '第 {current} / {total} 步',
    'en': 'Step {current} / {total}',
  },
  'onboarding.step1_label': <String, String>{
    'zh': '第一步',
    'en': 'Step 1',
  },
  'onboarding.step2_label': <String, String>{
    'zh': '第二步',
    'en': 'Step 2',
  },
  'onboarding.step3_label': <String, String>{
    'zh': '第三步',
    'en': 'Step 3',
  },
  'onboarding.step1_card_note': <String, String>{
    'zh': '先把这个字母记住，它会成为后面拼读和认词的起点。',
    'en':
        'Lock in this letter first. It will anchor later reading and recognition.',
  },
  'onboarding.first_letter_badge': <String, String>{
    'zh': '你的第一个字母',
    'en': 'Your First Letter',
  },
  'onboarding.got_it': <String, String>{
    'zh': '我知道了',
    'en': 'Got It',
  },
  'onboarding.step2_title': <String, String>{
    'zh': '听一听它的声音',
    'en': 'Listen to its sound',
  },
  'onboarding.step2_subtitle': <String, String>{
    'zh': '字母不是抽象符号，它可以被听见，也会出现在真实内容里。',
    'en':
        'A letter is not abstract. You can hear it and meet it in real content.',
  },
  'onboarding.example_note': <String, String>{
    'zh': '一个很基础的音感示例',
    'en': 'A simple sound example',
  },
  'onboarding.play_again': <String, String>{
    'zh': '再听一次',
    'en': 'Play Again',
  },
  'onboarding.continue': <String, String>{
    'zh': '继续',
    'en': 'Continue',
  },
  'onboarding.step3_title': <String, String>{
    'zh': '试一试',
    'en': 'Try It',
  },
  'onboarding.quiz_title': <String, String>{
    'zh': '刚才学的是哪个字母？',
    'en': 'Which letter did you just learn?',
  },
  'onboarding.quiz_correct': <String, String>{
    'zh': '很好，你已经认识了第一个阿拉伯字母。',
    'en': 'Great, you have learned your first Arabic letter.',
  },
  'onboarding.quiz_incorrect': <String, String>{
    'zh': '没关系，再看一眼就会了。',
    'en': 'No worries, one more look and you will get it.',
  },
  'onboarding.quiz_answer': <String, String>{
    'zh': '正确答案是 {answer}',
    'en': 'The correct answer is {answer}',
  },
  'onboarding.finish_step': <String, String>{
    'zh': '完成第一步',
    'en': 'Finish This Step',
  },
  'onboarding.complete_title': <String, String>{
    'zh': '很好，你已经开始学阿拉伯语了',
    'en': 'Great, you have started learning Arabic',
  },
  'onboarding.complete_subtitle': <String, String>{
    'zh': '你刚刚认识了第一个字母，并完成了第一次练习。',
    'en':
        'You learned your first letter and completed your first mini exercise.',
  },
  'onboarding.complete_primary': <String, String>{
    'zh': '继续学习',
    'en': 'Continue Learning',
  },
  'onboarding.complete_secondary': <String, String>{
    'zh': '进入首页',
    'en': 'Go to Home',
  },
  'onboarding.home_continue_badge': <String, String>{
    'zh': '首学已完成',
    'en': 'First Step Done',
  },
  'onboarding.home_continue_title': <String, String>{
    'zh': '继续学习',
    'en': 'Continue Learning',
  },
  'onboarding.home_continue_subtitle': <String, String>{
    'zh': '你已经完成第 1 步，继续学习下一个字母。',
    'en': 'You finished step 1. Continue with the next letter.',
  },
  'onboarding.home_continue_next_title': <String, String>{
    'zh': '下一步：字母学习',
    'en': 'Next: Alphabet Learning',
  },
  'onboarding.home_continue_next_subtitle': <String, String>{
    'zh': '从分组字母开始，继续建立发音和字形感。',
    'en': 'Start with grouped letters and build sound plus shape recognition.',
  },
  'onboarding.home_continue_button': <String, String>{
    'zh': '继续',
    'en': 'Continue',
  },
  'onboarding.home_continue_secondary': <String, String>{
    'zh': '看看字母路径',
    'en': 'Browse Alphabet',
  }
};
