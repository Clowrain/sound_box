import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sound_box/domain/sounds/white_noise_sound.dart';
import 'package:sound_box/features/home/widgets/display_surface.dart';
import 'package:sound_box/features/home/widgets/home_primary_actions.dart';
import 'package:sound_box/features/home/widgets/quick_sound_grid.dart';

/// 首页布局（固定使用竖屏移动端布局）。
class HomePortraitLayout extends StatelessWidget {
  const HomePortraitLayout({
    super.key,
    required this.nowListenable,
    required this.onPrimaryAction,
    required this.featuredSounds,
    required this.breathingProgress,
    required this.activeBreathingIds,
    required this.onBreathingChanged,
    required this.onSoundTap,
  });

  final ValueListenable<DateTime> nowListenable;
  final VoidCallback onPrimaryAction;
  final List<WhiteNoiseSound> featuredSounds;
  final Animation<double>? breathingProgress;
  final Set<String> activeBreathingIds;
  final void Function(String id, bool active) onBreathingChanged;
  final void Function(String key, String path, double volume) onSoundTap;

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
                  breathingProgress: breathingProgress,
                  activeBreathingIds: activeBreathingIds,
                  onBreathingChanged: onBreathingChanged,
                  onSoundTap: onSoundTap,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
