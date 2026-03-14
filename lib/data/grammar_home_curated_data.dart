import 'package:flutter/material.dart';

import '../models/grammar_home_models.dart';
import '../models/grammar_models.dart';

const List<GrammarHomeSearchChip> grammarHomeSearchChips =
    <GrammarHomeSearchChip>[
  GrammarHomeSearchChip(
    labelZh: '否定',
    labelEn: 'Negation',
    queryZh: '不是',
    queryEn: 'negation',
  ),
  GrammarHomeSearchChip(
    labelZh: '人称代词',
    labelEn: 'Pronouns',
    queryZh: '人称代词',
    queryEn: 'pronouns',
  ),
  GrammarHomeSearchChip(
    labelZh: '介词',
    labelEn: 'Prepositions',
    queryZh: '介词',
    queryEn: 'prepositions',
  ),
  GrammarHomeSearchChip(
    labelZh: '数字',
    labelEn: 'Numbers',
    queryZh: '数字',
    queryEn: 'numbers',
  ),
  GrammarHomeSearchChip(
    labelZh: '疑问句',
    labelEn: 'Questions',
    queryZh: '疑问句',
    queryEn: 'questions',
  ),
  GrammarHomeSearchChip(
    labelZh: '词序',
    labelEn: 'Word Order',
    queryZh: '词序',
    queryEn: 'word order',
  ),
];

const List<GrammarHomeShortcut> grammarHomeShortcuts = <GrammarHomeShortcut>[
  GrammarHomeShortcut(
    id: 'shortcut_pronouns',
    labelZh: '我 / 你 / 他',
    labelEn: 'I / You / He',
    icon: Icons.person_outline_rounded,
    quickSectionId: 'personal_pronouns',
  ),
  GrammarHomeShortcut(
    id: 'shortcut_negation',
    labelZh: '是 / 不是',
    labelEn: 'Is / Not',
    icon: Icons.remove_circle_outline_rounded,
    pageId: 'negation',
  ),
  GrammarHomeShortcut(
    id: 'shortcut_prepositions',
    labelZh: '在 / 从 / 到',
    labelEn: 'In / From / To',
    icon: Icons.place_rounded,
    quickSectionId: 'common_prepositions',
  ),
  GrammarHomeShortcut(
    id: 'shortcut_numbers',
    labelZh: '1-10',
    labelEn: '1-10',
    icon: Icons.pin_rounded,
    pageId: 'numbers_basic',
  ),
  GrammarHomeShortcut(
    id: 'shortcut_demonstrative',
    labelZh: '这是什么',
    labelEn: 'What is this',
    icon: Icons.lightbulb_outline_rounded,
    pageId: 'question_sentence',
  ),
  GrammarHomeShortcut(
    id: 'shortcut_question_words',
    labelZh: '怎么提问',
    labelEn: 'Ask Questions',
    icon: Icons.help_outline_rounded,
    quickSectionId: 'question_words',
  ),
];

