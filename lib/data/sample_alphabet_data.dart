import '../models/alphabet_group.dart';
import '../models/quiz_question.dart';
import 'alphabet_pronunciation_standards.dart';

class _AlphabetNameData {
  final String arabicName;
  final String latinName;

  const _AlphabetNameData({
    required this.arabicName,
    required this.latinName,
  });
}

const Map<String, _AlphabetNameData> _alphabetNames =
    <String, _AlphabetNameData>{
  'ا': _AlphabetNameData(arabicName: 'ألف', latinName: 'alif'),
  'ب': _AlphabetNameData(arabicName: 'باء', latinName: 'baa'),
  'ت': _AlphabetNameData(arabicName: 'تاء', latinName: 'taa'),
  'ث': _AlphabetNameData(arabicName: 'ثاء', latinName: 'thaa'),
  'ج': _AlphabetNameData(arabicName: 'جيم', latinName: 'jiim'),
  'ح': _AlphabetNameData(arabicName: 'حاء', latinName: 'haa'),
  'خ': _AlphabetNameData(arabicName: 'خاء', latinName: 'khaa'),
  'د': _AlphabetNameData(arabicName: 'دال', latinName: 'daal'),
  'ذ': _AlphabetNameData(arabicName: 'ذال', latinName: 'dhaal'),
  'ر': _AlphabetNameData(arabicName: 'راء', latinName: 'raa'),
  'ز': _AlphabetNameData(arabicName: 'زاي', latinName: 'zaay'),
  'س': _AlphabetNameData(arabicName: 'سين', latinName: 'siin'),
  'ش': _AlphabetNameData(arabicName: 'شين', latinName: 'shiin'),
  'ص': _AlphabetNameData(arabicName: 'صاد', latinName: 'saad'),
  'ض': _AlphabetNameData(arabicName: 'ضاد', latinName: 'daad'),
  'ط': _AlphabetNameData(arabicName: 'طاء', latinName: "taa'"),
  'ظ': _AlphabetNameData(arabicName: 'ظاء', latinName: "zaa'"),
  'ع': _AlphabetNameData(arabicName: 'عين', latinName: 'ayn'),
  'غ': _AlphabetNameData(arabicName: 'غين', latinName: 'ghayn'),
  'ف': _AlphabetNameData(arabicName: 'فاء', latinName: 'faa'),
  'ق': _AlphabetNameData(arabicName: 'قاف', latinName: 'qaaf'),
  'ك': _AlphabetNameData(arabicName: 'كاف', latinName: 'kaaf'),
  'ل': _AlphabetNameData(arabicName: 'لام', latinName: 'laam'),
  'م': _AlphabetNameData(arabicName: 'ميم', latinName: 'miim'),
  'ن': _AlphabetNameData(arabicName: 'نون', latinName: 'nuun'),
  'ه': _AlphabetNameData(arabicName: 'هاء', latinName: 'haa'),
  'و': _AlphabetNameData(arabicName: 'واو', latinName: 'waaw'),
  'ي': _AlphabetNameData(arabicName: 'ياء', latinName: 'yaa'),
};

AlphabetForms _forms(
  String isolated, {
  required bool connectsAfter,
}) {
  if (!connectsAfter) {
    return AlphabetForms(
      isolated: isolated,
      initial: isolated,
      medial: 'ـ$isolated',
      finalForm: 'ـ$isolated',
    );
  }

  return AlphabetForms(
    isolated: isolated,
    initial: '$isolatedـ',
    medial: 'ـ$isolatedـ',
    finalForm: 'ـ$isolated',
  );
}

AlphabetExample _example(String arabic, String latin, String meaning) {
  return AlphabetExample(arabic: arabic, latin: latin, meaning: meaning);
}

List<AlphabetPronunciationItem> _pronunciations(String letter) {
  return buildAlphabetPronunciations(letter);
}

AlphabetLetter _letter({
  required String arabic,
  required String name,
  required String pronunciation,
  required String phoneme,
  required String soundHint,
  required String hint,
  required AlphabetExample example,
  required bool connectsAfter,
  required String tip,
}) {
  final nameData = _alphabetNames[arabic];

  return AlphabetLetter(
    arabic: arabic,
    name: name,
    arabicName: nameData?.arabicName ?? arabic,
    latinName: nameData?.latinName ?? pronunciation,
    pronunciation: pronunciation,
    phoneme: phoneme,
    soundHint: soundHint,
    hint: hint,
    example: example,
    pronunciations: _pronunciations(arabic),
    forms: _forms(arabic, connectsAfter: connectsAfter),
    connectsAfter: connectsAfter,
    tip: tip,
  );
}

