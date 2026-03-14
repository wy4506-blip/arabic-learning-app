import 'dart:convert';

import 'package:flutter/services.dart';

import '../data/sample_alphabet_data.dart';
import '../models/alphabet_group.dart';

class AlphabetService {
  static Future<List<AlphabetGroup>> loadAlphabetGroups() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/alphabets.json');
      final List<dynamic> jsonData = jsonDecode(jsonString);
      final groups = jsonData
          .map((item) => AlphabetGroup.fromJson(item as Map<String, dynamic>))
          .toList();
      if (groups.isNotEmpty) {
        return groups;
      }
    } catch (_) {
      // Fall back to the built-in alphabet curriculum when local JSON is absent or invalid.
    }

    return List<AlphabetGroup>.from(sampleAlphabetGroups);
  }
}
