import 'dart:convert';
import 'dart:io';

void main() async {
  final manifestPath = 'assets/data/audio_manifest.json';
  final manifestFile = File(manifestPath);
  
  // 读取 manifest
  final manifestJson = jsonDecode(await manifestFile.readAsString()) as Map<String, dynamic>;
  final items = (manifestJson['items'] as List).cast<Map<String, dynamic>>();
  
  // 要添加 human 变体的基础条目 ID
  final baseIds = ['alpha_l_001_normal', 'alpha_l_002_normal', 'alpha_l_003_normal'];
  
  // 创建 human 变体
  final newItems = <Map<String, dynamic>>[];
  for (final baseId in baseIds) {
    final baseItem = items.firstWhere((item) => item['id'] == baseId, orElse: () => {} as Map<String, dynamic>);
    if (baseItem.isNotEmpty) {
      final humanItem = Map<String, dynamic>.from(baseItem);
      final suffix = '__human__20260314-test';
      final variantId = '$baseId$suffix';
      
      humanItem['id'] = variantId;
      humanItem['fileName'] = '$baseId$suffix.m4a';
      humanItem['assetPath'] = 'assets/audio/alphabet/letter/$baseId$suffix.m4a';
      humanItem['relativeAssetPath'] = 'alphabet/letter/$baseId$suffix.m4a';
      humanItem['voiceType'] = 'human';
      humanItem['source'] = 'test';
      humanItem['sourceFileName'] = '$baseId.m4a';
      humanItem['sourceFormat'] = 'm4a';
      humanItem['revision'] = '20260314-test';
      humanItem['importedAt'] = DateTime.now().toUtc().toIso8601String();
      
      newItems.add(humanItem);
      print('✅ 添加: $variantId');
    }
  }
  
  // 合并到 manifest
  items.addAll(newItems);
  manifestJson['items'] = items;
  
  // 写回 manifest（保持缩进和格式）
  final encoder = JsonEncoder.withIndent('  ');
  await manifestFile.writeAsString(encoder.convert(manifestJson));
  
  print('✅ Manifest 已更新');
  print('总条目数: ${items.length}');
}