AlphabetGroup _group({
  required int id,
  required String title,
  required String subtitle,
  required List<AlphabetLetter> letters,
}) {
  return AlphabetGroup(
    id: id,
    title: title,
    subtitle: subtitle,
    letters: letters,
  );
}

final List<AlphabetGroup> sampleAlphabetGroups = <AlphabetGroup>[
  _group(
    id: 1,
    title: '第一组：基础点位',
    subtitle: '先用点位差异建立最基本的字母辨识。',
    letters: <AlphabetLetter>[
      _letter(
        arabic: 'ا',
        name: 'Alif',
        pronunciation: 'a / aa',
        phoneme: 'a',
        soundHint: '常作为长音承载，也常出现在词首。',
        hint: '最像一条竖线，是最容易认出的字母。',
        example: _example('أَنَا', 'ana', '我'),
        connectsAfter: false,
        tip: 'Alif 自身不向后连写，看到它时要留意后面的字母会重新起笔。',
      ),
      _letter(
        arabic: 'ب',
        name: 'Ba',
        pronunciation: 'b',
        phoneme: 'b',
        soundHint: '双唇闭合后快速放开，发清晰的 b 音。',
        hint: '下方 1 个点，是和 ت、ث 区分的关键。',
        example: _example('بَيْت', 'bayt', '房子'),
        connectsAfter: true,
        tip: '看到下方单点时先想到 Ba，再去判断它处在词首、词中还是词尾。',
      ),
      _letter(
        arabic: 'ت',
        name: 'Ta',
        pronunciation: 't',
        phoneme: 't',
        soundHint: '舌尖轻触齿龈，发清楚的 t 音。',
        hint: '上方 2 个点。',
        example: _example('تُفَّاح', 'tuffah', '苹果'),
        connectsAfter: true,
        tip: '和 Ba 外形接近，但点挪到上方并且变成两个。',
      ),
      _letter(
        arabic: 'ث',
        name: 'Tha',
        pronunciation: 'th',
        phoneme: 'th',
        soundHint: '类似英语 think 里的 th。',
        hint: '上方 3 个点。',
        example: _example('ثَوْب', 'thawb', '长袍'),
        connectsAfter: true,
        tip: '和 Ta 只差点数，初学时优先把“2 点 / 3 点”分清。',
      ),
    ],
  ),
  _group(
    id: 2,
    title: '第二组：喉音与深音',
    subtitle: '这一组重点在口腔后部和喉部发音的区分。',
    letters: <AlphabetLetter>[
      _letter(
        arabic: 'ج',
        name: 'Jim',
        pronunciation: 'j',
        phoneme: 'j',
        soundHint: '首发阶段按 j 来记，先建立稳定识别。',
        hint: '下方 1 个点，外形和 ح、خ 相近。',
        example: _example('جَمَل', 'jamal', '骆驼'),
        connectsAfter: true,
        tip: '先记“弯弯的主体 + 下方 1 点”这两个最显眼特征。',
      ),
      _letter(
        arabic: 'ح',
        name: 'Hha',
        pronunciation: 'h (deep)',
        phoneme: 'ḥ',
        soundHint: '从喉部较深位置送气，比普通 h 更靠后。',
        hint: '没有点。',
        example: _example('حُبّ', 'hubb', '爱'),
        connectsAfter: true,
        tip: '和 ج、خ 外形几乎一样，先从“有没有点”开始判断。',
      ),
      _letter(
        arabic: 'خ',
        name: 'Kha',
        pronunciation: 'kh',
        phoneme: 'kh',
        soundHint: '带摩擦感，像较重的 kh。',
        hint: '上方 1 个点。',
        example: _example('خُبْز', 'khubz', '面包'),
        connectsAfter: true,
        tip: '看到上方 1 点时，优先和没有点的 ح 做对比记忆。',
      ),
    ],
  ),
  _group(
    id: 3,
    title: '第三组：断连字母',
    subtitle: '这些字母通常不向后连接，阅读时很关键。',
    letters: <AlphabetLetter>[
      _letter(
        arabic: 'د',
        name: 'Dal',
        pronunciation: 'd',
        phoneme: 'd',
        soundHint: '舌尖轻触齿龈，发 d 音。',
        hint: '无点，小而短。',
        example: _example('دَرْس', 'dars', '课'),
        connectsAfter: false,
        tip: 'Dal 不向后连接，后一个字母会重新起笔。',
      ),
      _letter(
        arabic: 'ذ',
        name: 'Dhal',
        pronunciation: 'dh',
        phoneme: 'dh',
        soundHint: '类似英语 this 里的 dh。',
        hint: '在 د 的基础上加上方 1 点。',
        example: _example('ذَهَب', 'dhahab', '黄金'),
        connectsAfter: false,
        tip: '把它和 د 放在一起看，先记住“多了上方 1 点”。',
      ),
      _letter(
        arabic: 'ر',
        name: 'Ra',
        pronunciation: 'r',
        phoneme: 'r',
        soundHint: '舌尖快速轻弹，发短促 r。',
        hint: '无点，弯度比 د 更明显。',
        example: _example('رَجُل', 'rajul', '男人'),
        connectsAfter: false,
        tip: 'Ra 也不向后连接，认字时要特别留意断开位置。',
      ),
      _letter(
        arabic: 'ز',
        name: 'Zay',
        pronunciation: 'z',
        phoneme: 'z',
        soundHint: '发清楚的 z 音。',
        hint: '在 ر 的基础上加上方 1 点。',
        example: _example('زَيْت', 'zayt', '油'),
        connectsAfter: false,
        tip: '把 ز 和 ر 结对记忆：外形一样，区别只在上方的点。',
      ),
    ],
  ),
  _group(
    id: 4,
    title: '第四组：齿龈连续组',
    subtitle: '这一组进入更高频的连续字母与常见结构字母。',
    letters: <AlphabetLetter>[
      _letter(
        arabic: 'س',
        name: 'Sin',
        pronunciation: 's',
        phoneme: 's',
        soundHint: '发清楚的 s 音。',
        hint: '像连续的小齿形，没有点。',
        example: _example('سَمَك', 'samak', '鱼'),
        connectsAfter: true,
        tip: '先记住它像一串三齿波浪，再和 ش 比点位差异。',
      ),
      _letter(
        arabic: 'ش',
        name: 'Shin',
        pronunciation: 'sh',
        phoneme: 'sh',
        soundHint: '类似英语 she 里的 sh。',
        hint: '和 س 同形，但上方 3 个点。',
        example: _example('شَمْس', 'shams', '太阳'),
        connectsAfter: true,
        tip: '看到三齿外形时，先看上方有没有 3 个点。',
      ),
      _letter(
        arabic: 'ص',
        name: 'Sad',
        pronunciation: 's (heavy)',
        phoneme: 'ṣ',
        soundHint: '更厚、更靠后的 s 音。',
        hint: '无点，形体比 س 更饱满。',
        example: _example('صَبْر', 'sabr', '耐心'),
        connectsAfter: true,
        tip: '把它当成“厚音版 s”，和 ض 一起记忆最有效。',
      ),
      _letter(
        arabic: 'ض',
        name: 'Dad',
        pronunciation: 'd (heavy)',
        phoneme: 'ḍ',
        soundHint: '更厚、更靠后的 d 音。',
        hint: '在 ص 的基础上加上方 1 点。',
        example: _example('ضَيْف', 'dayf', '客人'),
        connectsAfter: true,
        tip: '先认出“厚音外壳”，再看上方 1 点来区分它和 ص。',
      ),
    ],
  ),
  _group(
    id: 5,
    title: '第五组：厚音与咽音',
    subtitle: '这一组是进阶难点，要重视口腔后部和咽音位置。',
    letters: <AlphabetLetter>[
      _letter(
        arabic: 'ط',
        name: 'Ta',
        pronunciation: 't (heavy)',
        phoneme: 'ṭ',
        soundHint: '比普通 t 更厚、更靠后。',
        hint: '无点，外形比 د 更饱满。',
        example: _example('طَعَام', 'taam', '食物'),
        connectsAfter: true,
        tip: '把它当成“厚音版 t”，不要和普通 ت 混在一起。',
      ),
      _letter(
        arabic: 'ظ',
        name: 'Za',
        pronunciation: 'z (heavy)',
        phoneme: 'ẓ',
        soundHint: '比普通 z / dh 更厚。',
        hint: '在 ط 的基础上加上方 1 点。',
        example: _example('ظَرْف', 'zarf', '信封'),
        connectsAfter: true,
        tip: '先记住它和 ط 是一对，再靠上方 1 点区分。',
      ),
      _letter(
        arabic: 'ع',
        name: 'Ayn',
        pronunciation: 'ʿ',
        phoneme: 'ʿ',
        soundHint: '咽部发音，初学先建立听感和形感。',
        hint: '像开口的弯形，没有点。',
        example: _example('عَيْن', 'ayn', '眼睛'),
        connectsAfter: true,
        tip: 'Ayn 是很多初学者的难点，先会认字形，再慢慢训练口腔位置。',
      ),
      _letter(
        arabic: 'غ',
        name: 'Ghayn',
        pronunciation: 'gh',
        phoneme: 'gh',
        soundHint: '带摩擦感的 gh 音。',
        hint: '在 ع 的基础上加上方 1 点。',
        example: _example('غُرْفَة', 'ghurfa', '房间'),
        connectsAfter: true,
        tip: '把 غ 和 ع 放在一起练，看清“有没有上方 1 点”。',
      ),
    ],
  ),
  _group(
    id: 6,
    title: '第六组：常用口腔字母',
    subtitle: '进入大量高频单词中会出现的常用字母。',
    letters: <AlphabetLetter>[
      _letter(
        arabic: 'ف',
        name: 'Fa',
        pronunciation: 'f',
        phoneme: 'f',
        soundHint: '上齿轻触下唇，发 f 音。',
        hint: '上方 1 个点。',
        example: _example('فَم', 'fam', '嘴'),
        connectsAfter: true,
        tip: '把 ف 和 ق 放一起看，区别重点在点数。',
      ),
      _letter(
        arabic: 'ق',
        name: 'Qaf',
        pronunciation: 'q',
        phoneme: 'q',
        soundHint: '比 k 更靠后，带更明显的后部阻塞感。',
        hint: '上方 2 个点。',
        example: _example('قَلَم', 'qalam', '笔'),
        connectsAfter: true,
        tip: '看到与 ف 接近的形体时，先数上方的点。',
      ),
      _letter(
        arabic: 'ك',
        name: 'Kaf',
        pronunciation: 'k',
        phoneme: 'k',
        soundHint: '发清楚的 k 音。',
        hint: '常见于很多基础词，连写后要特别注意中间形。',
        example: _example('كِتَاب', 'kitab', '书'),
        connectsAfter: true,
        tip: 'Kaf 是高频字母，读词时要尽快熟悉它在词中的不同形态。',
      ),
      _letter(
        arabic: 'ل',
        name: 'Lam',
        pronunciation: 'l',
        phoneme: 'l',
        soundHint: '舌尖上抬，发 l 音。',
        hint: '细长且很常见，常和 ا 组合出现。',
        example: _example('لَيْمُون', 'laymun', '柠檬'),
        connectsAfter: true,
        tip: 'Lam 连写非常频繁，尤其要观察它与后字母的过渡。',
      ),
    ],
  ),
  _group(
    id: 7,
    title: '第七组：高频收尾字母',
    subtitle: '最后这一组覆盖最常见的鼻音、唇音和半元音。',
    letters: <AlphabetLetter>[
      _letter(
        arabic: 'م',
        name: 'Mim',
        pronunciation: 'm',
        phoneme: 'm',
        soundHint: '闭唇发 m 音。',
        hint: '外形饱满，常见于词中和词尾。',
        example: _example('مَاء', 'maa', '水'),
        connectsAfter: true,
        tip: 'Mim 是高频字母，先把独立形和词尾形认熟。',
      ),
      _letter(
        arabic: 'ن',
        name: 'Nun',
        pronunciation: 'n',
        phoneme: 'n',
        soundHint: '发清楚的 n 音。',
        hint: '上方 1 个点。',
        example: _example('نُور', 'nur', '光'),
        connectsAfter: true,
        tip: '和 ب、ت、ث 系列不同，Nun 的点在上方且主体更高。',
      ),
      _letter(
        arabic: 'ه',
        name: 'Ha',
        pronunciation: 'h',
        phoneme: 'h',
        soundHint: '普通的轻 h 音。',
        hint: '不要和深音 ح 混淆。',
        example: _example('هَدِيَّة', 'hadiyya', '礼物'),
        connectsAfter: true,
        tip: '把 ه 和 ح 分开记：一个是轻 h，一个是更深的喉音。',
      ),
      _letter(
        arabic: 'و',
        name: 'Waw',
        pronunciation: 'w / uu',
        phoneme: 'w',
        soundHint: '既可作辅音 w，也常承担合口长音符中的长音 uu。',
        hint: '圆润的小弯形，不向后连接。',
        example: _example('وَرْد', 'ward', '玫瑰'),
        connectsAfter: false,
        tip: 'Waw 和 Alif 一样不向后连写，阅读时很容易形成断开点。',
      ),
      _letter(
        arabic: 'ي',
        name: 'Ya',
        pronunciation: 'y / ii',
        phoneme: 'y',
        soundHint: '既可作辅音 y，也常承担齐齿长音符中的长音 ii。',
        hint: '下方 2 个点，词尾形很常见。',
        example: _example('يَد', 'yad', '手'),
        connectsAfter: true,
        tip: 'Ya 在词尾经常出现，既要认点位，也要认最终形态。',
      ),
    ],
  ),
];

