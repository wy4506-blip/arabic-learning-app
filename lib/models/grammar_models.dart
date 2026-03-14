import 'dart:ui';

class GrammarCategory {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final String themeColor;
  final String route;
  final List<String> children;

  const GrammarCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.themeColor,
    required this.route,
    required this.children,
  });

  Color get parsedColor => _colorFromHex(themeColor);

  factory GrammarCategory.fromJson(Map<String, dynamic> json) {
    return GrammarCategory(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      themeColor: json['themeColor'] as String? ?? '#EEF2FF',
      route: json['route'] as String? ?? '',
      children: List<String>.from(json['children'] as List? ?? const []),
    );
  }
}

class GrammarPageContent {
  final String id;
  final String title;
  final String subtitle;
  final String route;
  final String type;
  final String category;
  final String summary;
  final List<GrammarSection> sections;
  final List<String> relatedLessons;
  final List<String> tags;
  final List<String> keywords;
  final List<String> problemTags;
  final List<String> searchAliases;
  final String difficulty;
  final bool isFeatured;
  final bool isHighFrequency;
  final String updatedAt;

  const GrammarPageContent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.type,
    required this.category,
    required this.summary,
    required this.sections,
    required this.relatedLessons,
    required this.tags,
    required this.keywords,
    required this.problemTags,
    required this.searchAliases,
    required this.difficulty,
    required this.isFeatured,
    required this.isHighFrequency,
    required this.updatedAt,
  });

  factory GrammarPageContent.fromJson(Map<String, dynamic> json) {
    return GrammarPageContent(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      route: json['route'] as String? ?? '',
      type: json['type'] as String? ?? '',
      category: json['category'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      sections: (json['sections'] as List? ?? const [])
          .map(
            (item) => GrammarSection.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      relatedLessons: List<String>.from(
        json['relatedLessons'] as List? ?? const [],
      ),
      tags: List<String>.from(json['tags'] as List? ?? const []),
      keywords: List<String>.from(json['keywords'] as List? ?? const []),
      problemTags: List<String>.from(json['problemTags'] as List? ?? const []),
      searchAliases: List<String>.from(
        json['searchAliases'] as List? ?? const [],
      ),
      difficulty: json['difficulty'] as String? ?? 'beginner',
      isFeatured: json['isFeatured'] as bool? ?? false,
      isHighFrequency: json['isHighFrequency'] as bool? ?? false,
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  GrammarPageContent copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? route,
    String? type,
    String? category,
    String? summary,
    List<GrammarSection>? sections,
    List<String>? relatedLessons,
    List<String>? tags,
    List<String>? keywords,
    List<String>? problemTags,
    List<String>? searchAliases,
    String? difficulty,
    bool? isFeatured,
    bool? isHighFrequency,
    String? updatedAt,
  }) {
    return GrammarPageContent(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      route: route ?? this.route,
      type: type ?? this.type,
      category: category ?? this.category,
      summary: summary ?? this.summary,
      sections: sections ?? this.sections,
      relatedLessons: relatedLessons ?? this.relatedLessons,
      tags: tags ?? this.tags,
      keywords: keywords ?? this.keywords,
      problemTags: problemTags ?? this.problemTags,
      searchAliases: searchAliases ?? this.searchAliases,
      difficulty: difficulty ?? this.difficulty,
      isFeatured: isFeatured ?? this.isFeatured,
      isHighFrequency: isHighFrequency ?? this.isHighFrequency,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool matchesSearch(String query) {
    final normalizedQuery = _normalizeSearchText(query);
    if (normalizedQuery.isEmpty) return true;

    final values = <String>[
      id,
      title,
      subtitle,
      summary,
      difficulty,
      ...tags,
      ...keywords,
      ...problemTags,
      ...searchAliases,
    ];

    final haystack = values.map(_normalizeSearchText).join(' ');
    return haystack.contains(normalizedQuery);
  }
}

class GrammarSection {
  final String id;
  final String type;
  final String title;
  final String description;
  final bool isExpandable;
  final List<String> bullets;
  final GrammarTableData? table;
  final List<GrammarQuickLink> quickLinks;
  final List<GrammarRuleCardData> rules;
  final List<GrammarCompareCardData> compares;
  final List<GrammarExampleData> examples;

  const GrammarSection({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.isExpandable,
    required this.bullets,
    required this.table,
    required this.quickLinks,
    required this.rules,
    required this.compares,
    required this.examples,
  });

  factory GrammarSection.fromJson(Map<String, dynamic> json) {
    return GrammarSection(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isExpandable: json['isExpandable'] as bool? ?? false,
      bullets: List<String>.from(json['bullets'] as List? ?? const []),
      table: json['table'] is Map<String, dynamic>
          ? GrammarTableData.fromJson(json['table'] as Map<String, dynamic>)
          : null,
      quickLinks: (json['quickLinks'] as List? ?? const [])
          .map(
            (item) => GrammarQuickLink.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      rules: (json['rules'] as List? ?? const [])
          .map(
            (item) =>
                GrammarRuleCardData.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      compares: (json['compares'] as List? ?? const [])
          .map(
            (item) =>
                GrammarCompareCardData.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      examples: (json['examples'] as List? ?? const [])
          .map(
            (item) => GrammarExampleData.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class GrammarQuickLink {
  final String id;
  final String title;
  final String subtitle;
  final String route;

  const GrammarQuickLink({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  factory GrammarQuickLink.fromJson(Map<String, dynamic> json) {
    return GrammarQuickLink(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      route: json['route'] as String? ?? '',
    );
  }
}

class GrammarTableData {
  final List<String> columns;
  final List<List<String>> rows;

  const GrammarTableData({
    required this.columns,
    required this.rows,
  });

  factory GrammarTableData.fromJson(Map<String, dynamic> json) {
    return GrammarTableData(
      columns: List<String>.from(json['columns'] as List? ?? const []),
      rows: (json['rows'] as List? ?? const [])
          .map((row) => List<String>.from(row as List))
          .toList(),
    );
  }
}

class GrammarRuleCardData {
  final String id;
  final String title;
  final String symbol;
  final String summary;
  final GrammarExampleData? example;

  const GrammarRuleCardData({
    required this.id,
    required this.title,
    required this.symbol,
    required this.summary,
    required this.example,
  });

  factory GrammarRuleCardData.fromJson(Map<String, dynamic> json) {
    return GrammarRuleCardData(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      example: json['example'] is Map<String, dynamic>
          ? GrammarExampleData.fromJson(
              json['example'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class GrammarCompareCardData {
  final String id;
  final String leftLabel;
  final String leftValue;
  final String rightLabel;
  final String rightValue;
  final String note;

  const GrammarCompareCardData({
    required this.id,
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
    required this.note,
  });

  factory GrammarCompareCardData.fromJson(Map<String, dynamic> json) {
    final left = json['left'] as Map<String, dynamic>? ?? const {};
    final right = json['right'] as Map<String, dynamic>? ?? const {};

    return GrammarCompareCardData(
      id: json['id'] as String? ?? '',
      leftLabel: left['label'] as String? ?? '',
      leftValue: left['value'] as String? ?? '',
      rightLabel: right['label'] as String? ?? '',
      rightValue: right['value'] as String? ?? '',
      note: json['note'] as String? ?? '',
    );
  }
}

class GrammarExampleData {
  final String id;
  final String arabicWithDiacritics;
  final String arabicPlain;
  final String transliteration;
  final String translation;
  final String audioPath;
  final List<String> highlightParts;

  const GrammarExampleData({
    required this.id,
    required this.arabicWithDiacritics,
    required this.arabicPlain,
    required this.transliteration,
    required this.translation,
    required this.audioPath,
    required this.highlightParts,
  });

  factory GrammarExampleData.fromJson(Map<String, dynamic> json) {
    return GrammarExampleData(
      id: json['id'] as String? ?? '',
      arabicWithDiacritics: json['arabicWithDiacritics'] as String? ?? '',
      arabicPlain: json['arabicPlain'] as String? ?? '',
      transliteration: json['transliteration'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
      audioPath: json['audioPath'] as String? ?? '',
      highlightParts: List<String>.from(
        json['highlightParts'] as List? ?? const [],
      ),
    );
  }
}

Color _colorFromHex(String value) {
  final normalized = value.replaceAll('#', '').trim();
  final hex = normalized.length == 6 ? 'FF$normalized' : normalized;
  return Color(int.tryParse(hex, radix: 16) ?? 0xFFEEF2FF);
}

String _normalizeSearchText(String value) {
  final diacritics = RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]');
  return value
      .replaceAll(diacritics, '')
      .toLowerCase()
      .replaceAll('||', ' ')
      .replaceAll('，', ' ')
      .replaceAll('。', ' ')
      .replaceAll('/', ' ')
      .replaceAll('-', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
