import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sound_box/models/white_noise_sound.dart';
import 'package:sound_box/state/sound_selection_state.dart';

import 'widgets/sound_card.dart';

class SoundsPage extends StatefulWidget {
  const SoundsPage({super.key});

  @override
  State<SoundsPage> createState() => _SoundsPageState();
}

class _SoundsPageState extends State<SoundsPage> {
  final Map<String, WhiteNoiseSoundState> _soundStates = {};
  final Set<String> _pinnedVariantIds = <String>{};
  String? _activeCategory;

  String _variantKey(WhiteNoiseSound sound, int variantIndex) =>
      '${sound.id}::$variantIndex';

  WhiteNoiseSoundState _stateForVariant(
    WhiteNoiseSound sound,
    int variantIndex,
  ) {
    final key = _variantKey(sound, variantIndex);
    return _soundStates[key] ??
        const WhiteNoiseSoundState(volume: 0.6, isPlaying: false);
  }

  void _toggleVariant(WhiteNoiseSound sound, int variantIndex) {
    if (sound.locked) return;
    final key = _variantKey(sound, variantIndex);
    final current = _stateForVariant(sound, variantIndex);
    setState(() {
      _soundStates[key] = current.copyWith(isPlaying: !current.isPlaying);
    });
  }

  void _changeVariantVolume(
    WhiteNoiseSound sound,
    int variantIndex,
    double value,
  ) {
    if (sound.locked) return;
    final key = _variantKey(sound, variantIndex);
    final current = _stateForVariant(sound, variantIndex);
    setState(() {
      _soundStates[key] = current.copyWith(volume: value.clamp(0, 1));
    });
  }

  void _toggleVariantPin(WhiteNoiseSound sound, int variantIndex) {
    final key = _variantKey(sound, variantIndex);
    setState(() {
      if (_pinnedVariantIds.contains(key)) {
        _pinnedVariantIds.remove(key);
      } else {
        _pinnedVariantIds.add(key);
      }
    });
  }

  bool _isVariantPinned(WhiteNoiseSound sound, int variantIndex) =>
      _pinnedVariantIds.contains(_variantKey(sound, variantIndex));

  void _setCategory(String? category) {
    setState(() {
      if (_activeCategory == category) {
        _activeCategory = null;
      } else {
        _activeCategory = category;
      }
    });
  }

  List<WhiteNoiseSound> _applyCategoryFilter(List<WhiteNoiseSound> sounds) {
    if (_activeCategory == null) return List.of(sounds);
    return sounds
        .where((sound) => sound.category == _activeCategory)
        .toList(growable: false);
  }

  List<_CategoryOption> _categoryOptionsFor(List<WhiteNoiseSound> sounds) {
    final seen = <String>{};
    final options = <_CategoryOption>[];
    for (final sound in sounds) {
      if (seen.add(sound.category)) {
        options.add(
          _CategoryOption(value: sound.category, label: sound.categoryLabel),
        );
      }
    }
    return options;
  }

  List<_SoundVariantEntry> _variantEntries(WhiteNoiseSound sound) {
    final variants = sound.variants.isNotEmpty
        ? sound.variants
        : [WhiteNoiseSoundVariant(name: sound.name, path: '')];
    return List.generate(
      variants.length,
      (index) => _SoundVariantEntry(
        sound: sound,
        variant: variants[index],
        variantIndex: index,
      ),
    );
  }

  List<_SoundVariantEntry> _resolvePinnedVariants(
    List<WhiteNoiseSound> sounds,
  ) {
    final result = <_SoundVariantEntry>[];
    for (final sound in sounds) {
      for (final entry in _variantEntries(sound)) {
        if (_isVariantPinned(sound, entry.variantIndex)) {
          result.add(entry);
        }
      }
    }
    return result;
  }

  void _handlePinnedVariantTap(_SoundVariantEntry entry) {
    _toggleVariantPin(entry.sound, entry.variantIndex);
  }

