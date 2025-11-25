import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sound_box/domain/sounds/white_noise_sound.dart';

/// 加载扁平的音色列表，每个条目对应一个音频文件。
Future<List<WhiteNoiseSound>> loadWhiteNoiseSounds() async {
  if (_cachedSounds != null) return _cachedSounds!;

  final raw = await rootBundle.loadString(_soundAssetPath);
  _cachedSounds = await compute(_parseSounds, raw);
  return _cachedSounds ?? const [];
}

const _soundAssetPath = 'assets/sounds/sounds.json';
List<WhiteNoiseSound>? _cachedSounds;

List<WhiteNoiseSound> _parseSounds(String rawJson) {
  final List<dynamic> data = jsonDecode(rawJson) as List<dynamic>;
  return data
      .asMap()
      .entries
      .map((entry) {
        final json = entry.value as Map<String, dynamic>;
        final name = (json['name'] as String?)?.trim();
        final id = name != null && name.isNotEmpty
            ? name
            : 'sound_${entry.key}';
        return WhiteNoiseSound.fromJson(json, id: id);
      })
      .toList(growable: false);
}
