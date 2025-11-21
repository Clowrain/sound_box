import 'package:flutter/material.dart';
import 'package:sound_box/domain/sounds/white_noise_sound.dart';
import 'package:sound_box/shared/utils/pinned_variant_resolver.dart';

/// 首页主要操作区，包括入口按钮和快捷音效网格。
class HomePrimaryActions extends StatelessWidget {
  const HomePrimaryActions({
    super.key,
    required this.onSoundTap,
    this.onSettingsTap,
  });

  /// “音效” 按钮点击回调。
  final VoidCallback onSoundTap;

  /// “设置” 按钮回调，未指定时与音效入口保持一致。
  final VoidCallback? onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: HomeSquareButton(
            label: '音效',
            icon: Icons.graphic_eq,
            onTap: onSoundTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: HomeSquareButton(
            label: '设置',
            icon: Icons.settings_outlined,
            onTap: onSettingsTap ?? onSoundTap,
          ),
        ),
      ],
    );
  }
}

class QuickSoundGrid extends StatelessWidget {
  const QuickSoundGrid({
    super.key,
    required this.sounds,
    this.crossAxisCount = 3,
    this.pinnedEntries = const [],
  });

  final List<WhiteNoiseSound> sounds;
  final int crossAxisCount;
  final List<PinnedVariantEntry> pinnedEntries;

  @override
  Widget build(BuildContext context) {
    final items = _gridItems();

    return LayoutBuilder(
      builder: (context, constraints) {
        const targetSize = 72.0;
        const gap = 12.0;
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 320.0;
        final computedCrossAxisCount = (availableWidth / (targetSize + gap))
            .floor()
            .clamp(crossAxisCount, 6);

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
            return HomeSquareButton(
              icon: item.icon,
              label: item.label,
              onTap: () {},
            );
          },
        );
      },
    );
  }

  List<_GridItem> _gridItems() {
    if (pinnedEntries.isNotEmpty) {
      return pinnedEntries
          .map(
            (entry) => _GridItem(
              icon: entry.sound.icon,
              label: entry.variant.name.isNotEmpty
                  ? entry.variant.name
                  : entry.sound.name,
            ),
          )
          .toList();
    }
    return sounds
        .map((sound) => _GridItem(icon: sound.icon, label: sound.name))
        .toList();
  }
}

class _GridItem {
  const _GridItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class HomeSquareButton extends StatelessWidget {
  const HomeSquareButton({super.key, this.icon, this.label, this.onTap});

  final IconData? icon;
  final String? label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isIconOnly = (label == null) || label!.isEmpty;
    final Color iconColor = isIconOnly ? Colors.black : Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2E3548), Color(0xFF171C28)],
            ),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.55),
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                offset: Offset(0, 10),
                blurRadius: 18,
                spreadRadius: -2,
              ),
              BoxShadow(
                color: Color(0x3329394D),
                offset: Offset(-2, -2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF232838), Color(0xFF171C28)],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
            ),
            child: Center(
              child: isIconOnly
                  ? Icon(icon, color: iconColor, size: 24)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: iconColor, size: 22),
                        const SizedBox(height: 6),
                        Text(
                          label!,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
