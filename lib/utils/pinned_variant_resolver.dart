import 'package:sound_box/models/white_noise_sound.dart';

class PinnedVariantEntry {
  const PinnedVariantEntry({
    required this.sound,
    required this.variant,
    required this.variantIndex,
  });

  final WhiteNoiseSound sound;
  final WhiteNoiseSoundVariant variant;
  final int variantIndex;
}

List<PinnedVariantEntry> pinnedEntriesFromKeys(
  List<String> keys,
  List<WhiteNoiseSound> sounds,
) {
  final soundMap = {for (final sound in sounds) sound.id: sound};
  final result = <PinnedVariantEntry>[];
  for (final key in keys) {
    final entry = _entryFromKey(key, soundMap);
    if (entry != null) result.add(entry);
  }
  return result;
}

List<PinnedVariantEntry> variantEntriesForSound(WhiteNoiseSound sound) {
  final variants = _effectiveVariants(sound);
  return List.generate(
    variants.length,
    (index) => PinnedVariantEntry(
      sound: sound,
      variant: variants[index],
      variantIndex: index,
    ),
  );
}

List<WhiteNoiseSoundVariant> _effectiveVariants(WhiteNoiseSound sound) {
  return sound.variants.isNotEmpty
      ? sound.variants
      : [WhiteNoiseSoundVariant(name: sound.name, path: '')];
}

PinnedVariantEntry? _entryFromKey(
  String key,
  Map<String, WhiteNoiseSound> soundMap,
) {
  final parts = key.split('::');
  if (parts.length != 2) return null;
  final sound = soundMap[parts[0]];
  if (sound == null) return null;
  final index = int.tryParse(parts[1]) ?? 0;
  final variants = _effectiveVariants(sound);
  if (index < 0 || index >= variants.length) return null;
  return PinnedVariantEntry(
    sound: sound,
    variant: variants[index],
    variantIndex: index,
  );
}
