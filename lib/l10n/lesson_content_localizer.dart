import '../models/app_settings.dart';

class LessonContentLocalizer {
  LessonContentLocalizer._();

  static String meaning(
    String value,
    ContentLanguage language,
  ) {
    if (language != ContentLanguage.en) return value;
    return _translate(value);
  }

  static String ui(
    String value,
    AppLanguage language,
  ) {
    if (language != AppLanguage.en) return value;
    return _translate(value);
  }

  static String maybeTranslate(
    String value, {
    required bool english,
  }) {
    if (!english) return value;
    return _translate(value);
  }

  static String _translate(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return raw;

    final exact = _exact[value];
    if (exact != null) {
      return exact;
    }

    final quotedMeaning = RegExp(r'^“(.+)” 的意思是？$').firstMatch(value);
    if (quotedMeaning != null) {
      return 'What does “${quotedMeaning.group(1)}” mean?';
    }

    final quotedClosest =
        RegExp(r'^“(.+)” 最接近的中文意思是？$').firstMatch(value);
    if (quotedClosest != null) {
      return 'Which meaning is closest to “${quotedClosest.group(1)}”?';
    }

    final quotedMeaningMatch =
        RegExp(r'^“(.+)” 对应的中文是？$').firstMatch(value);
    if (quotedMeaningMatch != null) {
      return 'Which English meaning matches “${quotedMeaningMatch.group(1)}”?';
    }

    final pluralMatch = RegExp(r'^“(.+)” 的复数形式是？$').firstMatch(value);
    if (pluralMatch != null) {
      return 'What is the plural form of “${pluralMatch.group(1)}”?';
    }

    final feminineMatch =
        RegExp(r'^“(.+)” 的阴性形式是？$').firstMatch(value);
    if (feminineMatch != null) {
      return 'What is the feminine form of “${feminineMatch.group(1)}”?';
    }

    final masculineMatch =
        RegExp(r'^“(.+)” 的对应阳性形式是？$').firstMatch(value);
    if (masculineMatch != null) {
      return 'What is the masculine counterpart of “${masculineMatch.group(1)}”?';
    }

    final typeMatch = RegExp(r'^“(.+)” 属于哪类词？$').firstMatch(value);
    if (typeMatch != null) {
      return 'Which type of word is “${typeMatch.group(1)}”?';
    }

    final infoMatch = RegExp(r'^“(.+)” 属于什么信息？$').firstMatch(value);
    if (infoMatch != null) {
      return 'What kind of information does “${infoMatch.group(1)}” express?';
    }

    final describeMatch = RegExp(r'^“(.+)” 最合适描述什么？$').firstMatch(value);
    if (describeMatch != null) {
      return 'What does “${describeMatch.group(1)}” describe best?';
    }

    final saySentenceMatch =
        RegExp(r'^想表达“(.+)”，应选哪一句？$').firstMatch(value);
    if (saySentenceMatch != null) {
      return 'Which sentence says “${_translate(saySentenceMatch.group(1)!)}”?';
    }

    final sayWordMatch =
        RegExp(r'^想说“(.+)”，关键的阿语词是？$').firstMatch(value);
    if (sayWordMatch != null) {
      return 'Which Arabic word do you need to say “${_translate(sayWordMatch.group(1)!)}”?';
    }

    final askMatch = RegExp(r'^想问“(.+)”，最直接的说法是？$').firstMatch(value);
    if (askMatch != null) {
      return 'Which is the most direct way to ask “${_translate(askMatch.group(1)!)}”?';
    }

    if (value.contains('\n')) {
      return value
          .split('\n')
          .map((line) => _translate(line))
          .join('\n');
    }

    return raw;
  }
}

