import 'package:flutter/material.dart';

class GrammarHomeSearchChip {
  final String labelZh;
  final String labelEn;
  final String queryZh;
  final String queryEn;

  const GrammarHomeSearchChip({
    required this.labelZh,
    required this.labelEn,
    required this.queryZh,
    required this.queryEn,
  });
}

class GrammarHomeShortcut {
  final String id;
  final String labelZh;
  final String labelEn;
  final IconData icon;
  final String? quickSectionId;
  final String? pageId;

  const GrammarHomeShortcut({
    required this.id,
    required this.labelZh,
    required this.labelEn,
    required this.icon,
    this.quickSectionId,
    this.pageId,
  });
}

class GrammarHomeCategoryShortcut {
  final String id;
  final String titleZh;
  final String titleEn;
  final String subtitleZh;
  final String subtitleEn;
  final IconData icon;
  final Color tintColor;
  final String categoryId;

  const GrammarHomeCategoryShortcut({
    required this.id,
    required this.titleZh,
    required this.titleEn,
    required this.subtitleZh,
    required this.subtitleEn,
    required this.icon,
    required this.tintColor,
    required this.categoryId,
  });
}

class GrammarHomeProblemShortcut {
  final String id;
  final String questionZh;
  final String questionEn;
  final String subtitleZh;
  final String subtitleEn;
  final String pageId;

  const GrammarHomeProblemShortcut({
    required this.id,
    required this.questionZh,
    required this.questionEn,
    required this.subtitleZh,
    required this.subtitleEn,
    required this.pageId,
  });
}

class GrammarPageHomeMetadata {
  final String subtitle;
  final List<String> keywords;
  final List<String> searchAliases;
  final List<String> problemTags;
  final bool isFeatured;
  final bool isHighFrequency;
  final String updatedAt;

  const GrammarPageHomeMetadata({
    required this.subtitle,
    required this.keywords,
    required this.searchAliases,
    required this.problemTags,
    required this.isFeatured,
    required this.isHighFrequency,
    required this.updatedAt,
  });
}

class GrammarRecentVisit {
  final String pageId;
  final DateTime visitedAt;

  const GrammarRecentVisit({
    required this.pageId,
    required this.visitedAt,
  });
}
