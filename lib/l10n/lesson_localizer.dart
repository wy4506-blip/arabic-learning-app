import '../models/app_settings.dart';
import '../models/lesson.dart';

class LessonLocalizer {
  LessonLocalizer._();

  static String title(Lesson lesson, AppLanguage language) {
    if (language == AppLanguage.en) {
      return _titleEn[lesson.id] ?? lesson.titleCn;
    }
    return lesson.titleCn;
  }

  static String grammarTitle(Lesson lesson, ContentLanguage language) {
    if (language == ContentLanguage.en) {
      return _grammarTitleEn[lesson.id] ?? lesson.grammarTitle;
    }
    return lesson.grammarTitle;
  }

  static String grammarExplanation(
    Lesson lesson,
    ContentLanguage language,
  ) {
    if (language == ContentLanguage.en) {
      return _grammarExplanationEn[lesson.id] ?? lesson.grammarExplanation;
    }
    return lesson.grammarExplanation;
  }
}

const Map<String, String> _titleEn = <String, String>{
  'U1L1': 'Greetings and Essential Expressions',
  'U1L2': 'Introducing Yourself',
  'U1L3': 'Classroom Arabic',
  'U1L4': 'Things in the Classroom',
  'U2L1': 'Family Members',
  'U2L2': 'Jobs and Identity',
  'U2L3': 'Nationalities and Languages',
  'U2L4': 'Appearance and Personality',
  'U3L1': 'Numbers and Age',
  'U3L2': 'Daily Routine',
  'U3L3': 'Time and Dates',
  'U3L4': 'Food and Ordering',
  'U4L1': 'Home and Position',
  'U4L2': 'Shopping and Prices',
  'U4L3': 'Directions and Transportation',
  'U4L4': 'Weather and Clothing',
};

const Map<String, String> _grammarTitleEn = <String, String>{
  'U1L1': 'Chunk Greetings as Complete Expressions',
  'U1L2': 'Minimal Self-Introduction Patterns',
  'U1L3': 'Classroom Imperatives',
  'U1L4': 'هذا / هذه',
  'U2L1': 'Basic Possession in Family Talk',
  'U2L2': 'Identity Nouns in Sentences',
  'U2L3': 'Language and Nationality Pairings',
  'U2L4': 'Simple Descriptive Adjectives',
  'U3L1': 'Basic Number + Age Pattern',
  'U3L2': 'Habit Sentences with Present Tense',
  'U3L3': 'Time and Date Lookup Patterns',
  'U3L4': 'Ordering with “I want”',
  'U4L1': 'Spatial Expressions with Place Words',
  'U4L2': 'Price Adjectives',
  'U4L3': 'Sequence Words for Directions',
  'U4L4': 'Weather and Clothing Description Sentences',
};

const Map<String, String> _grammarExplanationEn = <String, String>{
  'U1L1':
      'Lesson 1 stays light. Learn greetings and responses as full chunks before breaking down grammar.',
  'U1L2':
      'This lesson builds only two core patterns first: “My name is ...” and “I am from ...”.',
  'U1L3':
      'Focus on the most common classroom command expressions. Hear them, react to them, and only later unpack the verb system.',
  'U1L4':
      'Start with the basic habit: هذا often appears with masculine nouns, while هذه often appears with feminine nouns.',
  'U2L1':
      'Family talk works best when possession is introduced through short ready-to-use phrases instead of long rules.',
  'U2L2':
      'Jobs and identities are first learned as sentence chunks so learners can speak earlier with less overload.',
  'U2L3':
      'Nationality and language expressions are grouped together to help learners talk about themselves in a natural way.',
  'U2L4':
      'This lesson introduces short descriptive phrases so learners can connect people with simple qualities.',
  'U3L1':
      'Numbers become more useful when immediately tied to age and short daily-life questions.',
  'U3L2':
      'The lesson uses daily routine sentences to build familiarity with present-tense habits instead of abstract tables first.',
  'U3L3':
      'Time and date patterns are treated as quick-reference expressions that learners can reuse in real situations.',
  'U3L4':
      'The lesson enters ordering through the direct and practical pattern “I want ...”, keeping the scene easy to use.',
  'U4L1':
      'Home and position are taught through spatial words like فوق and بجانب to build a strong location sense.',
  'U4L2':
      'Shopping starts with the two most useful functions: asking the price and describing something as cheap or expensive.',
  'U4L3':
      'Directions are introduced as short ordered instructions such as “to the right, then to the left”.',
  'U4L4':
      'Weather and clothing are linked together so learners can describe conditions and what they wear in complete sentences.',
};