List<AlphabetLetter> get sampleAlphabetLetters => sampleAlphabetGroups
    .expand((group) => group.letters)
    .toList(growable: false);

Map<String, List<QuizQuestion>> buildSampleAlphabetQuizData() {
  final letters = sampleAlphabetLetters;

  return <String, List<QuizQuestion>>{
    'recognition': _buildRecognitionQuestions(letters),
    'compare': _buildCompareQuestions(),
    'sound': _buildSoundQuestions(letters),
    'pronunciation': _buildPronunciationQuestions(letters),
  };
}

List<QuizQuestion> _buildRecognitionQuestions(List<AlphabetLetter> letters) {
  final names = letters.map((item) => item.name).toList(growable: false);
  final arabic = letters.map((item) => item.arabic).toList(growable: false);
  final questions = <QuizQuestion>[];

  for (var index = 0; index < letters.length; index++) {
    final letter = letters[index];

    if (index.isEven) {
      questions.add(
        QuizQuestion(
          title: '这个字母叫什么？',
          prompt: letter.arabic,
          promptType: 'arabic',
          correct: letter.name,
          options: _rotatingOptions(
            pool: names,
            correct: letter.name,
            index: index,
          ),
        ),
      );
    } else {
      questions.add(
        QuizQuestion(
          title: '请选择对应的阿语字母',
          prompt: letter.name,
          promptType: 'name',
          correct: letter.arabic,
          options: _rotatingOptions(
            pool: arabic,
            correct: letter.arabic,
            index: index,
          ),
        ),
      );
    }
  }

  return questions;
}

