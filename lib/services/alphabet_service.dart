import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/alphabet_group.dart';

class AlphabetService {
  static Future<List<AlphabetGroup>> loadAlphabetGroups() async {
    final jsonString =
        await rootBundle.loadString('assets/data/alphabets.json');
    final List<dynamic> jsonData = jsonDecode(jsonString);

    return jsonData
        .map((item) => AlphabetGroup.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
