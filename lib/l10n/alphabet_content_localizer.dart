import '../models/alphabet_group.dart';
import '../models/app_settings.dart';
import '../models/quiz_question.dart';
import 'lesson_content_localizer.dart';

class AlphabetContentLocalizer {
  AlphabetContentLocalizer._();

  static String groupTitle(
    AlphabetGroup group,
    AppLanguage language,
  ) {
    if (language != AppLanguage.en) return group.title;
    return _groupTitles[group.id] ?? group.title;
  }

  static String groupSubtitle(
    AlphabetGroup group,
    ContentLanguage language,
  ) {
    if (language != ContentLanguage.en) return group.subtitle;
    return _groupSubtitles[group.id] ?? group.subtitle;
  }

  static String hint(
    AlphabetLetter letter,
    ContentLanguage language,
  ) {
    if (language != ContentLanguage.en) return letter.hint;
    return _letterHints[letter.arabic] ?? letter.hint;
  }

  static String soundHint(
    AlphabetLetter letter,
    ContentLanguage language,
  ) {
    if (language != ContentLanguage.en) return letter.soundHint;
    return _letterSoundHints[letter.arabic] ?? letter.soundHint;
  }

  static String tip(
    AlphabetLetter letter,
    ContentLanguage language,
  ) {
    if (language != ContentLanguage.en) return letter.tip;
    return _letterTips[letter.arabic] ?? letter.tip;
  }

  static String exampleMeaning(
    AlphabetExample example,
    ContentLanguage language,
  ) {
    if (language != ContentLanguage.en) return example.meaning;
    return _exampleMeanings[example.arabic] ??
        LessonContentLocalizer.meaning(example.meaning, language);
  }

  static String pronunciationLabel(
    String value,
    AppLanguage language,
  ) {
    if (language != AppLanguage.en) return value;
    return _pronunciationLabels[value] ?? value;
  }

  static String pronunciationHint(
    String value,
    ContentLanguage language,
  ) {
    if (language != ContentLanguage.en) return value;
    return _pronunciationHints[value] ?? value;
  }

  static String quizText(
    String value,
    AppLanguage language,
  ) {
    if (language != AppLanguage.en) return value;
    return _quizText[value] ?? value;
  }

  static QuizQuestion localizeQuestion(
    QuizQuestion question,
    AppLanguage language,
  ) {
    if (language != AppLanguage.en) {
      return question;
    }

    return QuizQuestion(
      title: quizText(question.title, language),
      prompt: quizText(question.prompt, language),
      promptType: question.promptType,
      correct: quizText(question.correct, language),
      options: question.options
          .map((option) => quizText(option, language))
          .toList(growable: false),
    );
  }
}

const Map<int, String> _groupTitles = <int, String>{
  1: 'Group 1: Dot Foundations',
  2: 'Group 2: Throat and Deep Sounds',
  3: 'Group 3: Break Letters',
  4: 'Group 4: Continuous Dental Set',
  5: 'Group 5: Heavy and Pharyngeal Sounds',
  6: 'Group 6: Common Mouth Letters',
  7: 'Group 7: High-Frequency Closing Letters',
};

const Map<int, String> _groupSubtitles = <int, String>{
  1: 'Start with dot placement to build the first layer of letter recognition.',
  2: 'This group focuses on distinguishing back-of-mouth and throat sounds.',
  3: 'These letters often break the connection to the next letter, which matters in reading.',
  4: 'Move into high-frequency flowing letters and heavier sound pairs.',
  5: 'This is an advanced group. Pay attention to pharyngeal and deep mouth positions.',
  6: 'These are common letters that appear in a large number of basic words.',
  7: 'The final group covers frequent nasal, lip, and semivowel letters.',
};

const Map<String, String> _letterHints = <String, String>{
  'ا': 'A single vertical line. It is one of the easiest Arabic letters to recognize.',
  'ب': 'One dot below. That is the key to separating it from ت and ث.',
  'ت': 'Two dots above.',
  'ث': 'Three dots above.',
  'ج': 'One dot below, with a shape similar to ح and خ.',
  'ح': 'No dots.',
  'خ': 'One dot above.',
  'د': 'No dots. Small and short.',
  'ذ': 'Add one dot above to د.',
  'ر': 'No dots, with a more curved shape than د.',
  'ز': 'Add one dot above to ر.',
  'س': 'Like a row of small teeth, with no dots.',
  'ش': 'Same shape as س, but with three dots above.',
  'ص': 'No dots, with a fuller shape than س.',
  'ض': 'Add one dot above to ص.',
  'ط': 'No dots, with a fuller body than د.',
  'ظ': 'Add one dot above to ط.',
  'ع': 'An open curved shape with no dots.',
  'غ': 'Add one dot above to ع.',
  'ف': 'One dot above.',
  'ق': 'Two dots above.',
  'ك': 'Very common in basic words. Pay extra attention to its medial form.',
  'ل': 'A tall, slim shape that often appears with ا.',
  'م': 'A rounder body that often appears in the middle or end of words.',
  'ن': 'One dot above.',
  'ه': 'Do not confuse it with the deeper-sounding ح.',
  'و': 'A rounded short curve. It does not connect forward.',
  'ي': 'Two dots below, and a very common final form.',
};

