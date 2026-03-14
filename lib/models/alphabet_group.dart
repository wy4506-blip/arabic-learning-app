class AlphabetExample {
  final String arabic;
  final String latin;
  final String meaning;

  AlphabetExample({
    required this.arabic,
    required this.latin,
    required this.meaning,
  });

  factory AlphabetExample.fromJson(Map<String, dynamic> json) {
    return AlphabetExample(
      arabic: json['arabic'] as String,
      latin: json['latin'] as String,
      meaning: json['meaning'] as String,
    );
  }
}

class AlphabetPronunciationItem {
  final String id;
  final String key;
  final String shortTitle;
  final String fullTitle;
  final String arabicSymbol;
  final String transliteration;
  final String ipa;
  final String pronunciationValue;
  final String shortSubtitle;
  final String detailDescription;
  final String examplePattern;
  final String audioKey;
  final int sortOrder;
  final String form;
  final String audioQueryText;

  AlphabetPronunciationItem({
    required this.id,
    required this.key,
    required this.shortTitle,
    required this.fullTitle,
    required this.arabicSymbol,
    required this.transliteration,
    required this.ipa,
    required this.pronunciationValue,
    required this.shortSubtitle,
    required this.detailDescription,
    required this.examplePattern,
    required this.audioKey,
    required this.sortOrder,
    required this.form,
    required this.audioQueryText,
  });

  factory AlphabetPronunciationItem.fromJson(Map<String, dynamic> json) {
    return AlphabetPronunciationItem(
      id: json['id'] as String? ?? json['key'] as String? ?? '',
      key: json['key'] as String? ?? '',
      shortTitle: json['shortTitle'] as String? ?? json['label'] as String? ?? '',
      fullTitle: json['fullTitle'] as String? ?? json['label'] as String? ?? '',
      arabicSymbol: json['arabicSymbol'] as String? ?? '',
      transliteration: json['transliteration'] as String? ?? json['latin'] as String? ?? '',
      ipa: json['ipa'] as String? ?? '',
      pronunciationValue: json['pronunciationValue'] as String? ?? json['latin'] as String? ?? '',
      shortSubtitle: json['shortSubtitle'] as String? ?? '',
      detailDescription: json['detailDescription'] as String? ?? json['hint'] as String? ?? '',
      examplePattern: json['examplePattern'] as String? ?? '',
      audioKey: json['audioKey'] as String? ?? json['key'] as String? ?? '',
      sortOrder: json['sortOrder'] as int? ?? 0,
      form: json['form'] as String,
      audioQueryText: json['audioQueryText'] as String? ?? json['form'] as String? ?? '',
    );
  }
}

class AlphabetForms {
  final String isolated;
  final String initial;
  final String medial;
  final String finalForm;

  AlphabetForms({
    required this.isolated,
    required this.initial,
    required this.medial,
    required this.finalForm,
  });

  factory AlphabetForms.fromJson(Map<String, dynamic> json) {
    return AlphabetForms(
      isolated: json['isolated'] as String,
      initial: json['initial'] as String,
      medial: json['medial'] as String,
      finalForm: json['final'] as String,
    );
  }
}

class AlphabetLetter {
  final String arabic;
  final String name;
  final String arabicName;
  final String latinName;
  final String pronunciation;
  final String phoneme;
  final String soundHint;
  final String hint;
  final AlphabetExample example;
  final List<AlphabetPronunciationItem> pronunciations;
  final AlphabetForms forms;
  final bool connectsAfter;
  final String tip;

  AlphabetLetter({
    required this.arabic,
    required this.name,
    required this.arabicName,
    required this.latinName,
    required this.pronunciation,
    required this.phoneme,
    required this.soundHint,
    required this.hint,
    required this.example,
    required this.pronunciations,
    required this.forms,
    required this.connectsAfter,
    required this.tip,
  });

  factory AlphabetLetter.fromJson(Map<String, dynamic> json) {
    return AlphabetLetter(
      arabic: json['arabic'] as String,
      name: json['name'] as String,
      arabicName: (json['arabicName'] ?? json['arabic']) as String,
      latinName:
          (json['latinName'] ?? json['name'] ?? json['pronunciation']) as String,
      pronunciation: json['pronunciation'] as String,
      phoneme: (json['phoneme'] ?? json['pronunciation']) as String,
      soundHint: json['soundHint'] as String,
      hint: json['hint'] as String,
      example: AlphabetExample.fromJson(
        json['example'] as Map<String, dynamic>,
      ),
      pronunciations: (json['pronunciations'] as List)
          .map(
            (item) => AlphabetPronunciationItem.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      forms: AlphabetForms.fromJson(json['forms'] as Map<String, dynamic>),
      connectsAfter: json['connectsAfter'] as bool,
      tip: json['tip'] as String,
    );
  }

  String get fullNameLabel => '$arabicName · $latinName';
}

class AlphabetGroup {
  final int id;
  final String title;
  final String subtitle;
  final List<AlphabetLetter> letters;

  AlphabetGroup({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.letters,
  });

  factory AlphabetGroup.fromJson(Map<String, dynamic> json) {
    return AlphabetGroup(
      id: json['id'] as int,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      letters: (json['letters'] as List)
          .map((item) => AlphabetLetter.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
