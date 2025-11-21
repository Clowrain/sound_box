import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sound_box/features/home/widgets/display_surface.dart';
import 'package:sound_box/features/home/widgets/home_controls.dart';
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
  });

  final ValueListenable<DateTime> nowListenable;
  final VoidCallback onPrimaryAction;
  final List<WhiteNoiseSound> featuredSounds;
  final List<PinnedVariantEntry> pinnedEntries;

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
              HomePrimaryActions(onSoundTap: onPrimaryAction),
              const SizedBox(height: 12),
              Expanded(
                flex: 3,
                child: QuickSoundGrid(
                  sounds: featuredSounds,
                  pinnedEntries: pinnedEntries,
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
  });

  final ValueListenable<DateTime> nowListenable;
  final VoidCallback onPrimaryAction;
  final List<WhiteNoiseSound> featuredSounds;
  final List<PinnedVariantEntry> pinnedEntries;

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
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 右侧胶囊按钮容器。
class HomeSidePill extends StatelessWidget {
  const HomeSidePill({super.key, this.child, this.height = 110, this.onTap});

  final Widget? child;
  final double height;
  final VoidCallback? onTap;
  static const double _width = 70;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          width: _width,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF1B1F2C).withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.45),
              width: 2,
            ),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
