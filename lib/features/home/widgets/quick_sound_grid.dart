import 'package:flutter/material.dart';
import 'package:sound_box/domain/sounds/white_noise_sound.dart';
import 'package:sound_box/features/home/widgets/home_square_button.dart';
import 'package:sound_box/shared/adaptive/adaptive_grid.dart';
import 'package:sound_box/shared/audio/sound_track_pool.dart';

/// 精选音效网格，根据可用宽度自适应列数，兼顾移动端与桌面端。
class QuickSoundGrid extends StatelessWidget {
  const QuickSoundGrid({
    super.key,
    required this.sounds,
    this.crossAxisCount = 3,
    this.breathingProgress,
    this.activeBreathingIds = const {},
    this.onBreathingChanged,
    this.onSoundTap,
  });

  final List<WhiteNoiseSound> sounds;
  final int crossAxisCount;
  final Animation<double>? breathingProgress;
  final Set<String> activeBreathingIds;
  final void Function(String id, bool active)? onBreathingChanged;
  final void Function(String key, String path, double volume)? onSoundTap;

  @override
  Widget build(BuildContext context) {
    final items = _gridItems();

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final pool = SoundTrackPool.instance;
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 320.0;
        final computedCrossAxisCount = AdaptiveGrid.crossAxisCount(
          availableWidth,
          minCount: crossAxisCount,
          gap: gap,
        );

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: computedCrossAxisCount,
            childAspectRatio: 1,
            mainAxisSpacing: gap,
            crossAxisSpacing: gap,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final itemKey = item.soundId;
            final itemId = 'quick_${index}_${item.label}';
            return HomeSquareButton(
              svgAsset: item.svgAsset,
              onTap: () => onSoundTap?.call(
                itemKey,
                item.path,
                pool.preferredVolume(itemKey),
              ),
              breathingProgress: breathingProgress,
              iconColor: item.color,
              isBreathing: activeBreathingIds.contains(itemId),
              onBreathingChanged: (active) =>
                  onBreathingChanged?.call(itemId, active),
            );
          },
        );
      },
    );
  }

  /// 计算可显示的网格项。
  List<_GridItem> _gridItems() {
    return sounds
        .map(
          (sound) => _GridItem(
            label: sound.name,
            color: sound.color,
            soundId: sound.id,
            path: sound.path,
            svgAsset: sound.svgAsset,
          ),
        )
        .toList();
  }
}

class _GridItem {
  const _GridItem({
    required this.label,
    required this.soundId,
    required this.path,
    required this.svgAsset,
    this.color,
  });

  final String label;
  final String soundId;
  final String path;
  final String svgAsset;
  final Color? color;
}
