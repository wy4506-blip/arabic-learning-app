import '../data/v2_micro_lesson_catalog.dart';
import '../models/app_settings.dart';
import '../models/v2_micro_lesson.dart';

class V2MicroLessonLocalizer {
  const V2MicroLessonLocalizer._();

  static const Map<String, String> _lessonTitlesEn = <String, String>{
    'V2-ALPHA-CL-01': 'Alphabet Closure: Hear ث / ذ / ظ Clearly',
    'V2-BRIDGE-01': 'Short Vowel Bridge: Hear a / i / u',
    'V2-U1-01': 'Greeting Recognition: First 3 Phrases',
    'V2-U1-02': 'Greeting Response: Say Ana Bikhayr',
    'V2-U1-03': 'Introduce Yourself: Say "My Name Is..."',
    'V2-U1-04': 'Introduce Yourself: I Am From China',
    'V2-U1-05': 'Classroom Commands: اقرأ / كرر',
  };

  static const Map<String, String> _lessonOutcomesEn = <String, String>{
    'V2-ALPHA-CL-01':
      'After this lesson, you can hear and pick out ث / ذ / ظ as a confusable set.',
    'V2-BRIDGE-01':
      'After this lesson, you can tell a / i / u apart by ear.',
    'V2-U1-01':
      'After this lesson, you can hear three basic greetings and know what they mean.',
    'V2-U1-02':
      'After this lesson, you can hear "How are you?" and answer with Ana bikhayr, shukran.',
    'V2-U1-03':
      'After this lesson, you can say your name with Ismi ...',
    'V2-U1-04':
      'After this lesson, you can say in one sentence that you are a student from China.',
    'V2-U1-05':
      'After this lesson, you can understand اقرأ and كرر and say "Please repeat."',
  };

  static const Map<String, String> _objectiveSummariesEn = <String, String>{
    'alpha_close_hear_last_group': 'Hear ث / ذ / ظ apart',
    'alpha_close_name_last_group': 'Say the letter name when you see ظ',
    'bridge_short_vowels_hear': 'Hear a / i / u apart',
    'bridge_short_vowels_repeat': 'Repeat the vowel as soon as you see it',
    'greeting_recognize_3': 'Recognize 3 basic greetings by ear',
    'greeting_match_meaning': 'Match each greeting to its meaning',
    'reply_bikhayr': 'Reply with "Ana bikhayr, shukran"',
    'recognize_kayfa': 'Recognize when someone asks "How are you?"',
    'intro_name_phrase': 'Say "Ismi ..."',
    'hear_ma_ismuka': 'Recognize when someone asks your name',
    'intro_from_china': 'Say "I am from China"',
    'intro_student_identity': 'Say "I am a student"',
    'hear_where_from': 'Recognize when someone asks where you are from',
    'classroom_iqra': 'Understand اقرأ',
    'classroom_karrir': 'Understand كرر',
    'classroom_request_repeat': 'Say "Please repeat" when you miss it',
  };

  static const Map<String, String> _practicePromptsEn = <String, String>{
    'hear_tha': 'Tap it when you hear the sound ث.',
    'hear_dhal': 'Tap it when you hear the sound ذ.',
    'say_zha': 'Say the letter name when you see zha.',
    'hear_a': 'Tap it when you hear the sound a.',
    'hear_i': 'Tap it when you hear the sound i.',
    'repeat_u': 'Say it out loud when you see u.',
    'recognize_marhaban': 'Tap the line that means hello.',
    'recognize_sabah': 'Tap the line for good morning.',
    'recognize_salama': 'Which phrase best ends the conversation?',
    'hear_kayfa': 'Tap it when you hear "How are you?"',
    'say_bikhayr': 'Answer right away after the question.',
    'recall_reply': 'Say the full reply once without the prompt.',
    'hear_name_question': 'Tap it when you hear the name question.',
    'say_name': 'Say "My name is..." when it is your turn.',
    'recall_name': 'Say the opening phrase without the prompt.',
    'hear_where_from': 'Tap it when you hear "Where are you from?"',
    'say_from_china': 'Say "I am from China."',
    'say_student_identity': 'Build the sentence "I am a student."',
    'full_identity_sentence': 'Say the full self-introduction sentence.',
    'hear_iqra': 'Tap it when you hear "Read."',
    'hear_karrir': 'Tap it when you hear "Repeat."',
    'say_repeat_request': 'Say "Please repeat" when you miss it.',
  };

  static const Map<String, String> _practiceMeaningsEn = <String, String>{
    'recognize_marhaban': 'Hello',
    'recognize_sabah': 'Good morning',
    'recognize_salama': 'Goodbye',
  };

  static String lessonTitle(
    V2MicroLesson lesson,
    AppLanguage language,
  ) {
    if (language != AppLanguage.en) {
      return lesson.title;
    }
    return _lessonTitlesEn[lesson.lessonId] ?? lesson.title;
  }

  static String lessonTitleById(String lessonId, AppLanguage language) {
    final lesson = maybeV2MicroLessonById(lessonId);
    if (lesson == null) {
      return lessonId;
    }
    return lessonTitle(lesson, language);
  }

  static String outcomeSummary(
    V2MicroLesson lesson,
    AppLanguage language,
  ) {
    if (language != AppLanguage.en) {
      return lesson.outcomeSummary;
    }
    return _lessonOutcomesEn[lesson.lessonId] ?? lesson.outcomeSummary;
  }

  static String objectiveSummary(
    String objectiveId,
    AppLanguage language, {
    required String fallback,
  }) {
    if (language != AppLanguage.en) {
      return fallback;
    }
    return _objectiveSummariesEn[objectiveId] ?? fallback;
  }

  static String practicePrompt(
    String itemId,
    AppLanguage language, {
    required String fallback,
  }) {
    if (language != AppLanguage.en) {
      return fallback;
    }
    return _practicePromptsEn[itemId] ?? fallback;
  }

  static String? practiceMeaning(
    String itemId,
    ContentLanguage language, {
    String? fallback,
  }) {
    if (language != ContentLanguage.en) {
      return fallback;
    }
    return _practiceMeaningsEn[itemId] ?? fallback;
  }
}
