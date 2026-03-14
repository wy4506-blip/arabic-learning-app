import 'dart:convert';
import 'dart:io';

/// Remove test human variants from manifest
Future<void> main() async {
  final manifestPath = 'assets/data/audio_manifest.json';
  final manifestFile = File(manifestPath);
  
  // 读取 manifest
  final manifestJson = jsonDecode(await manifestFile.readAsString()) as Map<String, dynamic>;
  final items = (manifestJson['items'] as List).cast<Map<String, dynamic>>();
  
  // 移除测试条目
  final testIds = {
    'alpha_l_001_normal__human__20260314-test',
    'alpha_l_002_normal__human__20260314-test',
    'alpha_l_003_normal__human__20260314-test',
  };
  
  final before = items.length;
  items.removeWhere((item) => testIds.contains(item['id']));
  final removed = before - items.length;
  
  print('✅ Removed $removed test human variants');
  
  // 写回 manifest
  manifestJson['items'] = items;
  final encoder = JsonEncoder.withIndent('  ');
  await manifestFile.writeAsString(encoder.convert(manifestJson));
  
  print('✅ Manifest updated: ${items.length} items');
}
