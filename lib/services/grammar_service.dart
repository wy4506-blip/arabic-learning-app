import 'dart:convert';

import 'package:flutter/services.dart';

import '../data/grammar_home_curated_data.dart';
import '../models/grammar_models.dart';

class GrammarService {
  GrammarService._();

  static List<GrammarCategory>? _categories;
  static List<GrammarPageContent>? _pages;

  static Future<List<GrammarCategory>> loadCategories() async {
    if (_categories != null) return _categories!;

    final jsonString =
        await rootBundle.loadString('assets/grammar/categories.json');
    final items = jsonDecode(jsonString) as List<dynamic>;
    _categories = items
        .map((item) => GrammarCategory.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
    return _categories!;
  }

  static Future<List<GrammarPageContent>> loadPages() async {
    if (_pages != null) return _pages!;

    final jsonString = await rootBundle.loadString('assets/grammar/pages.json');
    final items = jsonDecode(jsonString) as List<dynamic>;
    _pages = items
        .map(
          (item) => enrichGrammarPageContent(
            GrammarPageContent.fromJson(item as Map<String, dynamic>),
          ),
        )
        .toList(growable: false);
    return _pages!;
  }

  static Future<GrammarCategory?> getCategory(String id) async {
    final categories = await loadCategories();
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  static Future<GrammarPageContent?> getPage(String id) async {
    final pages = await loadPages();
    for (final page in pages) {
      if (page.id == id) return page;
    }
    return null;
  }

  static Future<List<GrammarPageContent>> getPagesForCategory(
    String categoryId,
  ) async {
    final pages = await loadPages();
    return pages.where((page) => page.category == categoryId).toList();
  }

  static Future<List<GrammarPageContent>> getPagesForLesson(
    String lessonId,
  ) async {
    final pages = await loadPages();
    return pages
        .where((page) => page.relatedLessons.contains(lessonId))
        .toList(growable: false);
  }

  static Future<GrammarPageContent?> getPageByRoute(String route) async {
    final pages = await loadPages();
    for (final page in pages) {
      if (page.route == route) return page;
    }
    return null;
  }
}