const Map<String, String> _letterSoundHints = <String, String>{
  'ا': 'Often carries a long vowel and frequently appears at the beginning of words.',
  'ب': 'Close both lips, then release quickly for a clear b sound.',
  'ت': 'Touch the ridge behind the teeth lightly for a clean t sound.',
  'ث': 'Like the th in “think.”',
  'ج': 'For the first release, keep it as a steady j sound.',
  'ح': 'A deeper h sound produced from farther back in the throat.',
  'خ': 'A fricative kh sound with a rougher airflow.',
  'د': 'Touch the ridge behind the teeth lightly for a d sound.',
  'ذ': 'Like the th in “this.”',
  'ر': 'A short, quick tap of the tongue for r.',
  'ز': 'A clear z sound.',
  'س': 'A clear s sound.',
  'ش': 'Like the sh in “she.”',
  'ص': 'A heavier, deeper s sound.',
  'ض': 'A heavier, deeper d sound.',
  'ط': 'A heavier, deeper t sound.',
  'ظ': 'A heavier, deeper z / dh-like sound.',
  'ع': 'A pharyngeal sound. At first, focus on hearing and recognizing it.',
  'غ': 'A gh sound with friction.',
  'ف': 'Touch the lower lip lightly with the upper teeth for f.',
  'ق': 'Farther back than k, with a stronger back closure.',
  'ك': 'A clear k sound.',
  'ل': 'Raise the tip of the tongue for l.',
  'م': 'Close the lips for m.',
  'ن': 'A clear n sound.',
  'ه': 'A light, regular h sound.',
  'و': 'Can act as w and also carry the long vowel uu.',
  'ي': 'Can act as y and also carry the long vowel ii.',
};

const Map<String, String> _letterTips = <String, String>{
  'ا': 'Alif does not connect to the next letter. Watch for a fresh stroke after it.',
  'ب': 'When you see one dot below, think of Ba first, then judge its word position.',
  'ت': 'Its body is close to Ba, but the dots move to the top and become two.',
  'ث': 'It differs from Ta only by the number of dots, so train the 2-dot vs 3-dot contrast first.',
  'ج': 'Remember the curved body plus one dot below as the main visual clue.',
  'ح': 'Its body is almost the same as ج and خ, so start by checking whether there is a dot.',
  'خ': 'Train it together with ح and look for the single dot above.',
  'د': 'Dal does not connect forward, so the next letter starts again.',
  'ذ': 'Study it next to د and remember: same body, one dot above.',
  'ر': 'Ra also breaks the connection, so its stop point matters in reading.',
  'ز': 'Train ز and ر as a pair: same body, but ز has one dot above.',
  'س': 'Remember the three-tooth wave first, then contrast it with ش by the dots.',
  'ش': 'Once you see the toothed shape, check whether the three dots are above it.',
  'ص': 'Treat it as the heavy-sound version of s and pair it with ض.',
  'ض': 'Recognize the heavy outer shape first, then use the top dot to distinguish it from ص.',
  'ط': 'Treat it as the heavy-sound version of t. Do not merge it with regular ت.',
  'ظ': 'Study it together with ط. The main visual difference is the top dot.',
  'ع': 'Ayn is hard for many beginners. Learn the shape first, then train the throat position gradually.',
  'غ': 'Study it with ع and look carefully for the dot above.',
  'ف': 'Train ف and ق together. The dot count is the key difference.',
  'ق': 'If the shape looks close to ف, count the dots above first.',
  'ك': 'Kaf is high-frequency. Get used to its changing shape inside words early.',
  'ل': 'Lam connects very often, so pay attention to how it flows into the next letter.',
  'م': 'Mim is frequent. Start by mastering its isolated and final shapes.',
  'ن': 'Unlike the ب / ت / ث family, Nun has its single dot above and a taller body.',
  'ه': 'Keep ه and ح separate in your mind: one is a light h, the other is deeper.',
  'و': 'Like Alif, Waw does not connect forward and often creates a visible break.',
  'ي': 'Ya often appears at the end of words, so learn both the dots and the final form together.',
};

