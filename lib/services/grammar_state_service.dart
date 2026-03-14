import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/grammar_home_models.dart';

class GrammarStateService {
  static const _recentItemsKey = 'grammar_recent_items';
  static const _recentVisitsKey = 'grammar_recent_visits';
  static const _favoritesKey = 'grammar_favorites';
  static const _lastOpenedKey = 'grammar_last_opened_page';
  static const _expandStatesKey = 'grammar_expand_states';
  static const _homeScrollOffsetKey = 'grammar_home_scroll_offset';

  static Future<List<String>> getRecentItems() async {
    final prefs = await SharedPreferences.getInstance();
    final visits = await getRecentVisits();
    if (visits.isNotEmpty) {
      return visits.map((visit) => visit.pageId).toList(growable: false);
    }
    return prefs.getStringList(_recentItemsKey) ?? const <String>[];
  }

  static Future<void> recordOpenedPage(String pageId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_recentItemsKey) ?? const <String>[];
    final items = <String>[pageId, ...current.where((id) => id != pageId)]
        .take(5)
        .toList();
    await prefs.setStringList(_recentItemsKey, items);
    await prefs.setString(_lastOpenedKey, pageId);
    final visits = await getRecentVisits();
    final updatedVisits = <GrammarRecentVisit>[
      GrammarRecentVisit(pageId: pageId, visitedAt: DateTime.now()),
      ...visits.where((visit) => visit.pageId != pageId),
    ].take(5).toList(growable: false);
    await prefs.setString(
      _recentVisitsKey,
      jsonEncode(
        updatedVisits
            .map(
              (visit) => <String, String>{
                'pageId': visit.pageId,
                'visitedAt': visit.visitedAt.toIso8601String(),
              },
            )
            .toList(growable: false),
      ),
    );
  }

  static Future<String?> getLastOpenedPage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastOpenedKey);
  }

  static Future<List<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? const <String>[];
  }

  static Future<List<GrammarRecentVisit>> getRecentVisits() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_recentVisitsKey);
    if (raw == null || raw.isEmpty) return const <GrammarRecentVisit>[];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) {
            final map = item as Map<String, dynamic>;
            final timestamp = DateTime.tryParse(
              map['visitedAt'] as String? ?? '',
            );
            final pageId = map['pageId'] as String? ?? '';
            if (timestamp == null || pageId.isEmpty) {
              return null;
            }
            return GrammarRecentVisit(
              pageId: pageId,
              visitedAt: timestamp,
            );
          })
          .whereType<GrammarRecentVisit>()
          .toList(growable: false);
    } catch (_) {
      return const <GrammarRecentVisit>[];
    }
  }

  static Future<bool> isFavorite(String pageId) async {
    final favorites = await getFavoriteIds();
    return favorites.contains(pageId);
  }

  static Future<void> toggleFavorite(String pageId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = List<String>.from(
      prefs.getStringList(_favoritesKey) ?? const <String>[],
    );

    if (favorites.contains(pageId)) {
      favorites.removeWhere((id) => id == pageId);
    } else {
      favorites.insert(0, pageId);
    }

    await prefs.setStringList(_favoritesKey, favorites);
  }

  static Future<Map<String, bool>> getExpandStates() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_expandStatesKey);
    if (raw == null || raw.isEmpty) return <String, bool>{};

    final jsonMap = jsonDecode(raw) as Map<String, dynamic>;
    return jsonMap.map(
      (key, value) => MapEntry(key, value == true),
    );
  }

  static Future<bool> getExpandState(String id) async {
    final states = await getExpandStates();
    return states[id] ?? false;
  }

  static Future<void> setExpandState(String id, bool expanded) async {
    final prefs = await SharedPreferences.getInstance();
    final states = await getExpandStates();
    states[id] = expanded;
    await prefs.setString(_expandStatesKey, jsonEncode(states));
  }

  static Future<double> getHomeScrollOffset() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_homeScrollOffsetKey) ?? 0;
  }

  static Future<void> setHomeScrollOffset(double offset) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_homeScrollOffsetKey, offset);
  }
}