const List<GrammarHomeCategoryShortcut> grammarHomeCategoryShortcuts =
    <GrammarHomeCategoryShortcut>[
  GrammarHomeCategoryShortcut(
    id: 'category_sentences',
    titleZh: '句子怎么说',
    titleEn: 'Build Sentences',
    subtitleZh: '快速看懂句子怎么开头、怎么提问、怎么否定',
    subtitleEn: 'See how Arabic sentences start, ask, and negate.',
    icon: Icons.view_stream_rounded,
    tintColor: Color(0xFFEAF3FF),
    categoryId: 'grammar_sentences',
  ),
  GrammarHomeCategoryShortcut(
    id: 'category_pronouns',
    titleZh: '人称代词',
    titleEn: 'Pronouns',
    subtitleZh: '先掌握我、你、他、她、我们这些高频形式',
    subtitleEn: 'Start with I, you, he, she, and we.',
    icon: Icons.person_outline_rounded,
    tintColor: Color(0xFFE8F5F0),
    categoryId: 'grammar_pronouns',
  ),
  GrammarHomeCategoryShortcut(
    id: 'category_function_words',
    titleZh: '常用小词',
    titleEn: 'Useful Little Words',
    subtitleZh: '先掌握在、从、到、和这类高频表达',
    subtitleEn: 'Master in, from, to, and with first.',
    icon: Icons.tune_rounded,
    tintColor: Color(0xFFF7EFE4),
    categoryId: 'grammar_function_words',
  ),
  GrammarHomeCategoryShortcut(
    id: 'category_negation',
    titleZh: '否定表达',
    titleEn: 'Negation',
    subtitleZh: '先看不是、没有、不会这些基础说法',
    subtitleEn: 'Quickly learn how to say not, no, and cannot.',
    icon: Icons.block_rounded,
    tintColor: Color(0xFFFBEAEC),
    categoryId: 'grammar_sentences',
  ),
  GrammarHomeCategoryShortcut(
    id: 'category_numbers',
    titleZh: '数字与时间',
    titleEn: 'Numbers & Time',
    subtitleZh: '先抓 1-10 和最常见的数量表达',
    subtitleEn: 'Focus on 1-10 and everyday quantity patterns.',
    icon: Icons.schedule_rounded,
    tintColor: Color(0xFFFFF4DF),
    categoryId: 'grammar_function_words',
  ),
  GrammarHomeCategoryShortcut(
    id: 'category_questions',
    titleZh: '怎么提问',
    titleEn: 'Ask Questions',
    subtitleZh: '不懂术语也能快速找到问句入口',
    subtitleEn: 'Find question patterns without needing grammar terms.',
    icon: Icons.question_answer_rounded,
    tintColor: Color(0xFFF2EEFF),
    categoryId: 'grammar_sentences',
  ),
];

const List<GrammarHomeProblemShortcut> grammarHomeProblemShortcuts =
    <GrammarHomeProblemShortcut>[
  GrammarHomeProblemShortcut(
    id: 'problem_negation',
    questionZh: '如何表达“不是 / 没有”？',
    questionEn: 'How do I say "not / no"?',
    subtitleZh: '先看最常用的否定表达，不用先背完整规则',
    subtitleEn: 'Start with the most useful negation patterns first.',
    pageId: 'negation',
  ),
  GrammarHomeProblemShortcut(
    id: 'problem_word_order',
    questionZh: '句子里先说谁？',
    questionEn: 'What usually comes first in the sentence?',
    subtitleZh: '从最基础的名词句和动词句入手就够了',
    subtitleEn: 'Begin with the simplest nominal and verbal patterns.',
    pageId: 'nominal_sentence',
  ),
  GrammarHomeProblemShortcut(
    id: 'problem_gender',
    questionZh: '这个词怎么区分阴阳性？',
    questionEn: 'How do I tell masculine and feminine forms apart?',
    subtitleZh: '先用职业词和身份词建立成对记忆',
    subtitleEn: 'Use profession and identity words as easy pairs.',
    pageId: 'gender',
  ),
  GrammarHomeProblemShortcut(
    id: 'problem_numbers',
    questionZh: '数字怎么和名词搭配？',
    questionEn: 'How do numbers work with nouns?',
    subtitleZh: '先掌握基础数字，再慢慢看数量形式',
    subtitleEn: 'Learn the core numbers first, then the noun patterns.',
    pageId: 'numbers_basic',
  ),
  GrammarHomeProblemShortcut(
    id: 'problem_prepositions',
    questionZh: '什么时候用这个介词？',
    questionEn: 'When do I use this preposition?',
    subtitleZh: '先记住高频场景：在、从、到、和',
    subtitleEn: 'Start with high-frequency use cases: in, from, to, with.',
    pageId: 'prepositions',
  ),
];

