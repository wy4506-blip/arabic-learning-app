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
  final String form;
  final String latin;
  final String label;
  final String hint;

  AlphabetPronunciationItem({
    required this.form,
    required this.latin,
    required this.label,
    required this.hint,
  });

  factory AlphabetPronunciationItem.fromJson(Map<String, dynamic> json) {
    return AlphabetPronunciationItem(
      form: json['form'] as String,
      latin: json['latin'] as String,
      label: json['label'] as String,
      hint: json['hint'] as String,
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
  final String pronunciation;
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
    required this.pronunciation,
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
      pronunciation: json['pronunciation'] as String,
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
