import 'package:flutter/material.dart';
import 'package:sound_box/models/white_noise_sound.dart';

class PlayingSoundsChips extends StatelessWidget {
  const PlayingSoundsChips({
    super.key,
    required this.playingSounds,
    required this.onRemoveSound,
  });

  final List<WhiteNoiseSound> playingSounds;
  final ValueChanged<String> onRemoveSound;

  @override
  Widget build(BuildContext context) {
    if (playingSounds.isEmpty) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Card(
          color: Colors.white.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: playingSounds
                  .map(
                    (sound) => Chip(
                      labelPadding: const EdgeInsets.only(left: 2, right: 4),
                      avatar: Icon(sound.icon, size: 16, color: Colors.white),
                      label: Text(sound.label),
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                      deleteIconColor: Colors.white,
                      onDeleted: () => onRemoveSound(sound.id),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
