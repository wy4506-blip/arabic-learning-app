class DialogueLine {
  final String speaker;
  final String arabic;
  final String transliteration;
  final String chinese;
  final String? audio;

  const DialogueLine({
    required this.speaker,
    required this.arabic,
    required this.transliteration,
    required this.chinese,
    this.audio,
  });

  factory DialogueLine.fromJson(Map<String, dynamic> json) {
    return DialogueLine(
      speaker: json['speaker'] ?? '',
      arabic: json['arabic'] ?? '',
      transliteration: json['transliteration'] ?? '',
      chinese: json['chinese'] ?? '',
      audio: json['audio'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'speaker': speaker,
      'arabic': arabic,
      'transliteration': transliteration,
      'chinese': chinese,
      'audio': audio,
    };
  }
}
