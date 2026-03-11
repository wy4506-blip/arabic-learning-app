class WordItem {
  final String arabic;
  final String pronunciation;
  final String meaning;

  WordItem({
    required this.arabic,
    required this.pronunciation,
    required this.meaning,
  });

  Map<String, dynamic> toJson() {
    return {
      'arabic': arabic,
      'pronunciation': pronunciation,
      'meaning': meaning,
    };
  }

  factory WordItem.fromJson(Map<String, dynamic> json) {
    return WordItem(
      arabic: json['arabic'] as String,
      pronunciation: json['pronunciation'] as String,
      meaning: json['meaning'] as String,
    );
  }
}
