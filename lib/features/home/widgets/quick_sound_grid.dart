import 'package:flutter/material.dart';
import 'package:sound_box/domain/sounds/white_noise_sound.dart';
import 'package:sound_box/features/home/widgets/home_square_button.dart';
import 'package:sound_box/shared/utils/pinned_variant_resolver.dart';

/// 精选音效网格，根据可用宽度自适应列数，兼顾移动端与桌面端。
class QuickSoundGrid extends StatelessWidget {
  const QuickSoundGrid({
    super.key,
    required this.sounds,
    this.crossAxisCount = 3,
    this.pinnedEntries = const [],
    this.breathingProgress,
    this.activeBreathingIds = const {},
    this.onBreathingChanged,
  });

  final List<WhiteNoiseSound> sounds;
  final int crossAxisCount;
  final List<PinnedVariantEntry> pinnedEntries;
  final Animation<double>? breathingProgress;
  final Set<String> activeBreathingIds;
  final void Function(String id, bool active)? onBreathingChanged;

  @override
  Widget build(BuildContext context) {
    final items = _gridItems();

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 320.0;
        final computedCrossAxisCount = _resolveCrossAxisCount(
          availableWidth,
          min: crossAxisCount,
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
            final itemId = 'quick_${index}_${item.label}';
            return HomeSquareButton(
              icon: item.icon,
              label: item.label,
              onTap: () {},
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
    if (pinnedEntries.isNotEmpty) {
      return pinnedEntries
          .map(
            (entry) => _GridItem(
              icon: entry.sound.icon,
              label: entry.variant.name.isNotEmpty
                  ? entry.variant.name
                  : entry.sound.name,
              color: entry.variant.color ?? entry.sound.color,
            ),
          )
          .toList();
    }
    return sounds
        .map(
          (sound) => _GridItem(
            icon: sound.icon,
            label: sound.name,
            color: sound.color,
          ),
        )
        .toList();
  }
}

/// 计算屏幕允许的网格列数，避免窄屏过挤或宽屏浪费空间。
int _resolveCrossAxisCount(double width, {int min = 3, int max = 6}) {
  const targetSize = 72.0;
  const gap = 12.0;
  return (width / (targetSize + gap)).floor().clamp(min, max);
}

class _GridItem {
  const _GridItem({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;
}
