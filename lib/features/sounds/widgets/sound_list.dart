import 'package:flutter/material.dart';
import 'package:sound_box/domain/sounds/white_noise_sound.dart';
import 'package:sound_box/features/sounds/widgets/sound_card.dart';
import 'package:sound_box/shared/state/pinned_sounds_state.dart';
import 'package:sound_box/shared/utils/pinned_variant_resolver.dart';

/// 音效列表 Sliver，分离列表逻辑，便于后续做网格/分栏适配。
class SoundList extends StatelessWidget {
  const SoundList({
    super.key,
    required this.sounds,
    required this.pinnedState,
    required this.stateBuilder,
    required this.variantKeyBuilder,
    required this.onToggle,
    required this.onVolumeChanged,
    required this.onTogglePin,
  });

  final List<WhiteNoiseSound> sounds;
  final PinnedSoundsState pinnedState;
  final WhiteNoiseSoundState Function(WhiteNoiseSound sound, int variantIndex)
      stateBuilder;
  final String Function(WhiteNoiseSound sound, int variantIndex)
      variantKeyBuilder;
  final void Function(WhiteNoiseSound sound, int variantIndex) onToggle;
  final void Function(
    WhiteNoiseSound sound,
    int variantIndex,
    double volume,
  ) onVolumeChanged;
  final void Function(WhiteNoiseSound sound, int variantIndex) onTogglePin;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final sound = sounds[index];
          final entries = variantEntriesForSound(sound);
          return SoundTile(
            key: ValueKey('tile_${sound.id}'),
            sound: sound,
            variants: entries,
            stateOf: (variantIndex) =>
                stateBuilder(sound, variantIndex),
            isPinned: (variantIndex) => pinnedState.isPinned(
              variantKeyBuilder(sound, variantIndex),
            ),
            onToggle: (variantIndex) => onToggle(sound, variantIndex),
            onVolumeChanged: (variantIndex, value) =>
                onVolumeChanged(sound, variantIndex, value),
            onTogglePin: (variantIndex) => onTogglePin(sound, variantIndex),
          );
        },
        childCount: sounds.length,
      ),
    );
  }
}

class SoundTile extends StatelessWidget {
  const SoundTile({
    super.key,
    required this.sound,
    required this.variants,
    required this.stateOf,
    required this.isPinned,
    required this.onToggle,
    required this.onVolumeChanged,
    required this.onTogglePin,
  });

  final WhiteNoiseSound sound;
  final List<PinnedVariantEntry> variants;
  final WhiteNoiseSoundState Function(int variantIndex) stateOf;
  final bool Function(int variantIndex) isPinned;
  final void Function(int variantIndex) onToggle;
  final void Function(int variantIndex, double volume) onVolumeChanged;
  final void Function(int variantIndex) onTogglePin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(sound.name, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Column(
            children: variants.map((entry) {
              final state = stateOf(entry.variantIndex);
              final pinned = isPinned(entry.variantIndex);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SoundCard(
                  sound: entry.sound,
                  variant: entry.variant,
                  volume: state.volume,
                  isPlaying: state.isPlaying,
                  onToggle: () => onToggle(entry.variantIndex),
                  onVolumeChanged: (value) =>
                      onVolumeChanged(entry.variantIndex, value),
                  isPinned: pinned,
                  onTogglePin: () => onTogglePin(entry.variantIndex),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
