import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sound_box/features/home/widgets/display_surface.dart';
import 'package:sound_box/features/home/widgets/home_controls.dart';
import 'package:sound_box/features/home/widgets/home_side_pill.dart';
import 'package:sound_box/domain/sounds/white_noise_sound.dart';
import 'package:sound_box/shared/utils/pinned_variant_resolver.dart';

/// 根据横竖屏切换的主页布局。
class HomePortraitLayout extends StatelessWidget {
  const HomePortraitLayout({
    super.key,
    required this.nowListenable,
    required this.onPrimaryAction,
    required this.featuredSounds,
    required this.pinnedEntries,
    required this.breathingProgress,
    required this.activeBreathingIds,
    required this.onBreathingChanged,
  });

  final ValueListenable<DateTime> nowListenable;
  final VoidCallback onPrimaryAction;
  final List<WhiteNoiseSound> featuredSounds;
  final List<PinnedVariantEntry> pinnedEntries;
  final Animation<double>? breathingProgress;
  final Set<String> activeBreathingIds;
  final void Function(String id, bool active) onBreathingChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Column(
            children: [
              Expanded(
                flex: 4,
                child: HomeDisplaySurface(nowListenable: nowListenable),
              ),
              const SizedBox(height: 16),
              HomePrimaryActions(
                onSoundTap: onPrimaryAction,
                breathingProgress: breathingProgress,
                activeBreathingIds: activeBreathingIds,
                onBreathingChanged: onBreathingChanged,
              ),
              const SizedBox(height: 12),
              Expanded(
                flex: 3,
                child: QuickSoundGrid(
                  sounds: featuredSounds,
                  pinnedEntries: pinnedEntries,
                  breathingProgress: breathingProgress,
                  activeBreathingIds: activeBreathingIds,
                  onBreathingChanged: onBreathingChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HomeLandscapeLayout extends StatelessWidget {
  const HomeLandscapeLayout({
    super.key,
    required this.nowListenable,
    required this.onPrimaryAction,
    required this.featuredSounds,
    required this.pinnedEntries,
    required this.breathingProgress,
    required this.activeBreathingIds,
    required this.onBreathingChanged,
  });

  final ValueListenable<DateTime> nowListenable;
  final VoidCallback onPrimaryAction;
  final List<WhiteNoiseSound> featuredSounds;
  final List<PinnedVariantEntry> pinnedEntries;
  final Animation<double>? breathingProgress;
  final Set<String> activeBreathingIds;
  final void Function(String id, bool active) onBreathingChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: LayoutBuilder(
            builder: (context, constraints) {
              const gap = 12.0;
              final availableHeight = constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : 330;
              final pillHeight = ((availableHeight - gap * 2) / 3)
                  .clamp(72.0, 110.0)
                  .toDouble();

              return Column(
                children: [
                  HomeSidePill(
                    height: pillHeight,
                    onTap: onPrimaryAction,
                    child: const Icon(
                      Icons.graphic_eq,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: gap),
                  HomeSidePill(
                    height: pillHeight,
                    child: Icon(Icons.settings, color: Colors.white70),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: HomeDisplaySurface(
                  nowListenable: nowListenable,
                  minRows: 10,
                  minColumns: 28,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: QuickSoundGrid(
                  sounds: featuredSounds,
                  crossAxisCount: 2,
                  pinnedEntries: pinnedEntries,
                  breathingProgress: breathingProgress,
                  activeBreathingIds: activeBreathingIds,
                  onBreathingChanged: onBreathingChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
