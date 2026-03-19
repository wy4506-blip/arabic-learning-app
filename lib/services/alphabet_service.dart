import 'dart:convert';

import 'package:flutter/services.dart';

import '../data/sample_alphabet_data.dart';
import '../models/alphabet_group.dart';

class AlphabetService {
  static List<AlphabetGroup>? _cachedAlphabetGroups;

  static Future<List<AlphabetGroup>> loadAlphabetGroups() async {
    final cached = _cachedAlphabetGroups;
    if (cached != null) {
      return List<AlphabetGroup>.from(cached);
    }

    try {
      final jsonString =
          await rootBundle.loadString('assets/data/alphabets.json');
      final List<dynamic> jsonData = jsonDecode(jsonString);
      final groups = jsonData
          .map((item) => AlphabetGroup.fromJson(item as Map<String, dynamic>))
          .toList();
      if (groups.isNotEmpty) {
        _cachedAlphabetGroups = List<AlphabetGroup>.from(groups);
        return List<AlphabetGroup>.from(groups);
      }
    } catch (_) {
      // Fall back to the built-in alphabet curriculum when local JSON is absent or invalid.
    }

    final fallback = List<AlphabetGroup>.from(sampleAlphabetGroups);
    _cachedAlphabetGroups = List<AlphabetGroup>.from(fallback);
    return fallback;
  }

  static void debugClearCache() {
    _cachedAlphabetGroups = null;
  }
}