List<QuizQuestion> _buildSoundQuestions(List<AlphabetLetter> letters) {
  final sounds = letters.map((item) => item.phoneme).toList(growable: false);
  final arabic = letters.map((item) => item.arabic).toList(growable: false);
  final questions = <QuizQuestion>[];

  for (var index = 0; index < letters.length; index++) {
    final letter = letters[index];

    if (index.isEven) {
      questions.add(
        QuizQuestion(
          title: '听字母发音，选择正确的基础音值',
          prompt: letter.arabic,
          promptType: 'letter_audio',
          correct: letter.phoneme,
          options: _rotatingOptions(
            pool: sounds,
            correct: letter.phoneme,
            index: index,
          ),
        ),
      );
    } else {
      questions.add(
        QuizQuestion(
          title: '听字母发音，选择对应的字母',
          prompt: letter.arabic,
          promptType: 'letter_audio',
          correct: letter.arabic,
          options: _rotatingOptions(
            pool: arabic,
            correct: letter.arabic,
            index: index,
          ),
        ),
      );
    }
  }

  return questions;
}

List<QuizQuestion> _buildPronunciationQuestions(List<AlphabetLetter> letters) {
  const focusIndices = <int>[1, 4, 7, 12];
  final latinPool = letters
      .expand(
        (letter) => letter.pronunciations.map((item) => item.transliteration),
      )
      .toSet()
      .toList(growable: false);
  final labelPool = letters
      .expand((letter) => letter.pronunciations.map((item) => item.fullTitle))
      .toSet()
      .toList(growable: false);
  final questions = <QuizQuestion>[];

  for (var index = 0; index < letters.length; index++) {
    final letter = letters[index];
    final item =
        letter.pronunciations[focusIndices[index % focusIndices.length]];

    if (index.isEven) {
      questions.add(
        QuizQuestion(
          title: '听读音形式，选择正确的转写',
          prompt: item.form,
          promptType: 'pronunciation_audio',
          correct: item.transliteration,
          options: _rotatingOptions(
            pool: latinPool,
            correct: item.transliteration,
            index: index,
          ),
        ),
      );
    } else {
      questions.add(
        QuizQuestion(
          title: '听读音形式，选择正确的类别',
          prompt: item.form,
          promptType: 'pronunciation_audio',
          correct: item.fullTitle,
          options: _rotatingOptions(
            pool: labelPool,
            correct: item.fullTitle,
            index: index,
          ),
        ),
      );
    }
  }

  return questions;
}