const Map<String, String> _exact = <String, String>{
  '你好': 'Hello',
  '早上好': 'Good morning',
  '谢谢': 'Thank you',
  '再见': 'Goodbye',
  '老师': 'Teacher',
  '我很好，谢谢。': 'I am fine, thank you.',
  '你好，你好吗？': 'Hello, how are you?',
  '你好吗？': 'How are you?',
  '你叫什么名字？': 'What is your name?',
  '你来自哪里？': 'Where are you from?',
  '你是学生吗？': 'Are you a student?',
  '结束对话时更自然的表达是？': 'Which expression feels natural to close the dialogue?',
  '我': 'I',
  '我的名字是': 'My name is',
  '男学生': 'male student',
  '来自': 'from',
  '我叫李。': 'My name is Li.',
  '我是来自中国的学生。': 'I am a student from China.',
  '你来自哪个国家？': 'Which country are you from?',
  '中国人（男）': 'Chinese (masculine)',
  '中国人（女）': 'Chinese (feminine)',
  '阿拉伯语 / 阿拉伯的': 'Arabic / Arab',
  '语言': 'language',
  '国家 / 地方': 'country / place',
  '职业': 'profession',
  '工程师': 'engineer',
  '男老师': 'male teacher',
  '名词': 'noun',
  '形容词': 'adjective',
  '代词': 'pronoun',
  '动词': 'verb',
  '介词': 'preposition',
  '方位词': 'location word',
  '数词': 'number',
  '固定表达': 'fixed expression',
  '虚词': 'particle',
  '疑问词': 'question word',
  '句型': 'pattern',
  '阅读': 'reading',
  '书': 'book',
  '笔': 'pen',
  '黑板': 'board',
  '椅子': 'chair',
  '请读一下。': 'Please read it.',
  '我不明白。': 'I do not understand.',
  '请重复一下。': 'Please repeat it.',
  '这是一本书。': 'This is a book.',
  '这是一支笔。': 'This is a pen.',
  '这是一块黑板。': 'This is a board.',
  '本子': 'notebook',
  '本子在哪里？': 'Where is the notebook?',
  '本子在桌子上。': 'The notebook is on the table.',
  '门': 'door',
  '房间': 'room',
  '房子 / 家': 'house / home',
  '在……上面': 'above / on',
  '在……里面': 'inside',
  '在……前面': 'in front of',
  '在……后面': 'behind',
  '门在哪里？': 'Where is the door?',
  '这是我的家。': 'This is my home.',
  '房间在哪里？': 'Where is the room?',
  '房间在厨房上面。': 'The room is above the kitchen.',
  '门在楼梯旁边。': 'The door is beside the stairs.',
  '天气与衣着': 'Weather and Clothing',
  '热的（男）': 'hot (masculine)',
  '冷的（男）': 'cold (masculine)',
  '外套': 'coat',
  '衬衫': 'shirt',
  '今天天气热。': 'The weather is hot today.',
  '我穿外套。': 'I wear a coat.',
  '这件衬衫很好看。': 'This shirt looks nice.',
  '今天天气怎么样？': 'How is the weather today?',
  '你冬天穿什么？': 'What do you wear in winter?',
  '数字与年龄': 'Numbers and Age',
  '年 / 岁': 'year / age',
  '一': 'one',
  '二': 'two',
  '三': 'three',
  '昨天': 'yesterday',
  '今天': 'today',
  '明天': 'tomorrow',
  '小时 / 点钟': 'hour / o’clock',
  '预约 / 约定': 'appointment',
  '我二十岁。': 'I am twenty years old.',
  '我弟弟十岁。': 'My younger brother is ten years old.',
  '今天是星期一。': 'Today is Monday.',
  '我的预约在三点。': 'My appointment is at three.',
  '一天作息': 'Daily Routine',
  '我起床': 'I wake up',
  '我学习': 'I study',
  '我工作': 'I work',
  '我睡觉': 'I sleep',
  '我七点起床。': 'I wake up at seven.',
  '我晚上学阿语。': 'I study Arabic at night.',
  '然后我吃早餐。': 'Then I eat breakfast.',
  '然后我早睡。': 'Then I go to bed early.',
  '吃喝与点餐': 'Food and Ordering',
  '面包': 'bread',
  '水': 'water',
  '咖啡': 'coffee',
  '一餐 / 餐食': 'meal',
  '我要水和咖啡。': 'I want water and coffee.',
  '请买单。': 'Please bring the bill.',
  '价格': 'price',
  '市场': 'market',
  '便宜的（男）': 'cheap (masculine)',
  '贵的（男）': 'expensive (masculine)',
  '多少钱？': 'How much is it?',
  '这支笔很便宜。': 'This pen is cheap.',
  '这个包很贵。': 'This bag is expensive.',
  '这个价格合适。': 'This price is suitable.',
  '这个价格不合适。': 'This price is not suitable.',
  '家庭成员': 'Family Members',
  '父亲': 'father',
  '母亲': 'mother',
  '兄弟': 'brother',
  '姐妹': 'sister',
  '这是我爸爸。': 'This is my father.',
  '这是我妈妈。': 'This is my mother.',
  '我有一个兄弟和一个姐妹。': 'I have one brother and one sister.',
  '自我介绍': 'Self-introduction',
  '问候与基础表达': 'Greetings and Essential Expressions',
  '课堂与学习用语': 'Classroom Arabic',
  '教室里的物品': 'Things in the Classroom',
  '人物与身份': 'People and Identity',
  '国籍与语言': 'Nationalities and Languages',
  '外貌与性格': 'Appearance and Personality',
  '时间与日期': 'Time and Dates',
  '购物与价格': 'Shopping and Prices',
  '问路与交通': 'Directions and Transportation',
  '在家与方位': 'Home and Position',
  '女医生': 'female doctor',
  '漂亮的 / 美的（男）': 'beautiful (masculine)',
  '高的（男）': 'tall (masculine)',
  '安静的（男）': 'quiet (masculine)',
  '他很安静。': 'He is quiet.',
  '她很漂亮。': 'She is beautiful.',
  '我哥哥很高。': 'My brother is tall.',
  '我姐姐很漂亮。': 'My sister is beautiful.',
  '我姐姐很小。': 'My sister is small.',
  '我妈妈是老师。': 'My mother is a teacher.',
  '我妈妈是工程师。': 'My mother is an engineer.',
  '我爸爸是工程师。': 'My father is an engineer.',
  '我爸爸是老师。': 'My father is a teacher.',
  '我妈妈是女医生。': 'My mother is a doctor.',
  '我妈妈是学生。': 'My mother is a student.',
  '你爸爸做什么工作？': 'What does your father do?',
  '你的职业是什么？': 'What is your job?',
  '你学什么语言？': 'What language do you study?',
  '你的语言是什么？': 'What is your language?',
  '我是中国人。': 'I am Chinese.',
  '我是学生。': 'I am a student.',
  '我是老师。': 'I am a teacher.',
  '我来自中国。': 'I am from China.',
  '我在学习阿拉伯语。': 'I am learning Arabic.',
  '我今天学习。': 'I study today.',
  '我每天三点起床。': 'I wake up at three every day.',
  '然后我去学校。': 'Then I go to school.',
  '然后我回家。': 'Then I go home.',
  '然后我坐车。': 'Then I ride.',
  '然后向左走。': 'Then walk to the left.',
  '然后向右走。': 'Then walk to the right.',
  '车站': 'station',
  '右边': 'right side',
  '左边': 'left side',
  '街道': 'street',
  '车站在哪里？': 'Where is the station?',
  '车站在右边。': 'The station is on the right.',
  '车站在左边。': 'The station is on the left.',
  '然后呢？': 'And then?',
  '这条路对吗？': 'Is this the right way?',
  '今天天气冷。': 'The weather is cold today.',
  '我冬天穿外套。': 'I wear a coat in winter.',
  '我穿衬衫。': 'I wear a shirt.',
  '今天风很大。': 'It is windy today.',
  '褪写': 'Plain Arabic',
  '单数': 'singular',
  '复数': 'plural',
  '阴性': 'feminine',
  '阳性': 'masculine',
  '规律提示': 'Pattern Note',
  '例句': 'Example',
  '学习提示': 'Learning Note',
  '理解选择': 'Comprehension Check',
  '听音辨义': 'Listen and Choose the Meaning',
  '听音辨词': 'Listen and Choose the Word',
  '听写单词': 'Word Dictation',
  '听音辨字': 'Listen and Choose the Letter',
  '听写字母': 'Letter Dictation',
  '词形配对': 'Morphology Match',
  '单复数配对': 'Singular and Plural Match',
  '例句选形': 'Choose the Form in Context',
  '听音后选出对应字母': 'Listen and choose the matching letter.',
  '根据声音写出听到的字母': 'Write the letter you hear.',
  '先听，再用下方字母板完成输入。': 'Listen first, then use the letter bank below.',
  '听音后选择最接近的中文意思': 'Listen and choose the closest meaning.',
  '先听完整句子，再判断它对应的中文意思。': 'Listen to the full sentence first, then choose its meaning.',
  '听音后选择对应单词': 'Listen and choose the matching word.',
  '本题考察声音和词形的对应。': 'This checks the connection between sound and word form.',
  '根据声音写出听到的单词': 'Write the word you hear.',
  '先听，再用字母板拼出完整单词。': 'Listen first, then build the full word with the letter bank.',
  '先判断词的性，再选择对应词形。': 'Identify the gender first, then choose the matching form.',
  '高频可数词建议把单数和复数一起记。': 'High-frequency countable words are easier to remember in singular and plural pairs.',
  '根据例句选择正确词形': 'Choose the correct form from the sentence.',
  '你的答案': 'Your Answer',
  '点击下方字母开始输入': 'Tap a letter below to start typing',
  '回答正确': 'Correct Answer',
  '正确答案': 'Correct Form',
  '退格': 'Backspace',
  '清空': 'Clear',
  '播放音频': 'Play Audio',
  '提交答案': 'Submit Answer',
  '完成练习': 'Finish Practice',
  '当前课程还没有可用练习。': 'This lesson has no practice items yet.',
  '第 {index} / {total} 题': 'Question {index} / {total}',
  '单词聚焦': 'Word Focus',
  '句型聚焦': 'Pattern Focus',
  '对话聚焦': 'Dialogue Focus',
  '已加入单词本': 'Saved to Wordbook',
  '先掌握最常用的阿语问候语': 'Learn the most common Arabic greetings first',
  '能自然回应“你好吗”': 'Respond naturally to “How are you?”',
  '完成第一次最短阿语对话': 'Complete your first short Arabic dialogue',
  '会说自己的名字': 'Say your own name',
  '会用“我来自……”做最短介绍': 'Use “I am from…” for a brief introduction',
  '初步认识学生类名词的阴阳与复数': 'Start noticing gender and plural forms in student-related nouns',
  '听懂最常见的课堂指令': 'Understand the most common classroom instructions',
  '会表达“我不明白 / 请重复”': 'Say “I do not understand / Please repeat”',
  '让课堂阿语立刻有用起来': 'Make classroom Arabic useful right away',
  '认识教室中最常见的物品词': 'Recognize the most common classroom objects',
  '会问“这是什么 / 在哪里”': 'Ask “What is this?” and “Where is it?”',
  '开始区分 هذا 和 هذه': 'Start distinguishing هذا and هذه',
  '会介绍最常见的家庭成员': 'Introduce the most common family members',
  '能说“这是我爸爸 / 妈妈”': 'Say “This is my father / mother”',
  '开始接触简单所属表达': 'Start using simple possession expressions',
  '会介绍常见职业': 'Introduce common professions',
  '掌握职业类名词常见阴性形式': 'Learn common feminine forms of profession nouns',
  '能听懂“你做什么工作”这类问题': 'Understand questions like “What do you do?”',
  '会说自己的国籍和使用的语言': 'Talk about your nationality and the language you use',
  '认识形容国籍的阴阳形式': 'Recognize gender forms of nationality adjectives',
  '能问“你来自哪个国家”': 'Ask “Which country are you from?”',
  '会描述一个人的简单外貌': 'Describe a person’s basic appearance',
  '认识形容词的阴阳配合': 'Recognize adjective agreement in gender',
  '会说“他很安静 / 她很漂亮”': 'Say “He is quiet / She is beautiful”',
  '掌握最基础的数字表达': 'Master the most basic number expressions',
  '会说自己的年龄': 'Say your age',
  '开始接触“年”的单复数变化': 'Start noticing singular and plural forms of “year”',
  '会描述自己一天中的基本活动': 'Describe the basic activities in your day',
  '熟悉“我……”的现在时高频动词': 'Get used to high-frequency present-tense verbs with “I …”',
  '能说出简单的学习安排': 'Describe a simple study routine',
  '会说今天、明天和具体时间': 'Say today, tomorrow, and specific times',
  '熟悉“小时”和“预约”的表达': 'Get familiar with expressions for “hour” and “appointment”',
  '为后续生活场景建立时间框架': 'Build a time framework for later daily-life situations',
  '会说最基本的吃喝需求': 'Express the most basic food and drink needs',
  '能在简单点餐场景里开口': 'Speak up in a simple ordering situation',
  '继续熟悉高频生活名词': 'Keep getting familiar with high-frequency daily nouns',
  '会说家里常见空间': 'Name common spaces at home',
  '掌握最基础的位置表达': 'Learn the most basic location expressions',
  '能问门、房间在哪里': 'Ask where the door or room is',
  '会问价格': 'Ask about the price',
  '会说东西便宜或贵': 'Say whether something is cheap or expensive',
  '继续熟悉形容词与名词配合': 'Keep getting familiar with adjective and noun agreement',
  '会问路': 'Ask for directions',
  '会说右边、左边、车站': 'Say right, left, and station',
  '能理解最短的路线说明': 'Understand very short route instructions',
  '会描述天气冷热': 'Describe hot and cold weather',
  '会说简单穿着': 'Talk about simple clothing',
  '继续观察形容词与名词的配合': 'Continue observing adjective and noun agreement',
  '带音符': 'With Diacritics',
  '去音符': 'Plain Form',
  '阴性形式': 'Feminine Form',
  '阳性形式': 'Masculine Form',
  '复数形式': 'Plural Form',
  '收起学习补充': 'Hide Extra Notes',
  '展开学习补充': 'Show Extra Notes',
  '播放语音': 'Play Audio',
};