const Map<String, GrammarPageHomeMetadata> grammarPageHomeMetadataById =
    <String, GrammarPageHomeMetadata>{
  'personal_pronouns': GrammarPageHomeMetadata(
    subtitle:
        '先看我、你、他、她这些最常用的人称形式。||Start with the most common people words: I, you, he, and she.',
    keywords: <String>[
      '人称代词',
      '独立代词',
      '我你他',
      'pronoun',
      'personal pronouns',
    ],
    searchAliases: <String>['我', '你', '他', '她', '我们', 'I', 'you', 'he'],
    problemTags: <String>['我该怎么说我和你', '如何说我你他'],
    isFeatured: true,
    isHighFrequency: true,
    updatedAt: '2026-03-13',
  ),
  'demonstratives': GrammarPageHomeMetadata(
    subtitle:
        '先掌握“这个 / 那个”这类最常用的指示表达。||Get comfortable with this / that expressions first.',
    keywords: <String>['指示代词', '这个那个', '这是什么', 'demonstratives'],
    searchAliases: <String>['这个', '那个', '这是什么', 'this', 'that'],
    problemTags: <String>['如何表达这个那个'],
    isFeatured: true,
    isHighFrequency: true,
    updatedAt: '2026-03-13',
  ),
  'question_words': GrammarPageHomeMetadata(
    subtitle:
        '先学谁、什么、哪里、怎么这些高回报问句词。||Learn who, what, where, and how first.',
    keywords: <String>['疑问词', '问句', '谁', '哪里', 'question words'],
    searchAliases: <String>['怎么提问', '谁', '什么', '哪里', '怎样', '多少'],
    problemTags: <String>['怎么提问', '怎么问别人'],
    isFeatured: true,
    isHighFrequency: true,
    updatedAt: '2026-03-13',
  ),
  'gender': GrammarPageHomeMetadata(
    subtitle:
        '先看阳性 / 阴性最直观的成对变化。||See the most visible masculine and feminine pairs first.',
    keywords: <String>['阴阳性', '阳性', '阴性', 'gender', 'feminine'],
    searchAliases: <String>['阴性', '阳性', '男女形式', '词尾ة'],
    problemTags: <String>['如何区分阴阳性'],
    isFeatured: true,
    isHighFrequency: true,
    updatedAt: '2026-03-13',
  ),
  'number_forms': GrammarPageHomeMetadata(
    subtitle:
        '先理解单数、双数、复数最基础的区别。||Understand singular, dual, and plural at a glance.',
    keywords: <String>['单数', '双数', '复数', 'number forms', 'plural'],
    searchAliases: <String>['双数', '复数', '几个', '两个'],
    problemTags: <String>['数量怎么表达'],
    isFeatured: true,
    isHighFrequency: false,
    updatedAt: '2026-03-13',
  ),
  'adjective_agreement': GrammarPageHomeMetadata(
    subtitle:
        '先把“人 + 描述词”这种最常见的搭配看顺。||Get used to the simplest noun + adjective matches first.',
    keywords: <String>['形容词配合', '描述词', 'agreement', 'adjective'],
    searchAliases: <String>['好学生', '描述人', '形容词'],
    problemTags: <String>['描述人时词形怎么跟着变'],
    isFeatured: false,
    isHighFrequency: true,
    updatedAt: '2026-03-13',
  ),
  'past_tense': GrammarPageHomeMetadata(
    subtitle:
        '先认识过去式最基础的说法，不必一开始就背整张表。||Recognize the most basic past-tense forms before memorizing the full table.',
    keywords: <String>['过去式', '过去时', 'past tense', 'verb'],
    searchAliases: <String>['昨天做了', '过去时', '动词过去式'],
    problemTags: <String>['过去发生的动作怎么说'],
    isFeatured: false,
    isHighFrequency: false,
    updatedAt: '2026-03-13',
  ),
  'present_tense': GrammarPageHomeMetadata(
    subtitle:
        '先看现在时里“我 / 他 / 她”最常见的前缀变化。||Start with the most visible present-tense prefixes.',
    keywords: <String>['动词', '现在时', '变位', 'present tense', 'verb'],
    searchAliases: <String>['我学习', '他学习', '动词变化', '现在时'],
    problemTags: <String>['动词怎么开始变'],
    isFeatured: true,
    isHighFrequency: true,
    updatedAt: '2026-03-13',
  ),
  'nominal_sentence': GrammarPageHomeMetadata(
    subtitle:
        '先掌握“我是……”和“这是……”这类最常见的基础句型。||Master the basic "I am..." and "This is..." patterns.',
    keywords: <String>['名词句', '句型', '我是', '这是', 'nominal sentence'],
    searchAliases: <String>['我是', '这是', '句子怎么说', '句子开头'],
    problemTags: <String>['句子里先说谁'],
    isFeatured: true,
    isHighFrequency: true,
    updatedAt: '2026-03-13',
  ),
  'verbal_sentence': GrammarPageHomeMetadata(
    subtitle:
        '看动作句怎么开头，先学最简单的动词句顺序。||See how action sentences begin in the simplest form.',
    keywords: <String>['动词句', '动作句', '句子顺序', 'verbal sentence'],
    searchAliases: <String>['他学习', '我写', '动作句'],
    problemTags: <String>['动作句怎么说'],
    isFeatured: false,
    isHighFrequency: true,
    updatedAt: '2026-03-13',
  ),
  'negation': GrammarPageHomeMetadata(
    subtitle:
        '先看不是、没有、不会这些最常见的否定说法。||Start with the most common forms of not, no, and cannot.',
    keywords: <String>['否定', '不是', '没有', '不会', 'negation'],
    searchAliases: <String>['不是', '没有', '没', '不会', 'not'],
    problemTags: <String>['如何表达否定', '句子怎么否定'],
    isFeatured: true,
    isHighFrequency: true,
    updatedAt: '2026-03-13',
  ),
  'question_sentence': GrammarPageHomeMetadata(
    subtitle:
        '把最常用的疑问句模板先练顺。||Practice the most useful question templates first.',
    keywords: <String>['疑问句', '问句', '怎么问', 'question sentence'],
    searchAliases: <String>['怎么问', '这是什么', '你是学生吗', '从哪里来'],
    problemTags: <String>['如何提问', '这是什么'],
    isFeatured: true,
    isHighFrequency: true,
    updatedAt: '2026-03-13',
  ),
  'common_patterns': GrammarPageHomeMetadata(
    subtitle:
        '用最常见的短句模板加速开口。||Use common short patterns to speak sooner.',
    keywords: <String>['常见句型', '模板', 'patterns'],
    searchAliases: <String>['常用表达', '模板'],
    problemTags: <String>['想先学能直接说的句子'],
    isFeatured: false,
    isHighFrequency: true,
    updatedAt: '2026-03-13',
  ),
  'prepositions': GrammarPageHomeMetadata(
    subtitle:
        '先掌握在、从、到、和等最常见用法。||Master in, from, to, and with first.',
    keywords: <String>['介词', '在', '从', '到', 'preposition'],
    searchAliases: <String>['在', '从', '去', '到', '跟', '和'],
    problemTags: <String>['什么时候用这个介词'],
    isFeatured: true,
    isHighFrequency: true,
    updatedAt: '2026-03-13',
  ),
  'numbers_basic': GrammarPageHomeMetadata(
    subtitle:
        '先把 0-10 和最常见数量表达看熟。||Start by getting comfortable with 0-10 and common quantity phrases.',
    keywords: <String>['数字', '数词', '1到10', 'numbers'],
    searchAliases: <String>['1-10', '一到十', '数字', '数词'],
    problemTags: <String>['数字怎么和名词搭配'],
    isFeatured: true,
    isHighFrequency: true,
    updatedAt: '2026-03-13',
  ),
};

GrammarPageContent enrichGrammarPageContent(GrammarPageContent page) {
  final metadata = grammarPageHomeMetadataById[page.id];
  if (metadata == null) {
    return page;
  }

  return page.copyWith(
    subtitle: metadata.subtitle,
    keywords: metadata.keywords,
    searchAliases: metadata.searchAliases,
    problemTags: metadata.problemTags,
    isFeatured: metadata.isFeatured,
    isHighFrequency: metadata.isHighFrequency,
    updatedAt: metadata.updatedAt,
  );
}