List<QuizQuestion> _buildCompareQuestions() {
  const families = <Map<String, Object>>[
    <String, Object>{
      'prompt': '下方 1 个点',
      'correct': 'ب',
      'options': <String>['ب', 'ت', 'ث'],
    },
    <String, Object>{
      'prompt': '上方 2 个点',
      'correct': 'ت',
      'options': <String>['ب', 'ت', 'ث'],
    },
    <String, Object>{
      'prompt': '上方 3 个点',
      'correct': 'ث',
      'options': <String>['ب', 'ت', 'ث'],
    },
    <String, Object>{
      'prompt': '下方 1 个点',
      'correct': 'ج',
      'options': <String>['ج', 'ح', 'خ'],
    },
    <String, Object>{
      'prompt': '没有点',
      'correct': 'ح',
      'options': <String>['ج', 'ح', 'خ'],
    },
    <String, Object>{
      'prompt': '上方 1 个点',
      'correct': 'خ',
      'options': <String>['ج', 'ح', 'خ'],
    },
    <String, Object>{
      'prompt': '无点，且通常不向后连写',
      'correct': 'د',
      'options': <String>['د', 'ذ'],
    },
    <String, Object>{
      'prompt': '在 د 的基础上加上方 1 点',
      'correct': 'ذ',
      'options': <String>['د', 'ذ'],
    },
    <String, Object>{
      'prompt': '无点，且通常不向后连写',
      'correct': 'ر',
      'options': <String>['ر', 'ز'],
    },
    <String, Object>{
      'prompt': '在 ر 的基础上加上方 1 点',
      'correct': 'ز',
      'options': <String>['ر', 'ز'],
    },
    <String, Object>{
      'prompt': '像三齿形，没有点',
      'correct': 'س',
      'options': <String>['س', 'ش'],
    },
    <String, Object>{
      'prompt': '像三齿形，上方 3 个点',
      'correct': 'ش',
      'options': <String>['س', 'ش'],
    },
    <String, Object>{
      'prompt': '厚音外形，没有点',
      'correct': 'ص',
      'options': <String>['ص', 'ض'],
    },
    <String, Object>{
      'prompt': '厚音外形，上方 1 个点',
      'correct': 'ض',
      'options': <String>['ص', 'ض'],
    },
    <String, Object>{
      'prompt': '厚音外形，没有点',
      'correct': 'ط',
      'options': <String>['ط', 'ظ'],
    },
    <String, Object>{
      'prompt': '厚音外形，上方 1 个点',
      'correct': 'ظ',
      'options': <String>['ط', 'ظ'],
    },
    <String, Object>{
      'prompt': '开口弯形，没有点',
      'correct': 'ع',
      'options': <String>['ع', 'غ'],
    },
    <String, Object>{
      'prompt': '在 ع 的基础上加上方 1 点',
      'correct': 'غ',
      'options': <String>['ع', 'غ'],
    },
    <String, Object>{
      'prompt': '上方 1 个点',
      'correct': 'ف',
      'options': <String>['ف', 'ق'],
    },
    <String, Object>{
      'prompt': '上方 2 个点',
      'correct': 'ق',
      'options': <String>['ف', 'ق'],
    },
  ];

  return families
      .map(
        (item) => QuizQuestion(
          title: '根据提示选字母',
          prompt: item['prompt']! as String,
          promptType: 'hint',
          correct: item['correct']! as String,
          options: item['options']! as List<String>,
        ),
      )
      .toList(growable: false);
}

List<String> _rotatingOptions({
  required List<String> pool,
  required String correct,
  required int index,
}) {
  final unique = <String>{correct};
  var offset = 1;

  while (unique.length < 4 && offset < pool.length + 4) {
    unique.add(pool[(index + offset) % pool.length]);
    offset++;
  }

  return unique.toList(growable: false);
}
