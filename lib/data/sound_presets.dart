import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:sound_box/models/white_noise_sound.dart';

Future<List<WhiteNoiseSound>> loadWhiteNoiseSounds() async {
  if (_cachedSounds != null) return _cachedSounds!;

  final raw = await rootBundle.loadString(_soundAssetPath);
  final List<dynamic> data = jsonDecode(raw) as List<dynamic>;

  _cachedSounds = data
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

  return _cachedSounds!;
}

const _soundAssetPath = 'lib/sounds.json';
List<WhiteNoiseSound>? _cachedSounds;