  @override
  Widget build(BuildContext context) {
    final selection = context.watch<SoundSelectionState>();
    final orderedSounds = selection.sounds;
    final categoryOptions = _categoryOptionsFor(orderedSounds);
    final filteredSounds = _applyCategoryFilter(orderedSounds);
    final pinnedVariants = _resolvePinnedVariants(orderedSounds);
    final showFilterEmptyState = filteredSounds.isEmpty;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF171722), Color(0xFF0A0A11)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Spacer(),
                          _GhostButton(
                            icon: Icons.close,
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _PinnedSoundStrip(
                        variants: pinnedVariants,
                        onUnpin: _handlePinnedVariantTap,
                      ),
                      if (categoryOptions.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _CategoryFilterBar(
                          options: categoryOptions,
                          activeCategory: _activeCategory,
                          onChanged: _setCategory,
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: filteredSounds.isEmpty
                    ? const SliverToBoxAdapter(child: _EmptyFilterState())
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final sound = filteredSounds[index];
                          return _buildSoundTile(sound: sound);
                        }, childCount: filteredSounds.length),
                      ),
              ),
              if (showFilterEmptyState)
                const SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(child: _EmptyFilterState()),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoundTile({required WhiteNoiseSound sound}) {
    final variants = _variantEntries(sound);
    return Padding(
      key: ValueKey('tile_${sound.id}'),
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(sound.name, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Column(
            children: variants.map((entry) {
              final state = _stateForVariant(entry.sound, entry.variantIndex);
              final pinned = _isVariantPinned(entry.sound, entry.variantIndex);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SoundCard(
                  sound: entry.sound,
                  variant: entry.variant,
                  volume: state.volume,
                  isPlaying: state.isPlaying,
                  onToggle: () =>
                      _toggleVariant(entry.sound, entry.variantIndex),
                  onVolumeChanged: (value) => _changeVariantVolume(
                    entry.sound,
                    entry.variantIndex,
                    value,
                  ),
                  isPinned: pinned,
                  onTogglePin: () =>
                      _toggleVariantPin(entry.sound, entry.variantIndex),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _PinnedSoundStrip extends StatelessWidget {
  const _PinnedSoundStrip({required this.variants, required this.onUnpin});

  final List<_SoundVariantEntry> variants;
  final ValueChanged<_SoundVariantEntry> onUnpin;

  @override
  Widget build(BuildContext context) {
    if (variants.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            const Icon(Icons.push_pin_outlined, color: Colors.white70),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '点击音效右侧的图钉，可将常用音效固定在这里',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: variants.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
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
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Icon(
                      entry.sound.icon,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  Positioned(
                    right: -6,
                    top: -6,
                    child: GestureDetector(
                      onTap: () => onUnpin(entry),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 68,
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

class _SoundVariantEntry {
  const _SoundVariantEntry({
    required this.sound,
    required this.variant,
    required this.variantIndex,
  });

  final WhiteNoiseSound sound;
  final WhiteNoiseSoundVariant variant;
  final int variantIndex;
}

class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar({
    required this.options,
    required this.activeCategory,
    required this.onChanged,
  });

  final List<_CategoryOption> options;
  final String? activeCategory;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length + 1,
        padding: EdgeInsets.zero,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _CategoryChip(
              label: '全部',
              selected: activeCategory == null,
              onTap: () => onChanged(null),
            );
          }
          final option = options[index - 1];
          return _CategoryChip(
            label: option.label,
            selected: activeCategory == option.value,
            onTap: () => onChanged(option.value),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.06);
    final border = Colors.white.withValues(alpha: selected ? 0.2 : 0.08);
    final textColor = Colors.white.withValues(alpha: selected ? 0.95 : 0.7);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border),
        ),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: textColor),
        ),
      ),
    );
  }
}

class _CategoryOption {
  const _CategoryOption({required this.value, required this.label});

  final String value;
  final String label;
}

class _EmptyFilterState extends StatelessWidget {
  const _EmptyFilterState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        children: [
          Icon(Icons.filter_alt_off, color: Colors.white54, size: 48),
          const SizedBox(height: 12),
          Text(
            '暂无该场景的声音',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '试试其他分类或清空筛选',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
