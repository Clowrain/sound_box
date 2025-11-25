import 'package:flutter/material.dart';
import 'package:sound_box/domain/sounds/white_noise_sound.dart';
import 'package:sound_box/features/sounds/widgets/sound_card.dart';

/// 音效列表 Sliver，直接平铺所有音色，移动/桌面统一。
class SoundList extends StatelessWidget {
  const SoundList({
    super.key,
    required this.sounds,
    required this.stateBuilder,
    required this.onReorder,
    required this.onToggle,
    required this.onVolumeChanged,
  });

  final List<WhiteNoiseSound> sounds;
  final WhiteNoiseSoundState Function(WhiteNoiseSound sound) stateBuilder;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(WhiteNoiseSound sound) onToggle;
  final void Function(WhiteNoiseSound sound, double volume) onVolumeChanged;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      onReorder: onReorder,
      itemCount: sounds.length,
      buildDefaultDragHandles: false,
      itemBuilder: (context, index) {
        final sound = sounds[index];
        final state = stateBuilder(sound);
        return Padding(
          key: ValueKey(sound.id),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: SoundCard(
                  sound: sound,
                  volume: state.volume,
                  isPlaying: state.isPlaying,
                  onToggle: () => onToggle(sound),
                  onVolumeChanged: (value) => onVolumeChanged(sound, value),
                ),
              ),
              const SizedBox(width: 8),
              ReorderableDragStartListener(
                index: index,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  child: const Icon(Icons.drag_indicator, color: Colors.white70),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
