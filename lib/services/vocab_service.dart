import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word_item.dart';

class VocabService {
  static const String _favoritesKey = 'favorite_words';

  static Future<List<WordItem>> getFavoriteWords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStringList = prefs.getStringList(_favoritesKey) ?? [];

    return jsonStringList
        .map((item) => WordItem.fromJson(jsonDecode(item)))
        .toList();
  }

  static Future<bool> isFavorite(String arabic) async {
    final favorites = await getFavoriteWords();
    return favorites.any((word) => word.arabic == arabic);
  }

  static Future<void> toggleFavorite(WordItem word) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavoriteWords();

    final exists = favorites.any((item) => item.arabic == word.arabic);

    if (exists) {
      favorites.removeWhere((item) => item.arabic == word.arabic);
    } else {
      favorites.add(word);
    }

    final jsonStringList =
        favorites.map((item) => jsonEncode(item.toJson())).toList();

    await prefs.setStringList(_favoritesKey, jsonStringList);
  }
}
