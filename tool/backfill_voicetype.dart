import 'dart:convert';
import 'dart:io';

/// Add voiceType: 'ai' to all items that don't have it
Future<void> main() async {
  final manifestPath = 'assets/data/audio_manifest.json';
  final manifestFile = File(manifestPath);
  
  // 读取 manifest
  final manifestJson = jsonDecode(await manifestFile.readAsString()) as Map<String, dynamic>;
  final items = (manifestJson['items'] as List).cast<Map<String, dynamic>>();
  
  int updated = 0;
  for (final item in items) {
    if (!item.containsKey('voiceType')) {
      item['voiceType'] = 'ai';
      updated++;
    }
  }
  
  print('✅ Updated $updated items with voiceType: ai');
  
  // 写回 manifest
  final encoder = JsonEncoder.withIndent('  ');
  await manifestFile.writeAsString(encoder.convert(manifestJson));
  
  print('✅ Manifest saved');
}