const Map<String, String> _exampleMeanings = <String, String>{
  'أَنَا': 'I',
  'بَيْت': 'house',
  'تُفَّاح': 'apple',
  'ثَوْب': 'robe',
  'جَمَل': 'camel',
  'حُبّ': 'love',
  'خُبْز': 'bread',
  'دَرْس': 'lesson',
  'ذَهَب': 'gold',
  'رَجُل': 'man',
  'زَيْت': 'oil',
  'سَمَك': 'fish',
  'شَمْس': 'sun',
  'صَبْر': 'patience',
  'ضَيْف': 'guest',
  'طَعَام': 'food',
  'ظَرْف': 'envelope',
  'عَيْن': 'eye',
  'غُرْفَة': 'room',
  'فَم': 'mouth',
  'قَلَم': 'pen',
  'كِتَاب': 'book',
  'لَيْمُون': 'lemon',
  'مَاء': 'water',
  'نُور': 'light',
  'هَدِيَّة': 'gift',
  'وَرْد': 'rose',
  'يَد': 'hand',
};

const Map<String, String> _pronunciationLabels = <String, String>{
  '短音 a': 'Short a',
  '短音 i': 'Short i',
  '短音 u': 'Short u',
  '长音 aa': 'Long aa',
  '长音 ii': 'Long ii',
  '长音 uu': 'Long uu',
  '静音 / sukun': 'Sukun',
  '重音 + a': 'Shadda + a',
  '重音 + i': 'Shadda + i',
  '重音 + u': 'Shadda + u',
  '尾音 an': 'Ending an',
  '尾音 in': 'Ending in',
  '尾音 un': 'Ending un',
};

const Map<String, String> _pronunciationHints = <String, String>{
  '短促开口音。': 'A short open vowel.',
  '短促前元音。': 'A short front vowel.',
  '短促圆唇音。': 'A short rounded vowel.',
  '把 a 拉长。': 'Lengthen the a sound.',
  '把 i 拉长。': 'Lengthen the i sound.',
  '把 u 拉长。': 'Lengthen the u sound.',
  '只停住，不再带元音。': 'Stop the sound without adding a vowel.',
  '不再附带元音。': 'No extra vowel is added.',
  '强调后再接 a。': 'Add emphasis, then connect to a.',
  '强调后再接 i。': 'Add emphasis, then connect to i.',
  '强调后再接 u。': 'Add emphasis, then connect to u.',
  '强调辅音后再接 a。': 'Double the consonant, then add a.',
  '强调辅音后再接 i。': 'Double the consonant, then add i.',
  '强调辅音后再接 u。': 'Double the consonant, then add u.',
  '常见名词尾音。': 'A common noun ending.',
};

const Map<String, String> _quizText = <String, String>{
  '这个字母叫什么？': 'What is the name of this letter?',
  '请选择对应的阿语字母': 'Choose the matching Arabic letter.',
  '听字母发音，选择正确的基础音值': 'Listen to the letter sound and choose the correct core sound.',
  '听字母发音，选择对应的字母': 'Listen to the letter sound and choose the matching letter.',
  '听读音形式，选择正确的转写': 'Listen to the sound form and choose the correct transliteration.',
  '听读音形式，选择正确的类别': 'Listen to the sound form and choose the correct label.',
  '根据提示选字母': 'Choose the letter from the hint.',
  '下方 1 个点': 'One dot below',
  '上方 2 个点': 'Two dots above',
  '上方 3 个点': 'Three dots above',
  '没有点': 'No dots',
  '上方 1 个点': 'One dot above',
  '无点，且通常不向后连写': 'No dots, and it usually does not connect forward',
  '在 د 的基础上加上方 1 点': 'Add one dot above د',
  '在 ر 的基础上加上方 1 点': 'Add one dot above ر',
  '像三齿形，没有点': 'Three-tooth shape with no dots',
  '像三齿形，上方 3 个点': 'Three-tooth shape with three dots above',
  '厚音外形，没有点': 'Heavy-sound shape with no dots',
  '厚音外形，上方 1 个点': 'Heavy-sound shape with one dot above',
  '开口弯形，没有点': 'Open curved shape with no dots',
  '在 ع 的基础上加上方 1 点': 'Add one dot above ع',
};
