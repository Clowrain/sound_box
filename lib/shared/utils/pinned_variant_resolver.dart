import 'package:sound_box/domain/sounds/white_noise_sound.dart';

/// 固定音色的简化条目，直接指向单个音色。
class PinnedVariantEntry {
  const PinnedVariantEntry({
    required this.sound,
    this.variantIndex = 0,
  });

  final WhiteNoiseSound sound;
  final int variantIndex;

  String get key => sound.id;
}

List<PinnedVariantEntry> pinnedEntriesFromKeys(
  List<String> keys,
  List<WhiteNoiseSound> sounds,
) {
  final soundMap = {for (final sound in sounds) sound.id: sound};
  final result = <PinnedVariantEntry>[];
  for (final key in keys) {
    final normalizedKey = key.contains('::') ? key.split('::').first : key;
    final sound = soundMap[normalizedKey];
    if (sound != null) {
      result.add(PinnedVariantEntry(sound: sound));
    }
  }
  return result;
}

List<PinnedVariantEntry> variantEntriesForSound(WhiteNoiseSound sound) =>
    [PinnedVariantEntry(sound: sound)];
