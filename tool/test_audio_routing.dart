import 'dart:convert';
import 'dart:io';

/// Test script to verify audio routing logic works correctly
Future<void> main() async {
  print('🔍 Audio Preference Routing Test\n');

  // Load manifest
  final manifestFile = File('assets/data/audio_manifest.json');
  final manifestJson = jsonDecode(await manifestFile.readAsString()) as Map<String, dynamic>;
  final items = (manifestJson['items'] as List).cast<Map<String, dynamic>>();

  // Find alpha_l_001_normal items (both AI and human)
  final baseId = 'alpha_l_001_normal';
  final aiItem = items.firstWhere((item) => item['id'] == baseId, orElse: () => {} as Map<String, dynamic>);
  final humanVariantId = '${baseId}__human__20260314-test';
  final humanItem = items.firstWhere((item) => item['id'] == humanVariantId, orElse: () => {} as Map<String, dynamic>);

  print('✅ AI variant:');
  print('   id: ${aiItem['id']}');
  print('   voiceType: ${aiItem['voiceType']}');
  print('   relativeAssetPath: ${aiItem['relativeAssetPath']}');

  print('\n✅ Human variant:');
  print('   id: ${humanItem['id']}');
  print('   voiceType: ${humanItem['voiceType']}');
  print('   relativeAssetPath: ${humanItem['relativeAssetPath']}');

  // Simulate the routing logic
  final targetArabic = 'ا';  // Alif
  
  print('\n🔄 Routing Logic Test:\n');
  
  // Test 1: Prefer AI
  print('Test 1: Preference = AI');
  final aiPreferred = _findAudioVariants(items, 'alphabet', 'letter', 'normal', targetArabic, 'ai');
  print('   Result: ${aiPreferred.first} (count: ${aiPreferred.length})');
  
  // Test 2: Prefer Human
  print('\nTest 2: Preference = Human');
  final humanPreferred = _findAudioVariants(items, 'alphabet', 'letter', 'normal', targetArabic, 'human');
  print('   Result: ${humanPreferred.first} (count: ${humanPreferred.length})');
  
  // Verify they're different
  if (aiPreferred.first != humanPreferred.first) {
    print('\n✅ SUCCESS: Audio preference routing works correctly!');
  } else {
    print('\n❌ FAIL: Both preferences returned the same file!');
  }
}

List<String> _findAudioVariants(
  List<Map<String, dynamic>> items,
  String scope,
  String type,
  String speed,
  String textAr,
  String voicePreference,
) {
  final preferred = <String>[];
  final fallback = <String>[];
  final preferredType = voicePreference;
  final normalizedTarget = textAr.replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '').trim();

  for (final item in items) {
    if (item['scope'] != scope || 
        item['type'] != type || 
        item['speed'] != speed ||
        item['lessonId'] != 'alphabet') {
      continue;
    }

    final itemArabic = (item['textAr'] as String? ?? '').replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '').trim();
    
    if (itemArabic == normalizedTarget) {
      if (item['voiceType'] == preferredType) {
        preferred.add(item['relativeAssetPath'] as String);
      } else {
        fallback.add(item['relativeAssetPath'] as String);
      }
    }
  }

  return [...preferred, ...fallback];
}
