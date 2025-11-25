import 'package:flutter/material.dart';
import 'package:sound_box/shared/utils/pinned_variant_resolver.dart';

/// 顶部固定音色条，桌面/移动通用，支持空态提示。
class PinnedSoundStrip extends StatelessWidget {
  const PinnedSoundStrip({super.key, required this.variants, required this.onUnpin});

  final List<PinnedVariantEntry> variants;
  final ValueChanged<PinnedVariantEntry> onUnpin;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: variants.isEmpty
          ? const _PinnedHint()
          : _PinnedList(
              key: const ValueKey('pinned_list'),
              variants: variants,
              onUnpin: onUnpin,
            ),
    );
  }
}

class _PinnedHint extends StatelessWidget {
  const _PinnedHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Text(
        '点击音效右侧的图钉，可将常用音色固定在这里',
        maxLines: 1,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white.withValues(alpha: 0.65),
        ),
      ),
    );
  }
}

class _PinnedList extends StatelessWidget {
  const _PinnedList({super.key, required this.variants, required this.onUnpin});

  final List<PinnedVariantEntry> variants;
  final ValueChanged<PinnedVariantEntry> onUnpin;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: variants.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final entry = variants[index];
          final sound = entry.sound;
          final label = entry.variant.name.isNotEmpty
              ? entry.variant.name
              : sound.name;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Icon(sound.icon, color: Colors.white, size: 16),
                  ),
                  Positioned(
                    right: -4,
                    top: -4,
                    child: GestureDetector(
                      onTap: () => onUnpin(entry),
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              SizedBox(
                width: 48,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
